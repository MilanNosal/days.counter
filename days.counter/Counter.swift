//
//  Counter.swift
//  days.counter
//
//  Created by Milan Nosáľ on 01/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation
import CoreData

enum StateType: String, CustomStringConvertible {
    case running = "Running"
    case stopped = "Stopped"
    
    var description: String {
        return rawValue
    }
}

public class Counter: ManagedObject {
    
    @NSManaged fileprivate(set) var title: String
    
    @NSManaged fileprivate(set) var lastEditDate: Date
    
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
            NSSortDescriptor(key: "state", ascending: true),
            NSSortDescriptor(key: "lastEditDate", ascending: false),
            NSSortDescriptor(key: "start", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
    }
    
    static func last3RunnningCounters(dataContext: NSManagedObjectContext) -> [Counter] {
        
        let countersRequest = NSFetchRequest<Counter>(entityName: entityName)
        
        countersRequest.sortDescriptors = [NSSortDescriptor(key: "lastEditDate", ascending: false)]
        
        let predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "state"), rightExpression: NSExpression(forConstantValue: StateType.running.rawValue), modifier: .direct, type: .equalTo, options: .normalized)
        
        countersRequest.predicate = predicate
        
        countersRequest.returnsObjectsAsFaults = false
        
        countersRequest.fetchLimit = 2
        
        let counters = try! dataContext.fetch(countersRequest)
        return counters.reversed()
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
        newCounter.lastEditDate = Date()
        
        return newCounter
    }
}
