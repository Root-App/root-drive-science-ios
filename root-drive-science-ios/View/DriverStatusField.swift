//
//  DriverStatusField.swift
//  root-drive-science-ios
//
//  Created by Austin Emmons on 4/7/20.
//  Copyright © 2020 Root. All rights reserved.
//

import UIKit

class DriverStatusField: UIView {
    @IBOutlet var label: UILabel!
    @IBOutlet var driverId: UILabel!

    var registeredDriverId: String? {
        didSet {
            if let identifier = registeredDriverId {
                driverId.text = identifier
                label.text = "Driver registered:"
            } else {
                driverId.text = ""
                label.text = "No Driver Registered"
            }
        }
    }

    func displayErrorMessage() {
        label.text = "Driver registration failed"
        driverId.text = nil
    }
}
