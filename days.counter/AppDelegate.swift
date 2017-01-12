
//  AppDelegate.swift
//  days.counter
//
//  Created by Milan Nosáľ on 01/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true
        
        // If a shortcut was launched, display its information and take the appropriate action
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }
        
        // Install initial versions of our two extra dynamic shortcuts.
        if let shortcutItems = application.shortcutItems, shortcutItems.isEmpty {
            
            updateDynamicShortCuts()
            
        }
        
        return shouldPerformAdditionalDelegateHandling
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let shortcut = launchedShortcutItem {
            
            _ = handle(shortcutItem: shortcut)
            
            launchedShortcutItem = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

// MARK: - Core Data stack
extension AppDelegate {
    @nonobjc static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "com.svagant.day.counter")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
}

// MARK: Quick actions from home screen using 3D touch
extension AppDelegate {
    
    enum QuickActions {
        case addCounter
        case lastCounter(id: Int)
        
        static func from(fullType: String) -> QuickActions? {
            guard let last = fullType.components(separatedBy: ".").last else { return nil }
            
            if last == "addCounter" {
                return QuickActions.addCounter
            } else if last.hasPrefix("lastCounter"), let id = Int(last.replacingOccurrences(of: "lastCounter", with: "")) {
                return QuickActions.lastCounter(id: id)
            } else {
                return nil
            }
        }
        
        @nonobjc var type: String {
            switch self {
            case .addCounter:
                return "\(Bundle.main.bundleIdentifier!).addCounter"
            case .lastCounter(id: let id):
                return "\(Bundle.main.bundleIdentifier!).lastCounter\(id)"
            }
        }
    }
    
    
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard let action = QuickActions.from(fullType: shortcutItem.type) else { return handled }
        
        switch action {
        case .addCounter:
            handled = true
            AddCounterViewController.show(answeredCallback: nil)
            
        case .lastCounter(id: let counterId):
            handled = true
            guard let counter = Counter.findOrFetch(in: AppDelegate.persistentContainer.viewContext, with: counterId),
                let rootVC = window?.rootViewController as? UINavigationController else {
                    break
            }
            
            AddCounterViewController.dismissIfNeeded(animated: false, completion: { (_) in
            })
            rootVC.popToRootViewController(animated: false)
            
            guard let countersVC = rootVC.topViewController as? CountersViewController else {
                break
            }
            
            countersVC.presentCounterDetail(for: counter)
        }
        
        return handled
    }
    
    func updateDynamicShortCuts() {
        
        let lastCounters = Counter.lastRunnningCounters(dataContext: AppDelegate.persistentContainer.viewContext)
        
        var actionItems: [UIMutableApplicationShortcutItem] = []
        
        for counter in lastCounters {
            
            let time = counter.end == nil ? timePassed(since: counter.start) : timePassed(since: counter.start, to: counter.end!)
            
            let text = time.days == 1 ? "\(time.days) day" : "\(time.days) days"
            
            actionItems.append(UIMutableApplicationShortcutItem(type: QuickActions.lastCounter(id: counter.id.intValue).type, localizedTitle: "\(text) - '\(counter.title)'", localizedSubtitle: "Last edit: \(CounterDetailViewController.shortDateFormatter.string(from: counter.lastEditDate))", icon: UIApplicationShortcutIcon(templateImageName: "eyeIcon"), userInfo: nil))
            
        }
        
        // Update the application providing the initial 'dynamic' shortcut items.
        UIApplication.shared.shortcutItems = actionItems
    }
    
    // Called only when applicationDidLaunch returns true, in our case it means when application was reactivated instead of relaunched
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let handledShortCutItem = handle(shortcutItem: shortcutItem)
        
        completionHandler(handledShortCutItem)
    }
}
