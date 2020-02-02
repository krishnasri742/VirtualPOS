//
//  AppDelegate.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 18/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        self.checkLogin()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func checkLogin(){
        if USER_DEFAULTS.value(forKey: kAccessToken) != nil{
            self.homeMethod()
        }
        else{
            self.loginMethod()
        }
    }
    
    func homeMethod(){
        if let usrType = USER_DEFAULTS.value(forKey: kloginType) as? String{
            let vc1 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: VirtualTerminalViewC.className)
//            let vc2 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: TerminalListViewC.className)
            let vc3 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: TransactionListViewC.className)
            let vc4 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: InVoiceViewC.className)
//            let vc5 = AppStoryboards.tabBar.instantiateViewController(withIdentifier: InVoiceListViewC.className)
            let vcc1 = UINavigationController.init(rootViewController: vc1)
//            let vcc2 = UINavigationController.init(rootViewController: vc2)
            let vcc3 = UINavigationController.init(rootViewController: vc3)
            let vcc4 = UINavigationController.init(rootViewController: vc4)
//            let vcc5 = UINavigationController.init(rootViewController: vc5)
            var vccs = [UIViewController]()
            switch usrType {
            case "operator":
                if let vTerSts = USER_DEFAULTS.value(forKey: kVTerminalPresent) as? Int{
                    if let invoiceSts = USER_DEFAULTS.value(forKey: kInvoicePresent) as? Int{
                        if invoiceSts == 1 && vTerSts == 1{
                            vccs = [vcc1,vcc4]
                        }
                        else if invoiceSts == 1 && vTerSts == 0{
                            vccs = [vcc4]
                        }
                        else if invoiceSts == 0 && vTerSts == 1{
                            vccs = [vcc1]
                        }
                        else{
                            HHelper.showAlert(withTitle: "", message: "Invalid User", type: .error
                                , showButton: false)
                            kAppDelegate.loginMethod()
                            break
                        }
                    }
                }
                break
            case "accountant":
//                vccs = [vcc3,vcc2,vcc5]
                vccs = [vcc3]
                break
            case "manager","managerv1":
//                vccs = [vcc1,vcc2,vcc3,vcc4,vcc5]
                vccs = [vcc1,vcc3,vcc4]
                break
            default:
                break
            }
            let homeVC = AppStoryboards.tabBar.instantiateViewController(withIdentifier: TabBarViewC.className) as! TabBarViewC
            homeVC.viewControllers = vccs
            let naviVC = UINavigationController.init(rootViewController: homeVC)
            naviVC.navigationBar.isOpaque = true
            naviVC.navigationBar.isHidden = true
            self.window?.rootViewController = naviVC
            self.window?.makeKeyAndVisible()
        }
    }
    
    func loginMethod(){
        let homeVC = AppStoryboards.auth.instantiateViewController(withIdentifier: LoginViewC.className)
        let naviVC = UINavigationController.init(rootViewController: homeVC)
        naviVC.navigationBar.isOpaque = true
        naviVC.navigationBar.isHidden = true
        self.window?.rootViewController = naviVC
        self.window?.makeKeyAndVisible()
    }
}

