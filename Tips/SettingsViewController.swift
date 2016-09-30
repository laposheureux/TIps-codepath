//
//  SettingsViewController.swift
//  Tips
//
//  Created by Aaron on 9/30/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var defaultTipPercentage: UISegmentedControl!
    
    override func viewDidLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaultTipPercentage.selectedSegmentIndex = defaults.integerForKey("defaultTipPercentage")
    }
    
    @IBAction func changeDefaultTip(sender: UISegmentedControl) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(defaultTipPercentage.selectedSegmentIndex, forKey: "defaultTipPercentage")
        defaults.synchronize()
    }
}
