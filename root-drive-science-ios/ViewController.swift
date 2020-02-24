//
//  ViewController.swift
//  root-drive-science-ios
//
//  Created by Hammer on 9/9/19.
//  Copyright © 2019 Root. All rights reserved.
//

import UIKit
import RootTripTracker

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var trackingLabel: UILabel!
    @IBOutlet var notificationField: UITextView!

    @IBOutlet weak var driverIdTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var environmentData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackingLabel.text = "Waiting to start..."
        notificationField.text = ""

        observe(.didTrackAnalyticsEvent, selector: #selector(onDidTrackAnalyticsEvent(_:)))
        observe(.didFailWithError, selector: #selector(onDidFailWithError(_:)))
        observe(.didStartTrip, selector: #selector(onDidStartTrip(_:)))
        observe(.didEndTrip, selector: #selector(onDidEndTrip(_:)))

        observe(.didReceiveDriverId, selector: #selector(didReceiveDriverId(_:)))
        observe(.didNotReceiveDriverId, selector: #selector(didNotReceiveDriverId(_:)))

        observe(.activationDidSucceed, selector: #selector(activationDidSucceed(_:)))
        observe(.activationDidFail, selector: #selector(activationDidFail(_:)))
    }
    
    func appendNotificationText(_ text: String) {
        DispatchQueue.main.async {
            self.notificationField.text = "[\(self.timestamp())]:" + text + "\n" + (self.notificationField.text ?? "")
        }
    }
    
    func setTrackingText(_ text: String) {
        DispatchQueue.main.async {
            self.trackingLabel.text = text
        }
    }

    @IBAction func createDriver(_ sender: UIButton) {
        TelematicsManager.sharedManager.createDriver(
            driverId: driverIdTextField.text,
            email: emailTextField.text,
            phone: emailTextField.text
        )
    }
    
    @IBAction func startTracking(_ sender: UIButton) {
        setTrackingText("Waiting...")
        TelematicsManager.sharedManager.start()
    }
    
    @IBAction func stopTracking(_ sender: UIButton) {
        TelematicsManager.sharedManager.stopTracker()
        setTrackingText("Tracking Stopped")
        self.appendNotificationText("Tracking Stopped")
    }
    
    @IBAction func resetTokens() {
        setTrackingText("Resetting...")
        TelematicsManager.sharedManager.removeAllTokens()
    }
    
    @objc func didReceiveDriverId(_ notification: Notification) {
        let driverId = notification.userInfo?["driver_id"] as! String
        self.appendNotificationText("Created driver: \(driverId)")
    }

    @objc func didNotReceiveDriverId(_ notification: Notification) {
        let message = notification.userInfo?["message"] ?? ""
        self.appendNotificationText("Unable to create driver: \(message)")
    }

    @objc func activationDidSucceed(_ notification: Notification) {
        self.appendNotificationText("Activated successfully.")
    }

    @objc func activationDidFail(_ notification: Notification) {
        let message = notification.userInfo?["message"] ?? ""
        self.appendNotificationText("Unable to activate: \(message)")
    }
    
    @objc func onDidTrackAnalyticsEvent(_ notification: Notification) {
        let eventName = notification.userInfo!["eventName"] as! String
        self.appendNotificationText(eventName)
    }
    
    @objc func onDidFailWithError(_ notification: Notification) {
        self.appendNotificationText("Error")
    }
    
    @objc func onDidStartTrip(_ notification: Notification) {
        let tripId = notification.userInfo!["tripId"] as! String
        self.appendNotificationText("Trip started with id \(tripId)")
    }
    
    @objc func onDidEndTrip(_ notification: Notification) {
        let tripId = notification.userInfo!["tripId"] as! String
        self.appendNotificationText("Trip ended with id \(tripId)")
    }
    
    func timestamp() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: now)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return environmentData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return environmentData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selection = environmentData[row]
        let environment: EnvironmentType = (selection == "Local") ? .local : .staging
        TelematicsManager.sharedManager.environment = environment
    }

    func observe(_ name: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(
        self,
        selector: selector,
        name: name, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

