//
//  BaseViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 18/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit

//Mark:- Enum For Image Picker

enum ImagePickerSource: Int {
    
    case profile = 0
    case advertisementVideo = 1
    case other = 2
}

enum UIKeyboardTypeButton: Int {
    
    case next = 1
    case back = 2
}

enum UINavigationBarButtonType: Int {
    case back
    case calender
    case search
    case add
    case more
    case menu
    case send
    case home
    case skip
    case profile
    case filter
    case filterApply
    case reset
    case cross
    
    var iconImage: Any? {
        switch self {
            
        case .calender: return UIImage(named: "cale")
        case .search: return UIImage(named: "search")
        case .add: return UIImage(named: "add")
        case .more: return UIImage(named: "add")
        case .send: return UIImage(named: "send")
        case .menu: return UIImage(named: "menu_black")
        case .home: return UIImage(named: "home")
        case .back: return UIImage(named: "back")
        case .profile: return UIImage(named: "profile")
        case .filter: return UIImage(named: "filter")
        case .filterApply: return UIImage(named: "filterFilled")
        case .skip: return "Skip"
        case .cross: return UIImage(named: "cross")
        case .reset: return "Reset All"
        default: return nil
        }
    }
}


class BaseViewC: UIViewController {
    
    private let navButtonWidth = 40.0
    private let edgeInset = CGFloat(10.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavigationColor(shadowOpacity:Float = 0.0){
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.addShadow(5.0, shadowOpacity: shadowOpacity)
    }
    
    func setUpWhiteNavigationBar(_ title: String){
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor.init(red: 0.0/255.0, green: 111.0/255.0, blue: 200.0/255.0, alpha: 1)
        view.addSubview(barView)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.tintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.titleView = createLabel(text: title,white: true)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        let left = UIImage(named: "back")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: left, style: .plain , target: self, action: #selector(left(_sender: )))
    }
    
    func setUpNavigationBar(_ title: String,isBack: Bool){
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.tintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.titleView = createLabel(text: title,white: false)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        if isBack{
            let left = UIImage(named: "back")
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: left, style: .plain , target: self, action: #selector(left(_sender: )))
        }
        else{
            navigationItem.setHidesBackButton(true, animated:true);
        }
    }
    @objc func left(_sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Set Bottom View
    
    func setBottomViewWithKeyBoard(leftTitle: String,rightTitle: String, isShowleftView: Bool , isShowRightView: Bool) -> UIView? {
        let bottomView = UIView(frame: CGRect.init(x: 0, y: 0, width: MAIN_SCREEN_WIDTH, height: 50))
        guard let bView = Bundle.main.loadNibNamed(BottomView.className, owner: self, options: nil)?.first as? BottomView else {
            return nil
        }
        bView.leftBtn.setTitle(leftTitle, for: .normal)
        bView.rightBtn.setTitle(rightTitle, for: .normal)
        bView.leftView.isHidden = isShowleftView
        bView.rightView.isHidden = isShowRightView
        bView.leftBtn.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        bView.rightBtn.addTarget(self, action: #selector(nextButton), for: .touchUpInside)
        var frame = bView.frame
        frame.size.width = bottomView.frame.size.width
        bView.frame = frame
        bottomView.addSubview(bView)
        return bottomView
    }
    
    func setupNavigationBarTitle(_ title: String, leftBarButtonsType: [UINavigationBarButtonType], rightBarButtonsType: [UINavigationBarButtonType], titleViewFrame: CGRect = CGRect(x: 0, y: 0, width: 180, height: 44)) {
        if !title.isEmpty {
            self.navigationItem.titleView = createLabel(text: title, white: true)
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.colorWithHexString("034C81")
        var rightBarButtonItems = [UIBarButtonItem]()
        for rightButtonType in rightBarButtonsType {
            let rightButtonItem = getBarButtonItem(for: rightButtonType, isLeftBarButtonItem: false)
            rightBarButtonItems.append(rightButtonItem)
        }
        if rightBarButtonItems.count > 0 {
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
        }
        var leftBarButtonItems = [UIBarButtonItem]()
        for leftButtonType in leftBarButtonsType {
            let leftButtonItem = getBarButtonItem(for: leftButtonType, isLeftBarButtonItem: true)
            leftBarButtonItems.append(leftButtonItem)
        }
        if leftBarButtonItems.count > 0 {
            self.navigationItem.leftBarButtonItems = leftBarButtonItems
        }
    }
    
    func createLabel(text: String, white: Bool) -> UILabel {
        let rect = CGRect(origin: CGPoint(x: 100,y :0), size: CGSize(width: MAIN_SCREEN_WIDTH-200, height: 44))
        let frame = rect
        let lbl = UILabel.init(frame: frame)
        lbl.text = text
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 1
        lbl.textAlignment = NSTextAlignment.center
        lbl.font = UIFont.init(name: "RobotoCondensed-Bold", size: 18.0)
        if white{
            lbl.textColor = UIColor.white
        }
        else{
            lbl.textColor = UIColor.black
        }
        return lbl
    }
    
    func getBarButtonItem(for type: UINavigationBarButtonType, isLeftBarButtonItem: Bool) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Int(navButtonWidth), height: NAVIGATION_BAR_DEFAULT_HEIGHT))
        button.setTitleColor(.white, for: UIControl.State())
        button.titleLabel?.font = UIFont.init(name: "RobotoCondensed-Regular", size: 20.0)
        button.titleLabel?.textAlignment = .right
        button.tag = type.rawValue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: isLeftBarButtonItem ? -edgeInset : edgeInset, bottom: 0, right: isLeftBarButtonItem ? edgeInset : -edgeInset)
        if let iconImage = type.iconImage {
            button.setImage(iconImage as? UIImage, for: UIControl.State())
            if type == .skip {
                button.setTitle("Skip", for: .normal)
            }
            else if type == .reset {
                button.setTitle("Reset All", for: .normal)
            }
            else{
                button.setTitle("", for: .normal)
            }
        }
        button.addTarget(self, action: #selector(BaseViewC.navigationButtonTapped(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    func addDoneButtonOnKeyboard( textfield : UITextField)
    {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: MAIN_SCREEN_WIDTH, height: 50))
        let doneToolbar: UIToolbar = UIToolbar(frame: rect)
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title:"Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(tapDone(sender:)))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        textfield.inputAccessoryView = doneToolbar
    }
    
    @objc func tapDone(sender : UIButton)
    {
        view.endEditing(true)
    }
    
    // MARK: - Set Bottom View
    
    
    @objc func navigationButtonTapped(_ sender: AnyObject) {
        guard let buttonType = UINavigationBarButtonType(rawValue: sender.tag) else { return }
        switch buttonType {
        case .back: backButtonTapped()
        case .calender: calenderTapped()
        case .search: searchTapped()
        case .add: addEventTapped()
        case .menu: menuTapped()
        case .home: homeTapped()
        case .skip: skipBtnTapped()
        case .filter: filterBtnTapped()
        case .profile: profileBtnTapped()
        case .filterApply: filterFilledBtnTapped()
        case .reset: resetBtnTapped()
        case .cross: crossBtnTapped()
        default: break
        }
    }
    
    func backButtonTapped() {
        if self.navigationController!.viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func profileBtnTapped() {
    }
    
    func crossBtnTapped() {
    }
    
    func filterBtnTapped() {
    }
    
    func filterFilledBtnTapped() {
    }
    
    func resetBtnTapped() {
    }
    
    func skipBtnTapped() {
    }
    
    func calenderTapped() {
    }
    
    func searchTapped() {
    }
    
    func homeTapped(){
    }
    
    func addEventTapped() {
    }
    
    func backTapped(){
    }
    
    func menu2Tapped(){
    }
    
    func menuTapped() {
    }
    
    func moreTapped() {
    }
    
    @objc func keyboardButtonTapped(_ sender: AnyObject) {
        
        guard let buttonType = UIKeyboardTypeButton(rawValue: sender.tag) else { return }
        switch buttonType {
        case .back: actionBack()
        case .next: actionNext()
        }
    }
    
    func actionNext() {
    }
    
    func actionBack() {
    }
    
    @objc func submitButton(){
    }
    
    @objc func backButton(){
    }
    
    @objc func nextButton() {
        self.view.endEditing(true)
    }
}

