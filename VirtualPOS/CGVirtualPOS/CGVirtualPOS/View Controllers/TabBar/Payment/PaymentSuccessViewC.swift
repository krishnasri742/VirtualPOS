//
//  PaymentSuccessViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 01/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import UIKit

class PaymentSuccessViewC: BaseViewC {
    
    @IBOutlet weak var imgSuccess: UIImageView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var lblDetail: UILabel!
    
    var grdlayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grdlayer = self.btnHome.addGradientButtonSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"),btn: self.btnHome)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        super.hideNavigationBar()
    }
    override func viewDidLayoutSubviews() {
        self.grdlayer.frame = self.btnHome.bounds
        self.btnHome.layer.insertSublayer(grdlayer, at: 0)
    }
    func getDataFromPrevClass(amnt:String,transID:String,crdNmbr:String,crncy:String){
        HHelper.showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            HHelper.hideLoader()
            self.lblDetail.text = "Transaction Details:\n\nTransaction ID: \(transID)\nMASKED PAN: \(crdNmbr)\nAmount: \(amnt) \(crncy)"
        }
    }
    
    @IBAction func homeTapped(_ sender: UIButton) {
        IS_CARD_SWIPED = false
        IS_INVALID_SWIPE = 0
        self.navigationController?.popToRootViewController(animated: true)
    }
}
