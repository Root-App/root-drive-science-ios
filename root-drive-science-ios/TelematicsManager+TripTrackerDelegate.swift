//
//  TelematicsManager+TripTrackerDelegate.swift
//  root-drive-science-ios
//
//  Created by Noel Rappin on 9/27/19.
//  Copyright © 2019 Root. All rights reserved.
//

import Foundation
import RootTripTracker
import CoreData

extension TelematicsManager: TripTrackerClientDelegate {
    func didStartTrip(_ tripId: String) {
        NotificationCenter.default.post(
            name: .didStartTrip,
            object: nil,
            userInfo: ["tripId": tripId])
    }

    func didEndTrip(_ tripId: String) {
        NotificationCenter.default.post(
            name: .didEndTrip,
            object: nil,
            userInfo: ["tripId": tripId])
    }
}

extension TelematicsManager: TripTrackerDriveScienceManagerDelegate {
    func didReceiveDriverId(_ driverId: String) {
        activeDriverId = driverId

        NotificationCenter.default.post(
            name: .didReceiveDriverId,
            object: nil,
            userInfo: [ "driver_id" : driverId ]
        )
    }

    func didNotReceiveDriverId(_ errorMessage: String) {
        activeDriverId = nil
        NotificationCenter.default.post(
            name: .didNotReceiveDriverId,
            object: nil,
            userInfo: ["message" : errorMessage]
        )
    }

    func activationDidSucceed(_ manager: TripTrackerDriveScienceManager) {
        NotificationCenter.default.post(name: .activationDidSucceed, object: nil)
    }

    func activationDidFail(_ manager: TripTrackerDriveScienceManager, errorMessage: String) {
        NotificationCenter.default.post(
            name: .activationDidFail,
            object: nil,
            userInfo: ["message" : errorMessage]
        )
    }
}
