/*
 
 NCZip :: NCZip.swift
 
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

public class NCZip {
    
    @available(*, unavailable, message="init cannot be empty") init() {}
    @available(*, unavailable, renamed="remove") func removeSingleLimtiedCounty(county: String) { }
    @available(*, unavailable, renamed="silent") public var runSilent = false
    @available(*, unavailable, renamed="limitBy") func addCountyLimit(county: String) { }
    @available(*, unavailable, renamed="limitByMultiple") func addMultipleCountyLimits(counties: [String]) { }
    @available(*, unavailable, renamed="removeAllLimits") func removeAllCountyLimits() { }
    
    /// Read-Only: Returns the current zipcode
    
    public var zip : Int { return internalZip }
    
    /// Read-Only: Returns the current city if available
    
    public var city : String { return internalCity }
    
    /// Read-Only: Returns the current county if available
    
    public var county : String { return internalCounty }
    
    /// Read-Only: Returns the current tax rate if available
    
    public var tax : Double { return internalTax }
    
    /// Read-Only: Returns the current transit tax rate if available
    
    public var transit : Double { return internalTransit }
    
    /// Read-Only: Returns the county limits given if any
    
    public var countyLimits : [String] { return internalLimits }
    
    /// Change to allow zip to return even if it fails to pass the radius check (Not recommended unless expecting possible overrides)
    
    public var returnZipIfFail = false
    
    /// No error mode, enableing will turn off return of NSErrors (Not recommended)
    
    public var silent = false
    
    private var internalZip = Int()
    private var internalCity = String()
    private var internalCounty = String()
    private var internalTax = Double()
    private var internalTransit = Double()
    private var internalLimits = [String]()
    private let NCZipErrorDomain = "NCZipErrorDomain"

    /**
     Initilize will full location data, mostly used internally; limited to North Carolina only currently
     
     - Parameters:
        - zip: North Carolina Zipcode
        - city: North Carolina City listed within zipcode database
        - county: North Carolina County
        - tax: Sales and Use tax for location provided
        - transit: Transit tax if avalible, if not, put 0.00
     */
    
    public init(zip: Int, city: String, county: String, tax: Double, transit: Double) {
        self.internalZip = zip
        self.internalCity = city
        self.internalCounty = county
        self.internalTax = tax
        self.internalTransit = transit
    }
    
    /**
     ***** USE THIS INITILIZER *****
     
     This initilizer only requires the zipcode, the minimum required for NCZip to function
     
     - Parameter zip: North Carolina Zipcode
     */
    
    public init(zip: Int) {
        self.internalZip = zip
    }
    
    /**
     Initilize NCZip with another NCZip
     
     - Parameter NCZip: An already initilized NCZip object to be duplicated
     */
    
    public init(ncZip: NCZip) {
        self.internalZip = ncZip.zip
        self.internalCity = ncZip.city
        self.internalCounty = ncZip.county
        self.internalTax = ncZip.tax
        self.internalTransit = ncZip.transit
    }
    
    /**
     Limits the counties which the user will be allowed to collect tax in
     
     - Parameter county: A single county name
     */
    
    public func limitBy(county county: String) {
        let county = county.uppercaseString
        internalLimits.append(county)
    }
    
    /**
     Limits the counties which the user will be allowed to collect tax in
     
     - Parameter counties: Array of multiple county names
     */
    
    public func limitByMultiple(counties counties: [String]) {
        for county in counties {
            let county = county.uppercaseString
            internalLimits.append(county)
        }
    }
    
    /**
     Removes a single county from the county limits list
     
     - Parameter county: A single county name
     */
    
    public func remove(county county: String) {
        let county = county.uppercaseString
        let i = internalLimits.indexOf(county)
        internalLimits.removeAtIndex(i!)
        
    }
    
    /// Removes all counties from the list of limited counties
    
    public func removeAllLimits() {
        internalLimits.removeAll()
    }
    
    // private
    private func presentAlert(title title: String, message: String, alertType: UIAlertControllerStyle?, buttons: [UIAlertAction]?) {
        var style = UIAlertControllerStyle.Alert
        if alertType != nil {
            style = alertType!
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if buttons != nil {
            for button in buttons! {
                alert.addAction(button)
            }
        } else {
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
        }
        
        if let topViewController = UIApplication.topViewController() {
            topViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /// Returns the tax for the current NCZip location
    
    public func getTax(completion: (result: NCZip?, error: NSError?) -> Void) {
        let tempzip = String(internalZip)
        if tempzip.characters.count != 5 {
            let error = NSError(domain: NCZipErrorDomain, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid Zip Code", NSLocalizedFailureReasonErrorKey: "Zip Code must be a 5 digits and from North Carolina",NSLocalizedRecoverySuggestionErrorKey: "Please correct the Zip Code and try again."])
            if silent {
                completion(result: nil, error: nil)
            } else {
                completion(result: nil, error: error)
            }
        }
        var zip = Int()
        var city = String()
        var zcounty = String()
        var tax = Double()
        var transit = Double()
        let path = NSBundle(forClass: self.dynamicType).pathForResource("NCZipCode", ofType: "plist")
        let pData = NSDictionary(contentsOfFile: path!)
        let dict = pData as! Dictionary<String, NSDictionary>
        for dict2 in dict {
            for (zc, data) in dict2.1 {
                if Int(zc as! String) == internalZip {
                    let data = data as! Dictionary<String, NSDictionary>
                    if data.count > 1 {
                        var buttonArray = [UIAlertAction]()
                        for (county, cInfo) in data {
                            let button = UIAlertAction(title: String(county), style: UIAlertActionStyle.Default, handler: { (action) in
                                let cInfo = cInfo as! Dictionary<String, AnyObject>
                                var trans = Double()
                                if cInfo["Transit"] == nil {
                                    trans = 0.00
                                } else {
                                    trans = Double(cInfo["Transit"]! as! NSNumber)
                                }
                                zip = self.internalZip
                                tax = Double(cInfo["Tax"]! as! NSNumber)
                                city = String(cInfo["City"]!)
                                transit = trans
                                zcounty = county
                                
                                let zc = NCZip(zip: zip, city: city, county: zcounty, tax: tax, transit: transit)
                                
                                let check = self.limitCheck(zcounty, objectTwo: self.internalLimits, checkType: "NSCountyCheck")
                                
                                if check.checkPass {
                                    completion(result: zc, error: nil)
                                } else {
                                    if self.returnZipIfFail {
                                        completion(result: zc, error: check.error)
                                    } else {
                                        if self.silent {
                                            completion(result: nil, error: nil)
                                        } else {
                                            completion(result: nil, error: check.error)
                                        }
                                    }
                                }
                            })
                            buttonArray.append(button)
                        }
                        self.presentAlert(title: "Which County?", message: "The zipcode \(internalZip) contains multiple counties, which are you in?", alertType: nil, buttons: buttonArray)
                    } else if data.count == 1 {
                        let info = data.values.first as! Dictionary<String, AnyObject>
                        var trans = Double()
                        if info["Transit"] == nil {
                            trans = 0.00
                        } else {
                            trans = Double(info["Transit"]! as! NSNumber)
                        }
                        zip = self.internalZip
                        tax = Double(info["Tax"]! as! NSNumber)
                        city = String(info["City"]!)
                        transit = trans
                        zcounty = data.keys.first!
                        
                        let zc = NCZip(zip: zip, city: city, county: zcounty, tax: tax, transit: transit)
                        
                        let check = self.limitCheck(zcounty, objectTwo: internalLimits, checkType: "NSCountyCheck")
                        
                        if check.checkPass {
                            completion(result: zc, error: nil)
                        } else {
                            if returnZipIfFail {
                                completion(result: zc, error: check.error)
                            } else {
                                if silent {
                                    completion(result: nil, error: nil)
                                } else {
                                    completion(result: nil, error: check.error)
                                }
                            }
                        }
                    } else {
                        let error = NSError(domain: NCZipErrorDomain, code: -99, userInfo: [NSLocalizedDescriptionKey: "Unknown Error", NSLocalizedRecoverySuggestionErrorKey: "Please try again."])
                        if silent {
                            completion(result: nil, error: nil)
                        } else {
                            completion(result: nil, error: error)
                        }
                    }
                }
            }
        }
    }
    
    // private
    private func limitCheck(objectOne: AnyObject, objectTwo: AnyObject, checkType: String) -> (checkPass:Bool, error: NSError?) {
        
        
    /* NEEDS RESTRUCTURING - FEATURES STRIPPED
     *
     * Check Types:
     *
     *  - NCCountyCheck :: Checks Counties
     *  - NCZipCheck    :: Checks NCZips
     *
     * !! Invaild NCxxx returns false
     *
     * Object One:
     *  - County (String)
     *  - Zipcode (Int)
     *
     * Object Two:
     *  - County Limits List (Array)
     *  - NCLimits (NCZip)
     */
        if internalLimits.isEmpty {
            return (true, nil)
        }
        
        if checkType == "NSCountyCheck" {
            let one = objectOne as! String
            let two = objectTwo as! Array<String>
            
            if two.contains(one) {
                return(true, nil)
            } else {
                let error = NSError(domain: NCZipErrorDomain, code: 101, userInfo: [NSLocalizedDescriptionKey: "Outside Radius Allowed", NSLocalizedFailureReasonErrorKey: "Failed County Check"])
                return (false, error)
            }
            
        } else {
            let error = NSError(domain: NCZipErrorDomain, code: -98, userInfo: [NSLocalizedDescriptionKey: "Unknown Check Type", NSLocalizedFailureReasonErrorKey: "Unknown Check Type, possible misspelling", NSLocalizedRecoverySuggestionErrorKey: "Code level error, please report to developer."])
            return (false, error)
        }
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        } 
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
