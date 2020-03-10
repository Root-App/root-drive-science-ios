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
    
    @IBOutlet var notificationField: UITextView!
    @IBOutlet var driverStatusField: UILabel!

    @IBOutlet weak var driverIdTextField: UITextField!
    
    @IBOutlet var createDriverButton: UIButton!
    
    @IBOutlet var tripTrackingSwitch: UISwitch!
    @IBOutlet var reactivateSwitch: UISwitch!
    
    var environmentData: [String] = [String]()

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
        notificationField.text = ""
    }
    
    func displayTelematicsManagerState() {
        DispatchQueue.main.async {
            self.displayDriverRegistrationLabel()
            self.displayDriverIdField()
            self.displayDriverButton()
            self.displayActivationToggle()
            self.displayReactivationToggle()
        }
    }
    
    func displayDriverRegistrationLabel() {
        if (telematicsManager.hasActiveDriver) {
            self.driverStatusField.text = "Driver registered: \(telematicsManager.activeDriverId!)"
        } else {
            self.driverStatusField.text = "No Driver Registered"
        }
    }
    
    func displayDriverIdField() {
        driverIdTextField.isEnabled = !telematicsManager.hasActiveDriver
        driverIdTextField.text = ""
    }
    
    func displayDriverButton() {
        if (telematicsManager.hasActiveDriver) {
            self.createDriverButton.setTitle("Clear Registered Driver", for: .normal)
        } else {
            self.createDriverButton.setTitle("Register Driver", for: .normal)
        }
    }
    
    func displayActivationToggle() {
        self.tripTrackingSwitch.isEnabled = telematicsManager.hasActiveDriver
        self.setTrackingSwitch(telematicsManager.isTracking)
    }
    
    func displayReactivationToggle() {
        self.setActivationSwitch(!telematicsManager.driveScienceManager.storedSuppressAutoActivate)
    }

    private func setupTelematics() {
        telematicsManager = TelematicsManager(
            delegate: self,
            clientDelegate: self,
            tripTrackerDelegate: self
        )
        displayTelematicsManagerState()
    }

    private func checkLocationServicesEnabled() {
        if !CLLocationManager.locationServicesEnabled() {
            appendNotificationText("Location services disabled at system level! Will be unable to track trips!")
        }
    }
    
    func appendNotificationText(_ text: String) {
        DispatchQueue.main.async {
            self.notificationField.text = "[\(self.timestamp)]:" + text + "\n" + (self.notificationField.text ?? "")
        }
    }


    @IBAction func driverButtonClicked(_ sender: UIButton) {
        if (telematicsManager.hasActiveDriver) {
            cancelDriver()
        } else {
            telematicsManager.createDriver(
                driverId: driverIdTextField.text,
                email: "",
                phone: ""
            )
        }
    }
    
    func driverCreated(_ driverId: String) {
        displayTelematicsManagerState()
    }
    
    func cancelDriver() {
        telematicsManager.cancelDriver()
        stopTracking()
        self.appendNotificationText("Driver canceled successfully")
        displayTelematicsManagerState()
    }
    
    func startTracking() {
        if telematicsManager.hasActiveDriver {
            _ = telematicsManager.start()
        } else {
            self.appendNotificationText("No active driver")
        }
    }
    
    func stopTracking() {
        telematicsManager.stop()
        self.appendNotificationText("Tracking Stopped")
    }
    
    @IBAction func trackingSwitchTouched(_ sender: UISwitch) {
        if sender.isOn {
            self.startTracking()
        } else {
            self.stopTracking()
        }
    }
    
    @IBAction func reactivateSwitchTouched(_ sender: UISwitch) {
        telematicsManager.setAutoActivate(sender.isOn)
    }
    
    @IBAction func clearLog(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.notificationField.text = ""
        }
    }
    
   
    @IBAction func copyLog(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = self.notificationField.text
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
    
    func setTrackingSwitch(_ status: Bool) {
        DispatchQueue.main.async {
            self.tripTrackingSwitch.isOn = status
        }
    }
    
    func setActivationSwitch(_ status: Bool) {
        DispatchQueue.main.async {
            self.reactivateSwitch.isOn = status
        }
    }
    
}


