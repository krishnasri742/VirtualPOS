//
//  BaseService.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 26/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import XCGLogger

class BaseService {
    
    let _log = AppConfig._log
    
    func reqHeader () -> HTTPHeaders {
        let parameters:HTTPHeaders = [
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo1LCJpYXQiOjE1Nzc0Mjg4MzUsImV4cCI6MTU3NzUxNTIzNX0.IXX02aZ2oziSeJTeosWvRI2vzUZdp257QUp5UFd50yY",
        ];
        return parameters
    }
    
    func reqEncodedHeaderWithToken(_ token:String) -> HTTPHeaders {
        let parameters:HTTPHeaders = [
            "Authorization": "Bearer \(token)",
        ];
        return parameters
    }
    
    func reqHeaderWithToken() -> HTTPHeaders {
        let parameters:HTTPHeaders = [
            //            "Authorization": "SELVERA \((CoreDataHelper.shared.fetchUser()?.token) ?? "")"
            :];
        return parameters
    }
    
    func getServiceHostURL() -> String {
        return AppConfig.getServiceHostURL()
    }
    
    var className: String {
        return String(describing: self)
    }
    
    func createParametersForGetMethod(_ parametersDict:[String:Any]) -> String{
        var queryString = "?"
        for (key, value) in parametersDict {
            queryString = "\(queryString)\(key)=\(value)&"
        }
        if queryString.count == 1{
            return ""
        }
        else{
            let query = queryString.dropLast()
            let escapedString = query.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
            return escapedString!
        }
    }
    
    //    func logoutForUnauthorizedAccess(){
    //        DispatchQueue.main.async {
    //            kAppDelegate.pushSignInScreen()
    //        }
    //        CommonFunctions.deleteAllUserData()
    //    }
}
