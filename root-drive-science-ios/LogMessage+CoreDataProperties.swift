//
//  LogMessage+CoreDataProperties.swift
//  root-drive-science-ios
//
//  Created by Jesse Cooper on 9/24/20.
//  Copyright © 2020 Root. All rights reserved.
//
//

import Foundation
import CoreData


extension LogMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogMessage> {
        return NSFetchRequest<LogMessage>(entityName: "LogMessage")
    }

    @NSManaged public var date: Date?
    @NSManaged public var message: String?

}
