//
//  TabBarViewC.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 23/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit
import TransitionableTab
//import JBTabBarAnimation

//MARK:- Custome TabBar

class TabBar : UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 60
        return sizeThatFits
    }
    
    override var traitCollection: UITraitCollection {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return super.traitCollection
        }
        return UITraitCollection(horizontalSizeClass: .compact)
    }
}

class TabBarViewC: UITabBarController {

    //MARK:- Properties
    
    var priviousSelectedIndex: Int = -1
    
    //MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let item = self.tabBar.selectedItem {
            self.tabBar(self.tabBar, didSelect: item)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setUpView()
    }
    
    //MARK:- Custom TabBar
    
    private func tabBarItemViews() -> [UIView] {
        let interactionControls = tabBar.subviews.filter { $0 is UIControl }
        return interactionControls.sorted(by: { $0.frame.minX < $1.frame.minX })
    }
    private func removeBarItemCircleLayer(barItemView: UIView) {
        if let circleLayer = (barItemView.layer.sublayers?.filter { $0 is CircleLayer }.first) {
            circleLayer.removeFromSuperlayer()
        }
    }
    private func createRoundLayer(for tabBarItemView: UIView) {
        if let itemImageView = (tabBarItemView.subviews.filter { $0 is UIImageView }.first) {
            let circle = CircleLayer()
            circle.positionValue = itemImageView.center
            tabBarItemView.layer.addSublayer(circle.createCircle())
        }
    }
    private func showItemLabel(for tabBarItemView: UIView, isHidden: Bool) {
        if let itemLabel = (tabBarItemView.subviews.filter{ $0 is UILabel }.first),
            itemLabel is UILabel,
            let buttonLabel = itemLabel as? UILabel {
            buttonLabel.isHidden = isHidden
        }
    }
    private func setUpView(){
        self.delegate = self
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "RobotoCondensed-Regular", size: 10.0)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: "RobotoCondensed-Regular", size: 10.0)!], for: .selected)
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().backgroundImage = UIImage(named: "ic_blue_bar")
        UITabBar.appearance().contentMode = .scaleAspectFit
        self.tabBar.tintColor = UIColor.darkGray
        self.tabBar.unselectedItemTintColor = UIColor.white
        self.setUpTabBar()
    }
    private func setUpTabBar(){
        if let usrType = USER_DEFAULTS.value(forKey: kloginType) as? String{
            let virtualTerminalImage: UIImage! = UIImage(named: "ic_tab_1")?.withRenderingMode(.alwaysTemplate)
//            let terminalListImage: UIImage! = UIImage(named: "ic_tab_2")?.withRenderingMode(.alwaysTemplate)
            let transactionListImage: UIImage! = UIImage(named: "ic_tab_3")?.withRenderingMode(.alwaysTemplate)
            let invoiceImage = UIImage(named: "ic_tab_4")?.withRenderingMode(.alwaysTemplate)
//            let invoiceListImage = UIImage(named: "ic_tab_5")?.withRenderingMode(.alwaysTemplate)
            switch usrType {
            case "operator":
                if let vTerSts = USER_DEFAULTS.value(forKey: kVTerminalPresent) as? Int{
                    if let invoiceSts = USER_DEFAULTS.value(forKey: kInvoicePresent) as? Int{
                        if invoiceSts == 1 && vTerSts == 1{
                            (tabBar.items![0]).selectedImage = virtualTerminalImage
                            (tabBar.items![0]).image = virtualTerminalImage
                            (tabBar.items![1]).selectedImage = invoiceImage
                            (tabBar.items![1]).image = invoiceImage
                            (tabBar.items![0]).title = "Virtual Terminal"
                            (tabBar.items![1]).title = "Invoice"
                        }
                        else if invoiceSts == 1 && vTerSts == 0{
                            (tabBar.items![0]).selectedImage = invoiceImage
                            (tabBar.items![0]).image = invoiceImage
                            (tabBar.items![0]).title = "Virtual Terminal"
                        }
                        else if invoiceSts == 0 && vTerSts == 1{
                            (tabBar.items![0]).selectedImage = virtualTerminalImage
                            (tabBar.items![0]).image = virtualTerminalImage
                            (tabBar.items![0]).title = "Virtual Terminal"
                        }
                        else{}
                    }
                }
                break
            case "accountant":
                (tabBar.items![0]).selectedImage = transactionListImage
                (tabBar.items![0]).image = transactionListImage
//                (tabBar.items![1]).selectedImage = terminalListImage
//                (tabBar.items![1]).image = terminalListImage
//                (tabBar.items![2]).selectedImage = invoiceListImage
//                (tabBar.items![2]).image = invoiceListImage
                (tabBar.items![0]).title = "Transactions"
//                (tabBar.items![1]).title = "VTerminal List"
//                (tabBar.items![2]).title = "Invoice List"
                break
            case "manager","managerv1":
                (tabBar.items![0]).selectedImage = virtualTerminalImage
                (tabBar.items![0]).image = virtualTerminalImage
//                (tabBar.items![1]).selectedImage = terminalListImage
//                (tabBar.items![1]).image = terminalListImage
                (tabBar.items![1]).selectedImage = transactionListImage
                (tabBar.items![1]).image = transactionListImage
                (tabBar.items![2]).selectedImage = invoiceImage
                (tabBar.items![2]).image = invoiceImage
//                (tabBar.items![4]).selectedImage = invoiceListImage
//                (tabBar.items![4]).image = invoiceListImage
                (tabBar.items![0]).title = "Virtual Terminal"
//                (tabBar.items![1]).title = "VTerminal List"
                (tabBar.items![1]).title = "Transactions"
                (tabBar.items![2]).title = "Invoice"
//                (tabBar.items![4]).title = "Invoice List"
                break
            default:
                break
            }
        }
    }
}

//MARK:- Transition Tab Delegates

extension TabBarViewC: TransitionableTab {
    
    func transitionDuration() -> CFTimeInterval {
        return 0.4
    }
    
    func transitionTimingFunction() -> CAMediaTimingFunction {
        return .easeInOut
    }
    
    private func fromTransitionAnimation(layer: CALayer, direction: Direction) -> CAAnimation {
        return DefineAnimation.move(.from, direction: direction)
    }
    
    private func toTransitionAnimation(layer: CALayer, direction: Direction) -> CAAnimation {
        return DefineAnimation.move(.to, direction: direction)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = self.tabBar.items, let selectedIndex = items.firstIndex(of: item), priviousSelectedIndex != selectedIndex, let customTabBar = tabBar as? JBTabBar {
            let tabBarItemViews = self.tabBarItemViews()
            tabBarItemViews.forEach { tabBarItemView in
                let firstIndex = tabBarItemViews.firstIndex(of: tabBarItemView)
                if selectedIndex == firstIndex {
                    showItemLabel(for: tabBarItemView, isHidden: true)
                    createRoundLayer(for: tabBarItemView)
                    customTabBar.curveAnimation(for: selectedIndex)
                    UIView.animate(withDuration: 0.9, delay: 0.0, usingSpringWithDamping: 0.57, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                        tabBarItemView.frame = CGRect(x: tabBarItemView.frame.origin.x, y: tabBarItemView.frame.origin.y - 1, width: tabBarItemView.frame.width, height: tabBarItemView.frame.height)
                    }, completion: { _ in
                        customTabBar.finishAnimation()
                    })
                } else if priviousSelectedIndex == firstIndex {
                    showItemLabel(for: tabBarItemView, isHidden: false)
                    removeBarItemCircleLayer(barItemView: tabBarItemView)
                    UIView.animate(withDuration: 0.9, delay: 0.0, usingSpringWithDamping: 0.57, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                        tabBarItemView.frame = CGRect(x: tabBarItemView.frame.origin.x, y: tabBarItemView.frame.origin.y + 1, width: tabBarItemView.frame.width, height: tabBarItemView.frame.height)
                    }, completion: nil)
                }
            }
            priviousSelectedIndex = selectedIndex
        }
    }
}
