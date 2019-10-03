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
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var notificationField: UILabel!
    @IBOutlet var environmentPicker: UIPickerView!
    
    var environmentData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        environmentPicker.delegate = self
        environmentPicker.dataSource = self
        environmentData = ["Local", "Staging"]
        
        trackingLabel.text = "Enter name..."
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
    }
    
    func userName() -> String {
        return userNameField.text ?? ""
    }
    
    @IBAction func requestToken(_ sender: UIButton) {
        dismissKeyboard()
        trackingLabel.text = "Waiting..."
        TelematicsManager.sharedManager.start(userName())
    }
    
    @IBAction func resetTokens() {
        trackingLabel.text = "Resetting..."
        TelematicsManager.sharedManager.removeAllTokens()
    }
    
    @IBAction func dismissKeyboard() {
        userNameField.resignFirstResponder()
    }
    
    @objc func onDidReceiveToken(_ notification: Notification) {
        let token = notification.userInfo!["token"] as! String
        DispatchQueue.main.async {
            self.trackingLabel.text = "Now tracking user \(self.userName()) \n with token \(token)"
        }
    }
    
    @objc func onDidNotReceiveToken(_ notification: Notification) {
        DispatchQueue.main.async {
            self.trackingLabel.text = "Error retreiving token"
        }
    }
    
    @objc func onDidTrackAnalyticsEvent(_ notification: Notification) {
        let eventName = notification.userInfo!["eventName"] as! String
        DispatchQueue.main.async {
            self.notificationField.textColor = UIColor.black
            self.notificationField.text = "\n[\(self.timestamp())]: \(eventName)" + (self.notificationField.text ?? "")
        }
    }
    
    @objc func onDidFailWithError(_ notification: Notification) {
        DispatchQueue.main.async {
            self.notificationField.textColor = UIColor.red
            self.notificationField.text = "\n[\(self.timestamp())]: Error" + (self.notificationField.text ?? "") 
        }
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

