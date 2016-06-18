//
//  ViewController.swift
//  Tips
//
//  Created by Aaron on 6/15/16.
//  Copyright © 2016 Aaron L'Heureux. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var splitDivider: UIView!
    @IBOutlet weak var splitByLabel: UILabel!
    @IBOutlet weak var perPersonLabel: UILabel!
    @IBOutlet weak var perPersonTotal: UILabel!
    @IBOutlet weak var numberOfPeople: UILabel!
    @IBOutlet weak var peopleStepper: UIStepper!
    @IBOutlet weak var nagFriendsButton: UIBarButtonItem!
    
    var unformattedTotal = 0.0
    var rawBillAmount = 0.0
    
    let currencyFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }()
    
    let decimalFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        billField.placeholder = currencyFormatter.stringFromNumber(0)
        billField.delegate = self
        if !MFMessageComposeViewController.canSendText() {
            nagFriendsButton.enabled = false
        }
        maybeRestorePreviousState()
        billField.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func willEnterForeground() {
        maybeRestorePreviousState()
        nagFriendsButton.enabled = MFMessageComposeViewController.canSendText()
    }
    
    func willResignActive() {
        saveCurrentState()
    }
    
    // MARK: Helpers
    
    func saveCurrentState() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(tipControl.selectedSegmentIndex, forKey: "lastTipPercentage")
        defaults.setObject(NSDate(), forKey: "lastDate")
        defaults.setDouble(rawBillAmount, forKey: "lastBillAmount")
        defaults.setDouble(peopleStepper.value, forKey: "lastPeopleCount")
        defaults.synchronize()
    }
    
    func maybeRestorePreviousState() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastDate = defaults.objectForKey("lastDate") as? NSDate {
            if lastDate.timeIntervalSinceNow >= -600 {
                let lastTipPercentage = defaults.integerForKey("lastTipPercentage")
                let lastBillAmount = defaults.doubleForKey("lastBillAmount")
                let lastPeopleCount = defaults.doubleForKey("lastPeopleCount")
                tipControl.selectedSegmentIndex = lastTipPercentage
                billField.text = lastBillAmount.description
                peopleStepper.value = lastPeopleCount
            } else {
                tipControl.selectedSegmentIndex = defaults.integerForKey("defaultTipPercentage")
                billField.text = nil
            }
        } else {
            tipControl.selectedSegmentIndex = defaults.integerForKey("defaultTipPercentage")
        }
        onEditingChanged(billField)
    }
    
    func calculateTipWithPrice(price: Double) {
        let tipPercentages = [0.15, 0.18, 0.2, 0.25]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        let tip = price * tipPercentage
        let total = price + tip
        tipLabel.text = currencyFormatter.stringFromNumber(tip)
        totalLabel.text = currencyFormatter.stringFromNumber(total)
        unformattedTotal = total
    }
    
    // MARK: Actions from view controller

    @IBAction func onEditingChanged(sender: UITextField) {
        if let billFieldText = billField.text, billAmount = Double(billFieldText) {
            calculateTipWithPrice(billAmount)
            rawBillAmount = billAmount
        } else {
            tipLabel.text = currencyFormatter.stringFromNumber(0)
            totalLabel.text = currencyFormatter.stringFromNumber(0)
            rawBillAmount = 0
            unformattedTotal = 0
        }
        changeSplit(peopleStepper)
    }
    
    @IBAction func tipValueChanged(sender: AnyObject) {
        calculateTipWithPrice(rawBillAmount)
        changeSplit(peopleStepper)
        view.endEditing(true)
    }
    
    @IBAction func changeSplit(sender: UIStepper) {
        numberOfPeople.text = Int(sender.value).description
        perPersonTotal.text = currencyFormatter.stringFromNumber(unformattedTotal / sender.value)
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func nagFriends(sender: UIBarButtonItem) {
        guard let share = perPersonTotal.text else {
            return
        }
        let messageViewController = MFMessageComposeViewController()
        messageViewController.messageComposeDelegate = self
        messageViewController.body = "Hi! We just ate and your share is \(share)."
        presentViewController(messageViewController, animated: true, completion: nil)
    }
    
    @IBAction func resetEverything(sender: UIBarButtonItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        tipControl.selectedSegmentIndex = defaults.integerForKey("defaultTipPercentage")
        billField.text = nil
        peopleStepper.value = 1
        numberOfPeople.text = "1"
        onEditingChanged(billField)
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if splitDivider.alpha > 0 {
            UIView.animateWithDuration(0.35, delay: 0.0, options: .BeginFromCurrentState, animations: { () -> Void in
                self.splitDivider.alpha = 0
                self.splitDivider.frame.origin.y = 382
                self.splitByLabel.alpha = 0
                self.splitByLabel.frame.origin.y = 401
                self.perPersonLabel.alpha = 0
                self.perPersonLabel.frame.origin.y = 444
                self.perPersonTotal.alpha = 0
                self.perPersonTotal.frame.origin.y = 444
                self.numberOfPeople.alpha = 0
                self.numberOfPeople.frame.origin.y = 401
                self.peopleStepper.alpha = 0
                self.peopleStepper.frame.origin.y = 397
            }, completion: nil)
        }
        
        // Get friendly editable value (e.g.: don't insert decimals if they aren't needed)
        if rawBillAmount == 0.0 {
            billField.text = nil
        } else if Double(Int(rawBillAmount)) == rawBillAmount {
            billField.text = Int(rawBillAmount).description
        } else {
            billField.text = rawBillAmount.description
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if splitDivider.alpha < 1 {
            UIView.animateWithDuration(0.35, delay: 0.0, options: .BeginFromCurrentState, animations: { () -> Void in
                self.splitDivider.alpha = 1
                self.splitDivider.frame.origin.y = 332
                self.splitByLabel.alpha = 1
                self.splitByLabel.frame.origin.y = 361
                self.perPersonLabel.alpha = 1
                self.perPersonLabel.frame.origin.y = 404
                self.perPersonTotal.alpha = 1
                self.perPersonTotal.frame.origin.y = 404
                self.numberOfPeople.alpha = 1
                self.numberOfPeople.frame.origin.y = 361
                self.peopleStepper.alpha = 1
                self.peopleStepper.frame.origin.y = 357
                }, completion: nil)
        }
        billField.text = currencyFormatter.stringFromNumber(rawBillAmount)
    }
    
    // MARK: MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}