//
//  Application.swift
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
//  Representation of an application installed on the iOS device
//  Allows installing from manifests (using itms-service) and
//  allows progress reporting from that process
//
//  Assumptions made:
//  1) The code is not App Store compatible, as it uses private
//     parts of MobileCoreServices.framework
//  2) The manifest is assumed to be valid (including the metadata)
//
//  Created by Henri Normak on 25/08/15.
//  Copyright (c) 2015 Testlio. All rights reserved.
//

import Foundation
import UIKit

let ApplicationErrorDomain = "application.proxy.error"

class Application: NSObject {
    private var proxies = [LSApplicationProxy]()
    
    private var bundleVersion: String?
    private let bundleIdentifier: String
    private var manifestURL: NSURL?
    
    private var internalProgress: NSProgress?
    private var installationProgress: NSProgress?
    private var installationCompletion: ((Bool, NSError?) -> Void)?
    
    private var installationCheckingTimer: NSTimer?
        
    var version: String? {
        get {
            return self.bundleVersion ?? self.proxies.first?.bundleVersion
        }
    }
    
    var isInstallable: Bool {
        get {
            return self.manifestURL != nil
        }
    }
    
    var isInstalled: Bool {
        get {
            let count = self.proxies.filter({ $0.isInstalled }).count
            return count > 0 && count == self.proxies.count
        }
    }
    
    var isPlaceholder: Bool {
        get {
            return self.proxies.filter({ $0.isPlaceholder }).count > 0
        }
    }
    
    private var itmsURL: NSURL? {
        get {
            if let URLString = self.manifestURL?.absoluteString {
                let escapedString = CFURLCreateStringByAddingPercentEscapes(nil, URLString, nil, "/%&=?$#+-~@<>|\\*,.()[]{}^!", CFStringBuiltInEncodings.UTF8.rawValue)
                return NSURL(string: "itms-services://?action=download-manifest&url=\(escapedString)")
            }
            
            return nil
        }
    }
    
    ///
    /// Create a local representation of an application based on its bundle identifier
    ///
    init(bundleIdentifier: String, manifestURL: NSURL? = nil) {
        self.bundleIdentifier = bundleIdentifier
        self.manifestURL = manifestURL
        super.init()
        
        self.reloadProxies()
    }
    
    ///
    /// Create an application that not only refers to local applications, but also allows installation from
    /// a manifest online (using itms-service, so normal requirements apply)
    ///
    static func createApplication(manifestURL manifestURL: NSURL, completion: ((Application?, ErrorType?) -> Void)) {
        let request = NSURLRequest(URL: manifestURL)
        self.createApplication(manifestRequest: request, completion: completion)
    }
    
    ///
    /// Create an application that not only refers to local applications, but also allows installation from
    /// a manifest online (using itms-service, so normal requirements apply)
    ///
    static func createApplication(manifestRequest manifestRequest: NSURLRequest, completion: ((Application?, ErrorType?) -> Void)) {
        if let URL = manifestRequest.URL {
            // Fetch the manifest (we get our bundle identifier from there)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(manifestRequest) { data, response, error in
                if let data = data {
                    do {
                        let plist = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil)
                        
                        
                        if let dict = plist as? [String: AnyObject], items = dict["items"] as? [[String: AnyObject]], metadata = items.first?["metadata"] as? [String: String] {
                            let application = Application(bundleIdentifier: metadata["bundle-identifier"]!, manifestURL: URL)
                            application.bundleVersion = metadata["bundle-version"]
                            
                            completion(application, nil)
                        } else {
                            completion(nil, error)
                        }
                    } catch let err {
                        completion(nil, err)
                    }
                } else {
                    completion(nil, nil)
                }
            }
            
            task.resume()
        } else {
            completion(nil, nil)
        }
    }
    
    // MARK: Actions
    
    ///
    /// Possible error codes
    ///
    enum InstallError: Int {
        case UserCancelled
        case Internal
    }
    
    ///
    /// Install the application
    /// This is only applicable for applications created with a manifest URL
    ///
    /// - parameter completion:  Block to be executed when the installation finishes (either fails or succeeds)
    /// - returns: Progress for the installation
    ///
    func install(completion: ((Bool, NSError?) -> Void)?) -> NSProgress? {
        if let progress = self.installationProgress {
            return progress
        }

        if !self.isInstallable {
            return nil
        }
        
        // First step is to start the installation via itms-service
        // If this can not be done, fail immediately
        if let itmsURL = self.itmsURL where UIApplication.sharedApplication().canOpenURL(itmsURL) {
            // We can now start the actual installation process
            let progress = NSProgress(totalUnitCount: 101)
            
            self.installationProgress = progress
            self.installationCompletion = { success, error in
                self    // Capture ourselves so we won't be released during installation
                completion?(success, error)
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "startMonitoring", name: UIApplicationDidBecomeActiveNotification, object: nil)
            UIApplication.sharedApplication().openURL(itmsURL)
            
            return progress
        } else {
            return nil
        }
    }
    
    ///
    /// Launch the application
    ///
    /// - returns: True if launching was possible (does not guarantee the application was actually launched)
    ///
    func launch() -> Bool {
        let workspace = LSApplicationWorkspace.defaultWorkspace() as! LSApplicationWorkspace
        return workspace.openApplicationWithBundleID(self.bundleIdentifier)
    }
    
    // MARK: Notifications
    
    @objc private func startMonitoring() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // We should now be a placeholder, if not, the user likely cancelled the operation
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.reloadProxies()

            if self.isPlaceholder {
                let workspace = LSApplicationWorkspace.defaultWorkspace() as! LSApplicationWorkspace
                if let progress = workspace.installProgressForBundleID(self.bundleIdentifier, makeSynchronous: 1) as? NSProgress {
                    self.internalProgress = progress
                    progress.addObserver(self, forKeyPath: "fractionCompleted", options: .Initial, context: nil)
                }
            } else {
                self.failInstallationWithError(.UserCancelled)
            }
        }
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "fractionCompleted" {
            if let progress = self.installationProgress, other = object as? NSProgress {
                progress.completedUnitCount = other.completedUnitCount
                
                self.installationCheckingTimer?.invalidate()
                self.installationCheckingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "checkIfFinishedInstallation", userInfo: nil, repeats: true)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: Helpers
    
    @objc private func checkIfFinishedInstallation() {
        self.reloadProxies()
        
        if self.isInstalled {
            self.installationCheckingTimer?.invalidate()
            self.finishInstallation()
        } else if !self.isPlaceholder {
            self.installationCheckingTimer?.invalidate()
            self.failInstallationWithError(.Internal)
        }
    }
    
    private func reloadProxies() {
        let workspace = LSApplicationWorkspace.defaultWorkspace() as! LSApplicationWorkspace
        self.proxies = (workspace.allApplications() as! [LSApplicationProxy]).filter({ $0.applicationIdentifier == self.bundleIdentifier })
    }
    
    private func failInstallationWithError(error: InstallError) {
        let info = [NSLocalizedDescriptionKey: error.description]
        let error = NSError(domain: ApplicationErrorDomain, code: error.rawValue, userInfo: info)
        
        self.installationCompletion?(false, error)
        self.cleanup()
    }
    
    private func finishInstallation() {
        self.installationCompletion?(true, nil)
        self.cleanup()
    }
    
    private func cleanup() {
        self.installationCompletion = nil
        self.installationProgress = nil
    }
}

//
//  Convenience extensions for the error code
//

extension Application.InstallError: CustomStringConvertible {
    var description: String {
        get {
            switch self {
            case .UserCancelled:
                return "User cancelled"
            case .Internal:
                return "Internal error"
            }
        }
    }
}

func ==(lhs: Application.InstallError, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}

func ==(lhs: Int, rhs: Application.InstallError) -> Bool {
    return lhs == rhs.rawValue
}
