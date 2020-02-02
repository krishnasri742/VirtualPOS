//
//  AppConfig.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit
import XCGLogger

class AppConfig: NSObject{
    
    static let _log = XCGLogger.default
    static let configPath = MAIN_BUNDLE.path(forResource: "AppConfig", ofType: "plist")!
    static let config = NSDictionary(contentsOfFile: configPath)
    static let defautQ = DispatchQueue.global(qos: .default)
    static let defaultMainQ = DispatchQueue.main
    static let backgroundQ = DispatchQueue.global(qos: .background)
    static let priorityQ = DispatchQueue.global(qos: .userInteractive)
    static var debugDate = Date()
    
    /**
     Fully qualified host name including port
     **/
    
    static func getServiceHostURL() -> String{
        return config!.object(forKey: "prodPortalUrl") as! String
    }
    static func getTransactionServiceHostURL() -> String{
        return config!.object(forKey: "prodTransactionUrl") as! String
    }
}

