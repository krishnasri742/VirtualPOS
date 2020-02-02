//
//  FilterViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 30/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit
import DropDown

protocol FilterDelegate{
    func getFilterDict(array:[String:Any])
}

class FilterViewC: BaseViewC {

     //MARK:- IBOutlets
    
    @IBOutlet weak var tblFilter: UITableView!
    @IBOutlet weak var vwDatePicker:UIView!
    @IBOutlet weak var datePicker:UIDatePicker!
    
     //MARK:- Properties
    
    internal var plcFilter = ["Select Sort Direction","Sorted By","Select Date","Search Response","Transaction Type","Select Currency"]
    internal var resArr = [String]()
    internal var transArr = [String]()
    internal var fromDate = Date()
    internal var toDate = Date()
    internal var filterDict = [String:Any]()
    internal var delegate:FilterDelegate?
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setUpDatePicker()
        self.vwDatePicker.isHidden = true
        super.setupNavigationBarTitle("Filter", leftBarButtonsType: [.cross], rightBarButtonsType: [.reset])
    }
    override func resetBtnTapped() {
        tagForDatePicker = 0
        isEditDate = false
        plcFilter = ["Select Sort Direction","Sorted By","Select Date","Search Response","Transaction Type","Select Currency"]
        self.filterDict.removeAll()
        self.tblFilter.reloadData()
        delegate?.getFilterDict(array: self.filterDict)
        self.dismiss(animated: true, completion: nil)
    }
    override func crossBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    override func backButton() {
        self.vwDatePicker.isHidden = true
    }
    override func nextButton() {
        isEditDate = false
        self.vwDatePicker.isHidden = true
        tagForDatePicker = self.datePicker.tag
        if tagForDatePicker == 101{
            self.fromDate = self.datePicker.date
        }
        else if tagForDatePicker == 100{
            self.toDate = self.datePicker.date
        }
        self.tblFilter.reloadData()
    }
    func getDataFromPrevClass(responseArr:[String],transactionArr:[String],fDict:[String:Any]){
        self.resArr = responseArr
        self.transArr = transactionArr
        if fDict.count > 0{
            self.filterDict = fDict
            if let dir = self.filterDict["SortDirection"] as? String,dir != ""{
                self.plcFilter.remove(at: 0)
                self.plcFilter.insert(dir, at: 0)
            }
            if let sortedBy = self.filterDict["SortBy"] as? String,sortedBy != ""{
                self.plcFilter.remove(at: 1)
                self.plcFilter.insert(sortedBy, at: 1)
            }
            if let searchRes = self.filterDict["SearchRes"] as? String,searchRes != ""{
                self.plcFilter.remove(at: 3)
                self.plcFilter.insert(searchRes, at: 3)
            }
            if let transType = self.filterDict["TransType"] as? String,transType != ""{
                self.plcFilter.remove(at: 4)
                self.plcFilter.insert(transType, at: 4)
            }
            if let currncy = self.filterDict["Currency"] as? String,currncy != ""{
                self.plcFilter.remove(at: 5)
                self.plcFilter.insert(currncy, at: 5)
            }
        }
    }
    func setUpDatePicker(){
        self.datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        var view = UIView()
        view = super.setBottomViewWithKeyBoard(leftTitle: "Cancel", rightTitle: "Done", isShowleftView: false, isShowRightView: false)!
        vwDatePicker.addSubview(view)
        vwDatePicker.bringSubviewToFront(self.view)
    }
}

 //MARK:- UITableView Delegates & Data Sources

extension FilterViewC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ChangePswdButtonCell.className) as! ChangePswdButtonCell
            cell.selectionStyle = .none
            cell.btn.addGradientSublayer(topColor: UIColor.colorWithHexString("1286de"), bottomColor:UIColor.colorWithHexString("034C81"), width: cell.btn.frame.width, height: cell.btn.frame.height)
            cell.btn.setTitle("APPLY", for: .normal)
            cell.btn.addTarget(self, action: #selector(applyTapped(_:)), for: .touchUpInside)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterPickerCell.className) as! FilterPickerCell
            cell.selectionStyle = .none
            if isEditDate{
                 cell.txtFldFrom.text = HHelper.getDateStringWithDate("dd-MM-YYYY", date: filterFrmDate)
                 cell.txtFldTo.text = HHelper.getDateStringWithDate("dd-MM-YYYY", date: filterToDate)
            }
            else{
                if tagForDatePicker == 101{
                    cell.txtFldFrom.text = HHelper.getDateStringWithDate("dd-MM-YYYY", date: fromDate)
                }
                else if tagForDatePicker == 100{
                    cell.txtFldTo.text = HHelper.getDateStringWithDate("dd-MM-YYYY", date: toDate)
                }
                else{
                    cell.txtFldTo.text = ""
                    cell.txtFldFrom.text = ""
                }
            }
            cell.lblTop.text = "Date Range"
            cell.btnTo.addTarget(self, action: #selector(toTapped(_:)), for: .touchUpInside)
            cell.btnFrom.addTarget(self, action: #selector(fromTapped(_:)), for: .touchUpInside)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: DropDownCell.className) as! DropDownCell
            cell.selectionStyle = .none
            cell.lblDropDownValue.text = plcFilter[indexPath.row]
            cell.lblDropDownValue.textColor = UIColor.black
            cell.btnDropDown.tag = indexPath.row
            cell.btnDropDown.addTarget(self, action: #selector(openDrop(_:)), for: .touchUpInside)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 6{
            return UITableView.automaticDimension
        }
        return 80
    }
    
    @objc func openDrop(_ sender:UIButton){
        self.vwDatePicker.isHidden = true
        let dropDwn = DropDown()
        let tag = sender.tag
        //        var section = 0
        switch tag {
        case 0:
            dropDwn.dataSource = ["Ascending(Asc.)","Descending(Desc.)"]
        case 1:
            dropDwn.dataSource = ["Transaction Id","First Name","Last Name","Currency","Total","Response Reason","Created Date","Masked PAN"]
        case 3:
            dropDwn.dataSource = self.resArr
        case 4:
            dropDwn.dataSource = self.transArr
        case 5:
            dropDwn.dataSource = CURRENCY_ARR
        default:
            break
        }
        let indexPath = IndexPath(row: tag, section: 0)
        if let cell = self.tblFilter.cellForRow(at: indexPath) as? DropDownCell{
            dropDwn.heightt = 100.0
            dropDwn.cellHeight = 40.0
            dropDwn.width = 100.0
            dropDwn.textFont = UIFont.init(name: "RobotoCondensed-Regular", size: 14.0)!
            dropDwn.direction = .bottom
            dropDwn.width = self.view.frame.width - 40
            dropDwn.anchorView = cell.vwAnchor
            dropDwn.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                switch tag {
                case 0:
                    var dir = ""
                    if item == "Descending(Desc.)"{
                        dir = "desc"
                    }
                    else{
                        dir = "asc"
                    }
                    self.filterDict["SortDirection"] = dir
                case 1:
                    self.filterDict["SortBy"] = item
                case 3:
                    self.filterDict["SearchRes"] = item
                case 4:
                    self.filterDict["TransType"] = item
                case 5:
                    self.filterDict["Currency"] = item
                default:
                    break
                }
                self.plcFilter.remove(at: tag)
                self.plcFilter.insert(item, at: tag)
                cell.lblDropDownValue.text = item
                cell.lblDropDownValue.textColor = UIColor.black
            }
            dropDwn.show()
        }
    }
    private func showPickerVw(withTag:Int){
        if withTag == 100{
            self.datePicker.minimumDate = fromDate
        }
        else{
//            self.datePicker.minimumDate = Date()
        }
        self.datePicker.tag = withTag
        self.vwDatePicker.isHidden = false
        self.vwDatePicker.animate(.slideUp, curve: .easeInCubic)
    }
    @objc func fromTapped(_ sender:UIButton){
        self.showPickerVw(withTag: sender.tag + 100)
    }
    @objc func toTapped(_ sender:UIButton){
        self.showPickerVw(withTag: sender.tag + 100)
    }
    @objc func applyTapped(_ sender:UIButton){
        if tagForDatePicker != 101{
            self.filterDict["StartDate"] = HHelper.getDateStringWithDate("YYYY-MM-dd", date: fromDate)
            self.filterDict["EndDate"] = HHelper.getDateStringWithDate("YYYY-MM-dd", date: toDate)
            filterFrmDate = fromDate
            filterToDate = toDate
            isEditDate = true
        }
        delegate?.getFilterDict(array: self.filterDict)
        self.dismiss(animated: true, completion: nil)
    }
}

class FilterPickerCell: UITableViewCell {
    
    @IBOutlet weak var lblTop: UILabel!
    @IBOutlet weak var vwFrom: UIView!
    @IBOutlet weak var vwTo: UIView!
    @IBOutlet weak var btnFrom: UIButton!
    @IBOutlet weak var txtFldFrom: UITextField!
    @IBOutlet weak var btnTo: UIButton!
    @IBOutlet weak var txtFldTo: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtFldFrom.attributedPlaceholder = NSAttributedString(string: "From",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        txtFldTo.attributedPlaceholder = NSAttributedString(string: "TO",attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
