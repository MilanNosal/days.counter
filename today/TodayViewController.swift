//
//  TodayViewController.swift
//  today
//
//  Created by Milan Nosáľ on 13/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var mainLabel: UILabel!
    
    @IBOutlet var mainButton: UIButton!
    
    @IBAction func mainButtonPressed(_ sender: UIButton) {
        
        let action = lastCounter == nil ? QuickActions.addCounter : QuickActions.counter(id: lastCounter!.id.intValue)
        
        let url = URL(string: "\(urlSchemeDaysCounter)://\(action.type)")!
        
        self.extensionContext?.open(url, completionHandler: nil)
        
    }
    
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    fileprivate var timer = Timer()
    
    fileprivate var lastCounter: Counter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.00)
        mainLabel.isHidden = true
        mainButton.isHidden = true
        secondaryLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
//        if activeDisplayMode == .expanded {
//            self.preferredContentSize = maxSize
//            self.preferredContentSize = CGSize(width: 0, height: 110)
//        }
//    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.noData)
    }
    
}

// MARK: update view
extension TodayViewController {
    
    fileprivate func reset() {
        
        timer.invalidate()
        
        lastCounter = Counter.lastRunningCounters(dataContext: managedObjectContext, limit: 1).first
        
        if lastCounter != nil {
            mainButton.setTitle("View", for: .normal)
            update()
            
            mainLabel.isHidden = false
            mainButton.isHidden = false
            secondaryLabel.isHidden = false
            
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                self.update()
            })
        } else {
            
            mainLabel.text = "No currently running counter."
            mainButton.setTitle("Add new counter", for: .normal)
            
            mainLabel.isHidden = false
            mainButton.isHidden = false
            secondaryLabel.isHidden = true
        }
    }
    
    fileprivate func update() {
        
        if let lastCounter = lastCounter {
            
            let time = timePassedAsStringComponents(since: lastCounter.start)
            let days = (time.days == "1") ? "day" : "days"
            mainLabel.text = lastCounter.title
            secondaryLabel.text = "\(time.days) \(days) and \(time.hourTens)\(time.hourOnes):\(time.minuteTens)\(time.minuteOnes) passed"
        }
    }
    
}
