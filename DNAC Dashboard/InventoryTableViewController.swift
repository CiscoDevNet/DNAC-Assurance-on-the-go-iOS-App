//
//  InventoryTableViewController.swift
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

class InventoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var inventoryData = InventoryViewController()
    var deviceinventoryInfo = [DeviceInvetoryInfo]()
    
    var inventoryInformation: [String: [String:String]] = [:]
    
    let defaults = UserDefaults.standard
    let mymanager = NetworkManager.init().mysessionmanager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadDeviceInventory()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Loads all of the network devices found within the cluster
    //and presents them within a list view showing whether they are in a
    //"Reachable" or "Unreachable"
    func loadDeviceInventory(){
    
        let networkDevices = "https://\(defaults.string(forKey: "clusterIP")!)/api/v1/network-device"
        
        mymanager.request(networkDevices).validate().responseJSON{ response in
            debugPrint(response)
            switch response.result {
            case .success:
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    let JSONData = JSON["response"] as! [[String: Any]]
                    for inventoryInfo in JSONData {
                        
                        let hostname = inventoryInfo["hostname"]!
                        let family = inventoryInfo["family"]
                        let deviceID = inventoryInfo["instanceUuid"]!
                        let ipAddress = inventoryInfo["managementIpAddress"]!
                        let reachabilityStatus = inventoryInfo["reachabilityStatus"]!
                        let deviceArray = DeviceInvetoryInfo(hostname: hostname as! String, family: family as! String, deviceID: deviceID as! String, ipAddress: ipAddress as! String, deviceReachabilityStatus: reachabilityStatus as! String)
                        self.deviceinventoryInfo.append(deviceArray)
                    }
                    self.tableView.reloadData()
                }
            case .failure(let error):
                
                let alertController = UIAlertController(title: "Error", message:
                    error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    //Delgate methods for setting up table view...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceinventoryInfo.count
    }
    
    //gets triggered to find content for a tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let deviceInventoryInformation = deviceinventoryInfo[indexPath.row]
        cell?.textLabel?.text = deviceInventoryInformation.hostname
        
        cell?.detailTextLabel?.text = deviceInventoryInformation.deviceReachabilityStatus
        
        if cell?.detailTextLabel?.text == "Reachable" {
            cell?.detailTextLabel?.textColor = UIColor.green
        } else {
            cell?.detailTextLabel?.textColor = UIColor.red
        }
        return cell!
    }

}
