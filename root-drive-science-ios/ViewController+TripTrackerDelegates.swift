//
//  ViewController+TripTrackerDelegates.swift
//  root-drive-science-ios
//
//  Created by Austin Emmons on 2/3/20.
//  Copyright © 2020 Root. All rights reserved.
//

import Foundation
import RootTripTracker

extension ViewController: TripTrackerClientDelegate {
    func didStartTrip(_ tripId: String) {
        addLogMessage("Trip started with id \(tripId)")
    }

    func didEndTrip(_ tripId: String) {
        addLogMessage("Trip ended with id \(tripId)")
    }
}

extension ViewController: TripTrackerDriveScienceManagerDelegate {
    func didReceiveDriverId(_ driverId: String) {
        // save our own reference to activeDriverId
        telematicsManager.activeDriverId = driverId
        driverCreated(driverId)
        addLogMessage("Created driver: \(driverId)")
    }

    func didNotReceiveDriverId(_ errorMessage: String) {
        telematicsManager.activeDriverId = nil
        DispatchQueue.main.async {
            self.driverStatusView.displayErrorMessage()
        }
        addLogMessage("Unable to create driver: \(errorMessage)")
    }

    func activationDidSucceed(_ manager: TripTrackerDriveScienceManager) {
        addLogMessage("Activated successfully.")
        setTrackingSwitch(true)
    }

    func activationDidFail(_ manager: TripTrackerDriveScienceManager, errorMessage: String) {
        addLogMessage("Unable to activate: \(errorMessage)")
    }
}

extension ViewController: TripTrackerDelegate {
    func tripTracker(
        _ tripTracker: TripTracker,
        didTrackAnalyticsEvent eventName: String,
        withProperties properties: [String: Any]
    ) {
        addLogMessage("\(eventName) - \(properties)")
    }

    func tripTracker(
        _ tripTracker: TripTracker,
        didFailWithError error: TripTrackerError
    ) {
        addLogMessage("Trip Tracker error.")
    }
}
