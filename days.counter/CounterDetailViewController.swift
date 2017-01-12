//
//  CounterDetailViewController.swift
//  days.counter
//
//  Created by Milan Nosáľ on 01/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

class CounterDetailViewController: UIViewController {
    
    @IBOutlet var daysPassedLabel: UILabel!
    @IBOutlet var dayOfResetLabel: UILabel!
    
    @IBOutlet var tensOfHoursLabel: UILabel!
    @IBOutlet var onesOfHoursLabel: UILabel!
    
    @IBOutlet var tensOfMinutesLabel: UILabel!
    @IBOutlet var onesOfMinutesLabel: UILabel!
    
    @IBOutlet var tensOfSecondsLabel: UILabel!
    @IBOutlet var onesOfSecondsLabel: UILabel!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var counterTitleLabel: UILabel!
    
    fileprivate var stopButton: UIBarButtonItem!
    
    var currentCounter: Counter? {
        didSet {
//            if self.isViewLoaded {
//                
//                resetView()
//            }
        }
    }
    
    fileprivate var timer: Timer?
    
    fileprivate var managedContext = AppDelegate.persistentContainer.viewContext
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return df
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "dd/MM/yy HH:mm"
        return df
    }()
    
    var parentNavigationViewController: UINavigationController?
}



extension CounterDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = currentCounter?.title
        
        stopButton = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(CounterDetailViewController.stopPressed(_:)))
        
        navigationItem.rightBarButtonItem = stopButton
        
        resetView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = currentCounter?.title
        stopButton.title = currentCounter?.state == StateType.stopped ? "Restart" : "Stop"
        
        resetView()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        invalidateTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.managedContext.refreshAllObjects()
    }

    @objc fileprivate func stopPressed(_ sender: Any) {
        
        guard let currentCounter = currentCounter else {
            fatalError()
        }
        
        self.managedContext.performChanges(completion: {
            success -> Void in
            
            self.resetView()
            
            if success {
                (UIApplication.shared.delegate as! AppDelegate).updateDynamicShortCuts()
            }
            
            self.stopButton.title = currentCounter.state == .running ? "Stop" : "Restart"
        }) {
            
            if currentCounter.state == .running {
                currentCounter.stop()
            } else {
                currentCounter.restart()
            }
        }
    }
}

// MARK: View setup
extension CounterDetailViewController {
    
    fileprivate func resetView() {
        
        daysPassedLabel.text = "0"
        
        tensOfHoursLabel.text = "0"
        onesOfHoursLabel.text = "0"
        tensOfMinutesLabel.text = "0"
        onesOfMinutesLabel.text = "0"
        tensOfSecondsLabel.text = "0"
        onesOfSecondsLabel.text = "0"
        
        dayOfResetLabel.text = "date not set"
        
        counterTitleLabel.text = ""
        
        if let currentCounter = currentCounter {
            
            navigationItem.title = currentCounter.title
            
            dayOfResetLabel.text = CounterDetailViewController.dateFormatter.string(from: currentCounter.start)
            
            counterTitleLabel.text = "\(currentCounter.title) is \(currentCounter.state.rawValue.lowercased())"
            
            setPassedTime()
        }
    }
    
    fileprivate func setPassedTime() {
        guard let fromDate = currentCounter?.start else {
            return
        }
        
        var endDate = Date()
        
        if let endDateOrig = currentCounter?.end {
            endDate = endDateOrig
        }
        
        let passedTimeComponents = timePassedAsStringComponents(since: fromDate, to: endDate)
        
        daysPassedLabel.text = passedTimeComponents.days
        
        tensOfHoursLabel.text = passedTimeComponents.hourTens
        onesOfHoursLabel.text = passedTimeComponents.hourOnes
        tensOfMinutesLabel.text = passedTimeComponents.minuteTens
        onesOfMinutesLabel.text = passedTimeComponents.minuteOnes
        tensOfSecondsLabel.text = passedTimeComponents.secondTens
        onesOfSecondsLabel.text = passedTimeComponents.secondOnes
        
        setupTimer()
    }
}

extension CounterDetailViewController {
    
    fileprivate func setupTimer() {
        timer?.invalidate()
        if currentCounter?.state == .running {
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.setPassedTime()
            })
        }
    }
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
    }
}

extension CounterDetailViewController {
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        return [UIPreviewAction(title: self.currentCounter?.state == StateType.running ? "Stop counter" : "Restart counter", style: self.currentCounter?.state == StateType.running ? .destructive : .default) { previewAction, viewController in
            guard let detailViewController = viewController as? CounterDetailViewController,
                let parentNavigationController = self.parentNavigationViewController else { return }
            
            DispatchQueue.main.async {
                parentNavigationController.pushViewController(detailViewController, animated: true)
                detailViewController.stopPressed(self)
            }
            }]
    }
    
    
}
