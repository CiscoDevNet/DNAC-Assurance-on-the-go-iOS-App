//
//  NetworkManager.swift
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

import Foundation
import Alamofire

class NetworkManager {
    //This network manager enables the user to bypass certificates, for now...
    let mysessionmanager: Alamofire.SessionManager = {
        let defaults = UserDefaults.standard
        let cluster_ip = defaults.string(forKey: "clusterIP")
        let serverTrustPolicies: [String: ServerTrustPolicy] = [cluster_ip!: .disableEvaluation]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        return Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
}
