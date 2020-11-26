//
//  Meal+CoreDataProperties.swift
//  MyMealsCoreData
//
//  Created by Николаев Никита on 31.10.2020.
//  Copyright © 2020 Николаев Никита. All rights reserved.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var date: Date?
    @NSManaged public var user: User?

}
