//
//  ModelClass.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 26/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

import ObjectMapper

class BaseModel : Mappable {
    var base: String?
    
    required init?(map: Map) {
        
    }
    
    init(){
        
    }
    
    func mapping(map: Map) {
        base <- map["base"]
    }
}

class CommonErrorModel: BaseModel {
    var errorCode: Int?
    var responseMessage: String?
    var errors: String?
    
    
    override func mapping(map: Map)
    {
        errorCode <- map["errorCode"]
        responseMessage <- map["responseMessage"]
        errors <- map["errors"]
    }
}

class LoginModel: BaseModel {
    var success: Bool?
    var responseData: LoginResponseModel?
    var error:CommonErrorModel?
    var userinfo:UserModel?
    var time: String?
    var token: String?
    var vterminal:[VTerminalModel]?
    var trans:[VTerminalModel]?
    var invoices:[VTerminalModel]?
    var responseReason:[TransValueResponseModel]?
    var transactionType:[TransValueResponseModel]?
    
    override func mapping(map: Map)
    {
        success <- map["success"]
        responseData <- map["responseData"]
        error <- map["error"]
        time <- map["time"]
        token <- map["token"]
        userinfo <- map["userinfo"]
        vterminal <- map["vterminal"]
        trans <- map["trans"]
        invoices <- map["invoices"]
        responseReason <- map["responseReason"]
        transactionType <- map["transactionType"]
    }
}

class TransValueResponseModel: BaseModel {
    var responseReasonText: String?
    var transactionType: String?
    override func mapping(map: Map)
    {
        responseReasonText <- map["responseReasonText"]
        transactionType <- map["transactionType"]
    }
}

class LoginResponseModel: BaseModel {
    var message: String?
    var token: String?
    
    override func mapping(map: Map)
    {
        message <- map["message"]
        token <- map["token"]
    }
}

class UserModel: BaseModel {
    var name: String?
    var email: String?
    var merchantUrl:String?
    var enableInvoice:Int?
    var enableVirtualterm:Int?
    var defaultCurrency:String?
    
    override func mapping(map: Map)
    {
        name <- map["name"]
        email <- map["email"]
        merchantUrl <- map["merchantUrl"]
        enableVirtualterm <- map["enableVirtualterm"]
        enableInvoice <- map["enableInvoice"]
        defaultCurrency <- map["defaultCurrency"]
    }
}

class VTerminalModel: BaseModel {
    var id: Int?
    var transactionId: Int?
    var createddate: String?
    var createdDTS: String?
    var city:String?
    var customeremail: String?
    var email: String?
    var description: String?
    var firstname:String?
    var phonenumber: String?
    var lastname: String?
    var amount:Int?
    var transactionstatus:String?
    var currency:String?
    var maskedPAN:String?
    var invoiceId:String?
    var total:String?
    var responseReasonText:String?
    var transactionType:String?
    var clientRefId:String?
    var retRefNum:String?
    var isRefundEnable:Bool?
    
    override func mapping(map: Map)
    {
        id <- map["id"]
        transactionId <- map["transactionId"]
        createddate <- map["createddate"]
        createdDTS <- map["createdDTS"]
        city <- map["city"]
        customeremail <- map["customeremail"]
        email <- map["email"]
        description <- map["description"]
        firstname <- map["firstname"]
        phonenumber <- map["phonenumber"]
        lastname <- map["lastname"]
        amount <- map["amount"]
        transactionstatus <- map["transactionstatus"]
        currency <- map["currency"]
        maskedPAN <- map["maskedPAN"]
        invoiceId <- map["invoiceId"]
        total <- map["total"]
        responseReasonText <- map["responseReasonText"]
        transactionType <- map["transactionType"]
        clientRefId <- map["clientRefId"]
        retRefNum <- map["retRefNum"]
        isRefundEnable <- map["isRefundEnable"]
    }
}


class BluetoothDataResponseModel: BaseModel {
    
    var billing_magnesafe_devicesn: String?
    var billing_magnesafe_track_1: String?
    var billing_magnesafe_track_2: String?
    var billing_magnesafe_track_3: String?
    var billing_magnesafe_magneprint: String?
    var billing_magnesafe_ksn: String?
    var billing_magnesafe_magneprint_status: String?
    var fName: String?
    var lName: String?
    var cardNumber: String?
    var cardExpiry: String?
    var cardCvv: String?
    
    override func mapping(map: Map){
        billing_magnesafe_devicesn <- map["billing_magnesafe_devicesn"]
        billing_magnesafe_track_1 <- map["billing_magnesafe_track_1"]
        billing_magnesafe_track_2 <- map["billing_magnesafe_track_2"]
        billing_magnesafe_track_3 <- map["billing_magnesafe_track_3"]
        billing_magnesafe_magneprint <- map["billing_magnesafe_magneprint"]
        billing_magnesafe_ksn <- map["billing_magnesafe_ksn"]
        billing_magnesafe_magneprint_status <- map["billing_magnesafe_magneprint_status"]
        fName <- map["fName"]
        lName <- map["lName"]
        cardNumber <- map["cardNumber"]
        cardExpiry <- map["cardExpiry"]
        cardCvv <- map["cardCvv"]
    }
}
