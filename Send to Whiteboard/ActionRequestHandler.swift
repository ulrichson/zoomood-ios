//
//  ActionRequestHandler.swift
//  Send to Whiteboard
//
//  Created by Ulrich Lehner on 30/10/2016.
//  Copyright © 2016 Ulrich Lehner. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    
    var extensionContext: NSExtensionContext?
    
    func beginRequest(with context: NSExtensionContext) {
        self.extensionContext = context
        
        // registerSettingsBundle()
        
        for item in context.inputItems as! [NSExtensionItem] {
            //print(item.debugDescription)
            if let attachments = item.attachments {
                for itemProvider in attachments as! [NSItemProvider] {
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                        itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: {(item, error) in
                            print("item loaded")
                            //                                print(item.debugDescription)
                            if let imageURL = item as? NSURL {
                                print("url found")
                                let imageData = NSData(contentsOf: imageURL as URL)
                                
                                // Send image to whiteboard
                                print("preparing image")
                                let params:[String: String] = [
                                    "image_base64": imageData!.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
                                ]
                                
                                print("image encoded to base64")
                                //Ulrichs-MacBook-Pro.local
                                var zoomoodUrl = URL(string: "http://192.168.0.13:3000/media")
                                
                                if let url = UserDefaults.init(suiteName: "group.com.ulrichlehner.zoomood")?.string(forKey: "api_url") {
                                    zoomoodUrl = URL(string: "http://" + url + "/media")
                                }
                                
                                var request = URLRequest(url: zoomoodUrl!)
                                
                                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                                request.httpMethod = "POST"
                                do {
                                    request.httpBody = try JSONSerialization.data(withJSONObject: params)
                                }
                                catch {
                                    print(error)
                                }
                                
                                let task = URLSession.shared.dataTask(with: request) {
                                    data, response, error in
                                    
                                    print("sending image")
                                    
                                    if let httpResponse = response as? HTTPURLResponse {
                                        if httpResponse.statusCode != 200 {
                                            print("response was not 200: \(response)")
                                            return
                                        }
                                    }
                                    if (error != nil) {
                                        print("error submitting request: \(error)")
                                        return
                                    }
                                    do {
                                        
                                        // handle the data of the successful response here
                                        let result = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                                        print(result!)
                                    }
                                    catch {
                                        print(error)
                                    }
                                }
                                task.resume()
                                
                            }
                        })
                    }
                }
            }
        }
        
        self.doneWithResults(nil)
    }
    
    func itemLoadCompletedWithPreprocessingResults(_ javaScriptPreprocessingResults: [String: Any]) {
        // Here, do something, potentially asynchronously, with the preprocessing
        // results.
        
        // In this very simple example, the JavaScript will have passed us the
        // current background color style, if there is one. We will construct a
        // dictionary to send back with a desired new background color style.
        let bgColor: Any? = javaScriptPreprocessingResults["currentBackgroundColor"]
        if bgColor == nil ||  bgColor! as! String == "" {
            // No specific background color? Request setting the background to red.
            self.doneWithResults(["newBackgroundColor": "red"])
        } else {
            // Specific background color is set? Request replacing it with green.
            self.doneWithResults(["newBackgroundColor": "green"])
        }
    }
    
    func doneWithResults(_ resultsForJavaScriptFinalizeArg: [String: Any]?) {
        if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
            // Construct an NSExtensionItem of the appropriate type to return our
            // results dictionary in.
            
            // These will be used as the arguments to the JavaScript finalize()
            // method.
            
            let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
            
            let resultsProvider = NSItemProvider(item: resultsDictionary as NSDictionary, typeIdentifier: String(kUTTypePropertyList))
            
            let resultsItem = NSExtensionItem()
            resultsItem.attachments = [resultsProvider]
            
            // Signal that we're complete, returning our results.
            self.extensionContext!.completeRequest(returningItems: [resultsItem], completionHandler: nil)
        } else {
            // We still need to signal that we're done even if we have nothing to
            // pass back.
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        // Don't hold on to this after we finished with it.
        self.extensionContext = nil
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
        //UserDefaults.init(suiteName: "group.com.ulrichlehner.zoomood")?.register(defaults: appDefaults)
    }
    
}
