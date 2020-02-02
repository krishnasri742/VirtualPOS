//
//  VirtualTerminalViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit
import DropDown
import CoreBluetooth

class VirtualTerminalViewC: BaseViewC{
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var tblTerminal: UITableView!
    @IBOutlet weak var lblConnectionStateValue: UILabel!
    @IBOutlet weak var lblDeviceAddressValue: UILabel!
    @IBOutlet weak var lblResultText: UILabel!
    @IBOutlet weak var btnConnection: UIButton!
    @IBOutlet weak var vwState: UIView!
    
    //MARK:- Properties
    
    internal var terminalArr = [["plc": "Invoice number*" ,"value":""],["plc": "Invoice amount(IN KYD)*" ,"value":""],["plc": "Select currency*" ,"value":""],["plc": "First name*" ,"value":""],["plc": "Last name" ,"value":""],["plc": "Card number*" ,"value":""],["plc": "Card expiry*" ,"value":""],["plc": "Card CVV*" ,"value":""],["plc": "Customer email*" ,"value":""],["plc": "Phone number" ,"value":""],["plc": "Address1" ,"value":""],["plc": "Select country*" ,"value":""]]
    internal var sectionArr = ["Card Information","Billing Information"]
    internal var selectedVal = "KYD"
    internal var selectedVal2 = "Cayman Islands"
    internal var amountPaid = "Amount to be paid: "
    internal var amountVal = ""
    var lib : MTSCRA!;
    var cardData : MTCardData!;
    var devicePaired : Bool?
    var isConnected = false
    var i = 0
    var invalidSwipe = IS_INVALID_SWIPE
    var deviceList:NSMutableArray!;
    let popUpView = Bundle.main.loadNibNamed(PopUpVw.className, owner: self, options: nil)! [0] as! PopUpVw
    let bluetoothPopUpView = Bundle.main.loadNibNamed(BluetoothListVw.className, owner: self, options: nil)! [0] as! BluetoothListVw
    var bluetoothModel = BluetoothDataResponseModel()
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var grdlayer = CAGradientLayer()
    let ACCEPTABLE_CHARACTERS_NUMERIC = "0123456789"
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BluetoothManager.sharedInstance.start()
        self.isConnected = false
        self.devicePaired = true
        self.lib = MTSCRA()
        self.lib?.delegate = self
        self.vwState.roundCorners(self.vwState.frame.height/2)
        self.lblDeviceAddressValue.text = ""
        self.lblResultText.text = ""
        self.disconnected()
        grdlayer = self.btnConnection.addGradientButtonSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"),btn: self.btnConnection)
        super.hideKeyboardWhenTappedAround()
    }
    override func viewDidLayoutSubviews() {
        self.grdlayer.frame = self.btnConnection.bounds
        self.btnConnection.layer.insertSublayer(grdlayer, at: 0)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.lib != nil{
            DispatchQueue.main.async(execute: {
                if self.lib.isDeviceOpened() {
                    if self.lib.isDeviceConnected() {
                        self.btnConnection.setTitle("Disconnect", for: .normal)
                    } else {
                        self.btnConnection.setTitle("CONNECT TO DEVICE", for: .normal)
                    }
                } else {
                    self.btnConnection.setTitle("CONNECT TO DEVICE", for: .normal)
                }
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.showNavigationBar()
        IS_INVALID_SWIPE = 0
        self.btnConnection.alpha = 1.0
        self.btnConnection.isEnabled = true
        self.vwState.blink()
        super.setupNavigationBarTitle("Virtual Terminal", leftBarButtonsType: [], rightBarButtonsType: [.profile])
    }
    override func profileBtnTapped() {
        self.showPopVw()
    }
    
    func cardSwipeDidStart(_ instance: AnyObject!) {
        DispatchQueue.main.async{
            self.lblResultText.text = "Transfer started...";
        }
    }
    
    func cardSwipeDidGetTransError() {
        DispatchQueue.main.async{
            self.lblResultText.text = "Transfer error...";
        }
    }
    
    func disconnected(){
        self.isConnected = false
        self.lblConnectionStateValue.text = "Disconnected"
        self.vwState.backgroundColor = UIColor.red
        self.lblDeviceAddressValue.text = ""
        self.btnConnection.setTitle("CONNECT TO DEVICE", for: .normal)
    }
    
    func connected(){
        self.isConnected = true
        self.lblConnectionStateValue.text = "Connected"
        self.vwState.backgroundColor = UIColor.green
        self.btnConnection.setTitle("Disconnect", for: .normal)
    }
    
    func connecting(){
        self.isConnected = false
        self.lblConnectionStateValue.text = "Connecting"
        self.vwState.backgroundColor = UIColor.blue
        self.btnConnection.setTitle("Connecting", for: .normal)
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
    func checkValidation() -> Bool{
        if terminalArr[0]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Invoice Number", type: .error, showButton: false)
            return false
        }
        if terminalArr[1]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Amount", type: .error, showButton: false)
            return false
        }
        if terminalArr[2]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Select your Currency", type: .error, showButton: false)
            return false
        }
        if terminalArr[3]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your First Name", type: .error, showButton: false)
            return false
        }
        if terminalArr[5]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Card Number", type: .error, showButton: false)
            return false
        }
        if terminalArr[6]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Expiry", type: .error, showButton: false)
            return false
        }
        if !IS_CARD_SWIPED{
            if terminalArr[7]["value"] == ""{
                HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Card CVV", type: .error, showButton: false)
                return false
            }
        }
        if terminalArr[8]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Email Address", type: .error, showButton: false)
            return false
        }
        if !HHelper.isValidEmail(terminalArr[8]["value"]!){
            HHelper.showAlert(withTitle: APP_NAME, message: "Enter valid Email Address", type: .error, showButton: false)
            return false
        }
//        if terminalArr[10]["value"] == ""{
//            HHelper.showAlert(withTitle: APP_NAME, message: "Enter your Address1", type: .error, showButton: false)
//            return false
//        }
        if terminalArr[11]["value"] == ""{
            HHelper.showAlert(withTitle: APP_NAME, message: "Select your Currency", type: .error, showButton: false)
            return false
        }
        return true
    }
    func pushToWebVw(){
        if cardData != nil{
            self.fillDataInModel(data: self.cardData)
        }
        if IS_CARD_SWIPED{
            bluetoothModel.cardNumber = self.cardData.cardPAN.removingWhitespaces()
        }
        else{
            bluetoothModel.cardNumber = self.terminalArr[5]["value"]?.removingWhitespaces()
        }
        let webVw = AppStoryboards.tabBar.instantiateViewController(withIdentifier: PaymentWebViewViewC.className) as! PaymentWebViewViewC
        webVw.hidesBottomBarWhenPushed = true
        var dict = [String:Any]()
        dict["amount"] = changeAmountPaid().components(separatedBy: "Amount to be paid: ").joined()
        dict["email"] = self.terminalArr[8]["value"]
        dict["currency"] = self.terminalArr[2]["value"]
        dict["country"] = self.terminalArr[11]["value"]
        bluetoothModel.fName = self.terminalArr[3]["value"]
        bluetoothModel.lName = self.terminalArr[4]["value"]
        bluetoothModel.cardExpiry = self.terminalArr[6]["value"]?.components(separatedBy: "/").joined()
        bluetoothModel.cardCvv = self.terminalArr[7]["value"]
        bluetoothData = bluetoothModel
        webVw.getDataFromPrevClass(data: dict)
        self.navigationController?.pushViewController(webVw, animated: true)
        self.clearCellData()
    }
    func clearCellData(){
        terminalArr.removeAll()
        terminalArr = [["plc": "InVoice Number*" ,"value":""],["plc": "Invoice Amount(IN KYD)*" ,"value":""],["plc": "Select Currency*" ,"value":""],["plc": "First name*" ,"value":""],["plc": "Last Name" ,"value":""],["plc": "Card Number*" ,"value":""],["plc": "Card Expiry*" ,"value":""],["plc": "Card CVV*" ,"value":""],["plc": "Customer Email*" ,"value":""],["plc": "Phone Number" ,"value":""],["plc": "Address1" ,"value":""],["plc": "Select Country*" ,"value":""]]
        selectedVal = "KYD"
        selectedVal2 = "Cayman Islands"
        amountPaid = "Amount To be Paid: --"
        bluetoothModel = BluetoothDataResponseModel()
        self.tblTerminal.reloadData()
        self.tblTerminal.scrollToTop(animation: false)
    }
    func setUpBluetoothPopUpVw(){
        if self.deviceList != nil{
            bluetoothPopUpView.frame = CGRect(x: 0, y: 0, width: MAIN_SCREEN_WIDTH, height: MAIN_SCREEN_HEIGHT)
            self.view.window?.addSubview(bluetoothPopUpView)
            bluetoothPopUpView.setNeedsLayout()
            bluetoothPopUpView.layoutIfNeeded()
            bluetoothPopUpView.tblListVw.hideEmptyCells()
            bluetoothPopUpView.tblListVw.delegate = self
            bluetoothPopUpView.tblListVw.dataSource = self
            bluetoothPopUpView.showPopup()
        }
        else{
            HHelper.showAlert(withTitle: "", message: "No card reader found,please check bluetooth/battery on the reader", type: .info, showButton: false)
        }
    }
    
    @objc func showProfile(_ sender:UIButton){
        popUpView.hidePopUp()
        self.pushToMyProfile()
    }
    @objc func payTapped(_ sender:UIButton){
        if self.checkValidation(){
            self.pushToWebVw()
        }
    }
    
    @IBAction func connectionTapped(_ sender: UIButton) {
        if BluetoothManager.sharedInstance.bluetoothPeripheralManager?.state == .init(.poweredOn){
            if sender.currentTitle == "Disconnect"{
                self.lib.clearBuffers()
                self.lib.closeDevice();
                self.lib.stopScanningForPeripherals()
                self.disconnected()
                self.clearCardData()
            }
            else{
                self.lib.setDeviceType(UInt32(MAGTEKEDYNAMO))
                self.lib.setConnectionType(UInt(UInt32(BLE_EMV)))
                if(lib != nil) && (!self.lib.isDeviceOpened()){
                    let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.lib?.startScanningForPeripherals();
                        self.setUpBluetoothPopUpVw()
                    }
                }
            }
        }
        else{
            HHelper.showAlert(withTitle: "", message: "Please enable your bluetooth to access the services", type: .info, showButton: false)
        }
    }
    
    func bleReaderStateUpdated(_ state: MTSCRABLEState) {
        if state == UNSUPPORTED{
            HHelper.showAlert(title: "Bluetooth LE Error", "Bluetooth LE is unsupported on this device")
        }
    }
    func bleReaderDidDiscoverPeripheral(){
        if i == 0{
            deviceList = lib?.getDiscoveredPeripherals();
            self.bluetoothPopUpView.tblListVw.reloadData();
        }
    }
    func didSelectBLEReader(_ per: CBPeripheral) {
        i = 1
        self.lib.delegate = self;
        self.lib.setAddress(per.identifier.uuidString);
        self.lblDeviceAddressValue.text = ""
        self.lib.openDevice();
    }
}

//MARK:- UITable View DataSources & Delegates

extension VirtualTerminalViewC:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.bluetoothPopUpView.tblListVw{
            if(deviceList == nil) {return 0;}
            return deviceList.count;
        }
        else{
            switch section {
            case 0:
                return 3
            case 1:
                return 5
            default:
                return 5
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == bluetoothPopUpView.tblListVw{
            return 1
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bluetoothPopUpView.tblListVw{
            let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothListCell.className) as! BluetoothListCell
            cell.selectionStyle = .none
            cell.lblValue.text = (deviceList?.object(at: indexPath.row) as! CBPeripheral).name;
            return cell
        }
        else{
            switch indexPath.section{
            case 0:
                switch indexPath.row {
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
                    cell.selectionStyle = .none
                    cell.lblDropDownValue.text = self.selectedVal
                    cell.lblDropDownValue.textColor = UIColor.black
                    self.terminalArr[indexPath.row]["value"] = self.selectedVal
                    cell.lblAmountPaid.isHidden = false
                    cell.lblAmountPaid.text = amountPaid
                    cell.btnDropDown.tag = indexPath.row
                    cell.btnDropDown.addTarget(self, action: #selector(openDrop(_:)), for: .touchUpInside)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: BillDetailCell.className) as! BillDetailCell
                    cell.selectionStyle = .none
                    cell.textField.tag = indexPath.row
                    cell.textField.delegate = self
                    cell.textField.keyboardType = .numberPad
                    cell.textField.isSecureTextEntry = false
                    let snapshot = terminalArr[indexPath.row]
                    cell.configureCell(itemPlc: snapshot["plc"]!, item: snapshot["value"]!)
                    cell.hideEye()
                    return cell
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: BillDetailCell.className) as! BillDetailCell
                cell.selectionStyle = .none
                cell.textField.tag = indexPath.row
                cell.textField.delegate = self
                let snapshot = terminalArr[indexPath.row + 3]
                cell.configureCell(itemPlc: snapshot["plc"]!, item: snapshot["value"]!)
                if indexPath.row == 4{
                    cell.textField.isSecureTextEntry = true
                    cell.showEye()
                }
                else{
                    cell.textField.isSecureTextEntry = false
                    cell.hideEye()
                }
                switch indexPath.row{
                case 2,3,4:
                    cell.textField.keyboardType = .numberPad
                    cell.textField.autocapitalizationType = .none
                default:
                    cell.textField.keyboardType = .default
                    cell.textField.autocapitalizationType = .words
                }
                return cell
            default:
                switch indexPath.row{
                case 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.className) as! ButtonCell
                    cell.selectionStyle = .none
                    cell.button.tag = indexPath.row
                    cell.button.addTarget(self, action: #selector(payTapped(_:)), for: .touchUpInside)
                    cell.button.setTitle("PROCEED TO PAY", for: .normal)
                    cell.button.addGradientSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"), width: cell.button.frame.width, height: cell.button.frame.height)
                    return cell
                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
                    cell.selectionStyle = .none
                    cell.btnDropDown.tag = indexPath.row
                    cell.lblDropDownValue.text = self.selectedVal2
                    cell.lblDropDownValue.textColor = UIColor.black
                    self.terminalArr[11]["value"] = self.selectedVal2
                    cell.lblAmountPaid.isHidden = true
                    cell.btnDropDown.addTarget(self, action: #selector(openDrop(_:)), for: .touchUpInside)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: BillDetailCell.className) as! BillDetailCell
                    cell.selectionStyle = .none
                    cell.textField.tag = indexPath.row
                    cell.textField.delegate = self
                    cell.textField.isSecureTextEntry = false
                    cell.hideEye()
                    switch indexPath.row{
                    case 0:
                        cell.textField.keyboardType = .emailAddress
                        break
                    case 1:
                        cell.textField.keyboardType = .numberPad
                        break
                    default:
                        cell.textField.keyboardType = .default
                        break
                    }
                    let snapshot = terminalArr[indexPath.row + 8]
                    cell.configureCell(itemPlc: snapshot["plc"]!, item: snapshot["value"]!)
                    return cell
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.bluetoothPopUpView.tblListVw{
            return 60.0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.bluetoothPopUpView.tblListVw{
            return UIView()
        }
        else{
            switch section{
            case 1:
                let headerView = HeaderVw.instansiateFromNib()
                headerView.lblHeader.text = sectionArr[0]
                return headerView
            case 2:
                let headerView = HeaderVw.instansiateFromNib()
                headerView.lblHeader.text = sectionArr[1]
                return headerView
            default:
                break
            }
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.bluetoothPopUpView.tblListVw{
            return 0.0
        }
        else{
            switch section {
            case 0:
                return 0
            default:
                return 60
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.bluetoothPopUpView.tblListVw{
            self.bluetoothPopUpView.hidePopUp()
            didSelectBLEReader(self.deviceList?.object(at: indexPath.row) as! CBPeripheral)
        }
    }
    
    @objc func openDrop(_ sender:UIButton){
        let dropDwn = DropDown()
        let tag = sender.tag
        var section = 0
        if tag == 2{
            dropDwn.dataSource = CURRENCY_ARR
            section = 0
        }
        else{
            dropDwn.dataSource = ["Cayman Islands","United States"]
            section = 1
        }
        let indexPath = IndexPath(row: tag, section: section)
        if let cell = self.tblTerminal.cellForRow(at: indexPath) as? DropDownCell{
            dropDwn.heightt = 100.0
            dropDwn.cellHeight = 40.0
            dropDwn.width = 100.0
            dropDwn.textFont = UIFont.init(name: "RobotoCondensed-Regular", size: 14.0)!
            dropDwn.direction = .bottom
            dropDwn.width = self.view.frame.width - 40
            dropDwn.anchorView = cell.vwAnchor
            dropDwn.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                if tag == 2{
                    self.selectedVal = item
                    self.terminalArr[tag]["value"] = item
                    self.amountPaid = self.changeAmountPaid()
                    self.tblTerminal.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                }
                else{
                    self.selectedVal2 = item
                    self.terminalArr[11]["value"] = item
                }
                cell.lblDropDownValue.text = item
                cell.lblDropDownValue.textColor = UIColor.black
            }
            dropDwn.show()
        }
    }
}

extension VirtualTerminalViewC:MTSCRAEventDelegate{
    
    func onDeviceError(_ error: Error!) {
        print(error.localizedDescription)
    }
    
    func onDeviceResponse(_ data: Data!) {
        print(data as Any)
    }
    
    func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: Any!) {
        self.connecting()
        if((instance as! MTSCRA).isDeviceOpened() && self.lib.isDeviceConnected()){
            if(connected){
                if self.lib.isDeviceConnected() && self.lib.isDeviceOpened(){
                    self.btnConnection.setTitle("Disconnect", for: .normal)
                    let opsQue = OperationQueue()
                    let op1 = Operation()
                    let op2 = Operation()
                    if deviceType == MAGTEKEDYNAMO{
                        if ((instance as? MTSCRA)?.getConnectedPeripheral().name) != nil {
                            self.connected()
                        }
                        if !self.devicePaired! {
                            return
                        }
                    } else {
                        op1.completionBlock = {
                            self.connected() // @"Connected...";
                            opsQue.addOperation(op2)
                        }}}}
            else{
                self.devicePaired = true
                self.disconnected()
            }}
        else{
            self.devicePaired = true
            self.disconnected()
        }}
    
    func onDeviceExtendedResponse(_ data: String!) {
        print(data as Any)
    }
    
    func onDataReceived(_ cardDataObj: MTCardData!, instance: Any!) {
        DispatchQueue.main.async{
            let responseStr = String(format:  "Track.Status: %@\n\nTrack1.Status: %@\n\nTrack2.Status: %@\n\nTrack3.Status: %@\n\nEncryption.Status: %@\n\nBattery.Level: %ld\n\nSwipe.Count: %ld\n\nTrack.Masked: %@\n\nTrack1.Masked: %@\n\nTrack2.Masked: %@\n\nTrack3.Masked: %@\n\nTrack1.Encrypted: %@\n\nTrack2.Encrypted: %@\n\nTrack3.Encrypted: %@\n\nCard.PAN: %@\n\nMagnePrint.Encrypted: %@\n\nMagnePrint.Length: %i\n\nMagnePrint.Status: %@\n\nSessionID: %@\n\nCard.IIN: %@\n\nCard.Name: %@\n\nCard.Last4: %@\n\nCard.ExpDate: %@\n\nCard.ExpDateMonth: %@\n\nCard.ExpDateYear: %@\n\nCard.SvcCode: %@\n\nCard.PANLength: %ld\n\nKSN: %@\n\nDevice.SerialNumber: %@\n\nMagTek SN: %@\n\nFirmware Part Number: %@\n\nDevice Model Name: %@\n\nTLV Payload: %@\n\nDeviceCapMSR: %@\n\nOperation.Status: %@\n\nCard.Status: %@\n\nRaw Data: \n\n%@",
                                     cardDataObj.trackDecodeStatus,
                                     cardDataObj.track1DecodeStatus,
                                     cardDataObj.track2DecodeStatus,
                                     cardDataObj.track3DecodeStatus,
                                     cardDataObj.encryptionStatus,
                                     cardDataObj.batteryLevel,
                                     cardDataObj.swipeCount,
                                     cardDataObj.maskedTracks,
                                     cardDataObj.maskedTrack1,
                                     cardDataObj.maskedTrack2,
                                     cardDataObj.maskedTrack3,
                                     cardDataObj.encryptedTrack1,
                                     cardDataObj.encryptedTrack2,
                                     cardDataObj.encryptedTrack3,
                                     cardDataObj.cardPAN,
                                     cardDataObj.encryptedMagneprint,
                                     cardDataObj.magnePrintLength,
                                     cardDataObj.magneprintStatus,
                                     cardDataObj.encrypedSessionID,
                                     cardDataObj.cardIIN,
                                     cardDataObj.cardName,
                                     cardDataObj.cardLast4,
                                     cardDataObj.cardExpDate,
                                     cardDataObj.cardExpDateMonth,
                                     cardDataObj.cardExpDateYear,
                                     cardDataObj.cardServiceCode,
                                     cardDataObj.cardPANLength,
                                     cardDataObj.deviceKSN,
                                     cardDataObj.deviceSerialNumber,
                                     cardDataObj.deviceSerialNumberMagTek,
                                     cardDataObj.firmware,
                                     cardDataObj.deviceName,
                                     (instance as! MTSCRA).getTLVPayload(),
                                     cardDataObj.deviceCaps,
                                     (instance as! MTSCRA).getOperationStatus(),
                                     cardDataObj.cardStatus,
                                     (instance as! MTSCRA).getResponseData());
            if cardDataObj.encryptedTrack1 != "" && cardDataObj.encryptedTrack2 != "" && cardDataObj.cardPAN != "" && cardDataObj.deviceKSN != "" && cardDataObj.deviceSerialNumber != ""{
                self.lblDeviceAddressValue.text = cardDataObj.deviceSerialNumber
                self.cardData = cardDataObj
                self.setDataInTable(data: cardDataObj!)
                IS_CARD_SWIPED = true
            }
            else{
                self.invalidSwipe += 1
                self.disableConnectionButton()
            }
            print(self.invalidSwipe)
            print(responseStr)
        }
    }
    
    func disableConnectionButton(){
        if self.invalidSwipe == 4{
            self.btnConnection.alpha = 0.5
            self.btnConnection.isEnabled = false
            HHelper.showAlert(title: APP_NAME, "You have reached maximum number of invalid swipes. Please enter data manually now")
        }
        else{
            self.btnConnection.alpha = 1.0
            self.btnConnection.isEnabled = true
            HHelper.showAlert(title: APP_NAME, "We are unable to access your data. Please swipe again")
        }
    }
    
    func setDataInTable(data: MTCardData){
        var fName = ""
        var lName = ""
        var cNumber = ""
        var cExp = ""
        let name = data.cardLastName.components(separatedBy: " ")
        fName = "\(name.first ?? "")"
        if name.count > 1{
            lName = "\(name[1])"
        }
        else{
            lName = ""
        }
        cNumber = "XXXX XXXX XXXX " + data.cardLast4
//        cNumber = data.cardIIN + "XX XXXX " + data.cardLast4
        let expDt = data.cardExpDate.pairs
        cExp = "\(expDt[1])\(expDt[0])"
        if fName.containsOnlyLetters(input: fName){
            self.terminalArr[3].updateValue(fName, forKey: "value")
            self.terminalArr[4].updateValue(lName, forKey: "value")
        }
        self.terminalArr[5].updateValue(cNumber, forKey: "value")
        self.terminalArr[6].updateValue(cExp, forKey: "value")
        self.tblTerminal.reloadData()
    }
    func fillDataInModel(data: MTCardData){
        bluetoothModel.billing_magnesafe_devicesn = data.deviceSerialNumber.removingWhitespaces()
        bluetoothModel.billing_magnesafe_ksn = data.deviceKSN.removingWhitespaces()
        bluetoothModel.billing_magnesafe_magneprint_status = data.magneprintStatus.removingWhitespaces()
        bluetoothModel.billing_magnesafe_track_1 = data.encryptedTrack1.removingWhitespaces()
        bluetoothModel.billing_magnesafe_track_2 = data.encryptedTrack2.removingWhitespaces()
        bluetoothModel.billing_magnesafe_track_3 = data.encryptedTrack3.removingWhitespaces()
        bluetoothModel.billing_magnesafe_magneprint = data.encryptedMagneprint.removingWhitespaces()
    }
    func clearCardData(){
        self.terminalArr[3].updateValue("", forKey: "value")
        self.terminalArr[4].updateValue("", forKey: "value")
        self.terminalArr[5].updateValue("", forKey: "value")
        self.terminalArr[6].updateValue("", forKey: "value")
        self.tblTerminal.reloadData()
    }
    func changeAmountPaid() -> String{
        var val = ""
        var percent = 0.0
        let subTotal = Double(amountVal) ?? 0
        percent = subTotal / 0.82
        if self.selectedVal == "KYD"{
            val = "Amount to be paid: \(String(format: "%.2f", subTotal))"
        }
        else{
            val = "Amount to be paid: \(String(format: "%.2f", percent))"
        }
        return val
    }
}

extension VirtualTerminalViewC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text as Any)
        if let indexPath = HHelper.getIndexPathFor(view: textField, tableView: self.tblTerminal){
            switch indexPath.section{
            case 0:
                terminalArr[indexPath.row]["value"] = textField.text
                if indexPath.row == 1{
                    if textField.text != ""{
                        self.amountVal = textField.text!
                        self.amountPaid = self.changeAmountPaid()
                        self.tblTerminal.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                    }
                }
            case 1:
                terminalArr[indexPath.row + 3]["value"] = textField.text
            default:
                terminalArr[indexPath.row + 8]["value"] = textField.text
                break
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let indexPath = HHelper.getIndexPathFor(view: textField, tableView: self.tblTerminal){
            if indexPath.section == 0 && indexPath.row == 1{
                if let cell = self.tblTerminal.cellForRow(at: indexPath) as? BillDetailCell{
                    if textField == cell.textField {
                        if string == "" {
                            return true
                        }
                        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS_NUMERIC).inverted
                        let filtered = string.components(separatedBy: cs).joined(separator: "")
                        let currentCharacterCount = textField.text?.count ?? 0
                        if (range.length + range.location > currentCharacterCount){
                            return false
                        }
                        let newLength = currentCharacterCount + string.count - range.length
                        return newLength <= 5 && (string == filtered)
                    }
                }
            }
            if indexPath.section == 1 && indexPath.row == 2{
                if let cell = self.tblTerminal.cellForRow(at: indexPath) as? BillDetailCell{
                    if textField == cell.textField {
                        if string == "" {
                            return true
                        }
                        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS_NUMERIC).inverted
                        let filtered = string.components(separatedBy: cs).joined(separator: "")
                        let currentCharacterCount = textField.text?.count ?? 0
                        if (range.length + range.location > currentCharacterCount){
                            return false
                        }
                        if currentCharacterCount == 4 || currentCharacterCount == 9 || currentCharacterCount == 14 || currentCharacterCount == 19{
                            textField.text?.append(" ")
                        }
                        let newLength = currentCharacterCount + string.count - range.length
                        return newLength <= 23 && (string == filtered)
                    }
                }
            }
            if indexPath.section == 1 && indexPath.row == 3{
                if let cell = self.tblTerminal.cellForRow(at: indexPath) as? BillDetailCell{
                    if textField == cell.textField {
                        if string == "" {
                            return true
                        }
                        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS_NUMERIC).inverted
                        let filtered = string.components(separatedBy: cs).joined(separator: "")
                        let currentCharacterCount = textField.text?.count ?? 0
                        if (range.length + range.location > currentCharacterCount){
                            return false
                        }
                        if currentCharacterCount == 2{
                            textField.text?.append("/")
                        }
                        let newLength = currentCharacterCount + string.count - range.length
                        return newLength <= 5 && (string == filtered)
                    }
                }
            }
            if indexPath.section == 1 && indexPath.row == 4{
                if let cell = self.tblTerminal.cellForRow(at: indexPath) as? BillDetailCell{
                    if textField == cell.textField {
                        let maxLength = 4
                        let currentString: NSString = textField.text! as NSString
                        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                        return newString.length <= maxLength
                    }
                }
            }
            if indexPath.section == 2 && indexPath.row == 1{
                if let cell = self.tblTerminal.cellForRow(at: indexPath) as? BillDetailCell{
                    guard let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
                    if textField == cell.textField {
                        textField.text = currentText.toPhoneNumber()
                        return false
                    }
                }
            }
            else{
                return true
            }
        }
        return true
    }
}


extension VirtualTerminalViewC : CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(peripheral.state)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unauthorized: break
        case .unknown: break
        case .unsupported: break
        case .poweredOn:
            print("ON")
        case .poweredOff:
            break
        case .resetting: break
        default: break
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        
        centralManager?.connect(peripheral, options: nil)
        centralManager?.stopScan()
    }
}
