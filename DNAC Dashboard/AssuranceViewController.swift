//
//  AssuranceViewController.swift
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
import Foundation
import Alamofire
import Charts

class AssuranceViewController: UIViewController, ChartViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var mymanager = NetworkManager().mysessionmanager
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var networkHealthScoreLabel: UILabel!
    @IBOutlet weak var clientHealthLabel: UILabel!
    @IBOutlet weak var sitePickerView: UIPickerView!
    @IBOutlet weak var siteTypeValue: UILabel!
    @IBOutlet weak var overallNetworkDeviceHealth: UILabel!
    @IBOutlet weak var horizontalBarChartView: HorizontalBarChartView!
    
    var siteHierarchyChartEntry: [String:[String:Int]] = [:]
    var siteHierarchyData = [SiteHierarchyData]()
    var networkHealthData = [NetworkHealth]()
    
    //Grabs EPOC Unix time
    let starttime = Int(NSDate().timeIntervalSince1970-24*60*60)*1000
    let endtime = Int(NSDate().timeIntervalSince1970-15*60)*1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sitePickerView.dataSource = self
        sitePickerView.delegate = self
        getNetworkHealthInformation()
        getClientHealthInformation()
        getSiteHierarchy()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Gets network health of the network
    func getNetworkHealthInformation() {

        let headers: HTTPHeaders = [
            "Content-Type":"application/x-www-form-urlencoded",
            "__runsync": "true"
        ]
        let parameters: Parameters = [
            "startTime":starttime,
            "endTime":endtime
        ]
        let networkHealthURL = "https://\(defaults.string(forKey: "clusterIP")!)/dna/intent/api/v1/network-health"
        mymanager.request(networkHealthURL, parameters:parameters, headers:headers).validate().responseJSON
            { response in
                debugPrint(response)
                if let result = response.result.value {
                    let JSON = result as! Dictionary<String, Any>
                    let jsonData = JSON["response"] as! [String:Any]
                    let healthDistribution = jsonData["healthDistirubution"] as! [[String:Any]]
                    
                    for data in healthDistribution {
                        let category = data["category"] as! String
                        let totalCount = data["totalCount"] as! Int
                        let healthScore = data["healthScore"] as! Int
                        self.siteHierarchyChartEntry[category] = ["totalCount":totalCount, "healthScore":healthScore]
                        self.drawMarginChart(input: self.siteHierarchyChartEntry)
                    }
                    
                
                    let latestHealthScore = jsonData["latestHealthScore"] as! Int
                    self.networkHealthScoreLabel.text = String(latestHealthScore) + "%"
                    if 60...100 ~= latestHealthScore {
                        self.networkHealthScoreLabel.textColor = UIColor.green
                    }
                    if 30...60 ~= latestHealthScore {
                        self.networkHealthScoreLabel.textColor = UIColor.orange
                    }
                    if 0...30 ~= latestHealthScore {
                        self.networkHealthScoreLabel.textColor = UIColor.red
                    }
                }
        }
    }
    
    //Gets the overall value for client health
    func getClientHealthInformation() {
        
        //Specify header to run synchronously...
        let headers: HTTPHeaders = [
            "Content-Type":"application/x-www-form-urlencoded",
            "__runsync": "true"
        ]
        //Specify start and end time as parameter payload
        let parameters: Parameters = [
            "startTime":starttime,
            "endTime":endtime
        ]
        var clientHealthScore: Int = 0
        let clientHealthURL = "https://\(defaults.string(forKey: "clusterIP")!)/dna/intent/api/v1/client-health"
        
        mymanager.request(clientHealthURL, parameters:parameters, headers:headers).validate().responseJSON
            { response in
                debugPrint(response)
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    let jsonData = JSON["response"] as! [[String:Any]]
          
                    for data in jsonData {
                        let scoreDetail = data["scoreDetail"] as! [[String:Any]]
                        for scoreData in scoreDetail {
                            let scoreCategory = scoreData["scoreCategory"] as! [String: Any]
                            let value = scoreCategory["value"] as! String
                            if value == "ALL" {
                                clientHealthScore = scoreData["scoreValue"] as! Int
                            }
                        }
                    }
                    self.clientHealthLabel.text = String(clientHealthScore) + "%"
                    if 60...100 ~= clientHealthScore { //>60 - green
                        self.clientHealthLabel.textColor = UIColor.green
                    }
                    if 30...60 ~= clientHealthScore { //30..60
                        self.clientHealthLabel.textColor = UIColor.orange
                    }
                    if 0...30 ~= clientHealthScore { //0...30
                        self.clientHealthLabel.textColor = UIColor.red
                    }
                }
        }
    }
    
    //Grabs the overall site hierarchy based on the times specified in
    //starttime. Starttime is given in EPOCH (milliseconds)
    func getSiteHierarchy(){
        
        //Specify header to run synchronously...
        let headers: HTTPHeaders = [
            "Content-Type":"application/x-www-form-urlencoded",
            "__runsync":"true"
        ]
        //Specify start time as parameter payload
        let parameters: Parameters = [
            "timestamp":starttime
        ]
        let siteHierarchyURL = "https://\(defaults.string(forKey: "clusterIP")!)/dna/intent/api/v1/site-hierarchy"
        mymanager.request(siteHierarchyURL, parameters: parameters, headers: headers).validate().responseJSON{ response in
            debugPrint(response)
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                let JSONData = JSON["response"] as! [[String: Any]]
                
                for data in JSONData {
                    if let sitename = data["siteName"] {
                        let siteType = data["siteType"]
                        let healthyNetworkDevicePercentage = data["healthyNetworkDevicePercentage"]
                        let siteHierarchyDataEntry = SiteHierarchyData(healthyNetworkDevicePercentage: healthyNetworkDevicePercentage as! Int, siteName: sitename as! String, siteType: siteType as! String)
                        self.siteHierarchyData.append(siteHierarchyDataEntry)
                    }
                    self.sitePickerView.reloadAllComponents()
                }
            }
        }
    }
    
    // <--- UI Picker View --->
    
    //This UIPickerView will dynamically updated based on the number of sites found
    //in your network. Upon getting them, it will also grab the health of the network device
    //and display that alongside the type of the site e.g "building" or "area".
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return siteHierarchyData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let selectedSiteName = siteHierarchyData[row].siteName
        for data in siteHierarchyData {
            if data.siteName == selectedSiteName {
                siteTypeValue.text = data.siteType
                if 60...100 ~= data.healthyNetworkDevicePercentage { //>60 - green
                    self.overallNetworkDeviceHealth.textColor = UIColor.green
                }
                if 30...60 ~= data.healthyNetworkDevicePercentage { //30..60
                    self.overallNetworkDeviceHealth.textColor = UIColor.orange
                }
                if 0...30 ~= data.healthyNetworkDevicePercentage { //0...30
                    self.overallNetworkDeviceHealth.textColor = UIColor.red
                }
                
                overallNetworkDeviceHealth.text = "\(data.healthyNetworkDevicePercentage)" + "%"
            }
        }
        return selectedSiteName
    }
    
    //This method draws the horizontal bar graph shown on the
    //assurance tab
    func drawMarginChart(input: [String:[String: Int]]) {
        
        var category: [String] = []
        var healthscore: [Double] = []

        for networkHealth in input {
            category.append(networkHealth.key)
            let stats = networkHealth.value
            for values in stats {
                if values.key == "healthScore" {
                    healthscore.append(Double(values.value))
                }
            }
        }
        var dataEntries = [ChartDataEntry]()
        
        for i in 0..<healthscore.count {
            let entry = BarChartDataEntry(x: Double(i), y: Double(healthscore[i]))
            dataEntries.append(entry)
        }
        let barChartDataSet = BarChartDataSet(values: dataEntries, label: "")
        barChartDataSet.drawValuesEnabled = false
        
        barChartDataSet.colors = ChartColorTemplates.joyful()

        let barChartData = BarChartData(dataSet: barChartDataSet)
        horizontalBarChartView.data = barChartData
        horizontalBarChartView.legend.enabled = false

        horizontalBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: category)
        horizontalBarChartView.xAxis.granularityEnabled = true
        horizontalBarChartView.xAxis.granularity = 1

        horizontalBarChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInOutBounce)

        horizontalBarChartView.chartDescription?.text = ""

        horizontalBarChartView.zoom(scaleX: 0.5, scaleY: 0.5, x: 0, y: 0)

        self.horizontalBarChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom

        let rightAxis = horizontalBarChartView.rightAxis
        rightAxis.drawGridLinesEnabled = false

        let leftAxis = horizontalBarChartView.leftAxis
        leftAxis.drawGridLinesEnabled = false

        let xAxis = horizontalBarChartView.xAxis
        xAxis.drawGridLinesEnabled = false
        horizontalBarChartView.setVisibleXRange(minXRange: 10.0, maxXRange: 10.0)

        horizontalBarChartView.setExtraOffsets (left: 0, top: 20.0, right:0.0, bottom: 20.0)
    }
    
    //Refresh Button - enables the user to refresh the data shown
    //on the Assurance screen.
    @IBAction func refreshData(_ sender: Any) {
        getNetworkHealthInformation()
        getClientHealthInformation()
        getSiteHierarchy()
    }

}
