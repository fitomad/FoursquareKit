//
//  FoursquareConfig.swift
//  Sharing
//
//  Created by Adolfo Vera Blasco on 11/1/17.
//  Copyright © 2017 Adolfo Vera Blasco. All rights reserved.
//

import Foundation

internal struct FoursquareConfig
{
    ///
    internal private(set) var baseURL: String
    ///
    internal private(set) var apiVersion: String
    ///
    internal private(set) var apiLocale: String
    ///
    internal private(set) var clientID: String
    ///
    internal private(set) var clientSecret: String
    
    /**
 
    */
    internal init()
    {
        self.baseURL = "https://api.foursquare.com/v2"
        self.apiVersion = "20170101"
        
        self.clientID = ""
        self.clientSecret = ""

        self.apiLocale = NSLocale.current.languageCode!
    }
}
