//
//  ViewController.swift
//  root-drive-science-ios
//
//  Created by Hammer on 9/9/19.
//  Copyright © 2019 Root. All rights reserved.
//

import CoreData
import CoreLocation
import RootTripTracker
import UIKit

class ViewController: UIViewController {
    var telematicsManager: TelematicsManager!

    @IBOutlet var notificationField: UITextView!
    @IBOutlet var versionFooter: UILabel!
    @IBOutlet var driverStatusView: DriverStatusField!

    @IBOutlet var activationToggleRow: UIStackView!
    @IBOutlet var driverIdTextField: UITextField!

    @IBOutlet var createDriverButton: UIButton!

    @IBOutlet var tripTrackingSwitch: UISwitch!
    @IBOutlet var reactivateSwitch: UISwitch!

    var environmentData: [String] = [String]()

    var container: NSPersistentContainer!
    var logMessages: [LogMessage] = []

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
        container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }

        navigationController?.navigationBar.barTintColor = UIColor(red: 1.0, green: 87 / 255, blue: 21 / 255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        setupTelematics()
        checkLocationServicesEnabled()
        notificationField.text = ""
        driverStatusView.driverId.isCopyEnabled = true
        versionFooter.isCopyEnabled = true

        let managedContext = container.viewContext

        let fetchRequest: NSFetchRequest<LogMessage> = LogMessage.fetchRequest()

        do {
            logMessages = try managedContext.fetch(fetchRequest)
            for logMessage in logMessages {
                displayLogMessage(logMessage)
            }

        } catch let error as NSError {
            print("Could not fetch log messages. \(error), \(error.userInfo)")
        }
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
        driverStatusView.registeredDriverId = telematicsManager.activeDriverId
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
        UIView.animate(withDuration: 0.2) {
            self.activationToggleRow.alpha = self.telematicsManager.hasActiveDriver ? 1 : 0
        }
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
            addLogMessage("Location services disabled at system level! Will be unable to track trips!")
        }
    }

    func addLogMessage(_ text: String) {
        if let newMessage = saveLogMessage(text) {
            displayLogMessage(newMessage)
        }
    }

    private func saveLogMessage(_ text: String) -> LogMessage? {
        let managedContext = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "LogMessage", in: managedContext)!

        let logMessage = LogMessage(entity: entity, insertInto: managedContext)

        logMessage.message = text
        logMessage.date = Date()

        do {
            try managedContext.save()
            logMessages.append(logMessage)
            return logMessage
        } catch let error as NSError {
            print("Could not save log message. \(error), \(error.userInfo)")
        }

        return nil
    }

    private func displayLogMessage(_ logMessage: LogMessage) {
        DispatchQueue.main.async {
            if let message = logMessage.message, let date = logMessage.date {
                self.notificationField.text = self.notificationField.text.appending("[\(self.dateFormat.string(from: date))]:" + message + "\n")
            }
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
        addLogMessage("Driver unregistered successfully")
        displayTelematicsManagerState()
    }

    func startTracking() {
        if telematicsManager.hasActiveDriver {
            _ = telematicsManager.start()
        } else {
            addLogMessage("No active driver")
        }
    }

    func stopTracking() {
        telematicsManager.stop()
        addLogMessage("Tracking Stopped")
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

    @IBAction func checkPermissions(_ sender: UIButton) {
        let check = telematicsManager.driveScienceManager.tripTrackingPermissionCheck
        if check.allPermissionsAuthorized {
            addLogMessage("All permissions set correctly!")
        } else {
            addLogMessage("Correctly authorized permissions:")
            let authorized = check.authorizedPermissions
            for permission in authorized {
                addLogMessage(permission.rawValue)
            }

            addLogMessage("Incorrect permissions:")
            let unauthorized = check.unauthorizedPermissions
            for permission in unauthorized {
                addLogMessage(permission.rawValue)
            }
        }
    }

    @IBAction func clearLog(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.notificationField.text = ""

            do {
                let managedContext = self.container.viewContext

                for logMessage in self.logMessages {
                    managedContext.delete(logMessage)
                }
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete log messages. \(error), \(error.userInfo)")
            }
        }
    }

    @IBAction func copyLog(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = notificationField.text
    }

    @objc func onDidTrackAnalyticsEvent(_ notification: Notification) {
        let eventName = notification.userInfo!["eventName"] as! String
        addLogMessage(eventName)
    }

    @objc func onDidFailWithError(_ notification: Notification) {
        addLogMessage("Error")
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
