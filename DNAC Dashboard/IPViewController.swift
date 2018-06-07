//  IPViewController.swift
//  DNAC Dashboard
//
//  Copyright (c) 2018 Cisco and/or its affiliates.
//
//  This software is licensed to you under the terms of the Cisco Sample
//  Code License, Version 1.0 (the "License"). You may obtain a copy of the
//  License at
//
//  https://developer.cisco.com/docs/licenses
//
//  All use of the material herein must be in accordance with the terms of
//  the License. All rights not expressly granted by the License are
//  reserved. Unless required by applicable law or agreed to separately in
//  writing, software distributed under the License is distributed on an "AS
//  IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
//  or implied.
//
//  Created by agohel on 6/1/18.
//  Copyright © 2018 agohel. All rights reserved.
//

import UIKit

class IPViewController: UIViewController {
    
    @IBOutlet weak var clusterIPTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Checks whether the IP Address text field is empty,
    //else, stores the cluster IP into User Defaults for global access
    //and loads the login screen.
    @IBAction func advanceToLogin(_ sender: Any) {
        if clusterIPTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message:
                "Please enter a cluster IP Value", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            self.defaults.set(self.clusterIPTextField.text, forKey:"clusterIP")
            performSegue(withIdentifier: "showLoginVC", sender: self)
        }
    }
    
    //Takes the current IP address and carries it through to the
    //destination segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoginViewController {
            destination.ipAddress = clusterIPTextField.text!
        }
    }
}
