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

class ClientTelmaticsTokenDelegate: TripTrackerOnboarderDelegate {
    
    var userName: String
    
    public init(userName: String) {
        self.userName = userName
    }
    
    func didReceiveTelematicsToken(_ token: String) -> Void {
        TelematicsManager.sharedManager.startTracker()
        TelematicsManager.sharedManager.saveUser(userName: self.userName, token: token)
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

}
