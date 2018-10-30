
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
    
    var launchedURL: URL?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true
        
        // If a shortcut was launched, display its information and take the appropriate action
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            shouldPerformAdditionalDelegateHandling = false
        }
        
        if let url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL,
            url.scheme == urlSchemeDaysCounter {
            
            launchedURL = url
            
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
        
        if let url = launchedURL {
            
            _ = handle(URL: url)
            
            launchedURL = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

// MARK: Quick actions from home screen using 3D touch
extension AppDelegate {
    
    
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard let action = QuickActions.from(fullType: shortcutItem.type) else { return handled }
        
        switch action {
        case .addCounter:
            handled = true
            AddCounterViewController.addNewCounter()
            
        case .counter(id: let counterId):
            handled = true
            presentCounter(id: counterId)
        }
        
        return handled
    }
    
    func updateDynamicShortCuts() {
        
        let lastCounters = Counter.lastRunningCounters(dataContext: managedObjectContext, limit: 2)
        
        var actionItems: [UIMutableApplicationShortcutItem] = []
        
        for counter in lastCounters {
            
            actionItems.append(UIMutableApplicationShortcutItem(type: QuickActions.counter(id: counter.id.intValue).type, localizedTitle: counter.title, localizedSubtitle: "Last edit: \(shortDateFormatter.string(from: counter.lastEditDate))", icon: UIApplicationShortcutIcon(templateImageName: "eyeIcon"), userInfo: nil))
            
        }
        
        // Update the application providing the initial 'dynamic' shortcut items.
        UIApplication.shared.shortcutItems = actionItems
    }
    
    // Called only when applicationDidLaunch returns true, in our case it means when application was reactivated instead of relaunched
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let handledShortCutItem = handle(shortcutItem: shortcutItem)
        
        completionHandler(handledShortCutItem)
    }
    
    fileprivate func presentCounter(id: Int) {
        guard let counter = Counter.findOrFetch(in: managedObjectContext, with: id),
            let rootVC = window?.rootViewController as? UINavigationController else {
                return
        }
        
        AddCounterViewController.dismissIfNeeded(animated: false, completion: { (_) in
        })
        rootVC.popToRootViewController(animated: false)
        
        guard let countersVC = rootVC.topViewController as? CountersViewController else {
            return
        }
        
        countersVC.presentCounterDetail(for: counter)
    }
}

extension AppDelegate {
    
    func handle(URL url: URL) -> Bool {
        
        if url.scheme == urlSchemeDaysCounter,
            let action = QuickActions.from(fullType: url.absoluteString.replacingOccurrences(of: "daysCounter://", with: "")) {
            
            switch action {
                
            case .addCounter:
                AddCounterViewController.addNewCounter()
                
            case .counter(let counterId):
                presentCounter(id: counterId)
            }
            
            return true
        }
        return false
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return handle(URL: url)
    }
    
}
