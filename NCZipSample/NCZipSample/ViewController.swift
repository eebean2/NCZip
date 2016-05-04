//
//  ViewController.swift
//  NCZipSampleApp
//
//  Created by Erik Bean on 5/2/16.
//  Copyright © 2016 Little Man Apps. All rights reserved.
//

import UIKit
import NCZip

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userTotal: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var total = Double()
    var zip = false
    var totalTax = Double()
    
    // MARK - NCZip Example

    @IBAction func zipCodeEntered(sender: UITextField) {
        let text = sender.text
        if text?.characters.count == 5 {
            let code = Int(text!)
            let nczip = NCZip(zip: code!)
            nczip.getTax({ (result, error) in
                if error != nil {
                    print(":: NCZipErrorDomain :: Error Code: \(error!.code)")
                    print(":: NCZipErrorDomain :: Error Description: \(error!.localizedDescription)")
                    print(":: NCZipErrorDomain :: Reason for Failure: \(error!.localizedFailureReason)")
                    print(":: NCZipErrorDomain :: Suggestions: \(error!.localizedRecoverySuggestion)")
                } else {
                    self.totalTax = result!.tax + result!.transit
                    self.zip = true
                    self.setTotal()
                }
            })
        }
    }
    
    // MARK - Other Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func fishDidChange(sender: UISwitch) {
        if sender.on {
            total = total + 1.99
        } else {
            total = total - 1.99
        }
        
        if zip == true {
            self.setTotal()
        }
    }
    
    @IBAction func chickenDidChange(sender: UISwitch) {
        if sender.on {
            total = total + 2.99
        } else {
            total = total - 2.99
        }
        
        if zip == true {
            self.setTotal()
        }
    }
    
    @IBAction func lambDidChange(sender: UISwitch) {
        if sender.on {
            total = total + 3.99
        } else {
            total = total - 3.99
        }
        
        if zip == true {
            self.setTotal()
        }
    }
    
    @IBAction func beefDidChange(sender: UISwitch) {
        if sender.on {
            total = total + 0.99
        } else {
            total = total - 0.99
        }
        
        if zip == true {
            self.setTotal()
        }
    }
    
    func setTotal() {
        let grandtotal = total * (totalTax + 1)
        self.userTotal.text = "$\(grandtotal)"
    }
    
}

