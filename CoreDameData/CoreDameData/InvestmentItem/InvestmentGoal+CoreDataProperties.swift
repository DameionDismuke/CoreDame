//
//  InvestmentGoal+CoreDataProperties.swift
//  CoreDameData
//
//  Created by Consultant on 1/3/23.
//
//

import Foundation
import CoreData


extension InvestmentGoal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvestmentGoal> {
        return NSFetchRequest<InvestmentGoal>(entityName: "InvestmentGoal")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var unit: String?
    @NSManaged public var value: Float

}

extension InvestmentGoal : Identifiable {

}
