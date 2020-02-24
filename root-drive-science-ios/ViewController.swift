//
//  ViewController.swift
//  root-drive-science-ios
//
//  Created by Hammer on 9/9/19.
//  Copyright © 2019 Root. All rights reserved.
//

import UIKit
import RootTripTracker
import CoreLocation

class ViewController: UIViewController {

    var telematicsManager: TelematicsManager!
    
    @IBOutlet var trackingLabel: UILabel!
    @IBOutlet var notificationField: UITextView!

    @IBOutlet weak var driverIdTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var environmentData: [String] = [String]()

    lazy var clientId: String = {
        return Bundle.main.object(forInfoDictionaryKey: "RootClientId") as! String
    }()

    private lazy var dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    var timestamp: String {
        return dateFormat.string(from: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTelematics()
        checkLocationServicesEnabled()

        trackingLabel.text = "Waiting to start..."
        notificationField.text = ""
    }

    private func setupTelematics() {
        let driveScienceManager = TripTrackerDriveScienceManager(
            clientId: clientId,
            environment: .staging,
            delegate: self,
            clientDelegate: self
        )

        driveScienceManager.tripTracker.delegate = self
        telematicsManager = TelematicsManager(driveScienceManager: driveScienceManager)
    }

    private func checkLocationServicesEnabled() {
        if !CLLocationManager.locationServicesEnabled() {
            appendNotificationText("Location services disabled at system level! Will be unable to track trips!")
        }
    }

    // MARK: UI Helpers
    
    func appendNotificationText(_ text: String) {
        DispatchQueue.main.async {
            self.notificationField.text = "[\(self.timestamp)]:" + text + "\n" + (self.notificationField.text ?? "")
        }
    }
    
    func setTrackingText(_ text: String) {
        DispatchQueue.main.async {
            self.trackingLabel.text = text
        }
    }

    // MARK: UI Actions

    @IBAction func createDriver(_ sender: UIButton) {
        telematicsManager.createDriver(
            driverId: driverIdTextField.text,
            email: emailTextField.text,
            phone: emailTextField.text
        )
    }
    
    @IBAction func startTracking(_ sender: UIButton) {
        setTrackingText("Waiting...")
        if telematicsManager.hasActiveDriver {
            _ = telematicsManager.start()
        } else {
            self.appendNotificationText("No active driver.")
        }
    }
    
    @IBAction func stopTracking(_ sender: UIButton) {
        telematicsManager.stop()
        setTrackingText("Tracking Stopped")
        self.appendNotificationText("Tracking Stopped")
    }

    @objc func onDidTrackAnalyticsEvent(_ notification: Notification) {
        let eventName = notification.userInfo!["eventName"] as! String
        self.appendNotificationText(eventName)
    }
    
    @objc func onDidFailWithError(_ notification: Notification) {
        self.appendNotificationText("Error")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

