//
//  ManagedObject.swift
//  day.planer
//
//  Created by Milan Nosáľ on 21/12/2016.
//  Copyright © 2016 Svagant. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObject: NSManagedObject {
}

extension ManagedObject {
    
    @NSManaged fileprivate(set) var id: NSNumber
    
    func setRawValue<ValueType: RawRepresentable>(_ value: ValueType?, forKey key: String)
    {
        self.willChangeValue(forKey: key)
        self.setPrimitiveValue(value?.rawValue, forKey: key)
        self.didChangeValue(forKey: key)
    }
    
    func getFromRawValue<ValueType: RawRepresentable>(forKey key: String) -> ValueType?
    {
        self.willAccessValue(forKey: key)
        defer { self.didAccessValue(forKey: key) }
        return ValueType(rawValue: self.primitiveValue(forKey: key) as! ValueType.RawValue)
    }
}

protocol ManagedObjectType {
    
    static var entityName: String { get }
    
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    static func sortedFetchRequest<T: ManagedObject>() -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

extension ManagedObjectType where Self: ManagedObject {
    
    static func findOrFetch(in dataContext: NSManagedObjectContext, with id: Int) -> Self? {
        let predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: "id"), rightExpression: NSExpression(forConstantValue: id), modifier: .direct, type: .equalTo, options: .normalized)
        
        return findOrFetch(in: dataContext, matchingPredicate: predicate)
    }
    
    static func findOrFetch(in dataContext: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        guard let obj = materializedObject(in: dataContext, matchingPredicate: predicate) else {
            
            return fetch(in: dataContext) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
            
        }
        
        return obj
    }
    
    static func materializedObject(in dataContext: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        
        for obj in dataContext.registeredObjects where !obj.isFault {
            guard let res = obj as? Self,
                predicate.evaluate(with: res)
                else { continue }
            return res
        }
        
        return nil
    }
    
    static func fetch(in dataContext: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! dataContext.fetch(request)
    }
}

extension NSManagedObjectContext {
    
    func createObject<MO: ManagedObject>() -> MO where MO: ManagedObjectType {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: MO.entityName, into: self) as? MO
            else {
                fatalError("Wrong object type.")
        }
        
        object.id = UserDefaults.standard.nextAutoIncrementedId
        
        return object
    }
    
    
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    func performChanges(completion: ((Bool) -> Void)? = nil, block: @escaping () -> ()) {
        perform {
            block()
            let success = self.saveOrRollback()
            completion?(success)
        }
    }
}

extension UserDefaults {
    
    private static let autoIncrementKey = "com.svagant.core.sorm.autoincrement"
    
    var nextAutoIncrementedId: NSNumber {
        get {
            let currentValue = UserDefaults.standard.object(forKey: UserDefaults.autoIncrementKey) as? NSNumber
            if currentValue == nil {
                UserDefaults.standard.set(NSNumber(integerLiteral: 2), forKey: UserDefaults.autoIncrementKey)
                return 1
            } else {
                let next = NSNumber(value: currentValue!.int64Value + 1)
                UserDefaults.standard.set(next, forKey: UserDefaults.autoIncrementKey)
                return currentValue!
            }
        }
        set {
            guard newValue.int64Value >= 0 else {
                fatalError("Only positive values are supported for autoincremented id.")
            }
            print("Destructive operation in process - resetting the autoincremented id getter to \(newValue.int64Value).")
            
            UserDefaults.standard.set(newValue, forKey: UserDefaults.autoIncrementKey)
        }
    }
}
