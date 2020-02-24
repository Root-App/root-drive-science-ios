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

    public private(set) var driveScienceManager: TripTrackerDriveScienceManager
    public var isTracking: Bool

    init(driveScienceManager: TripTrackerDriveScienceManager) {
        isTracking = false
        self.driveScienceManager = driveScienceManager
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

    func createDriver(driverId: String?, email: String?, phone: String?) {
        self.driveScienceManager.createDriver(
            driverId: driverId,
            email: email,
            phone: phone
        )
    }
    
    public func start() -> Bool {
        guard hasActiveDriver else { return false }
        guard !isTracking else { return false }

        driveScienceManager.activate(driverId: activeDriverId!)
        isTracking = true

        return isTracking
    }

    public func stop() {
        if (isTracking) {
            driveScienceManager.deactivate()
            isTracking = false
        }
    }

}
