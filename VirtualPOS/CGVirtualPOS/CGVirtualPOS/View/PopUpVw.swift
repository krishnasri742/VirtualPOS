//
//  PopUpVw.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 26/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import UIKit

class PopUpVw: UIView {
    
    @IBOutlet weak var vwPopUp: UIView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    func setUpView(proTitle:String,logTitle:String){
        self.vwPopUp.roundCorners(10.0)
        self.btnProfile.setTitle(proTitle, for: .normal)
        self.btnLogout.setTitle(logTitle, for: .normal)
    }
    
    //MARK:- Show View Method
    
    func showPopup(){
        self.vwPopUp.animate(.fadeInDown, curve: .easeInCubic)
        self.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 1
        }) { (suceess) -> Void in}
    }
    
    //MARK:- Hide View Method
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
        }) { (suceess) -> Void in
            self.removeFromSuperview()
        }
    }
    
    func pushToMyProfile(){
        let profileVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: ProfileViewC.className)
        self.topMostController()?.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func hideTapped(_ sender: UIButton) {
        self.hidePopUp()
    }
    @IBAction func profileTapped(_ sender: UIButton) {
        self.hidePopUp()
        self.pushToMyProfile()
    }
    @IBAction func btnLogoutTapped(_ sender: UIButton) {
        self.hidePopUp()
        HHelper.showAlertWithAction(title: APP_NAME, message: "Are you sure want to logout?", style: .alert, actionTitles: ["Yes","No"]) { (alert) in
            switch alert.title{
            case "Yes":
                HHelper.removeProfileData()
                kAppDelegate.loginMethod()
                break
            default:
                break
            }
        }
    }
}
