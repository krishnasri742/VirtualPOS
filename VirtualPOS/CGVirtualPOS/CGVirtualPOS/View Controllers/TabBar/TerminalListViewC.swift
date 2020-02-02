//
//  TerminalListViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

class TerminalListViewC: BaseViewC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var tblTerminal: UITableView!
    @IBOutlet weak var lblNoTerminal: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK:- Properties
    
    let popUpView = Bundle.main.loadNibNamed(PopUpVw.className, owner: self, options: nil)! [0] as! PopUpVw
    internal var terminalListArr = [VTerminalModel]()
    internal var filterListArr = [VTerminalModel]()
    internal var refreshControl = UIRefreshControl()
    internal var isScrolling = false
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HHelper.showLoader()
        self.hideKeyboardWhenTappedAround()
        self.searchBarUIModification()
        self.getTerminalList(pgCount: 0)
        self.addRefreshControl()
        self.lblNoTerminal.isHidden = true
        super.setupNavigationBarTitle("Virtual Terminal List", leftBarButtonsType: [], rightBarButtonsType: [.profile])
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
    
    func getTerminalList(pgCount:Int){
        if let token = USER_DEFAULTS.value(forKey: kAccessToken) as? String{
            ServiceClass().getTerminalListEndPoint(token: token).then { (userResponse) -> Void in
                HHelper.hideLoader()
                self.refreshControl.endRefreshing()
                print(userResponse)
                if let suc = userResponse.success{
                    if suc{
                        if let vter = userResponse.vterminal{
                            self.terminalListArr = vter
                            self.filterListArr = self.terminalListArr
                        }
                        if self.terminalListArr.count == 0{
                            self.lblNoTerminal.isHidden = false
                        }
                        else{
                            self.lblNoTerminal.isHidden = true
                        }
                    }
                    else{
                        self.lblNoTerminal.isHidden = false
                    }
                }
                else{
                    self.lblNoTerminal.isHidden = false
                }
                self.tblTerminal.reloadData()
                }.catch { (error) in
                    self.refreshControl.endRefreshing()
                    self.lblNoTerminal.isHidden = false
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
        self.tblTerminal.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    // MARK: - Action For Refresh Control
    
    @objc func refreshData(_ sender: UIRefreshControl){
        self.getTerminalList(pgCount: 0)
    }
}

extension TerminalListViewC:UIScrollViewDelegate{
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && (!isScrolling)  && (self.terminalListArr.count) > 0){
            isScrolling = true
            let arrayCount = self.terminalListArr.count
            if arrayCount % 20 != 0{
                self.getTerminalList(pgCount: arrayCount % 20)
            }
        }
    }
}

extension TerminalListViewC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("asdvb")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchString == "" {
            self.terminalListArr = filterListArr
            self.tblTerminal.reloadData()
            self.lblNoTerminal.isHidden = true
        }
        else{
            let filteredArray = filterListArr.filter { (values:VTerminalModel) -> Bool in
                return ((values.firstname?.lowercased().contains(searchString.lowercased()) ?? false) || (values.city?.lowercased().contains(searchString.lowercased()) ?? false) || (values.lastname?.lowercased().contains(searchString.lowercased()) ?? false) || (values.phonenumber?.lowercased().contains(searchString.lowercased()) ?? false) || (values.retRefNum?.lowercased().contains(searchString.lowercased()) ?? false))
            }
            self.terminalListArr = filteredArray
            self.tblTerminal.reloadData()
        }
        if terminalListArr.count == 0{
            self.lblNoTerminal.isHidden = false
        }
        else{
            self.lblNoTerminal.isHidden = true
        }
    }
}

//MARK:- UITable View DataSources & Delegates

extension TerminalListViewC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InVoiceCell") as! InVoiceCell
        cell.selectionStyle = .none
        if let idVal = self.terminalListArr[indexPath.row].id{
            cell.lblIdValue.text = String(idVal)
        }
        if let fnmVal = self.terminalListArr[indexPath.row].firstname{
            var fullNm = fnmVal
            if let lnmVal = self.terminalListArr[indexPath.row].lastname,lnmVal != ""{
                fullNm = fnmVal + " " + lnmVal
            }
            cell.lblNmValue.text = fullNm
        }
        if let priceVal = self.terminalListArr[indexPath.row].amount{
            cell.lblAmntValue.text = "$ " + String(priceVal)
        }
        if let cityVal = self.terminalListArr[indexPath.row].city{
            cell.lblCityValue.text = cityVal
        }
        if let descVal = self.terminalListArr[indexPath.row].description{
            cell.lblDescValue.text = descVal
        }
        if let timeVal = self.terminalListArr[indexPath.row].createddate{
            cell.lblTimeDate.text = HHelper.localToUTC(date: timeVal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.terminalListArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
