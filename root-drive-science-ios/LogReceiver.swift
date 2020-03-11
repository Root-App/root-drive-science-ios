import Foundation
import RootTripTracker
import UIKit

class LogReceiver: LogDelegate {
    enum LogLevel: String {
        case Debug = "debug"
        case Info = "info"
        case Warning = "warning"
        case Error = "error"
    }

    public var level: LogLevel
    public var view: ViewController
    var mostRecentMessage: String

    public static func fromString(_ levelString: String) -> LogLevel {
        LogLevel(rawValue: levelString) ?? LogLevel.Warning
    }

    public init(viewController: ViewController, level: LogLevel = LogLevel.Warning) {
        self.level = level
        view = viewController
        mostRecentMessage = ""
        Log.addLogDelegate(self)
    }

    func sendLog(_ message: String, color: UIColor = UIColor.black) {
        if message != mostRecentMessage {
            view.appendNotificationText(message, color: color)
            mostRecentMessage = message
        }
    }

    func debugLogged(_ message: String) {
        if level == .Debug {
            sendLog("Debug: " + message)
        }
    }

    func infoLogged(_ message: String) {
        if level == .Debug || level == .Info {
            sendLog("Info: " + message)
        }
    }

    func warningLogged(_ message: String) {
        if level == .Debug || level == .Info || level == .Warning {
            sendLog("Warning: " + message)
        }
    }

    func errorLogged(_ message: String) {
        sendLog("Error: " + message, color: UIColor.systemRed)
    }
}
