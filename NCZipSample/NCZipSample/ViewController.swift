/*
 
 NCZipSample :: ViewController.swift
 
*/

/*
 
 The MIT License (MIT)
 
 Copyright (c) 2016 Little Man Apps
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

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

