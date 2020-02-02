//
//  InVoiceViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit
import DropDown

class InVoiceViewC: BaseViewC{

    //MARK:- IBOutlets
    
    @IBOutlet weak var tblCreateInvoice: UITableView!
    
    //MARK:- Properties
    
     internal var invoiceArr = [["plc": "Invoice description*" ,"value":""],["plc": "Amount*" ,"value":""],["plc": "Select currency*" ,"value":""],["plc": "First name*" ,"value":""],["plc": "Last name" ,"value":""],["plc": "Customer email*" ,"value":""],["plc": "Phone number" ,"value":""],["plc": "Address1*" ,"value":""],["plc": "Address2" ,"value":""],["plc": "State*" ,"value":""],["plc": "City*" ,"value":""],["plc": "Postal code*" ,"value":""],["plc": "Select country*" ,"value":""]]
    internal var selectedVal = "USD"
    internal var selectedVal2 = "Cayman Islands"
    internal var amountVal = ""
    internal var amountPaid = "Amount to be paid: "
    let popUpView = Bundle.main.loadNibNamed(PopUpVw.className, owner: self, options: nil)! [0] as! PopUpVw
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
        super.setupNavigationBarTitle("Create Invoice", leftBarButtonsType: [], rightBarButtonsType: [.profile])
    }
    override func profileBtnTapped() {
        self.showPopVw()
    }
    
    func showPopVw(){
        popUpView.setUpView(proTitle: "My Profile", logTitle: "Logout")
        popUpView.frame = CGRect(x: 0, y: 0, width: MAIN_SCREEN_WIDTH, height: MAIN_SCREEN_HEIGHT)
        self.view.window?.addSubview(popUpView)
        popUpView.btnProfile.addTarget(self, action: #selector(showProfile(_:)), for: .touchUpInside)
        popUpView.setNeedsLayout()
        popUpView.layoutIfNeeded()
        popUpView.showPopup()
    }
    func hidePopVw(){
        popUpView.hidePopUp()
    }
    func pushToMyProfile(){
        let profileVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: ProfileViewC.className)
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    func checkValidation() -> Bool{
        if invoiceArr[0]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Invoice Description", type: .error, showButton: false)
            return false
        }
        if invoiceArr[1]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Amount", type: .error, showButton: false)
            return false
        }
        if invoiceArr[2]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Select your Currency", type: .error, showButton: false)
            return false
        }
        if invoiceArr[3]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your First Name", type: .error, showButton: false)
            return false
        }
        if invoiceArr[5]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Email Address", type: .error, showButton: false)
            return false
        }
        if !HHelper.isValidEmail(invoiceArr[5]["value"]!){
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter valid Email Address", type: .error, showButton: false)
            return false
        }
        if invoiceArr[7]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Address1", type: .error, showButton: false)
            return false
        }
        if invoiceArr[9]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your State", type: .error, showButton: false)
            return false
        }
        if invoiceArr[10]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your City", type: .error, showButton: false)
            return false
        }
        if invoiceArr[11]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Postal Code", type: .error, showButton: false)
            return false
        }
        if invoiceArr[12]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Select your Country", type: .error, showButton: false)
            return false
        }
        return true
    }
    func hitCreateInvoiceAPI(){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            HHelper.showLoader()
            var parameters = [String:Any]()
            parameters["amount"] = changeAmountPaid().components(separatedBy: "Amount to be paid: ").joined()
            parameters["invoiceDesc"] = invoiceArr[0]["value"]
//            parameters["amount"] = invoiceArr[1]["value"]
            parameters["currency"] = invoiceArr[2]["value"]
            parameters["firstname"] = invoiceArr[3]["value"]
            parameters["lastname"] = invoiceArr[4]["value"]
            parameters["email"] = invoiceArr[5]["value"]
            parameters["phone"] = invoiceArr[6]["value"]
            parameters["address1"] = invoiceArr[7]["value"]
            parameters["address2"] = invoiceArr[8]["value"]
            parameters["city"] = invoiceArr[9]["value"]
            parameters["state"] = invoiceArr[10]["value"]
            parameters["postal"] = invoiceArr[11]["value"]
            parameters["country"] = invoiceArr[12]["value"]
            ServiceClass().postCreateInvoiceEndPoint(parameters,tkn: token).then { (userResponse) -> Void in
                HHelper.hideLoader()
                print(userResponse)
                if let suc = userResponse.success{
                    if suc{
                        self.clearCellData()
                        self.tabBarController?.selectedIndex = 4
                        if let item = self.tabBarController!.tabBar.selectedItem {
                            self.tabBarController?.tabBar(self.tabBarController!.tabBar, didSelect: item)
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
    func clearCellData(){
        invoiceArr = [["plc": "Invoice description*" ,"value":""],["plc": "Amount*" ,"value":""],["plc": "Select currency*" ,"value":""],["plc": "First name*" ,"value":""],["plc": "Last name" ,"value":""],["plc": "Customer email*" ,"value":""],["plc": "Phone number" ,"value":""],["plc": "Address1*" ,"value":""],["plc": "Address2" ,"value":""],["plc": "State*" ,"value":""],["plc": "City*" ,"value":""],["plc": "Postal code*" ,"value":""],["plc": "Select country*" ,"value":""]]
        selectedVal = "USD"
        selectedVal2 = "Cayman Islands"
        amountPaid = "Amount To be Paid: --"
        self.tblCreateInvoice.reloadData()
        self.tblCreateInvoice.scrollToTop(animation: false)
    }
    
    @objc func showProfile(_ sender:UIButton){
        popUpView.hidePopUp()
        self.pushToMyProfile()
    }
    @objc func createTapped(_ sender:UIButton){
        if self.checkValidation(){
            self.hitCreateInvoiceAPI()
        }
    }
}

//MARK:- UITableView Data Sources & Delegates

extension InVoiceViewC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 11
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
//                cell.selectionStyle = .none
//                cell.textVw.delegate = self
//                cell.textVw.text = invoiceArr[indexPath.row]["value"]
//                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
                cell.selectionStyle = .none
                cell.lblDropDownValue.text = self.selectedVal
                cell.btnDropDown.tag = indexPath.row
                cell.lblDropDownValue.textColor = UIColor.black
                self.invoiceArr[indexPath.row]["value"] = self.selectedVal
                cell.lblAmountPaid.isHidden = false
                cell.lblAmountPaid.text = amountPaid
                cell.btnDropDown.addTarget(self, action: #selector(openDrop(_:)), for: .touchUpInside)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: BillDetailCell.className) as! BillDetailCell
                cell.selectionStyle = .none
                cell.textField.tag = indexPath.row
                cell.textField.delegate = self
                cell.textField.text = invoiceArr[indexPath.row]["value"]
                switch indexPath.row{
                case 1:
                    cell.textField.keyboardType = .numberPad
                    break
                default:
                    cell.textField.keyboardType = .default
                    break
                }
                let snapshot = invoiceArr[indexPath.row]
                cell.configureCell(itemPlc: snapshot["plc"]!, item: snapshot["value"]!)
                return cell
            }
        }
        else{
            switch indexPath.row{
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.className) as! ButtonCell
                cell.selectionStyle = .none
                cell.button.addGradientSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"), width: cell.button.frame.width, height: cell.button.frame.height)
                cell.button.addTarget(self, action: #selector(createTapped(_:)), for: .touchUpInside)
                cell.button.setTitle("Create InVoice", for: .normal)
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
                cell.selectionStyle = .none
                cell.lblAmountPaid.isHidden = true
                cell.btnDropDown.tag = indexPath.row
                cell.lblDropDownValue.text = self.selectedVal2
                cell.lblDropDownValue.textColor = UIColor.black
                self.invoiceArr[12]["value"] = self.selectedVal2
                cell.btnDropDown.addTarget(self, action: #selector(openDrop(_:)), for: .touchUpInside)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: BillDetailCell.className) as! BillDetailCell
                cell.selectionStyle = .none
                cell.textField.tag = indexPath.row
                cell.textField.delegate = self
                cell.textField.text = invoiceArr[indexPath.row]["value"]
                switch indexPath.row{
                case 2:
                    cell.textField.keyboardType = .emailAddress
                    break
                case 3,8:
                    cell.textField.keyboardType = .numberPad
                    break
                default:
                    cell.textField.keyboardType = .default
                    break
                }
                let snapshot = invoiceArr[indexPath.row + 3]
                cell.configureCell(itemPlc: snapshot["plc"]!, item: snapshot["value"]!)
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderVw.instansiateFromNib()
        headerView.lblHeader.text = "Billing Information"
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 60
        }
    }
    
    @objc func openDrop(_ sender:UIButton){
        let dropDwn = DropDown()
        let tag = sender.tag
        var section = 0
        if tag == 2{
            dropDwn.dataSource = ["USD","KYD"]
            section = 0
        }
        else{
            dropDwn.dataSource = ["Cayman Islands","United States"]
            section = 1
        }
        let indexPath = IndexPath(row: tag, section: section)
        if let cell = self.tblCreateInvoice.cellForRow(at: indexPath) as? DropDownCell{
            dropDwn.heightt = 100.0
            dropDwn.cellHeight = 40.0
            dropDwn.width = 100.0
            dropDwn.textFont = UIFont.init(name: "RobotoCondensed-Regular", size: 14.0)!
            dropDwn.direction = .bottom
            dropDwn.width = self.view.frame.width - 40
            dropDwn.anchorView = cell.vwAnchor
            dropDwn.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                if tag == 2{
                    self.selectedVal = item
                    self.invoiceArr[tag]["value"] = item
                    self.amountPaid = self.changeAmountPaid()
                    self.tblCreateInvoice.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                }
                else{
                    self.selectedVal2 = item
                    self.invoiceArr[12]["value"] = item
                }
                cell.lblDropDownValue.text = item
            }
            dropDwn.show()
        }
    }
    
    func changeAmountPaid() -> String{
        var val = ""
        var percent = 0.0
        let subTotal = Double(amountVal) ?? 0
        percent = subTotal / 0.82
        if self.selectedVal == "KYD"{
            val = "Amount to be paid: \(String(format: "%.2f", subTotal))"
        }
        else{
            val = "Amount to be paid: \(String(format: "%.2f", percent))"
        }
        return val
    }
}

extension InVoiceViewC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text as Any)
        if let indexPath = HHelper.getIndexPathFor(view: textField, tableView: self.tblCreateInvoice){
            if indexPath.section == 1{
                invoiceArr[indexPath.row + 3]["value"] = textField.text
            }
            else{
                if indexPath.row == 1{
                    if textField.text != ""{
                        self.amountVal = textField.text!
                        self.amountPaid = self.changeAmountPaid()
                        self.tblCreateInvoice.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                    }
                }
                invoiceArr[indexPath.row]["value"] = textField.text
            }
        }
        print(invoiceArr)
    }
}

extension InVoiceViewC:UITextViewDelegate{
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let indexPath = HHelper.getIndexPathFor(view: textView, tableView: self.tblCreateInvoice){
            invoiceArr[indexPath.row]["value"] = textView.text
        }
    }
}

//MARK:- Description Cell

class DescriptionCell: UITableViewCell {
    
    @IBOutlet weak var lblInVoice: UILabel!
    @IBOutlet weak var textVw: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Bill Details Cell

class BillDetailCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imgEye: UIImageView!
    @IBOutlet weak var btnEye: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(itemPlc:String,item:String){
        self.textField.attributedPlaceholder = NSAttributedString(string: itemPlc, attributes: [.foregroundColor: UIColor.gray,.font:UIFont.systemFont(ofSize: 12.0)])
        self.textField.text = item
        if self.textField.tag == 2{
            self.textField.text = self.textField.text?.grouping(every: 4, with: " ")
        }
        if self.textField.tag == 3{
            self.textField.text = self.textField.text?.grouping(every: 2, with: "/")
        }
    }
    
    func showEye(){
        self.imgEye.image = #imageLiteral(resourceName: "eye_icon")
        self.btnEye.isHidden = false
        self.imgEye.isHidden = false
    }
    func hideEye(){
        self.btnEye.isHidden = true
        self.imgEye.isHidden = true
    }
    
    @IBAction func btnEyeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            self.textField.isSecureTextEntry = false
            self.imgEye.image = #imageLiteral(resourceName: "eye")
        }
        else{
            self.textField.isSecureTextEntry = true
            self.imgEye.image = #imageLiteral(resourceName: "eye_icon")
        }
    }
}

//MARK:- Button Cell

class ButtonCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Drop Down Cell

class DropDownCell: UITableViewCell {
    
    @IBOutlet weak var lblDropDownValue: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var vwAnchor: UIView!
    @IBOutlet weak var vwDropdown: UIView!
    @IBOutlet weak var lblAmountPaid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

