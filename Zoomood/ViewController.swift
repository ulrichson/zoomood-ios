//
//  ViewController.swift
//  Zoomood
//
//  Created by Ulrich Lehner on 30/10/2016.
//  Copyright © 2016 Ulrich Lehner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textFieldApiUrl: UITextField!
    @IBOutlet weak var labelUserDefaults: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let apiUrl = UserDefaults.init(suiteName: "group.com.ulrichlehner.zoomood")?.string(forKey: "api_url")  {
            //if apiUrl != nil {
            print(apiUrl)
            labelUserDefaults.text = apiUrl
            //}
        } else {
            labelUserDefaults.text = "[not set]"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setApiUrl(_ sender: Any) {
        let apiUrl = textFieldApiUrl.text!
        UserDefaults.init(suiteName: "group.com.ulrichlehner.zoomood")?.set(apiUrl, forKey: "api_url")
        labelUserDefaults.text = apiUrl
    }

}

