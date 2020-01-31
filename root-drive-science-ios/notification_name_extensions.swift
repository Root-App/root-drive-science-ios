//
//  notification_name_extensions.swift
//  root-drive-science-ios
//
//  Created by Noel Rappin on 9/23/19.
//  Copyright © 2019 Root. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didReceiveDriverId = Notification.Name("didReceiveDriverId")
    static let didNotReceiveDriverId = Notification.Name("didNotReceiveDriverId")
    static let activationDidSucceed = Notification.Name("activationDidSucceed")
    static let activationDidFail = Notification.Name("activationDidFail")

    static let didTrackAnalyticsEvent = Notification.Name("didTrackAnalyticsEvent")
    static let didFailWithError = Notification.Name("didFailWithError")
    static let didStartTrip = Notification.Name("didStartTrip")
    static let didEndTrip = Notification.Name("didEndTrip")
}
