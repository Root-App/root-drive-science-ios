//
//  TelematicsManager.swift
//  root-drive-science-ios
//
//  Created by Noel Rappin on 9/26/19.
//  Copyright © 2019 Root. All rights reserved.
//

import Foundation
import RootTripTracker
import CoreData

class TelematicsManager {
    
    static let sharedManager = TelematicsManager()
    private var tracker: TripTracker!
    private var driveScienceManager: TripTrackerDriveScienceManager!
    public var environment: EnvironmentType
    public var isTracking: Bool
    
    init() {
        environment = .staging
        isTracking = false
    }
    
    let userStoreContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserStore")
        container.loadPersistentStores() { (description, error) in
            if let error = error {
                print("Error setting up Core Data: \(error)")
            }
        }
        return container
    }()
    
    public func tokenFor(_ username: String) -> String? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(
            format: "userName == %@ AND environment == %@", username, environmentString())
        fetchRequest.predicate = predicate
        let viewContext = userStoreContainer.viewContext
        do {
            let users = try viewContext.fetch(fetchRequest)
            if (users.count) > 0 {
                return users[0].token
            } else {
                return nil
            }
        } catch let error as NSError {
            print(error.description)
            return nil
        }
    }
    
    func start() -> Void {
        tracker = TripTracker(environment: environment) // TODO: Set the environment
        tracker.delegate = self
        let clientDelegate = ClientTelematicsTokenDelegate()
        self.driveScienceManager = TripTrackerDriveScienceManager(
            clientId: "t56482015d476dd7434f7da4b",
            tripTracker: tracker,
            delegate: clientDelegate,
            clientDelegate: clientDelegate)
        driveScienceManager.onboardWithoutToken()
    }
    
    public func startTracker() -> Void {
        guard let driveScienceManager = self.driveScienceManager else { return }
        if (!isTracking) {
            driveScienceManager.activate()
            isTracking = true
        }
    }
    
    public func stopTracker() -> Void {
        if (isTracking) {
            driveScienceManager.deactivate()
            isTracking = false
        }
    }
    
    public func removeAllTokens() {
        let viewContext = userStoreContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    public func environmentString() -> String {
        switch(environment) {
        case .local :
            return "Local"
        case .staging :
            return "Staging"
        default :
            return "Other"
        }
    }
}

extension TelematicsManager: TripTrackerDelegate {
    func tripTracker(
        _ tripTracker: TripTracker,
        didTrackAnalyticsEvent eventName: String,
        withProperties properties: [String: Any])
    {
        NotificationCenter.default.post(
            name: .didTrackAnalyticsEvent,
            object: nil,
            userInfo: ["eventName": eventName])
    }
    
    func tripTracker(
        _ tripTracker: TripTracker,
        didFailWithError error: TripTrackerError)
    {
        NotificationCenter.default.post(
            name: .didFailWithError,
            object: nil,
            userInfo: ["error": error])
    }
}
