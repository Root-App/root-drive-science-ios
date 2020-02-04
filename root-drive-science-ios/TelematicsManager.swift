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
    private var driveScienceManager: TripTrackerDriveScienceManager!
    public var environment: EnvironmentType
    public var isTracking: Bool

    lazy var clientId: String = {
        return Bundle.main.object(forInfoDictionaryKey: "RootClientId") as! String
    }()

    init() {
        environment = .staging
        isTracking = false

        self.driveScienceManager = TripTrackerDriveScienceManager(
            clientId: clientId,
            environment: environment,
            delegate: self,
            clientDelegate: self
        )
    }

    private let activeDriverIdKey = "ActiveDriverId"
    var activeDriverId: String? {
        get {
            return UserDefaults.standard.string(forKey: activeDriverIdKey)
        }
        set(newValue) {
            return UserDefaults.standard.set(newValue, forKey: activeDriverIdKey)
        }
    }

    var hasActiveDriver : Bool { return activeDriverId != nil }
    
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

    func createDriver(driverId: String?, email: String?, phone: String?) {
        self.driveScienceManager.createDriver(
            driverId: driverId,
            email: email,
            phone: phone
        )
    }
    
    func start() {
        if hasActiveDriver {
            driveScienceManager.tripTracker.delegate = self
            startTracker(driverId: activeDriverId!)
        } else {
            activationDidFail(driveScienceManager, errorMessage: "No active driver.")
        }
    }
    
    public func startTracker(driverId: String) {
        guard let driveScienceManager = self.driveScienceManager else { return }
        if (!isTracking) {
            driveScienceManager.activate(driverId: driverId)
            isTracking = true
        }
    }
    
    public func stopTracker() {
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
