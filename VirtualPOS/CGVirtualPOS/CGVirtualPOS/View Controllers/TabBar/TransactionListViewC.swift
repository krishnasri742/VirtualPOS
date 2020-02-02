//
//  TransactionListViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

class TransactionListViewC: BaseViewC {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var tblTransactionList:UITableView!
    @IBOutlet weak var lblNoTrans: UILabel!
    
    //MARK:- Properties
    
    internal var transactionListArr = [VTerminalModel]()
    internal var responseReasonArr = [String]()
    internal var transactionTypeArr = [String]()
    internal var filterDict = [String:Any]()
    internal var refreshControl = UIRefreshControl()
    internal var transTag = Int()
    internal var isScrolling = false
    internal var pageNo = 0
    var grdlayer = CAGradientLayer()
    let popUpView = Bundle.main.loadNibNamed(RefundVw.className, owner: self, options: nil)! [0] as! RefundVw
    let profilePopUpView = Bundle.main.loadNibNamed(PopUpVw.className, owner: self, options: nil)! [0] as! PopUpVw
    
    //MARK:- View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HHelper.showLoader()
        self.addRefreshControl()
        self.getTransValue()
        self.getTransactionList(pgCount: 0)
        self.lblNoTrans.isHidden = true
        super.setupNavigationBarTitle("Transaction List", leftBarButtonsType: [], rightBarButtonsType: [.profile,.filter])
    }
    override func filterBtnTapped() {
        self.pushToFilter()
    }
    override func profileBtnTapped() {
        self.showPopVw()
    }
    
    func getTransactionList(pgCount:Int){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            var paramDict = [String:Any]()
            paramDict["page"] = pgCount
            paramDict["pagesize"]  = 20
            if let crncy = self.filterDict["Currency"] as? String,crncy != ""{
                paramDict["currency"]  = crncy
            }
            else{
                paramDict["currency"]  = ""
            }
            if let strtDt = self.filterDict["StartDate"] as? String,strtDt != ""{
                paramDict["startDate"]  = strtDt
            }
            else{
                paramDict["startDate"]  = ""
            }
            if let endDt = self.filterDict["EndDate"] as? String,endDt != ""{
                paramDict["endDate"]  = endDt
            }
            else{
                paramDict["endDate"]  = ""
            }
            if let srchRes = self.filterDict["SearchRes"] as? String,srchRes != ""{
                paramDict["response"]  = srchRes
            }
            else{
                paramDict["response"]  = ""
            }
            if let srtDir = self.filterDict["SortDirection"] as? String,srtDir != ""{
                paramDict["sortDirection"]  = srtDir
            }
            else{
                paramDict["sortDirection"]  = "desc"
            }
            if let trnsType = self.filterDict["TransType"] as? String,trnsType != ""{
                paramDict["transType"]  = trnsType
            }
            else{
                paramDict["transType"]  = ""
            }
            if let srtType = self.filterDict["SortBy"] as? String,srtType != ""{
                paramDict["sortColumn"]  = srtType.removingWhitespaces().lowercased()
            }
            else{
                paramDict["sortColumn"]  = "transactionId"
            }
            paramDict["transactionId"]  = ""
            paramDict["merchVal"] = 0
            ServiceClass().getTransactionListEndPoint(token: token,param: paramDict).then { (userResponse) -> Void in
                self.refreshControl.endRefreshing()
                HHelper.hideLoader()
                print(userResponse)
                if let suc = userResponse.success{
                    if suc{
                        if self.isScrolling{
                            if let trans = userResponse.trans{
                                var transcarray = self.transactionListArr
                                transcarray.append(contentsOf:trans)
                                self.transactionListArr = transcarray
                            }
                            if self.transactionListArr.count == 0{
                                self.lblNoTrans.isHidden = false
                            }
                            else{
                                self.lblNoTrans.isHidden = true
                            }
                            self.isScrolling = false
                        }
                        else{
                            if let trans = userResponse.trans{
                                self.transactionListArr = trans
                            }
                            if self.transactionListArr.count == 0{
                                self.lblNoTrans.isHidden = false
                            }
                            else{
                                self.lblNoTrans.isHidden = true
                            }
                        }
                    }
                }
                else{
                    self.lblNoTrans.isHidden = false
                }
                self.tblTransactionList.reloadData()
                }.catch { (error) in
                    self.refreshControl.endRefreshing()
                    self.lblNoTrans.isHidden = false
                    HHelper.hideLoader()
                    let nsError = error as NSError
                    print(nsError.userInfo["errorMessage"] as! String)
                    HHelper.showAlertWith(message: nsError.userInfo["errorMessage"] as! String)
            }
        }
        else{
            HHelper.hideLoader()
        }
    }
    func getTransValue(){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            ServiceClass().getTransValueEndPoint(token: token).then { (userResponse) -> Void in
                print(userResponse)
                if let transactionTypeArr = userResponse.transactionType{
                    if transactionTypeArr.count > 0{
                        for item in transactionTypeArr{
                            self.transactionTypeArr.append(item.transactionType ?? "")
                        }
                    }
                }
                if let responseArr = userResponse.responseReason{
                    if responseArr.count > 0{
                        for item in responseArr{
                            self.responseReasonArr.append(item.responseReasonText ?? "")
                        }
                    }
                }
                }.catch { (error) in
                    let nsError = error as NSError
                    print(nsError.userInfo["errorMessage"] as! String)
            }
        }
    }
    func hitRefundApi(){
        if let _ = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            HHelper.showLoader()
            var refundDict = [String:Any]()
            refundDict["amount"] = "\(self.popUpView.txtFldRefundAmnt.text ?? "1")"
            refundDict["api-key"] = API_KEY
            refundDict["transaction-id"] = "\(self.transactionListArr[transTag].clientRefId ?? "")"
            var paramDict = [String:Any]()
            paramDict["refund"] = refundDict
            ServiceClass().postRefundEndPoint(paramDict).then { (userResponse) -> Void in
                HHelper.hideLoader()
                print(userResponse)
                let jsonData = userResponse.data(using: .utf8)
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                    if let array = json as? [String : AnyObject]{
                        if array["result"] as? String == "1"{
                            HHelper.showAlert(withTitle: "", message: "Refund Successful", type: .success, showButton: false)
                            HHelper.showLoader()
                            self.getTransactionList(pgCount: 0)
                        }
                        else{
                            if let rsltTxt = array["result-text"] as? String,rsltTxt != ""{
                                HHelper.showAlert(withTitle: "", message: "Something Went wrong\n\(rsltTxt)", type: .error, showButton: false)
                            }
                            else{
                                HHelper.showAlert(withTitle: "", message: "Something Went wrong", type: .error, showButton: false)
                            }
                        }
                    }
                }
                catch {
                     HHelper.showAlert(withTitle: "", message: "Something Went wrong", type: .error, showButton: false)
                    print("Couldn't parse json \(error)")
                }
                self.tblTransactionList.reloadData()
                }.catch { (error) in
                    HHelper.hideLoader()
                    let nsError = error as NSError
                    print(nsError.userInfo["errorMessage"] as! String)
                    HHelper.showAlertWith(message: nsError.userInfo["errorMessage"] as! String)
            }
        }
        else{
            HHelper.hideLoader()
        }
    }
    func addRefreshControl(){
        self.refreshControl.tintColor = UIColor.black
        self.tblTransactionList.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    func pushToFilter(){
        let filterVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: FilterViewC.className) as! FilterViewC
        filterVC.getDataFromPrevClass(responseArr: self.responseReasonArr, transactionArr: self.transactionTypeArr,fDict: self.filterDict)
        filterVC.delegate = self
        let naviVC = UINavigationController.init(rootViewController: filterVC)
        self.present(naviVC, animated: true, completion: nil)
    }
    func showRefundPopUp(tag:Int){
        popUpView.frame = CGRect(x: 0, y: 0, width: MAIN_SCREEN_WIDTH, height: MAIN_SCREEN_HEIGHT)
        self.view.window?.addSubview(popUpView)
        self.popUpView.txtFldRefundAmnt.text = ""
        self.popUpView.pswdPopUpVw.isHidden = true
        popUpView.btnRefund.addTarget(self, action: #selector(refundTapped(_:)), for: .touchUpInside)
        popUpView.btnVerify.addTarget(self, action: #selector(verifyBtnTapped(_:)), for: .touchUpInside)
        popUpView.setUpData(transId: (self.transactionListArr[tag].transactionId?.toString())!, frstNm: self.transactionListArr[tag].firstname ?? "-", lstNm: self.transactionListArr[tag].lastname ?? "-", transId2: self.transactionListArr[tag].clientRefId ?? "-", rspnsType: self.transactionListArr[tag].responseReasonText ?? "-", transType: self.transactionListArr[tag].transactionType ?? "-", amnt: self.transactionListArr[tag].amount?.toString() ?? "-", refnd: self.transactionListArr[tag].total ?? "-")
        if let refndEnable = USER_DEFAULTS.value(forKey: kIsRefund) as? Int{
            if let enableRefund = self.transactionListArr[tag].isRefundEnable{
                if refndEnable == 1 && enableRefund{
                    popUpView.btnRefund.isHidden = false
                    popUpView.txtFldRefundAmnt.isHidden = false
                    popUpView.lblRefundAmnt.isHidden = false
                    popUpView.heightPopUpVw.constant = 332
                }
                else{
                    popUpView.btnRefund.isHidden = true
                    popUpView.txtFldRefundAmnt.isHidden = true
                    popUpView.lblRefundAmnt.isHidden = true
                    popUpView.heightPopUpVw.constant = 260
                }
            }
            else{
                popUpView.btnRefund.isHidden = true
                popUpView.txtFldRefundAmnt.isHidden = true
                popUpView.lblRefundAmnt.isHidden = true
                popUpView.heightPopUpVw.constant = 260
            }
        }
        else{
            popUpView.btnRefund.isHidden = true
            popUpView.txtFldRefundAmnt.isHidden = true
            popUpView.lblRefundAmnt.isHidden = true
            popUpView.heightPopUpVw.constant = 260
        }
        popUpView.setNeedsLayout()
        popUpView.layoutIfNeeded()
        popUpView.showPopup()
    }
    func showPopVw(){
        profilePopUpView.setUpView(proTitle: "My Profile", logTitle: "Logout")
        profilePopUpView.frame = CGRect(x: 0, y: 0, width: MAIN_SCREEN_WIDTH, height: MAIN_SCREEN_HEIGHT)
        self.view.window?.addSubview(profilePopUpView)
        profilePopUpView.btnProfile.addTarget(self, action: #selector(showProfile(_:)), for: .touchUpInside)
        profilePopUpView.setNeedsLayout()
        profilePopUpView.layoutIfNeeded()
        profilePopUpView.showPopup()
    }
    func hidePopVw(){
        profilePopUpView.hidePopUp()
    }
    func pushToMyProfile(){
        let profileVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: ProfileViewC.className)
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func refundTapped(_ sender:UIButton){
        self.view.endEditing(true)
        if self.popUpView.txtFldRefundAmnt.text != ""{
            popUpView.hidePopUp()
            self.hitRefundApi()
        }
    }
    @objc func refundBtnTapped(_ sender:UIButton){
        self.showRefundPopUp(tag: sender.tag)
    }
    @objc func verifyBtnTapped(_ sender:UIButton){
        if popUpView.txtFldPswd.text != ""{
            popUpView.hidePopUp()
            self.hitRefundApi()
        }
    }
    @objc func showProfile(_ sender:UIButton){
        popUpView.hidePopUp()
        self.pushToMyProfile()
    }
    // MARK: - Action For Refresh Control
    
    @objc func refreshData(_ sender: UIRefreshControl){
        self.getTransactionList(pgCount: 0)
    }
}

extension TransactionListViewC:UIScrollViewDelegate{

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && (!isScrolling)  && (self.transactionListArr.count) > 0){
            isScrolling = true
            self.pageNo = self.transactionListArr.count
            let arrayCount = self.transactionListArr.count
            if arrayCount % 20 == 0{
                HHelper.showLoader()
                self.getTransactionList(pgCount: arrayCount/20)
            }
        }
    }
}

//MARK:- UITableView Data Sources & Delegates

extension TransactionListViewC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
        cell.selectionStyle = .none
        grdlayer = cell.btnRefund.addGradientButtonSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"),btn: cell.btnRefund)
        cell.btnRefund.layer.insertSublayer(grdlayer, at: 0)
        cell.btnRefund.tag = indexPath.row
        if let idVal = self.transactionListArr[indexPath.row].transactionId{
            cell.lblIdValue.text = String(idVal)
        }
        if let fnmVal = self.transactionListArr[indexPath.row].firstname{
            var fullNm = fnmVal
            if let lnmVal = self.transactionListArr[indexPath.row].lastname,lnmVal != ""{
                fullNm = fnmVal + " " + lnmVal
            }
            cell.lblNmValue.text = fullNm
        }
        if let priceVal = self.transactionListArr[indexPath.row].total{
            cell.lblAmntValue.text = "$ " + String(priceVal)
        }
        if let crncyVal = self.transactionListArr[indexPath.row].currency{
            cell.lblCrncyValue.text = crncyVal
        }
        if let panVal = self.transactionListArr[indexPath.row].maskedPAN{
            cell.lblMskValue.text = panVal
        }
        if let voiceVal = self.transactionListArr[indexPath.row].invoiceId{
            cell.lblInvoiceIdValue.text = voiceVal
        }
        if let voiceVal = self.transactionListArr[indexPath.row].createddate{
            cell.lblInvoiceIdValue.text = voiceVal
        }
        if let crdDateVal = self.transactionListArr[indexPath.row].createdDTS{
            cell.lblDateValue.text = HHelper.localToUTC(date: crdDateVal)
        }
        if let typeVal = self.transactionListArr[indexPath.row].transactionType{
            cell.lblTransTypeValue.text = typeVal
        }
        if let emailVal = self.transactionListArr[indexPath.row].email{
            cell.lblEmailValue.text = emailVal
        }
        if let stsVal = self.transactionListArr[indexPath.row].responseReasonText{
            if stsVal == "Declined" || stsVal == "Service Not Allowed"{
                cell.lblSts.textColor = UIColor.red
            }
            else{
                cell.lblSts.textColor = UIColor.green
            }
            cell.lblSts.text = stsVal
        }
        if self.transactionListArr[indexPath.row].transactionType == "STEP_AUTH"{
            cell.btnRefund.isHidden = false
            cell.btnRefund.addTarget(self, action: #selector(refundBtnTapped(_:)), for: .touchUpInside)
        }
        else{
            cell.btnRefund.isHidden = true
            cell.btnRefund.removeTarget(self, action: #selector(refundBtnTapped(_:)), for: .touchUpInside)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionListArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transTag = indexPath.row
        self.showRefundPopUp(tag: indexPath.row)
    }
}

//Mark: - Skill Delegates

extension TransactionListViewC:FilterDelegate{
    
    func getFilterDict(array: [String : Any]) {
        HHelper.showLoader()
        filterDict = array
        self.getTransactionList(pgCount: self.pageNo)
    }
}

//MARK:- Transaction Cell

class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblNm: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblAmnt: UILabel!
    @IBOutlet weak var lblMskdPan: UILabel!
    @IBOutlet weak var btnRefund: UIButton!
    @IBOutlet weak var lblIdValue: UILabel!
    @IBOutlet weak var lblNmValue: UILabel!
    @IBOutlet weak var lblCrncyValue: UILabel!
    @IBOutlet weak var lblAmntValue: UILabel!
    @IBOutlet weak var lblMskValue: UILabel!
    @IBOutlet weak var lblInvoiceIdValue: UILabel!
    @IBOutlet weak var lblInvoice: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var lblSts: UILabel!
    @IBOutlet weak var lblTransTypeValue: UILabel!
    @IBOutlet weak var lblEmailValue:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
