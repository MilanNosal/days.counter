//
//  DataStack.swift
//  days.counter
//
//  Created by Milan Nosáľ on 15/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation
import CoreData

let managedObjectContext: NSManagedObjectContext = {
    
    let containerPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.svagant.days.counter")!.path
    let sqlitePath = String(format: "%@/%@", containerPath, "counter.sqlite")
    let storeURL = URL(fileURLWithPath: sqlitePath, isDirectory: false)
    
    let bundles = [Bundle(for: Counter.self)]
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
        fatalError("Model not created!")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    context.persistentStoreCoordinator = psc

    return context
}()
