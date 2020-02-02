//
//  BluetoothListVw.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 24/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import UIKit

class BluetoothListVw: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var tblListVw: UITableView!
    @IBOutlet weak var popUpVw: UIView!
    
    //MARK:- Show View Method
    
    func showPopup(){
        self.tblListVw.register(nib: BluetoothListCell.className)
        self.popUpVw.animate(.fadeOutIn, curve: .easeInCubic)
        self.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 1
        }) { (suceess) -> Void in
            self.isHidden = false
        }
    }
    
    //MARK:- Hide View Method
    
    func hidePopUp(){
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            self.alpha = 0
        }) { (suceess) -> Void in
            self.isHidden = true
        }
    }
    
    @IBAction func hideTapped(_ sender: UIButton) {
        self.hidePopUp()
    }
}

