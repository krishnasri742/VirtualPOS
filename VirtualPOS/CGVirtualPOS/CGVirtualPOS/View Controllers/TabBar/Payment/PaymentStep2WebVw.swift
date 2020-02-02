//
//  PaymentStep2WebVw.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 01/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import UIKit

class PaymentStep2WebVw: BaseViewC {

    @IBOutlet weak var webVw: UIWebView!
    
    let titlee = "<p>Do not go back, your payment is in process.</p>"
    let somethingError = "Something Went Wrong...Please try again"
    let progressColor = "#03A9F4"
    var formUrl = ""
    var cardNumber = ""
    var month = ""
    var year = ""
    var cvv = ""
    var load = 0
    var exp = ""
    var amnt = ""
    var tokenId = ""
    var transactionId = ""
    var clientRefId = ""
    var currency = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupNavigationBarTitle("", leftBarButtonsType: [.back], rightBarButtonsType: [])
        self.loadHtmlInWebView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setTabBarVisible(visible: false, animated: false)
    }
    override func backButtonTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func getDataFromPrevClass(data:[String:Any]){
        if let formURl = data["formUrl"] as? String{
            self.formUrl = formURl
        }
        if let crdNmbr = data["cardNum"] as? String{
            self.cardNumber = crdNmbr
        }
        if let mnth = data["month"] as? String{
            self.month = mnth
        }
        if let yr = data["year"] as? String{
            self.year = yr
        }
        if let cvvv = data["cvv"] as? String{
            self.cvv = cvvv
        }
    }
    
    func getFromUrlFromPrevClass(url:String){
        self.formUrl = url
    }
    
    func loadHtmlInWebView(){
        var htmlString = ""
        cardNumber = bluetoothData.cardNumber ?? ""
        exp = bluetoothData.cardExpiry ?? ""
        cvv = bluetoothData.cardCvv ?? ""
        if !IS_CARD_SWIPED{
            htmlString = "<body>\n" +
                "\n" +
                "<h1>Welcome to Cayman Gateway</h1>\n" +
                "\n" +
                titlee +
                "\n" +
                "<p style=\"margin-top: 50.0\"> Please wait... </p>\n" +
                "\n" +
                "<div class=\"loader\"></div>\n" +
                "<style>\n" +
                "body {\n" +
                "  background-color: white;\n" +
                "  text-align: center;\n" +
                "  gravity:100.0;\n" +
                "  color: grey;\n" +
                "  margin: 30.0;\n" +
                "  font-family: Arial, Helvetica, sans-serif;\n" +
                "}\n" +
                "</style>\n" +
                "</body><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
                "<style>\n" +
                ".loader {\n" +
                "  position: absolute;\n" +
                "  left: 50%;\n" +
                "  top: 50%;\n" +
                "  z-index: 1;\n" +
                "  width: 150px;\n" +
                "  height: 150px;\n" +
                "  margin: -75px 0 0 -75px;\n" +
                "  border: 16px solid #f3f3f3;\n" +
                "  border-radius: 50%;\n" +
                "  border-top: 16px solid " + progressColor + ";\n" +
                "  width: 120px;\n" +
                "  height: 120px;\n" +
                "  -webkit-animation: spin 1s linear infinite;\n" +
                "  animation: spin 1s linear infinite;\n" +
                "}" + "@-webkit-keyframes spin {\n" +
                "  0% { -webkit-transform: rotate(0deg); }\n" +
                "  100% { -webkit-transform: rotate(360deg); }\n" +
                "}\n" +
                "\n" +
                "@keyframes spin {\n" +
                "  0% { transform: rotate(0deg); }\n" +
                "  100% { transform: rotate(360deg); }\n" +
                "}" +
                "</style>" +
                "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js\"></script>\n" +
                "<script>\n" +
                "$(document).ready(function(){\n" +
                "\tsetTimeout(myFunction, 2000);\n" +
                "   function myFunction() {\n" +
                "\t\tdocument.getElementById('data').click();\n" +
                "\t}\n" +
                "});\n" +
                "</script>\n" +
                "<form style=\"display:none\"  action=" + formUrl + " method=\"\\&quot;" +
                "post\\&quot;\"><input name=\"\\&quot;billing-cc-number\\&quot;\" type=\"\\&quot;" +
                "text\\&quot;\" value=" + cardNumber + "/> <input name=\"\\&quot;billing-cc-exp\\&quot;\" " +
                "type=\"\\&quot;text\\&quot;\" value=" + exp + "/> <input name=\"\\&quot;" +
                "billing-cvv\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + cvv + "/> <button " +
            "id = 'data' type =\"\\&quot;submit\\&quot;\">Submit</button></form>"
        }
        else{
            htmlString = "<body>\n" +
                "\n" +
                "<h1>Welcome to Cayman Gateway</h1>\n" +
                "\n" +
                titlee +
                "\n" +
                "<p style=\"margin-top: 50.0\"> Please wait... </p>\n" +
                "\n" +
                "<div class=\"loader\"></div>\n" +
                "<style>\n" +
                "body {\n" +
                "  background-color: white;\n" +
                "  text-align: center;\n" +
                "  gravity:100.0;\n" +
                "  color: grey;\n" +
                "  margin: 30.0;\n" +
                "  font-family: Arial, Helvetica, sans-serif;\n" +
                "}\n" +
                "</style>\n" +
                "</body><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
                "<style>\n" +
                ".loader {\n" +
                "  position: absolute;\n" +
                "  left: 50%;\n" +
                "  top: 50%;\n" +
                "  z-index: 1;\n" +
                "  width: 150px;\n" +
                "  height: 150px;\n" +
                "  margin: -75px 0 0 -75px;\n" +
                "  border: 16px solid #f3f3f3;\n" +
                "  border-radius: 50%;\n" +
                "  border-top: 16px solid " + progressColor + ";\n" +
                "  width: 120px;\n" +
                "  height: 120px;\n" +
                "  -webkit-animation: spin 1s linear infinite;\n" +
                "  animation: spin 1s linear infinite;\n" +
                "}" + "@-webkit-keyframes spin {\n" +
                "  0% { -webkit-transform: rotate(0deg); }\n" +
                "  100% { -webkit-transform: rotate(360deg); }\n" +
                "}\n" +
                "\n" +
                "@keyframes spin {\n" +
                "  0% { transform: rotate(0deg); }\n" +
                "  100% { transform: rotate(360deg); }\n" +
                "}" +
                "</style>" +
                "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js\"></script>\n" +
                "<script>\n" +
                "$(document).ready(function(){\n" +
                "\tsetTimeout(myFunction, 2000);\n" +
                "   function myFunction() {\n" +
                "\t\tdocument.getElementById('data').click();\n" +
                "\t}\n" +
                "});\n" +
                "</script>\n" +
                "<form style=\"display:none\"  action=" + formUrl + " method=\"\\&quot;" +
                "post\\&quot;\"><input name=\"\\&quot;billing-magnesafe-devicesn\\&quot;\" type=\"\\&quot;" +
                "text\\&quot;\" value=" + "\(bluetoothData.billing_magnesafe_devicesn ?? "")" + "/> <input name=\"\\&quot;billing-magnesafe-track-1\\&quot;\" " +
                "type=\"\\&quot;text\\&quot;\" value=" + "\(bluetoothData.billing_magnesafe_track_1 ?? "")" + "/> <input name=\"\\&quot;" +
                "billing-magnesafe-track-2\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + "\(bluetoothData.billing_magnesafe_track_2 ?? "")" + "/><input name=\"\\&quot;" +
                "billing-magnesafe-track-3\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + "\("")" + "/><input name=\"\\&quot;" +
                "billing-magnesafe-magneprint\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + "\(bluetoothData.billing_magnesafe_magneprint ?? "")" + "/><input name=\"\\&quot;" +
                "billing-magnesafe-ksn\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + "\(bluetoothData.billing_magnesafe_ksn ?? "")" + "/><input name=\"\\&quot;" +
                "billing-magnesafe-magneprint-status\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + "\(bluetoothData.billing_magnesafe_magneprint_status ?? "")" + "/><input name=\"\\&quot;" +
                "billing-cvv\\&quot;\" type=\"\\&quot;text\\&quot;\" value=" + "\(cvv)" + "/> <button " +
            "id = 'data' type =\"\\&quot;submit\\&quot;\">Submit</button></form>"
        }
        self.webVw.load(htmlString.data(using: .utf8)!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: URL(string: self.formUrl)!)
    }
    
    func hitStep3Api(){
        var apiDict = [String:Any]()
        apiDict["api-key"] = API_KEY
        apiDict["token-id"] = self.tokenId
        var parameters = [String:Any]()
        parameters["complete-action"] = apiDict
        ServiceClass().postPaymentFirstStepEndPoint(parameters).then { (userResponse) -> Void in
            print(userResponse)
            let jsonData = userResponse.data(using: .utf8)
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                if let array = json as? [String : AnyObject]{
                    if array["success"] as? Bool == true{
                        if let tID = array["transaction-id"] as? String,tID != ""{
                            self.clientRefId = tID
                            self.hitSendEmailto(id: tID)
                        }
                        if let tCurrency = array["currency"] as? String,tCurrency != ""{
                            self.currency = tCurrency
                        }
                        if let rslt = array["result"] as? String,rslt != ""{
                            switch rslt{
                            case "0":
                                self.pushToError(desc: self.somethingError)
                                break
                            case "1":
                                if let tID = array["id"] as? String,tID != ""{
                                    self.transactionId = tID
                                }
                                else{
                                    if let tID = array["transaction-id"] as? String,tID != ""{
                                        self.transactionId = tID
                                        self.clientRefId = tID
                                    }
                                }
                                if let tAmnt = array["amount"] as? Int,tAmnt != 0{
                                    self.amnt = String(tAmnt)
                                }
                                else{
                                    if let tAmnt = array["amount"] as? Double,tAmnt != 0.0{
                                        self.amnt = String(format: "%.2f", tAmnt)
                                    }
                                }
                                if let tBill = array["billing"] as? [String : AnyObject]{
                                    if let crdnm = tBill["cc-number"] as? String{
                                        self.cardNumber = crdnm
                                    }
                                }
                                self.pushToSuccess()
                                break
                            case "2":
                                if let rsltTxt = array["result-text"] as? String,rsltTxt != ""{
                                    var txt = rsltTxt
                                    if (rsltTxt == "Account Number not on file"){
                                        txt = "Please check your card number and try again"
                                    }
                                    if (rsltTxt == "Service Not Allowed"){
                                        txt = "Please check your card number or use different card"
                                    }
                                    if (rsltTxt == "Expired Card"){
                                        txt = "Your card expired please use different card"
                                    }
                                    if (rsltTxt == "CVV2 Declined"){
                                        txt = "Please check your CVV and try again"
                                    }
                                    self.pushToError(desc: txt)
                                }
                                else{
                                    self.pushToError(desc: self.somethingError)
                                }
                                break
                            default:
                                self.pushToError(desc: self.somethingError)
                                break
                            }
                        }
                        else{
                            self.pushToError(desc: self.somethingError)
                        }
                    }
                    else{
                        self.pushToError(desc: self.somethingError)
                    }
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
    
    func pushToError(desc:String){
        let errorVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: PaymentErrorViewC.className) as! PaymentErrorViewC
        errorVC.hidesBottomBarWhenPushed = true
        errorVC.getDataFromPrevClas(descData: desc)
        self.navigationController?.pushViewController(errorVC, animated: true)
    }
    func pushToSuccess(){
        let successVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: PaymentSuccessViewC.className) as! PaymentSuccessViewC
        successVC.getDataFromPrevClass(amnt: self.amnt, transID: self.transactionId, crdNmbr: self.cardNumber,crncy: self.currency)
        successVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(successVC, animated: true)
    }
}

extension PaymentStep2WebVw:UIWebViewDelegate,NSURLConnectionDelegate,URLSessionDelegate{
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if ((request.url?.absoluteString.contains("error"))!){
            self.pushToError(desc: self.somethingError)
        }
        else if (request.url?.absoluteString.contains("http://merchant.com/testurl/"))!{
            let rqStr = request.url?.absoluteString.components(separatedBy: "token-id=")
            print(rqStr as Any)
            self.tokenId = rqStr?.last ?? ""
            self.hitStep3Api()
            print(request.url?.absoluteString as Any)
        }
        else{
            if load == 0{
                self.load = 1
                var request = URLRequest(url: URL(string: self.formUrl)!)
                request.httpMethod = "POST"
                var postString = ""
                if !IS_CARD_SWIPED{
                    postString = "billing-cc-number=\(self.cardNumber)&billing-cc-exp=\(exp)&billing-cvv=\(self.cvv)"
                }
                else{
                    postString = "billing-magnesafe-devicesn=\(bluetoothData.billing_magnesafe_devicesn ?? "")&billing-magnesafe-track-1=\(bluetoothData.billing_magnesafe_track_1 ?? "")&billing-magnesafe-track-3=\("")&billing-magnesafe-magneprint=\(bluetoothData.billing_magnesafe_magneprint ?? "")&billing-magnesafe-ksn=\(bluetoothData.billing_magnesafe_ksn ?? "")&billing-magnesafe-magneprint-status=\(bluetoothData.billing_magnesafe_magneprint_status ?? "")&billing-magnesafe-track-2=\(bluetoothData.billing_magnesafe_track_2 ?? "")&billing-cvv=\(cvv)";
                }
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = postString.data(using: .utf8, allowLossyConversion: false)
                webView.loadRequest(request)
            }
        }
        return true
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate) {
            completionHandler(.rejectProtectionSpace, nil)
        }
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription)
    }
}


extension PaymentStep2WebVw{
    
    func hitSendEmailto(id:String){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            let apiUrl = ServiceClass().sendEmailEndPoint + "\(id)"
            ServiceClass().getSendEmailEndPoint(url: apiUrl,token: token).then { (userResponse) -> Void in
                print(userResponse)
                let jsonData = userResponse.data(using: .utf8)
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                    if let array = json as? [String : AnyObject]{
                        print(array)
                    }
                    else{}
                }
                catch {
                    print("Couldn't parse json \(error)")
                }
            }.catch { (error) in
                //                HHelper.hideLoader()
                let nsError = error as NSError
                print(nsError.userInfo["errorMessage"] as! String)
            }
        }
    }
}
