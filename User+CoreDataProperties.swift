//
//  User+CoreDataProperties.swift
//  
//
//  Created by Noel Rappin on 10/2/19.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var token: String?
    @NSManaged public var userName: String?
    @NSManaged public var environment: String?

}
