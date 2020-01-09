//
//  ClientTelematicsTokenDelegate.swift
//  root-drive-science-ios
//
//  Created by Noel Rappin on 9/27/19.
//  Copyright © 2019 Root. All rights reserved.
//

import Foundation
import RootTripTracker
import CoreData

class ClientTelematicsTokenDelegate: TripTrackerDriveScienceManagerDelegate, TripTrackerClientDelegate {
    
    func didReceiveTelematicsToken(_ token: String) -> Void {
        TelematicsManager.sharedManager.startTracker()
        NotificationCenter.default.post(
            name: .didReceiveToken,
            object: nil,
            userInfo: ["token": token])
    }
    
    func didNotReceiveTelematicsToken(_ errorMessage: String) -> Void {
        NotificationCenter.default.post(
            name: .didNotReceiveToken,
            object: nil,
            userInfo: ["errorMessage": errorMessage])
    }
    
    func tripHasStarted(_ tripId: String) {
        NotificationCenter.default.post(
            name: .didStartTrip,
            object: nil,
            userInfo: ["tripId": tripId])
    }
    
    func tripHasEnded(_ tripId: String) {
        NotificationCenter.default.post(
            name: .didEndTrip,
            object: nil,
            userInfo: ["tripId": tripId])
    }

}
