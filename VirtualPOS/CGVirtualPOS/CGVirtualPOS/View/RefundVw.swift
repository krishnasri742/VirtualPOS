//
//  RefundVw.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 02/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import Foundation
import UIKit

class RefundVw: UIView {
    
    @IBOutlet weak var lblTransIdValue: UILabel!
    @IBOutlet weak var lblFirstnmValue: UILabel!
    @IBOutlet weak var lblLastNmValue: UILabel!
    @IBOutlet weak var lblTransactionId2Value: UILabel!
    @IBOutlet weak var lblResponseValue: UILabel!
    @IBOutlet weak var lblTransactionTypeValue: UILabel!
    @IBOutlet weak var lblAmountValue: UILabel!
    @IBOutlet weak var lblRefundAmnt: UILabel!
    @IBOutlet weak var txtFldRefundAmnt: UITextField!
    @IBOutlet weak var btnRefund: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var heightPopUpVw: NSLayoutConstraint!
    @IBOutlet weak var refndPopUpVw: UIView!
    @IBOutlet weak var pswdPopUpVw: UIView!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var txtFldPswd: UITextField!
    
    @IBAction func hide(_ sender: UIButton) {
        self.hidePopUp()
    }
    
    //MARK:- Show View Method
    
    func showPopup(){
        self.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 1
        }) { (suceess) -> Void in
            self.isHidden = false
        }
    }
    
    //MARK:- Hide View Method
    
    func hidePopUp(){
        self.endEditing(true)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
        }) { (suceess) -> Void in
            self.isHidden = true
        }
    }
    
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.hidePopUp()
    }
    
    func setUpData(transId:String,frstNm:String,lstNm:String,transId2:String,rspnsType:String,transType:String,amnt:String,refnd:String){
        self.lblTransIdValue.text = transId
        self.lblFirstnmValue.text = frstNm
        self.lblLastNmValue.text = lstNm
        self.lblTransactionId2Value.text = transId2
        self.lblResponseValue.text = rspnsType
        self.lblTransactionTypeValue.text = transType
        self.lblAmountValue.text = refnd
//        self.lblRefundAmnt.text = refnd
    }
    
}
