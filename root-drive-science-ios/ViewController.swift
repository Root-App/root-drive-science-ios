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

    @IBOutlet weak var notificationField: UITextView!
    @IBOutlet weak var driverStatusField: UILabel!
    @IBOutlet weak var versionFooter: UILabel!

    @IBOutlet weak var driverIdTextField: UITextField!

    @IBOutlet weak var createDriverButton: UIButton!

    @IBOutlet weak var tripTrackingSwitch: UISwitch!
    @IBOutlet weak var reactivateSwitch: UISwitch!

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
        driverStatusField.isCopyEnabled = true
        versionFooter.isCopyEnabled = true
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
            appendNotificationText("Location services disabled at system level! Will be unable to track trips!")
        }
    }

    func appendNotificationText(_ text: String) {
        DispatchQueue.main.async {
            self.notificationField.text = "[\(self.timestamp)]:" + text + "\n" + (self.notificationField.text ?? "")
        }
    }

    @IBAction func driverButtonClicked(_ sender: UIButton) {
        if telematicsManager.hasActiveDriver {
            let alert = UIAlertController(title: "Deactivate your driver?", message: "This will unregister your driver.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Unregister", style: .destructive, handler: { _ in
                self.cancelDriver()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            present(alert, animated: true, completion: nil)
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
        appendNotificationText("Driver unregistered successfully")
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
