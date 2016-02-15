//
//  ViewController.swift
//  Example
//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Testlio, Inc.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//
//  Created by Henri Normak on 27/08/15.
//  Copyright (c) 2015 Testlio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var progressIndicator: UIProgressView!
    
    private var application: Application!
    private var progress: NSProgress?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actionButton.titleLabel?.font = .boldSystemFontOfSize(12.0)
        self.actionButton.setOutlinedBackground(1.0, cornerOffset: UIOffset(horizontal: 4.0, vertical: 4.0))
        
        // METHOD 1: Dynamic bundle identifier (for cases when you don't know what it is, but have the manifest)
        // Fill in with your manifest, you can see an example of a manifest in this project
        // (look for manifest.plist)
//        let manifestURL: NSURL = 
//        
//        Application.createApplication(manifestURL: manifestURL) { (app, error) -> Void in
//            dispatch_async(dispatch_get_main_queue()) {
//                if let app = app {
//                    self.application = app
//                    self.actionButton.enabled = true
//                } else if let error = error {
//                    self.displayError(error)
//                }
//            }
//        }
        
        // METHOD 2: You know the bundle identifier, and optionally where it is 
        // (if not, then can't be installed, but can still be opened)
        let bundleIdentifier = "com.apple.Preferences"
        self.application = Application(bundleIdentifier: bundleIdentifier)
        self.actionButton.enabled = true
    }
    
    // MARK: Actions
    
    @IBAction func handleAction() {
        if !self.application.launch() {
            self.progress = self.application.install({ success, error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.progress?.removeObserver(self, forKeyPath: "fractionCompleted")

                    if success {
                        self.actionButton.setTitle("OPENING...", forState: .Normal)
                        self.actionButton.sizeToFit()
                        
                        // Try opening the app again (with a small delay so that the UI can change and user notices
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            self.application.launch()
                            self.actionButton.setTitle("OPEN", forState: .Normal)
                            self.actionButton.sizeToFit()
                            self.progressIndicator.hidden = true
                            self.actionButton.enabled = true
                        }
                    } else {
                        if let error = error {
                            self.displayError(error)
                        }
                        
                        self.actionButton.setTitle("OPEN", forState: .Normal)
                        self.actionButton.sizeToFit()
                        self.progressIndicator.hidden = true
                        self.actionButton.enabled = true
                    }
                }
            })
            
            if let progress = self.progress {
                self.actionButton.enabled = false
                self.actionButton.setTitle("INSTALLING...", forState: .Normal)
                self.actionButton.sizeToFit()
                self.progressIndicator.hidden = false

                progress.addObserver(self, forKeyPath: "fractionCompleted", options: .Initial, context: nil)
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to start installation, this demo does not work in the simulator"])
                self.displayError(error)
            }
        }
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "fractionCompleted" {
            dispatch_async(dispatch_get_main_queue()) {
                self.progressIndicator.progress = Float(self.progress!.fractionCompleted)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: Helpers
    
    private func displayError(error: ErrorType) {
        if let printable = error as? CustomStringConvertible {
            let alert = UIAlertController(title: "Failed", message: printable.description, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let typedError = error as NSError
            let alert = UIAlertController(title: "Failed", message: typedError.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

