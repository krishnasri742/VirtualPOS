//
//  ChangePasswordViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 26/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

class ChangePasswordViewC: BaseViewC {

    @IBOutlet weak var tblChangePswd:UITableView!
    
    internal var changePswdDict = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupNavigationBarTitle("Change Password", leftBarButtonsType: [.back], rightBarButtonsType: [])
        changePswdDict = [["plc":"Enter Old Passsword","value":""], [ "plc":"Enter New Passsword","value":""],[ "plc":"Enter Confirm Passsword","value":""]]
    }
    
    func updatePassword(){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            HHelper.showLoader()
            var parameters = [String:Any]()
            parameters["pwd"] = changePswdDict[0]["value"]
            parameters["newpwd"] = changePswdDict[1]["value"]
            parameters["confirmpwd"] = changePswdDict[2]["value"]
            ServiceClass().changePasswordEndPoint(parameters, token: token).then { (userResponse) -> Void in
                HHelper.hideLoader()
                print(userResponse)
                if let success = userResponse.success{
                    if success{
                        HHelper.showAlertWithAction(title: APP_NAME, message: "Password Changed Successfully, Please login again", style: .alert, actionTitles: ["OK"], action: { (alert) in
                            switch alert.title{
                            case "OK":
                                let loginVC = AppStoryboards.auth.instantiateViewController(withIdentifier: LoginViewC.className)
                                self.navigationController?.pushViewController(loginVC, animated: true)
                                break
                            default:
                                break
                            }
                        })
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

extension ChangePasswordViewC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePswdButtonCell") as! ChangePswdButtonCell
            cell.selectionStyle = .none
            cell.btn.addGradientSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"), width: cell.btn.frame.width, height: cell.btn.frame.height)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePswdTextFieldCell") as! ChangePswdTextFieldCell
            cell.selectionStyle = .none
            cell.txtFld.delegate = self
            cell.txtFld.tag = indexPath.row
            let snapshot = self.changePswdDict[indexPath.row]
            cell.txtFld.placeholder = snapshot["plc"] as? String
            cell.txtFld.isSecureTextEntry = true
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChangePasswordViewC:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text as Any)
        if textField.text != nil{
            self.changePswdDict[textField.tag]["value"] = textField.text
        }
    }
}

//MARK:- Change Password TextField Cell

class ChangePswdTextFieldCell: UITableViewCell {
    
    @IBOutlet weak var txtFld:UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Change Password Button Cell

class ChangePswdButtonCell: UITableViewCell {
    
    @IBOutlet weak var btn:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
