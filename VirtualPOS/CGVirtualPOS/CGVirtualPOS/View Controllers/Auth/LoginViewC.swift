//
//  LoginViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

class LoginViewC: BaseViewC {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var tblLogin: UITableView!
    
    //MARK:- Properties
    
    internal var loginDict = [String:Any]()
    internal var rememberMe = false
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (USER_DEFAULTS.value(forKey: kloginEmail) != nil) && (USER_DEFAULTS.value(forKey: kloginPass) != nil){
            if let email = USER_DEFAULTS.value(forKey: kloginEmail) as? String{
                self.loginDict["email"] = email
            }
            if let pass = USER_DEFAULTS.value(forKey: kloginPass) as? String{
                self.loginDict["password"] = pass
            }
        }
        self.hideNavigationBar()
    }
    
    func validate() -> Bool{
        if loginDict["email"] == nil{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Email Address", type: .error, showButton: false)
            return false
        }
        if loginDict["password"] == nil{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your password", type: .error, showButton: false)
            return false
        }
        if !HHelper.isValidEmail(loginDict["email"] as! String){
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter valid Email Address", type: .error, showButton: false)
            return false
        }
        return true
    }
    
    func hitLoginApi(){
        HHelper.showLoader()
        var parameters = [String:Any]()
        parameters["apiUsername"] = loginDict["email"]
        parameters["apiPassword"] = loginDict["password"]
        if !self.rememberMe{
            parameters["rememberme"] = ""
            USER_DEFAULTS.removeObject(forKey: kloginEmail)
            USER_DEFAULTS.removeObject(forKey: kloginPass)
        }
        else{
            parameters["rememberme"] = self.rememberMe
            USER_DEFAULTS.set(loginDict["email"], forKey: kloginEmail)
            USER_DEFAULTS.set(loginDict["password"], forKey: kloginPass)
        }
        ServiceClass().postLoginEndPoint(parameters).then { (userResponse) -> Void in
            HHelper.hideLoader()
            print(userResponse)
            let jsonData = userResponse.data(using: .utf8)
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                if let array = json as? [String : AnyObject]{
                    if array["success"] as? Bool == true{
                        if let rfndAllowd = array["isRefundAllowed"] as? Int{
                            USER_DEFAULTS.setValue(rfndAllowd, forKey: kIsRefund)
                        }
                        if let tkn = array["token"] as? String{
                            USER_DEFAULTS.setValue(tkn, forKey: kAccessToken)
                        }
                        if let usrRole = array["role"] as? String{
                            if usrRole != ""{
                                self.getProfile(ty: usrRole)
                            }
                            else{
                                HHelper.showAlert(withTitle: "", message: "No access for admin", type: .error, showButton: false)
                            }
                        }
                    }
                    else{
                        if let msg = array["errors"] as? String{
                            HHelper.showAlert(withTitle: "", message: msg, type: .error, showButton: false)
                        }
                    }
                }
            }
        }.catch { (error) in
            HHelper.hideLoader()
            let nsError = error as NSError
            print(nsError.userInfo["errorMessage"] as! String)
            HHelper.showAlertWith(message: nsError.userInfo["errorMessage"] as! String)
        }
    }
    
    func pushToHome(type:String){
        USER_DEFAULTS.setValue(type, forKey: kloginType)
        let vc1 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: VirtualTerminalViewC.className)
        //let vc2 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: TerminalListViewC.className)
        let vc3 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: TransactionListViewC.className)
        let vc4 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: InVoiceViewC.className)
        //let vc5 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: InVoiceListViewC.className)
        let vcc1 = UINavigationController.init(rootViewController: vc1)
//        let vcc2 = UINavigationController.init(rootViewController: vc2)
        let vcc3 = UINavigationController.init(rootViewController: vc3)
        let vcc4 = UINavigationController.init(rootViewController: vc4)
//        let vcc5 = UINavigationController.init(rootViewController: vc5)
        var vccs = [UIViewController]()
        switch type {
        case "operator":
            if let vTerSts = USER_DEFAULTS.value(forKey: kVTerminalPresent) as? Int{
                if let invoiceSts = USER_DEFAULTS.value(forKey: kInvoicePresent) as? Int{
                    if invoiceSts == 1 && vTerSts == 1{
                        vccs = [vcc1,vcc4]
                        HHelper.showAlert(withTitle: "", message: "Login Successfully", type: .success, showButton: false)
                    }
                    else if invoiceSts == 1 && vTerSts == 0{
                        vccs = [vcc4]
                        HHelper.showAlert(withTitle: "", message: "Login Successfully", type: .success, showButton: false)
                    }
                    else if invoiceSts == 0 && vTerSts == 1{
                        vccs = [vcc1]
                        HHelper.showAlert(withTitle: "", message: "Login Successfully", type: .success, showButton: false)
                    }
                    else{
                        HHelper.showAlert(withTitle: "", message: "Invalid User", type: .error
                            , showButton: false)
                        kAppDelegate.loginMethod()
                        break
                    }
                }
            }
            break
        case "accountant":
            vccs = [vcc3]
            HHelper.showAlert(withTitle: "", message: "Login Successfully", type: .success, showButton: false)
            break
        case "manager","managerv1":
            vccs = [vcc1,vcc3,vcc4]
            HHelper.showAlert(withTitle: "", message: "Login Successfully", type: .success, showButton: false)
            break
        default:
            break
        }
        let tabBarVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: TabBarViewC.className) as! TabBarViewC
        tabBarVC.viewControllers = vccs
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
    func getProfile(ty:String){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            ServiceClass().getUserInfoEndPoint(token: token).then { (userResponse) -> Void in
                print(userResponse)
                if let suc = userResponse.success{
                    if suc{
                        if let userDetails = userResponse.userinfo{
                            if let nm = userDetails.name{
                                USER_DEFAULTS.setValue(nm, forKey: kName)
                            }
                            if let emailId = userDetails.email{
                                USER_DEFAULTS.setValue(emailId, forKey: kEmail)
                            }
                            if let url = userDetails.merchantUrl{
                                USER_DEFAULTS.setValue(url, forKey: kUrl)
                            }
                            if let invoiceSts = userDetails.enableInvoice{
                                USER_DEFAULTS.setValue(invoiceSts, forKey: kInvoicePresent)
                            }
                            if let dfltCrncy = userDetails.defaultCurrency{
                                USER_DEFAULTS.setValue(dfltCrncy, forKey: kDefaultCrncy)
                            }
                            if let vTerminalSts = userDetails.enableVirtualterm{
                                USER_DEFAULTS.setValue(vTerminalSts, forKey: kVTerminalPresent)
                            }
                        }
                    }
                    self.getToken()
                    self.pushToHome(type: ty)
                }
            }.catch { (error) in
                HHelper.hideLoader()
                let nsError = error as NSError
                print(nsError.userInfo["errorMessage"] as! String)
                HHelper.showAlertWith(message: nsError.userInfo["errorMessage"] as! String)
            }
        }
    }
    
    func getToken(){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            ServiceClass().getMerchantTokenEndPoint(token: token).then { (userResponse) -> Void in
                print(userResponse)
                let jsonData = userResponse.data(using: .utf8)
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                    if let array = json as? [String : AnyObject]{
                        if array["success"] as? Bool == true{
                            if let v1Mrchnt = (array["v1Merchant"] as? [String:Any]){
                                if let tkns = v1Mrchnt["tokens"] as? [[String:Any]]{
                                    if let tkncrncy = tkns[0]["currency"] as? String,tkncrncy == "KYD" {
                                        if let tkn = tkns[0]["token"] as? String{
                                            USER_DEFAULTS.setValue(tkn, forKey: ktknKyd)
                                        }
                                    }
                                    else{
                                        if let tkn = tkns[1]["token"] as? String{
                                            USER_DEFAULTS.setValue(tkn, forKey: ktknKyd)
                                        }
                                    }
                                    if let tkncrncy = tkns[1]["currency"] as? String,tkncrncy == "USD" {
                                        if let tkn = tkns[1]["token"] as? String{
                                            USER_DEFAULTS.setValue(tkn, forKey: ktknUsd)
                                        }
                                    }
                                    else{
                                        if let tkn = tkns[0]["token"] as? String{
                                            USER_DEFAULTS.setValue(tkn, forKey: ktknUsd)
                                        }
                                    }
                                }
                            }
                            else{
                                if let mrchnt = array["merchant"] as? [String:Any]{
                                    if let tkn = mrchnt["token"] as? String{
                                        API_KEY = tkn
                                    }
                                }
                            }
                        }
                        else{
                            if let msg = array["errors"] as? String{
                                HHelper.showAlert(withTitle: "", message: msg, type: .error, showButton: false)
                            }
                        }
                    }
                }
            }.catch { (error) in
                HHelper.hideLoader()
                let nsError = error as NSError
                print(nsError.userInfo["errorMessage"] as! String)
                HHelper.showAlertWith(message: nsError.userInfo["errorMessage"] as! String)
            }
        }
    }
}

extension LoginViewC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: LogoImageCell.className) as! LogoImageCell
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: LoginLabelCell.className) as! LoginLabelCell
            cell.selectionStyle = .none
            cell.lblInsertLogin.text = ""
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: LoginTextFieldCell.className) as! LoginTextFieldCell
            cell.selectionStyle = .none
            cell.txtFldEmail.delegate = self
            cell.txtFldPassword.delegate = self
            cell.txtFldEmail.keyboardType = .emailAddress
            cell.txtFldPassword.isSecureTextEntry = true
            cell.btnRemember.tag = indexPath.row
            //            cell.showEye()
            if ((self.loginDict["email"] as? String) != nil) && ((self.loginDict["password"] as? String) != nil){
                cell.txtFldEmail.text = self.loginDict["email"] as? String
                cell.txtFldPassword.text = self.loginDict["password"] as? String
            }
            cell.btnRemember.addTarget(self, action: #selector(rememberTapped(_:)), for: .touchUpInside)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: LoginButtonCell.className) as! LoginButtonCell
            cell.selectionStyle = .none
            cell.btnlogin.addTarget(self, action: #selector(LoginTapped(_:)), for: .touchUpInside)
            cell.btnlogin.addGradientSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"), width: cell.btnlogin.frame.width, height: cell.btnlogin.frame.height)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK:- IBActions
    
    @objc func LoginTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if validate(){
            self.hitLoginApi()
        }
    }
    @objc func rememberTapped(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        rememberMe = sender.isSelected
        let indexpathh = IndexPath(row: sender.tag, section: 0)
        if let cell = self.tblLogin.cellForRow(at: indexpathh) as? LoginTextFieldCell{
            if sender.isSelected{
                cell.imgChekBox.image = #imageLiteral(resourceName: "check-box")
            }
            else{
                cell.imgChekBox.image = #imageLiteral(resourceName: "check-box-empty")
            }
        }
    }
}

extension LoginViewC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text as Any)
        if textField.tag == 20{
            if textField.text != nil{
                self.loginDict["email"] = textField.text
            }
        }
        else{
            if textField.text != nil{
                self.loginDict["password"] = textField.text
            }
        }
    }
}

//MARK:- Logo Image Cell

class LogoImageCell: UITableViewCell {
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Login Label Cell

class LoginLabelCell: UITableViewCell {
    
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var lblInsertLogin: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Login TextField Cell

class LoginTextFieldCell: UITableViewCell {
    
    @IBOutlet weak var txtFldEmail: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var imgChekBox: UIImageView!
    @IBOutlet weak var btnRemember: UIButton!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var imgEye: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func hideEye(){
        self.btnEye.isHidden = true
        self.imgEye.isHidden = true
    }
    func showEye(){
        self.imgEye.image = #imageLiteral(resourceName: "eye_icon")
        self.btnEye.isHidden = false
        self.imgEye.isHidden = false
    }
    
    @IBAction func eyeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            self.txtFldPassword.isSecureTextEntry = false
            self.imgEye.image = #imageLiteral(resourceName: "eye")
        }
        else{
            self.txtFldPassword.isSecureTextEntry = true
            self.imgEye.image = #imageLiteral(resourceName: "eye_icon")
        }
    }
}

//MARK:- Login Button Cell

class LoginButtonCell: UITableViewCell {
    
    @IBOutlet weak var btnlogin: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
