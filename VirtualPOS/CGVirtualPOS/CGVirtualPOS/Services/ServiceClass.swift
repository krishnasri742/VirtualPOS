//
//  ServiceClass.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 26/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit
import ObjectMapper
import XCGLogger

class ServiceClass: BaseService {
    
    let loginEndPoint: String = "\(AppConfig.getServiceHostURL())login"
    let userInfoEndPoint: String = "\(AppConfig.getServiceHostURL())userinfo"
    let terminalListEndPoint: String = "\(AppConfig.getServiceHostURL())vterminallist"
    let changePswdEndPoint: String = "\(AppConfig.getServiceHostURL())updatepwd"
    let transactionListEndPoint: String = "\(AppConfig.getServiceHostURL())trans"
    let transactionValueEndPoint: String = "\(AppConfig.getServiceHostURL())transValues"
    let inVoiceListEndPoint: String = "\(AppConfig.getServiceHostURL())invoicelist"
    let inVoiceEndPoint: String = "\(AppConfig.getServiceHostURL())invoice"
    let refundEndPoint: String = "\(AppConfig.getServiceHostURL())refund"
    let sendEmailEndPoint: String = "\(AppConfig.getServiceHostURL())sendemail/"
    let merchantTokenEndPoint: String = "\(AppConfig.getServiceHostURL())getmerchanttoken"
    let paymentEndPoint: String = "\(AppConfig.getTransactionServiceHostURL())"
    
    // Login User
    func postLoginEndPoint(_ dict: [String:Any]) -> Promise<String> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.loginEndPoint) Param \(dict)")
            
            Alamofire.request(self.loginEndPoint, method: .post, parameters: dict,encoding: JSONEncoding.default, headers: HTTPHeaders()).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(){
                        fullfill(jsonString)
                    }
                    else{
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Get User Info
    func getUserInfoEndPoint(token:String) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.userInfoEndPoint)")
            
            Alamofire.request(self.userInfoEndPoint, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    func getMerchantTokenEndPoint(token:String) -> Promise<String> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.merchantTokenEndPoint)")
            
            Alamofire.request(self.merchantTokenEndPoint, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(){
                        fullfill(jsonString)
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    
    
    // Get Terminal List
    func getTerminalListEndPoint(token:String) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.terminalListEndPoint)")
            
            Alamofire.request(self.terminalListEndPoint, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Change Password
    func changePasswordEndPoint(_ dict: [String:Any],token:String) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.changePswdEndPoint) Param \(dict)")
            
            Alamofire.request(self.changePswdEndPoint, method: .post, parameters: dict,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Get Transaction List
    func getTransactionListEndPoint(token:String,param:[String:Any]) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.transactionListEndPoint)")
            
            Alamofire.request(self.transactionListEndPoint, method: .get, parameters: param,encoding: URLEncoding.queryString, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Get Transaction List
    func getTransValueEndPoint(token:String) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.transactionValueEndPoint)")
            
            Alamofire.request(self.transactionValueEndPoint, method: .get, parameters: nil,encoding: URLEncoding.queryString, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Get Terminal List
    func getInVoiceListEndPoint(token:String) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.inVoiceListEndPoint)")
            
            Alamofire.request(self.inVoiceListEndPoint, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Create Invoice User
    func postCreateInvoiceEndPoint(_ dict: [String:Any],tkn:String) -> Promise<LoginModel> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.inVoiceEndPoint) Param \(dict)")
            
            Alamofire.request(self.inVoiceEndPoint, method: .post, parameters: dict,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(tkn)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(),
                        let userReponseModel = Mapper<LoginModel>().map(JSONString: jsonString){
                        self._log.debug("response :\(jsonString)")
                        if let errorData = userReponseModel.error{
                            reject(NSError(domain: "AuthService",code:errorData.errorCode ?? 0,userInfo: [ErrorMessageKey:errorData.responseMessage ?? NotParsable]))
                        }
                        else{
                            fullfill(userReponseModel)
                        }
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Create Invoice User
    func postPaymentFirstStepEndPoint(_ dict: [String:Any]) -> Promise<String> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.paymentEndPoint) Param \(dict)")
            
            Alamofire.request(self.paymentEndPoint, method: .post, parameters: dict,encoding: JSONEncoding.default, headers: HTTPHeaders()).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(){
                        fullfill(jsonString)
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Refund User
    func postRefundEndPoint(_ dict: [String:Any]) -> Promise<String> {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(self.paymentEndPoint) Param \(dict)")
            
            Alamofire.request(self.paymentEndPoint, method: .post, parameters: dict,encoding: JSONEncoding.default, headers: HTTPHeaders()).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(){
                        fullfill(jsonString)
                    }
                    else
                    {
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
    
    // Get Terminal List
    func getSendEmailEndPoint(url:String,token:String) -> Promise<String>  {
        return Promise { fullfill, reject in
            if AppReachability.sharedInstance.isReachAble == false{
                HHelper.showAlertWith(message: "Please check your internet connection")
                return
            }
            self._log.debug("API:\(url)")
            
            Alamofire.request(url, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: self.reqEncodedHeaderWithToken(token)).responseJSON (queue: AppConfig.defautQ, options: JSONSerialization.ReadingOptions.allowFragments,completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let jsonString = JSON(value).rawString(){
                        fullfill(jsonString)
                    }
                    else{
                        reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:NotParsable]))
                    }
                    break;
                case .failure(let error):
                    self._log.debug("\(error) and error is \(error.localizedDescription)")
                    reject(NSError(domain: "AuthService",code:1000,userInfo: [ErrorMessageKey:error.localizedDescription]))
                    break;
                }
            }) //End of alamofire
        }
    }//End of function
}
