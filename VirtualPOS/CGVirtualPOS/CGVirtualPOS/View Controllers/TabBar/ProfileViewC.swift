//
//  ProfileViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 26/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

class ProfileViewC: BaseViewC {

    @IBOutlet weak var tblProfile: UITableView!
    
    internal var profileDict = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupNavigationBarTitle("My Profile", leftBarButtonsType: [.back], rightBarButtonsType: [])
        self.getDataFromUserDefaults()
        self.tblProfile.hideEmptyCells()
    }
    
    func getDataFromUserDefaults(){
        var det = [String:Any]()
        if let usrNm = USER_DEFAULTS.value(forKey: kName) as? String{
            det["n"] = "Name:"
            det["v"] = usrNm
            profileDict.insert(det, at: 0)
        }
        else{
            det["n"] = "Name:"
            det["v"] = ""
            profileDict.insert(det, at: 0)
        }
        if let usrEml = USER_DEFAULTS.value(forKey: kEmail) as? String{
            det["n"] = "Email:"
            det["v"] = usrEml
            profileDict.insert(det, at: 1)
        }
        else{
            det["n"] = "Email:"
            det["v"] = ""
            profileDict.insert(det, at: 1)
        }
        if let usrUrl = USER_DEFAULTS.value(forKey: kUrl) as? String{
            det["n"] = "URL:"
            det["v"] = usrUrl
            profileDict.insert(det, at: 2)
        }
        else{
            det["n"] = "URL:"
            det["v"] = ""
            profileDict.insert(det, at: 2)
        }
        self.tblProfile.reloadData()
    }
}

extension ProfileViewC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordButtonCell") as! ChangePasswordButtonCell
            cell.selectionStyle = .none
            cell.btnChangePswd.addTarget(self, action: #selector(passwordTapped(_:)), for: .touchUpInside)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileValueCell") as! ProfileValueCell
            cell.selectionStyle = .none
            let snapshot = self.profileDict[indexPath.row]
            cell.lblName.text = snapshot["n"] as? String
            if let val = snapshot["v"] as? String{
                cell.lblValue.text = val
            }
            else{
                cell.lblValue.text = "Not Found"
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func passwordTapped(_ sender:UIButton){
        self.pushToChangePswd()
    }
    
    internal func pushToChangePswd(){
        let chngePswdVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: ChangePasswordViewC.className)
        self.navigationController?.pushViewController(chngePswdVC, animated: true)
    }
}

//MARK:- Profile Cell

class ProfileValueCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Profile Cell

class ChangePasswordButtonCell: UITableViewCell {
    
    @IBOutlet weak var btnChangePswd: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
