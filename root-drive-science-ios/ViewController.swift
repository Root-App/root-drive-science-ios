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
    @IBOutlet var notificationField: UILabel!
    
    var environmentData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackingLabel.text = "Waiting to start..."
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidReceiveToken(_:)),
            name: .didReceiveToken, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidNotReceiveToken(_:)),
            name: .didNotReceiveToken, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidTrackAnalyticsEvent(_:)),
            name: .didTrackAnalyticsEvent, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidFailWithError(_:)),
            name: .didFailWithError, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidStartTrip(_:)),
            name: .didStartTrip, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidEndTrip(_:)),
            name: .didEndTrip,
            object: nil)
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
    
    @IBAction func requestToken(_ sender: UIButton) {
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
    
    @objc func onDidReceiveToken(_ notification: Notification) {
        let token = notification.userInfo!["token"] as! String
        setTrackingText("Tracking Started")
        self.appendNotificationText("Now tracking token \(token)")
    }
    
    @objc func onDidNotReceiveToken(_ notification: Notification) {
        setTrackingText("Error")
        self.appendNotificationText("Error retreiving token")
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

