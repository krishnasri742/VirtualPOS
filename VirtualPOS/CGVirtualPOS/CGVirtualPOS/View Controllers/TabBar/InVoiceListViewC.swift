//
//  InVoiceListViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

class InVoiceListViewC: BaseViewC {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var tblInVoice: UITableView!
    @IBOutlet weak var lblNoInvoice: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK:- Properties
    
    let popUpView = Bundle.main.loadNibNamed(PopUpVw.className, owner: self, options: nil)! [0] as! PopUpVw
    internal var inVoiceListArr = [VTerminalModel]()
    internal var filterListArr = [VTerminalModel]()
    internal var refreshControl = UIRefreshControl()
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HHelper.showLoader()
        self.hideKeyboardWhenTappedAround()
        self.searchBarUIModification()
        self.getInVoiceList()
        self.addRefreshControl()
        self.lblNoInvoice.isHidden = true
        super.setupNavigationBarTitle("Invoice List", leftBarButtonsType: [], rightBarButtonsType: [.profile])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.searchBar.text = ""
    }
    override func profileBtnTapped() {
        self.showPopVw()
    }
    
    private func searchBarUIModification() {
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.backgroundColor = UIColor.clear
        textField.attributedPlaceholder = NSAttributedString(string:"Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font: UIFont.init(name: "RobotoCondensed-Regular", size: 16.0) as Any])
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 10.0, vertical: 0.0)
        searchBar.backgroundImage = UIImage()
        searchBar.setImage(#imageLiteral(resourceName: "searchImg"), for: .search, state: .normal)
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
    
    @objc func showProfile(_ sender:UIButton){
        popUpView.hidePopUp()
        self.pushToMyProfile()
    }
    
    func getInVoiceList(){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            ServiceClass().getInVoiceListEndPoint(token: token).then { (userResponse) -> Void in
                HHelper.hideLoader()
                self.refreshControl.endRefreshing()
                print(userResponse)
                if let suc = userResponse.success{
                    if suc{
                        if let vter = userResponse.invoices{
                            self.inVoiceListArr = vter
                            self.filterListArr = self.inVoiceListArr
                        }
                        if self.inVoiceListArr.count == 0{
                            self.lblNoInvoice.isHidden = false
                        }
                        else{
                            self.lblNoInvoice.isHidden = true
                        }
                    }
                    else{
                        self.lblNoInvoice.isHidden = false
                    }
                }
                else{
                    self.lblNoInvoice.isHidden = false
                }
                self.tblInVoice.reloadData()
                }.catch { (error) in
                    self.refreshControl.endRefreshing()
                    self.lblNoInvoice.isHidden = false
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
        self.tblInVoice.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    // MARK: - Action For Refresh Control
    
    @objc func refreshData(_ sender: UIRefreshControl){
        self.getInVoiceList()
    }
}

//MARK:- UITableView Delegate & DataSources

extension InVoiceListViewC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InVoiceCell") as! InVoiceCell
        cell.selectionStyle = .none
        if let idVal = self.inVoiceListArr[indexPath.row].id{
            cell.lblIdValue.text = String(idVal)
        }
        if let fnmVal = self.inVoiceListArr[indexPath.row].firstname{
            var fullNm = fnmVal
            if let lnmVal = self.inVoiceListArr[indexPath.row].lastname,lnmVal != ""{
                fullNm = fnmVal + " " + lnmVal
            }
            cell.lblNmValue.text = fullNm
        }
        if let priceVal = self.inVoiceListArr[indexPath.row].amount{
            cell.lblAmntValue.text = "$ " + String(priceVal)
        }
        if let cityVal = self.inVoiceListArr[indexPath.row].city{
            cell.lblCityValue.text = cityVal
        }
        if let descVal = self.inVoiceListArr[indexPath.row].description{
            cell.lblDescValue.text = descVal
        }
        if let timeVal = self.inVoiceListArr[indexPath.row].createddate{
            cell.lblTimeDate.text = HHelper.localToUTC(date: timeVal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inVoiceListArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension InVoiceListViewC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchString == "" {
            self.inVoiceListArr = filterListArr
            self.tblInVoice.reloadData()
            self.lblNoInvoice.isHidden = true
        }
        else{
            let filteredArray = filterListArr.filter { (values:VTerminalModel) -> Bool in
                return ((values.firstname?.lowercased().contains(searchString.lowercased()) ?? false) || (values.city?.lowercased().contains(searchString.lowercased()) ?? false) || (values.lastname?.lowercased().contains(searchString.lowercased()) ?? false) || (values.phonenumber?.lowercased().contains(searchString.lowercased()) ?? false) || (values.retRefNum?.lowercased().contains(searchString.lowercased()) ?? false))
            }
            self.inVoiceListArr = filteredArray
            self.tblInVoice.reloadData()
        }
        if inVoiceListArr.count == 0{
            self.lblNoInvoice.isHidden = false
        }
        else{
            self.lblNoInvoice.isHidden = true
        }
    }
}

//MARK:- InVoice Cell

class InVoiceCell: UITableViewCell {
    
    @IBOutlet weak var lblTimeDate: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblNm: UILabel!
    @IBOutlet weak var lblAmnt: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblIdValue: UILabel!
    @IBOutlet weak var lblNmValue: UILabel!
    @IBOutlet weak var lblAmntValue: UILabel!
    @IBOutlet weak var lblCityValue: UILabel!
    @IBOutlet weak var lblDescValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
