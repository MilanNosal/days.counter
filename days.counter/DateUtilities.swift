//
//  DateUtilities.swift
//  days.counter
//
//  Created by Milan Nosáľ on 06/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation


func timePassedAsStringComponents(since date: Date, to toDate: Date = Date()) -> (days: String, hourTens: String, hourOnes: String, minuteTens: String, minuteOnes: String, secondTens: String, secondOnes: String) {
    let components = timePassed(since: date, to: toDate)
    let hourTens: Int = components.hours / 10
    let hourOnes: Int = components.hours % 10
    let minuteTens: Int = components.minutes / 10
    let minuteOnes: Int = components.minutes % 10
    let secondTens: Int = components.seconds / 10
    let secondOnes: Int = components.seconds % 10
    
    return (days: "\(components.days)", hourTens: "\(hourTens)", hourOnes: "\(hourOnes)", minuteTens: "\(minuteTens)", minuteOnes: "\(minuteOnes)", secondTens: "\(secondTens)", secondOnes: "\(secondOnes)")
}

func timePassed(since date: Date, to toDate: Date = Date()) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
    let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: toDate)
    guard let days = components.day,
        let hours = components.hour,
        let minutes = components.minute,
        let seconds = components.second else {
            return (days: 0, hours: 0, minutes: 0, seconds: 0)
    }
    
    return (days: days, hours: hours, minutes: minutes, seconds: seconds)
}
