//
//  LoginViewController.swift
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
import Alamofire

class LoginViewController: UIViewController {
    
    var mymanager = NetworkManager().mysessionmanager
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ipAddress: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipAddressLabel.text = ipAddress
        ipAddressLabel.text = defaults.string(forKey: "clusterIP")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //LoginButton
    //Upon successful credential entry, starts a session with the specified cluster
    @IBAction func loginButton(_ sender: Any) {
        if (usernameTextField.text == "") || (passwordTextField.text == "") {
            let alertController = UIAlertController(title: "Error", message:
                "Please enter a valid username and password combination", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            
        let authURL = "https://\(ipAddressLabel.text!)/api/system/v1/auth/login"
        
        self.defaults.set(usernameTextField.text, forKey: "cluster_username")
        self.defaults.set(passwordTextField.text, forKey: "cluster_password")
            
        let cluster_username = defaults.string(forKey: "cluster_username")
        let cluster_password = defaults.string(forKey: "cluster_password")
            
            var headers: HTTPHeaders = [:]
            if let authorizationHeader = Request.authorizationHeader(user: cluster_username!, password: cluster_password!) {
                headers[authorizationHeader.key] = authorizationHeader.value
            }
            mymanager.request(authURL, headers: headers).validate().authenticate(user: cluster_username!, password: cluster_password!).responseString
            { response in
                debugPrint(response)
                switch response.result {
                case .success:
                    self.performSegue(withIdentifier: "showTabController", sender: self)
                case .failure(let error):
                    let alertController = UIAlertController(title: "Error", message:
                        error.localizedDescription , preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
             }
           }
        }
    }
}

