//
//  ViewController+TripTrackerDelegates.swift
//  root-drive-science-ios
//
//  Created by Austin Emmons on 2/3/20.
//  Copyright © 2020 Root. All rights reserved.
//

import RootTripTracker

extension ViewController: TripTrackerClientDelegate {
    func didStartTrip(_ tripId: String) {
        appendNotificationText("Trip started with id \(tripId)")
    }

    func didEndTrip(_ tripId: String) {
        appendNotificationText("Trip ended with id \(tripId)")
    }
}

extension ViewController: TripTrackerDriveScienceManagerDelegate {
    func didReceiveDriverId(_ driverId: String) {
        // save our own reference to activeDriverId
        telematicsManager.activeDriverId = driverId
        driverCreated(driverId)
        appendNotificationText("Created driver: \(driverId)")
    }

    func didNotReceiveDriverId(_ errorMessage: String) {
        telematicsManager.activeDriverId = nil
        DispatchQueue.main.async {
            self.driverStatusField.text = "Driver registration failed"
        }
        appendNotificationText("Unable to create driver: \(errorMessage)")
    }

    func activationDidSucceed(_ manager: TripTrackerDriveScienceManager) {
        appendNotificationText("Activated successfully.")
        setTrackingSwitch(true)
    }

    func activationDidFail(_ manager: TripTrackerDriveScienceManager, errorMessage: String) {
        appendNotificationText("Unable to activate: \(errorMessage)")
    }
}

extension ViewController: TripTrackerDelegate {
    func tripTracker(
        _ tripTracker: TripTracker,
        didTrackAnalyticsEvent eventName: String,
        withProperties properties: [String: Any]
    ) {
        appendNotificationText(eventName)
    }

    func tripTracker(
        _ tripTracker: TripTracker,
        didFailWithError error: TripTrackerError
    ) {
        appendNotificationText("Trip Tracker error.")
    }
}
