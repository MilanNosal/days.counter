//
//  Counter.swift
//  days.counter
//
//  Created by Milan Nosáľ on 01/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation
import CoreData

enum StateType: String {
    case running = "Running"
    case stopped = "Stopped"
}

public class Counter: ManagedObject {
    
    @NSManaged fileprivate(set) var title: String
    
    @NSManaged fileprivate(set) var start: Date
    
    @NSManaged private(set) var end: Date?
    
    /* @NSManaged */ var state: StateType {
        get {
            return getFromRawValue(forKey: "state")!
        }
        set {
            if newValue == .stopped {
                end = Date()
            }
            setRawValue(newValue, forKey: "state")
        }
    }
    
}

extension Counter: ManagedObjectType {
    static var entityName: String {
        return "Counter"
    }
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [
            NSSortDescriptor(key: "state", ascending: false),
            NSSortDescriptor(key: "start", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]
    }
    
    static func lastCounter(dataContext: NSManagedObjectContext) -> Counter? {
        
        let countersRequest = NSFetchRequest<Counter>(entityName: entityName)
        let predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "end"), rightExpression: NSExpression(forConstantValue: nil), modifier: .direct, type: .equalTo, options: .normalized)
        countersRequest.predicate = predicate
        let counters = try! dataContext.fetch(countersRequest)
        return counters.first
    }
    
    static func allCounters(dataContext: NSManagedObjectContext) -> [Counter] {
        
        let countersRequest: NSFetchRequest<Counter> = Counter.sortedFetchRequest()
        return try! dataContext.fetch(countersRequest)
    }
    
    static func createCounter(_ title: String?, startingFrom: Date = Date(), throughContext context: NSManagedObjectContext) -> Counter {
        let newCounter: Counter = context.createObject()
        
        newCounter.start = startingFrom
        newCounter.title = title ?? "Unnamed counter \(newCounter.id.int64Value)"
        newCounter.state = .running
        
        return newCounter
    }
}
