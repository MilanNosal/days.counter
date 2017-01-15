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
        
        AddCounterViewController.addNewCounter()
        
    }
    
    override func viewDidLoad() {
        
        counterDetailVC.parentNavigationViewController = navigationController
        
        self.title = "Magic Days Counter"
        
        setupTableView()
        
        // Check for force touch feature, and add force touch/previewing capability.
        if traitCollection.forceTouchCapability == .available {
            /*
             Register for `UIViewControllerPreviewingDelegate` to enable
             "Peek" and "Pop".
             (see: MasterViewController+UIViewControllerPreviewing.swift)
             
             The view controller will be automatically unregistered when it is
             deallocated.
             */
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    
    private func setupTableView() {
        
        tableView.register(CounterTableViewCell.self, forCellReuseIdentifier: "CounterTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let request: NSFetchRequest<Counter> = Counter.sortedFetchRequest()
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: "state", cacheName: nil)
        fetchedResultsController.delegate = self
        try! self.fetchedResultsController.performFetch()
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
        presentCounterDetail(for: fetchedResultsController.object(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func presentCounterDetail(for counter: Counter) {
        counterDetailVC.currentCounter = counter
        navigationController?.pushViewController(counterDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let counter = self.fetchedResultsController.object(at: indexPath)
        
        // touch action
        let touchAction = UITableViewRowAction(style: .default, title: "Touch", handler: { (action, indexPath) in
            
            managedObjectContext.performChanges(completion: {
                success -> Void in
                
                if success {
                    (UIApplication.shared.delegate as! AppDelegate).updateDynamicShortCuts()
                }
            }) {
                counter.lastEditDate = Date()
            }
        })
        touchAction.backgroundColor = UIColor.green
        
        // edit action
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            
            AddCounterViewController.edit(counter: counter,
                                          answeredCallback: nil,
                                          dismissalCallback: {
                                            _ in
                                            
                                            self.tableView.setEditing(false, animated: true)
            })
        })
        editAction.backgroundColor = UIColor.blue
        
        // delete action
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            
            let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure to delete this counter?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                
                managedObjectContext.performChanges(completion: {
                    success -> Void in
                    
                    if success {
                        (UIApplication.shared.delegate as! AppDelegate).updateDynamicShortCuts()
                    }
                }) {
                    managedObjectContext.delete(counter)
                }
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
                
                    self.tableView.setEditing(false, animated: true)
            
            }))
            
            
            self.present(deleteAlert, animated: true, completion: nil)

            
        })
        deleteAction.backgroundColor = UIColor.red
        
        return counter.state == .running ? [deleteAction, editAction, touchAction] : [deleteAction]
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





// MARK: Peek and pop
extension CountersViewController: UIViewControllerPreviewingDelegate {
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        let previewDetail = fetchedResultsController.object(at: indexPath)
        counterDetailVC.currentCounter = previewDetail
        
        // Set the source rect to the cell frame, so surrounding elements are blurred.
        previewingContext.sourceRect = cell.frame
        
        return counterDetailVC
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(counterDetailVC, animated: true)
    }
    
}
