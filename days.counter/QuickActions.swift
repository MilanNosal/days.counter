//
//  QuickActions.swift
//  days.counter
//
//  Created by Milan Nosáľ on 15/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation


enum QuickActions {
    case addCounter
    case counter(id: Int)
    
    static func from(fullType: String) -> QuickActions? {
        guard let last = fullType.components(separatedBy: ".").last else { return nil }
        
        if last == "addCounter" {
            return QuickActions.addCounter
        } else if last.hasPrefix("counter"), let id = Int(last.replacingOccurrences(of: "counter/", with: "")) {
            return QuickActions.counter(id: id)
        } else {
            return nil
        }
    }
    
    @nonobjc var type: String {
        switch self {
        case .addCounter:
            return "\(Bundle.main.bundleIdentifier!).addCounter"
        case .counter(id: let id):
            return "\(Bundle.main.bundleIdentifier!).counter/\(id)"
        }
    }
}
