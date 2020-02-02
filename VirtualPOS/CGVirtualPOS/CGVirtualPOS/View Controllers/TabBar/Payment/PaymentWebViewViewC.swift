//
//  PaymentWebViewViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 01/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import UIKit
import WebKit

class PaymentWebViewViewC: BaseViewC {

    @IBOutlet weak var webVw: UIWebView!
    
    internal var paymentDict = [String:Any]()
    internal var formStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavigationBar()
        self.loadHtmlInWebView()
        self.hitFirstStepAPI()
        super.setupNavigationBarTitle("", leftBarButtonsType: [.back], rightBarButtonsType: [])
    }
    
    func getDataFromPrevClass(data:[String:Any]){
        self.paymentDict = data
        if USER_DEFAULTS.value(forKey: ktknUsd) != nil && USER_DEFAULTS.value(forKey: ktknKyd) != nil{
            if paymentDict["currency"] as? String == "KYD"{
                API_KEY = USER_DEFAULTS.value(forKey: ktknKyd) as! String
            }
            else{
                API_KEY = USER_DEFAULTS.value(forKey: ktknUsd) as! String
            }
        }
    }
    
    func loadHtmlInWebView(){
        let htmlString = "<body>\n" +
        "<h1>Welcome to Cayman Gateway</h1>\n" +
        "<p style=\\\"margin-top: 50.0\\\"> Your Transaction is in process </p>             \n" +
        "<p style=\\\"margin-top: 50.0\\\"> Please wait... </p>\n" +
        "<div class=\\\"loader\\\"></div>\n" +
        "\t<style>\n" +
        "        body {background-color: white; text-align: center; gravity:100.0; color: grey;margin: 30.0; font-family: Arial, Helvetica, sans-serif;} \n" +
        "               </style>\n" +
        "               \n" +
        "                </body>\n" +
        "                \n" +
        "  <meta name=\"viewport\" content=\"width=device-width\", initial-scale=1>\n" +
        "  <style>\n" +
        "    .loader {position: absolute;left: 50%; top: 50%;  z-index: 1; width: 150px; height: 150px; margin: -75px 0 0 -75px; border: 16px solid #f3f3f3; border-radius: 50%;border-top: 16px solid #008577;  width: 120px; height: 120px;  -webkit-animation: spin 1s linear infinite; animation: spin 1s linear infinite;}\n" +
        "                @-webkit-keyframes spin {  0% { -webkit-transform: rotate(0deg); } 100% { -webkit-transform: rotate(360deg); }\n" +
        "                \n" +
        "                @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); }\n" +
        "                }\n" +
        "                \n" +
        "</style>\n" +
        "<div class=\"loader\"></div>"
        self.webVw.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func pushToCardDetails(){
        let cardDetailVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: CardDetailViewC.className) as! CardDetailViewC
        cardDetailVC.getDataFromPrevClass(str: self.formStr)
        self.navigationController?.pushViewController(cardDetailVC, animated: true)
    }
    func pushToError(){
        let errorVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: PaymentErrorViewC.className)
        errorVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(errorVC, animated: true)
    }
    func pushToNextSteps(){
        let nextStepsVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: PaymentStep2WebVw.className) as! PaymentStep2WebVw
        nextStepsVC.getFromUrlFromPrevClass(url: self.formStr)
        self.navigationController?.pushViewController(nextStepsVC, animated: true)
    }
}


extension PaymentWebViewViewC{
    
    func hitFirstStepAPI(){
        var billingDict = [String:Any]()
        var saleDict = [String:Any]()
        billingDict["address1"] = "George Town"
        billingDict["city"] = "WestBay"
        billingDict["country"] = paymentDict["country"]
        billingDict["first-name"] = bluetoothData.fName
        billingDict["last-name"] = bluetoothData.lName
        billingDict["postal"] = "KY1-1201"
        billingDict["state"] = "Grand cayman"
        saleDict["amount"] = paymentDict["amount"]
        saleDict["currency"] = paymentDict["currency"]
        saleDict["email"] = paymentDict["email"]
        saleDict["redirect-url"] = "http://merchant.com/testurl/"
        saleDict["api-key"] = API_KEY
        saleDict["billing"] = billingDict
        var parameters = [String:Any]()
        parameters["sale"] = saleDict
        ServiceClass().postPaymentFirstStepEndPoint(parameters).then { (userResponse) -> Void in
            print(userResponse)
            let jsonData = userResponse.data(using: .utf8)
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                if let array = json as? [String : AnyObject]{
                    self.formStr = array["form-url"] as? String ?? ""
                    if array["success"] as? Bool == true{
                        self.pushToNextSteps()
                    }
                    else{
                        self.pushToError()
                    }
                }
                else{
                    self.pushToError()
                }
            }
            catch {
                print("Couldn't parse json \(error)")
            }
            }.catch { (error) in
//                HHelper.hideLoader()
                let nsError = error as NSError
                print(nsError.userInfo["errorMessage"] as! String)
                HHelper.showAlertWith(message: nsError.userInfo["errorMessage"] as! String)
        }
    }
}
