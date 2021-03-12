//
//  TelematicsManager.swift
//  root-drive-science-ios
//
//  Created by Noel Rappin on 9/26/19.
//  Copyright © 2019 Root. All rights reserved.
//

import CoreData
import Foundation
import RootTripTracker

class TelematicsManager {
    public private(set) var driveScienceManager: TripTrackerDriveScienceManager
    public var isTracking: Bool

    static var clientId: String = {
        Bundle.main.object(forInfoDictionaryKey: "RootClientId") as! String
    }()

    init(delegate: TripTrackerDriveScienceManagerDelegate,
         clientDelegate: TripTrackerClientDelegate,
         tripTrackerDelegate: TripTrackerDelegate) {
        TripTracker.debugLoggingEnabled = true

        driveScienceManager = TripTrackerDriveScienceManager(
            clientId: TelematicsManager.clientId,
            environment: .staging,
            delegate: delegate,
            clientDelegate: clientDelegate
        )
        driveScienceManager.tripTracker.delegate = tripTrackerDelegate
        isTracking = driveScienceManager.configuredToAutoActivate
    }

    private let activeDriverIdKey = "ActiveDriverId"
    var activeDriverId: String? {
        get {
            return UserDefaults.standard.string(forKey: activeDriverIdKey)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: activeDriverIdKey)
        }
    }

    var hasActiveDriver: Bool { return activeDriverId != nil }

    func createDriver(driverId: String?, email: String?, phone: String?) {
        driveScienceManager.createDriver(
            driverId: driverId,
            email: email,
            phone: phone
        )
    }

    func cancelDriver() {
        activeDriverId = nil
        driveScienceManager.clearActiveDriver()
    }

    public func start() -> Bool {
        guard hasActiveDriver else { return false }
        guard !isTracking else { return false }

        driveScienceManager.activate(driverId: activeDriverId!)
        isTracking = true

        return isTracking
    }

    public func stop() {
        if isTracking {
            driveScienceManager.deactivate()
            isTracking = false
        }
    }

    public func configuredToAutoActivate() -> Bool {
        return driveScienceManager.configuredToAutoActivate
    }

    public func setAutoActivate(_ status: Bool) {
        driveScienceManager.storedSuppressAutoActivate = !status
    }
}
