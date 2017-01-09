//
//  CountersViewController.swift
//  days.counter
//
//  Created by Milan Nosáľ on 05/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit
import CoreData

class CountersViewController: UIViewController {
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Counter>!
    
    @IBOutlet var tableView: UITableView!
    
    fileprivate var timer: Timer?
    
    
    fileprivate let counterDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CounterDetailViewController") as! CounterDetailViewController
    
    @IBAction func addNewCounter(_ sender: UIBarButtonItem) {
        
        AddCounterViewController.show(answeredCallback: nil)
        
    }
    
    override func viewDidLoad() {
        setupTableView()
        try! self.fetchedResultsController.performFetch()
        self.title = "Magic Days Counter"
    }
    
    private func setupTableView() {
        
        tableView.register(CounterTableViewCell.self, forCellReuseIdentifier: "CounterTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let request: NSFetchRequest<Counter> = Counter.sortedFetchRequest()
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDelegate.persistentContainer.viewContext, sectionNameKeyPath: "state", cacheName: nil)
        fetchedResultsController.delegate = self
    }

}

extension CountersViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.tableView.visibleCells.filter({ (cell) -> Bool in
                guard let counterCell = cell as? CounterTableViewCell,
                    let counter = counterCell.counter else {
                    return false
                }
                return counter.state == .running
            }).forEach({ (cell) in
                (cell as! CounterTableViewCell).update()
            })
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }
}

extension CountersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CounterTableViewCell") as! CounterTableViewCell
        let counter = fetchedResultsController.object(at: indexPath)
        cell.configureForObject(counter)
        return cell
    }
}

extension CountersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        counterDetailVC.currentCounter = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(counterDetailVC, animated: true)
    }
}

extension CountersViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! CounterTableViewCell
            cell.configureForObject(fetchedResultsController.object(at: indexPath!))
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            tableView.insertSections([sectionIndex], with: .fade)
            
        case .delete:
            tableView.deleteSections([sectionIndex], with: .fade)
            
        default:
            print("Default fall-through")
        }
    }
}

class CounterTableViewCell: UITableViewCell {
    
    private(set) var counter: Counter?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
        detailTextLabel?.font = UIFont(name: "Courier", size: 17)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureForObject(_ counter: Counter) {
        self.counter = counter
        self.textLabel?.text = counter.title
        self.update()
    }
    
    func update() {
        guard let counter = counter else {
            return
        }
        let timeComponents = (counter.state == .stopped && counter.end != nil) ? timePassedAsStringComponents(since: counter.start, to: counter.end!) : timePassedAsStringComponents(since: counter.start)
        let days = timeComponents.days == "1" ? "day" : "days"
        let text = "\(timeComponents.days) \(days) \(timeComponents.hourTens)\(timeComponents.hourOnes):\(timeComponents.minuteTens)\(timeComponents.minuteOnes)"
        self.detailTextLabel?.text = text
    }
}

