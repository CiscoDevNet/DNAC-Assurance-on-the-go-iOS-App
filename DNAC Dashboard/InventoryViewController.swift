//
//  FirstViewController.swift
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
import Charts

class InventoryViewController: UIViewController, ChartViewDelegate {

    var mymanager = NetworkManager().mysessionmanager
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var pieChartView: PieChartView!

    var inventoryInformation: [String: [String:String]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self
        getDeviceFamilyCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Grabs the device family count using the network-device API
    //then calculates the total count for each type of device family and
    //constructs a dictionary of each family and their total count.
    func getDeviceFamilyCount() {
        
        var unifiedAPCount: Double = 0
        var switchesHubsCount: Double = 0
        var wirelessControllerCount: Double = 0
        var routerCount: Double = 0
        
        var totalCount: [String: [String: Double]] = [:]
        
        let networkDevices = "https://\(defaults.string(forKey: "clusterIP")!)/api/v1/network-device"
        
        mymanager.request(networkDevices).validate().responseJSON { response in
            debugPrint(response)
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                let JSONData = JSON["response"] as! [[String: Any]]
                
                for devices in JSONData {
                    if devices["family"] as! String != "" {
                        if devices["family"] as! String == "Unified AP" {
                            unifiedAPCount += 1
                        }
                        if devices["family"] as! String == "Switches and Hubs" {
                            switchesHubsCount += 1
                        }
                        if devices["family"] as! String == "Wireless Controller" {
                            wirelessControllerCount += 1
                        }
                        if devices["family"] as! String == "Routers" {
                            routerCount += 1
                        }
                    }
                }
                totalCount["totalcount"] = ["AP":unifiedAPCount, "Switches and Hubs":switchesHubsCount, "Wireless Controllers":wirelessControllerCount, "Routers":routerCount]
                self.getUpdate(input: totalCount)
            }
        }
    }
    
    //Constructs the pie chart of Inventory data!
    func getUpdate(input: [String: [String: Double]]){
    
        let totalcount = input["totalcount"]
        var deviceFamilies: [String] = []
        var deviceFamilyCount: [Double] = []
        
        for (key, value) in totalcount! {
            deviceFamilies.append(key)
            deviceFamilyCount.append(value)
        }
 
        var entries = [PieChartDataEntry]()
        
        for (index, value) in deviceFamilyCount.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = deviceFamilies[index]
            entries.append(entry)
        }
        
        let set = PieChartDataSet(values: entries, label: "Device Family")
        var colors: [UIColor] = []
        
        for _ in 0..<deviceFamilyCount.count {
            colors.append(UIColor.purple)
            colors.append(UIColor.green)
            colors.append(UIColor.blue)
            colors.append(UIColor.orange)
        }
        set.colors = colors
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        set.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        set.highlightEnabled = false
        set.valueTextColor = UIColor.black
        let pieChartData = PieChartData(dataSet: set)
        pieChartView.data = pieChartData
        pieChartView.noDataText = "Inventory data"
        
        // user interaction
        pieChartView.rotationEnabled = true
        pieChartView.chartDescription?.text = ""
        pieChartView.centerText = "Inventory"
        pieChartView.holeRadiusPercent = 0.3
        pieChartView.transparentCircleColor = UIColor.clear
        self.view.addSubview(pieChartView)
    }
    
    func getInventoryInformation(completionHandler: @escaping ([String:[String:String]]) -> ()) {
        getDeviceInventoryInformation(completionHandler: completionHandler)
    }

    //gets information related to each device in the network
    func getDeviceInventoryInformation(completionHandler: @escaping ([String:[String:String]]) -> ())  {
        
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
                        self.inventoryInformation[hostname as! String] = ["family":family as! String,"deviceID": deviceID as! String, "ipAddress":ipAddress as! String, "reachabilityStatus":reachabilityStatus as! String]
                        completionHandler(self.inventoryInformation)
                    }
                }
            case .failure(let error):
                //returns an error message if it's unable to load the number of network devices
                let alertController = UIAlertController(title: "Error", message:
                error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if chartView == pieChartView {
            performSegue(withIdentifier: "InventoryDeepView" , sender: self)
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
        mymanager.session.invalidateAndCancel()
        let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }

    
}

