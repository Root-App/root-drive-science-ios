//
//  ViewController.swift
//  root-drive-science-ios
//
//  Created by Hammer on 9/9/19.
//  Copyright © 2019 Root. All rights reserved.
//

import CoreLocation
import RootTripTracker
import UIKit

class ViewController: UIViewController {
    var telematicsManager: TelematicsManager!
    var logReceiver: LogReceiver!

    @IBOutlet var notificationField: UITextView!
    @IBOutlet var driverStatusField: UILabel!

    @IBOutlet var driverIdTextField: UITextField!

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
        logReceiver = LogReceiver(viewController: self, level: LogReceiver.LogLevel.Info)
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
        if telematicsManager.hasActiveDriver {
            driverStatusField.text = "Driver registered: \(telematicsManager.activeDriverId!)"
        } else {
            driverStatusField.text = "No Driver Registered"
        }
    }

    func displayDriverIdField() {
        driverIdTextField.isEnabled = !telematicsManager.hasActiveDriver
        driverIdTextField.text = ""
    }

    func displayDriverButton() {
        if telematicsManager.hasActiveDriver {
            createDriverButton.setTitle("Clear Registered Driver", for: .normal)
        } else {
            createDriverButton.setTitle("Register Driver", for: .normal)
        }
    }

    func displayActivationToggle() {
        tripTrackingSwitch.isEnabled = telematicsManager.hasActiveDriver
        setTrackingSwitch(telematicsManager.isTracking)
    }

    func displayReactivationToggle() {
        setActivationSwitch(!telematicsManager.driveScienceManager.storedSuppressAutoActivate)
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
            appendNotificationText(
                "Location services disabled at system level! Will be unable to track trips!",
                color: UIColor.systemRed
            )
        }
    }

    public func appendNotificationText(_ text: String, color: UIColor = UIColor.black) {
        DispatchQueue.main.async {
            let newAttributedText = NSMutableAttributedString(
                string: "[\(self.timestamp)]:" + text + "\n",
                attributes: [NSAttributedString.Key.foregroundColor: color,
                             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)]
            )
            let existingText: NSAttributedString = self.notificationField.attributedText ?? NSAttributedString(string: "")
            newAttributedText.append(existingText)
            self.notificationField.attributedText = newAttributedText
        }
    }

    @IBAction func driverButtonClicked(_ sender: UIButton) {
        if telematicsManager.hasActiveDriver {
            clearDriver()
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

    func clearDriver() {
        telematicsManager.cancelDriver()
        stopTracking()
        appendNotificationText("Driver canceled successfully")
        displayTelematicsManagerState()
    }

    func startTracking() {
        if telematicsManager.hasActiveDriver {
            _ = telematicsManager.start()
        } else {
            appendNotificationText("No active driver")
        }
    }

    func stopTracking() {
        telematicsManager.stop()
        appendNotificationText("Tracking Stopped")
    }

    @IBAction func trackingSwitchTouched(_ sender: UISwitch) {
        if sender.isOn {
            startTracking()
        } else {
            stopTracking()
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
        pasteBoard.string = notificationField.text
    }

    @objc func onDidTrackAnalyticsEvent(_ notification: Notification) {
        let eventName = notification.userInfo!["eventName"] as! String
        appendNotificationText(eventName)
    }

    @objc func onDidFailWithError(_ notification: Notification) {
        appendNotificationText("Error")
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
