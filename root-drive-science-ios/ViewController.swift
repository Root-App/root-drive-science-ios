//
//  ViewController.swift
//  root-drive-science-ios
//
//  Created by Hammer on 9/9/19.
//  Copyright © 2019 Root. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var trackingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        trackingLabel.text = "Waiting..."
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidReceiveToken(_:)),
            name: .didReceiveToken, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidNotReceiveToken(_:)),
            name: .didNotReceiveToken, object: nil)
    }
    
    @objc func onDidReceiveToken(_ notification:Notification) {
        let token = notification.userInfo!["token"] as! String
        DispatchQueue.main.async {
            self.trackingLabel.text = "Now tracking with token \(token)"
        }
    }
    
    @objc func onDidNotReceiveToken(_ notification:Notification) {
        DispatchQueue.main.async {
            self.trackingLabel.text = "Error retreiving token"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

