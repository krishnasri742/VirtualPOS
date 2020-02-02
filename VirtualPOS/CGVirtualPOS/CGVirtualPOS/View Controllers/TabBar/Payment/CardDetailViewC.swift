//
//  CardDetailViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 01/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import UIKit

class CardDetailViewC: BaseViewC {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var txtFldCardHolderNm: UITextField!
    @IBOutlet weak var txtFldCardHolderNum: UITextField!
    @IBOutlet weak var txtFldExpiry: UITextField!
    @IBOutlet weak var txtFldCvv: UITextField!
    @IBOutlet weak var btnPayment: UIButton!
    
    //MARK:- Properties
    
    internal var formStr = ""
    internal var detailDict = [String:Any]()
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.viewControllers.remove(at: 1)
        super.setupNavigationBarTitle("", leftBarButtonsType: [.back], rightBarButtonsType: [])
        self.btnPayment.addGradientSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"), width: btnPayment.frame.width, height: btnPayment.frame.height)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setTabBarVisible(visible: false, animated: false)
    }
    func getDataFromPrevClass(str:String){
        self.formStr = str
    }
    func pushToSecondStep(){
        let tabVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: PaymentStep2WebVw.className) as! PaymentStep2WebVw
        self.detailDict["formUrl"] = self.formStr
        tabVC.getDataFromPrevClass(data: self.detailDict)
        tabVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(tabVC, animated: true)
    }
    
    @IBAction func paymentTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        guard !(txtFldCardHolderNm.text ?? "").isEmpty  else {
            HHelper.showAlert(withTitle: "", message: "Please enter card holder name", type: .error, showButton: false)
            return
        }
        guard !(txtFldCardHolderNum.text ?? "").isEmpty  else {
            HHelper.showAlert(withTitle: "", message: "Please enter card number", type: .error, showButton: false)
            return
        }
        guard !(txtFldExpiry.text ?? "").isEmpty  else {
            HHelper.showAlert(withTitle: "", message: "Please enter expiration month and year", type: .error, showButton: false)
            return
        }
        guard txtFldExpiry.text?.count == 5 else{
            HHelper.showAlert(withTitle: "", message: "Please enter expiration month and year in mm/yy format", type: .error, showButton: false)
            return
        }
        let charset = CharacterSet(charactersIn: "/")
        guard txtFldExpiry.text?.rangeOfCharacter(from: charset) != nil else{
            HHelper.showAlert(withTitle: "", message: "Please enter expiration month and year in mm/yy format", type: .error, showButton: false)
            return
        }
        guard !(txtFldCvv.text ?? "").isEmpty  else {
            HHelper.showAlert(withTitle: "", message: "Please enter expiration cvv number", type: .error, showButton: false)
            return
        }
        self.pushToSecondStep()
    }
}

extension CardDetailViewC:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtFldExpiry{
            if string == "" {
                return true
            }
            
            let currentText = textField.text! as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            textField.text = updatedText
            let numberOfCharacters = updatedText.count
            if numberOfCharacters == 2 {
                textField.text?.append("/")
            }
            return false
        }
        else if textField == txtFldCardHolderNum{
            let maxLength = 16
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        else{
            if string == "." {
                return false
            }
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                
                if textField == txtFldCardHolderNum {
                    if updatedText.count > 16 {
                        return false
                    }
                } else if textField == txtFldCvv {
                    
                    if updatedText.count > 3 {
                        return false
                    }
                } else if textField == txtFldExpiry {
                    
                    if updatedText.count > 5 {
                        return false
                    }
                }
                
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtFldCardHolderNm{
            self.detailDict["Name"] = textField.text
        }
        if textField == txtFldCardHolderNum{
            self.detailDict["cardNum"] = textField.text
        }
        if textField == txtFldCvv{
            self.detailDict["cvv"] = textField.text
        }
        if textField == txtFldExpiry{
            let txt = textField.text?.components(separatedBy: "/")
            self.detailDict["month"] = txt?.first
            self.detailDict["year"] = txt?.last
        }
    }
}
