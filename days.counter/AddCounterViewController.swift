//
//  AddCounterViewController.swift
//  days.counter
//
//  Created by Milan Nosáľ on 05/01/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit

class AddCounterViewController: KeyboardAdjustingViewController {
    
    fileprivate let restrictionDelegate: UITextFieldDelegate = {
        class LengthRestriction: NSObject, UITextFieldDelegate {
            
            private let maxLength = 22
            
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                
                let oldLength = textField.text?.characters.count ?? 0
                let replacementLength = string.characters.count
                let rangeLength = range.length
                
                let newLength = (oldLength - rangeLength) + replacementLength
                
                return newLength <= 22
            }
        }
        
        return LengthRestriction()
    }()
    
    
    
    fileprivate var dismissalCallback: ((AddCounterViewController) -> Void)?
    fileprivate var answeredCallback: ((AddCounterViewController, String?, Date) -> Void)?
    
    static let popupBorders = CGFloat(19)
    static let popupContentVertBorders = CGFloat(14)
    static let popupContentHorizBorders = CGFloat(16)
    static let popupContentHorizSpacing = CGFloat(9)
    
    fileprivate let bubbleView = UIView()
    
    fileprivate let headerLabel = UILabel()
    
    fileprivate let contentView = UIView()
    
    fileprivate let contentStackView = UIStackView()
    
    fileprivate let titleStackView = UIStackView()
    fileprivate let titleLabel = UILabel()
    fileprivate let titleTextField = UITextField()
    
    fileprivate let fromLabel = UILabel()
    fileprivate let fromSelector = UIDatePicker()
    
    fileprivate let buttonStackView = UIStackView()
    fileprivate let confirmButton = UIButton()
    fileprivate let cancelButton = UIButton()
    
    // not to be edited
    fileprivate var originalCounter: Counter?
    
    init(originalCounter: Counter?) {
        super.init(nibName: nil, bundle: nil)
        self.originalCounter = originalCounter
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddCounterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialViewHierarchy()
        setInitialLayout()
        setInitialAttributes()
        
        view.layoutIfNeeded()
        
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(AddCounterViewController.outsideTapHappening(sender:)))
        view.addGestureRecognizer(gr)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = titleTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        titleTextField.resignFirstResponder()
    }
    
    private func setInitialViewHierarchy() {
        
        bubbleView.addSubview(headerLabel)
        
        view.addSubview(bubbleView)
        
        bubbleView.addSubview(contentView)
        
        contentView.addSubview(contentStackView)
        
        titleStackView.addArrangedSubview(titleTextField)
        titleStackView.addArrangedSubview(fromLabel)
        
        contentStackView.addArrangedSubview(titleStackView)
        
        contentStackView.addArrangedSubview(fromSelector)
        
        contentStackView.addArrangedSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }
    
    private func setInitialLayout() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(contentsOf: [
            
            bubbleView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: AddCounterViewController.popupBorders),
            bubbleView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -AddCounterViewController.popupBorders),
            bubbleView.bottomAnchor.constraint(equalTo: self.keyboardAwareBottomLayoutGuide.topAnchor, constant: -AddCounterViewController.popupBorders)
            ])
        
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(contentsOf: [
            headerLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: AddCounterViewController.popupContentHorizBorders),
            headerLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: AddCounterViewController.popupContentVertBorders)
            ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(contentsOf: [
            contentView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: AddCounterViewController.popupContentVertBorders)
            ])
        
        
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(contentsOf: [
            contentStackView.widthAnchor.constraint(equalTo: titleStackView.widthAnchor)
            ])
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(contentsOf: [
            contentStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            contentStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(contentsOf: [
            confirmButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
            ])
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(contentsOf: [
            contentStackView.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor)
            ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setInitialAttributes() {
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        bubbleView.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1.0)
        bubbleView.layer.cornerRadius = 8
        bubbleView.clipsToBounds = true
        
        contentView.backgroundColor = .white
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 19)
        headerLabel.text = originalCounter == nil ? "Add new counter" : "Edit \(originalCounter!.title)"
        
        titleTextField.placeholder = "Counter's title (optional)"
        titleTextField.setContentHuggingPriority(240, for: .horizontal)
        titleTextField.borderStyle = .line
        
        titleTextField.delegate = restrictionDelegate
        
        fromLabel.text = "starting at"
        fromSelector.datePickerMode = .dateAndTime
        let now = Date()
        fromSelector.date = now
        fromSelector.maximumDate = now
        
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.spacing = 10
        titleStackView.alignment = .lastBaseline
        
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.spacing = 0
        contentStackView.alignment = .center
        
        confirmButton.setTitle(originalCounter == nil ? "Add" : "Save", for: .normal)
        confirmButton.setTitleColor(UIColor.blue, for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        
        confirmButton.addTarget(self, action: #selector(AddCounterViewController.confirm(sender:)), for: .touchUpInside)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.red, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        
        cancelButton.addTarget(self, action: #selector(AddCounterViewController.cancel(sender:)), for: .touchUpInside)
        
        if let originalCounter = originalCounter {
            titleTextField.text = originalCounter.title
            fromSelector.date = originalCounter.start
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension AddCounterViewController {
    
    func outsideTapHappening(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            if view.hitTest(sender.location(in: view), with: nil) === view {
                cancel(sender: sender)
            }
        }
        
    }
    
    func cancel(sender: Any?) {
        
        view.endEditing(true)
        
        self.dismissPresented(animated: true) {
            self.dismissalCallback?(self)
        }
    }
    
    
    func confirm(sender: Any?) {
        
        view.endEditing(true)
        
        let title = titleTextField.text
        var titleReady: String?
        
        if title == nil || title!.isEmpty {
            titleReady = nil
        } else {
            titleReady = title
        }
        
        let date = fromSelector.date
        
        self.dismissPresented(animated: true) {
            self.answeredCallback?(self, titleReady, date)
            self.dismissalCallback?(self)
        }
    }
}

extension AddCounterViewController {
    
    fileprivate struct Static {
        
        static let window: UIWindow = {
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = RootViewController()
            window.windowLevel = UIWindowLevelAlert - 1
            return window
        }()
    }
    
    private class RootViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .clear
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .default
        }
    }
    
    fileprivate func dismissPresented(animated: Bool = true, completion: @escaping (Void) -> Void) {
        
        if animated {
            
            UIView.animate(withDuration: 0.25, animations: {
                () -> Void in
                self.view.alpha = 0
            }, completion: {
                (_) -> Void in
                
                DispatchQueue.main.async {
                    
                    Static.window.rootViewController?.dismiss(animated: false, completion: {
                        DispatchQueue.main.async {
                            Static.window.isHidden = Static.window.rootViewController!.presentedViewController == nil
                        }
                        
                        completion()
                    })
                }
            })
            
        } else {
            
            DispatchQueue.main.async {
                
                Static.window.rootViewController?.dismiss(animated: false, completion: {
                    DispatchQueue.main.async {
                        Static.window.isHidden = Static.window.rootViewController!.presentedViewController == nil
                    }
                    
                    completion()
                })
            }
        }
    }
    
    static func dismissIfNeeded(animated: Bool, completion: @escaping (_ dismissed: Bool) -> Void) {
        
        if Static.window.rootViewController!.presentedViewController == nil || Static.window.rootViewController!.presentedViewController!.isBeingDismissed {
            completion(false)
        } else {
            
            let popup = Static.window.rootViewController!.presentedViewController as! AddCounterViewController
            popup.dismissPresented(animated: animated, completion: {
                completion(true)
            })
        }
    }
    
    private static func present(
        counter: Counter?,
        animated: Bool = true,
        answeredCallback: ((AddCounterViewController, String?, Date) -> Void)?,
        dismissalCallback: ((AddCounterViewController) -> Void)?,
        _ presentCompletionBlock: ((AddCounterViewController) -> Void)?) {
        
        guard Static.window.rootViewController!.presentedViewController == nil || Static.window.rootViewController!.presentedViewController!.isBeingDismissed else {
            
            presentCompletionBlock?(Static.window.rootViewController!.presentedViewController as! AddCounterViewController)
            return
        }
        
        let popup = AddCounterViewController(originalCounter: counter)
        
        popup.answeredCallback = answeredCallback
        popup.dismissalCallback = dismissalCallback
        
        if animated {
            
            popup.view.alpha = 0
            
            Static.window.isHidden = false
            Static.window.rootViewController!.present(popup, animated: false, completion: {
                
                UIView.animate(withDuration: 0.25, animations: {
                    () in
                    
                    popup.view.alpha = 1
                }, completion:  {
                    _ in
                    
                    _ = popup.becomeFirstResponder()
                })
                presentCompletionBlock?(popup)
            })
            
        } else {
            
            Static.window.isHidden = false
            Static.window.rootViewController!.present(popup, animated: false, completion: {
                
                _ = popup.becomeFirstResponder()
                presentCompletionBlock?(popup)
            })
            
        }
        
    }
    
    static func show(
        counter: Counter?,
        answeredCallback: ((AddCounterViewController, String?, Date) -> Void)?,
        dismissalCallback: ((AddCounterViewController) -> Void)? = nil) {
        
        precondition(Thread.isMainThread)
        
        AddCounterViewController.dismissIfNeeded(animated: true, completion: {
            (_) in
            
            AddCounterViewController.present(
                counter: counter,
                answeredCallback: answeredCallback, dismissalCallback: dismissalCallback, nil)
        })
    }
    
    static func addNewCounter(
        answeredCallback: ((AddCounterViewController, String?, Date) -> Void)? = nil,
        dismissalCallback: ((AddCounterViewController) -> Void)? = nil) {
        
        AddCounterViewController.show(counter: nil, answeredCallback: {
            (addCounterViewController, title, startDate) in
            
            managedObjectContext.performChanges(completion: {
                success -> Void in
                
                if success {
                    (UIApplication.shared.delegate as! AppDelegate).updateDynamicShortCuts()
                }
                
                answeredCallback?(addCounterViewController, title, startDate)
            }) {
                _ = Counter.createCounter(title, startingFrom: startDate, throughContext: managedObjectContext)
            }
        }, dismissalCallback: dismissalCallback)
    }
    
    static func edit(
        counter: Counter,
        answeredCallback: ((AddCounterViewController, String?, Date) -> Void)? = nil,
        dismissalCallback: ((AddCounterViewController) -> Void)? = nil) {
        
        AddCounterViewController.show(counter: counter, answeredCallback: {
            (addCounterViewController, title, startDate) in
            
            managedObjectContext.performChanges(completion: {
                success -> Void in
                
                if success {
                    (UIApplication.shared.delegate as! AppDelegate).updateDynamicShortCuts()
                }
                
                answeredCallback?(addCounterViewController, title, startDate)
            }) {
                counter.update(title: title, startDate: startDate)
            }
        }, dismissalCallback: dismissalCallback)
    }
}
