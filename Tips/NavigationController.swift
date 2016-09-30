//
//  NavigationController.swift
//  Tips
//
//  Created by Aaron on 9/29/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import MessageUI

class NavigationController: UINavigationController, UINavigationControllerDelegate {
    var askForMoneyButton: UIBarButtonItem?
    var resetButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func willEnterForeground() {
        askForMoneyButton?.enabled = MFMessageComposeViewController.canSendText()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let mainVC = viewController as? ViewController {
            resetButton = UIBarButtonItem(title: "Reset", style: .Plain, target: mainVC, action: #selector(mainVC.resetEverything))
            askForMoneyButton = UIBarButtonItem(title: "Ask Friends for Money", style: .Plain, target: mainVC, action: #selector(mainVC.nagFriends))
            let flexibleSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            
            askForMoneyButton?.enabled = MFMessageComposeViewController.canSendText()
            
            setToolbarHidden(false, animated: true)
            
            mainVC.setToolbarItems([resetButton!, flexibleSpacer,  askForMoneyButton!], animated: false)
        }
        
        if let _ = viewController as? SettingsViewController {
            setToolbarHidden(true, animated: true)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
