//
//  PaymentErrorViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 01/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import UIKit

class PaymentErrorViewC: BaseViewC {

    @IBOutlet weak var imgError: UIImageView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var lblDescError: UILabel!
    
    var grdlayer = CAGradientLayer()
    var desc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblDescError.text = self.desc
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
    
    func getDataFromPrevClas(descData:String){
        self.desc = descData
    }
    @IBAction func homeTaped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
