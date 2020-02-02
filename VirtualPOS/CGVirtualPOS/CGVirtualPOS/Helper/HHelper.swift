//
//  HHelper.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 19/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MapKit
import EventKit
import AlamofireImage
import SwiftMessages

var loader = GeometricLoader()

class HHelper {
    
    public typealias ImageDownloadCompletionClosure = (_ imageData: NSData ) -> Void
    
    class func getScaleFactor() -> CGFloat{
        let screenRect:CGRect = UIScreen.main.bounds
        let screenWidth:CGFloat = screenRect.size.width
        let scalefactor:CGFloat = screenWidth / 375.0
        return scalefactor
    }
    
    class func setCurrentDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let result = formatter.string(from: date)
        return result
    }
    
    class func localToUTC(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        return dateFormatter.string(from: dt!)
    }
    
    class func UTCToLocal(date:String,format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.init(name: "UTC") as TimeZone?
        if let dt = dateFormatter.date(from: date) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: dt)
        } else {
            return "Unknown date"
        }
    }
    
    class func serverToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.date(from: date)
        let dateStr = HHelper.getDateStringWithDate("dd MMM yyyy hh:mm a", date: localDate ?? Date())
        return dateStr
    }
    
    class func dateTimeStatus(date:String,format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let dt = dateFormatter.date(from: date) {
            dateFormatter.locale = Locale.current
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: dt)
        } else {
            return "Unknown date"
        }
    }
    
    class func  getTimeRemaining(expiry: String) -> TimeInterval {
        let formatter1 = DateFormatter()
        let formatter2 = DateFormatter()
        var date1 : Date = Date()
        var date2 : Date = Date()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        formatter1.timeZone = NSTimeZone.init(name: "UTC") as TimeZone?
        date1 = formatter1.date(from: String(expiry)) ?? Date.distantFuture
        formatter2.timeZone = TimeZone.current
        let dateStr = formatter2.string(from: date1)
        date2 = formatter2.date(from: dateStr)!
        return date2.timeIntervalSince1970
    }
    class func dateStringFromTimeStamp(timeStamp:Int,dateFormate:String) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = dateFormate //"yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    class func millisecondsToLocal(milliseconds: Int) -> Date{
        let date = Date(timeIntervalSince1970: (TimeInterval(milliseconds / 1000)))
        return date
    }
    
    class func getDateStringWithDate(_ format:String, date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    class func rootViewController() -> UIViewController{
        return (UIApplication.shared.keyWindow?.rootViewController)!
    }
    
    // MARK: - Get topmost view controller
    
    class func topMostViewController(rootViewController: UIViewController) -> UIViewController?{
        
        if let navigationController = rootViewController as? UINavigationController
        {
            return topMostViewController(rootViewController: navigationController.visibleViewController!)
        }
        
        if let tabBarController = rootViewController as? UITabBarController
        {
            if let selectedTabBarController = tabBarController.selectedViewController
            {
                return topMostViewController(rootViewController: selectedTabBarController)
            }
        }
        
        if let presentedViewController = rootViewController.presentedViewController
        {
            return topMostViewController(rootViewController: presentedViewController)
        }
        return rootViewController
    }
    
    // MARK: Alert methods
    
    class func showAlert(title:String,_ message: String, okButtonTitle: String? = nil, target: UIViewController? = nil) {
        
        let topViewController: UIViewController? = HHelper.topMostViewController(rootViewController: HHelper.rootViewController())
        
        if let _ = topViewController {
            let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertController.Style.alert);
            let okBtnTitle = "OK"
            let okAction = UIAlertAction(title:okBtnTitle, style: UIAlertAction.Style.default, handler: nil);
            
            alert.addAction(okAction);
            if UIApplication.shared.applicationState != .background{
                topViewController?.present(alert, animated:true, completion:nil);
            }
        }
    }
    
    class func showLoader(){
        loader = BlinkingCircles.createGeometricLoader()
        loader.tintColor = UIColor.colorWithHexString("034C81")
        loader.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loader.startAnimation()
    }
    class func hideLoader(){
        loader.stopAnimation()
    }
    @objc func hide(){
        print("Hide Tapped")
        loader.stopAnimation()
    }
    
    class func showAlert(withTitle title:String, message:String, type:AlertType, showButton:Bool){

        if showButton{
            let view = MessageView.viewFromNib(layout: .centeredView)
            view.configureContent(title: kNoInterNet, body: message, iconImage: #imageLiteral(resourceName: "logo"), iconText: nil, buttonImage: nil, buttonTitle: "DISMISS") { (sender) in
                SwiftMessages.hide()
            }
            var config = SwiftMessages.Config()
            config.presentationStyle = .center
            config.ignoreDuplicates = true
            config.dimMode = .gray(interactive: true)
            config.duration = .forever
            config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            config.eventListeners.append() { event in
                if case .didHide = event {  }
            }
            SwiftMessages.show(config: config, view: view)
        }
        else{
            var alertType:Theme!
            switch type {
            case .success:
                alertType = .success
            case .error:
                alertType = .error
            default:
                alertType = .warning
            }
            let view = MessageView.viewFromNib(layout: .cardView)
            view.configureTheme(alertType)
            view.button?.isHidden = true
            view.configureContent(title: title, body: message)
            var config = SwiftMessages.Config()
            config.presentationStyle = .top
            config.duration = .automatic
            config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            config.eventListeners.append() { event in
                if case .didHide = event {  }
            }
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    class func showAlertWithAction(title: String?, message: String?, style: UIAlertController.Style, actionTitles:[String?], action:((UIAlertAction) -> Void)?) {
        
        showAlertWithActionWithCancel(title: title, message: message, style: style, actionTitles: actionTitles, showCancel: false, deleteTitle: nil, action: action)
    }
    
    class func showAlertWithActionWithCancel(title: String?, message: String?, style: UIAlertController.Style, actionTitles:[String?], showCancel:Bool, deleteTitle: String? ,_ viewC: UIViewController? = nil, action:((UIAlertAction) -> Void)?) {
        
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        if deleteTitle != nil {
            let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive, handler: action)
            alertController.addAction(deleteAction)
        }
        for (_, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: action)
            alertController.addAction(action)
        }
        
        if showCancel {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        if let viewController = viewC {
            
            viewController.present(alertController, animated: true, completion: nil)
            
        } else {
            let topViewController: UIViewController? = HHelper.topMostViewController(rootViewController: HHelper.rootViewController())
            topViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func showAlertWith(_ title:String? = nil, message: String, okButtonTitle: String? = nil, target: UIViewController? = nil) {
        
        var strTitle: String = ""
        
        if title != nil {
            strTitle = title!
        }else{
            strTitle = APP_NAME
        }
        let topViewController: UIViewController? = HHelper.topMostViewController(rootViewController: HHelper.rootViewController())
        
        if let _ = topViewController {
            let alert = UIAlertController(title:strTitle, message: message, preferredStyle: UIAlertController.Style.alert);
            let okBtnTitle = "OK"
            let okAction = UIAlertAction(title:okBtnTitle, style: UIAlertAction.Style.default, handler: nil);
            
            alert.addAction(okAction);
            if UIApplication.shared.applicationState != .background{
                topViewController?.present(alert, animated:true, completion:nil);
            }
        }
    }
    
    class func getDateFromString(dateString:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString)
    }
    
    class func getStringFromDate(_ format:String, date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
    
    class func stringToDate(strDate:String, format:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: strDate)
    }
    
    // MARK: Alert methods
    
    class func showAlertWithBlock(_ message: String, block : @escaping ((UIAlertAction) -> Void)) {
        
        let topViewController: UIViewController? = HHelper.topMostViewController(rootViewController: HHelper.rootViewController())
        
        if let _ = topViewController {
            let alertC = UIAlertController.init(title: APP_NAME, message: message, preferredStyle:.alert)
            let alertAction = UIAlertAction.init(title: "OK", style: .default , handler : block)
            
            alertC.addAction(alertAction)
            if UIApplication.shared.applicationState != .background {
                topViewController?.present(alertC, animated:true, completion:nil);
            }
        }
    }
    
    // MARK: Validate email
    
    class func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    // MARK: Validate password
    
    class func isValidPassword(_ password: String) -> Bool {
        let pswdRegEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[^A-Za-z0-9])\\S{8,}$"
        let pswdTest = NSPredicate(format:"SELF MATCHES %@", pswdRegEx)
        return pswdTest.evaluate(with: password)
    }
    
    // MARK: Validate username
    
    class func isValidUsername(_ username: String) -> Bool {
        
        let regularExpressionText = "^[ء-يa-zA-Z0-9_.-]+"
        let regularExpression = NSPredicate(format:"SELF MATCHES %@", regularExpressionText)
        return regularExpression.evaluate(with: username)
    }
    
    // MARK:- Validate phone number
    
    class func isValidPhone(value: String) -> Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    class func getIndexPathFor(view: UIView, tableView: UITableView) -> IndexPath? {
        let point = tableView.convert(view.bounds.origin, from: view)
        let indexPath = tableView.indexPathForRow(at: point)
        return indexPath
    }
    
    class func getIndexPathFor(view: UIView, collectionView: UICollectionView) -> IndexPath? {
        let point = collectionView.convert(view.bounds.origin, from: view)
        let indexPath = collectionView.indexPathForItem(at: point)
        return indexPath
    }
    
    // MARK: - Get Format For Timer
    
    class func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    class func getGradient() -> CAGradientLayer{
        let gradient = CAGradientLayer()
        let bottomYPoint = 64
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: bottomYPoint)
        gradient.frame = defaultNavigationBarFrame
        
        let color = UIColor(red: 247.0/255.0, green: 154.0/255.0, blue: 172.0/255.0, alpha: 1.0)
        let color2 = UIColor(red: 63.0/255.0, green: 185.0/255.0, blue: 232.0/255.0, alpha: 1.0)
        gradient.colors = [color.cgColor, color2.cgColor]
        gradient.startPoint = CGPoint(x:0.0, y:0.5)
        gradient.endPoint = CGPoint(x:1.0, y:0.5)
        return gradient
    }
    
    class func orderalphabetically(_ arr: [String]) -> [String]{
        let orderedArr = arr.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        return orderedArr
    }
    
    class func addCommmaInArray(Arr: [String]) ->String{
        var arrayCity = String()
        var newArr = [String]()
        for item in Arr{
            if newArr.count == 0{
                let value = item
                arrayCity.append(value)
                newArr.append(value)
            }
            else{
                let value =  "," + item
                arrayCity.append(value)
            }
        }
        return arrayCity
    }
    
    class func addCommmaAndQuotesInArray(Arr: [String]) ->String{
        var arrayCity = String()
        var newArr = [String]()
        for item in Arr{
            if newArr.count == 0{
                let value = item
                arrayCity.append(value)
                newArr.append(value)
            }
            else{
                let value =  "," + item
                arrayCity.append(value)
            }
        }
        return arrayCity
    }
    
    class func addCommmaWithSpaceInArray(Arr: [String]) ->String{
        var arrayCity = String()
        var newArr = [String]()
        for item in Arr{
            if newArr.count == 0{
                let value = item
                arrayCity.append(value)
                newArr.append(value)
            }
            else{
                let value =  "," + " " + item
                arrayCity.append(value)
            }
        }
        return arrayCity
    }
    
    class func formatHeight(_ truncatedStr: String) -> String{
        var splittedStr = truncatedStr.split(separator: ".")
        if splittedStr.count > 1{
            if splittedStr[1].first == "0"{
                splittedStr[1].removeFirst()
            }
            if (splittedStr[1].count == 1){
                splittedStr[1] = splittedStr[1] + "0"
            }
            return "\(splittedStr[0])'\(splittedStr[1])"
        }
        else{
            return "\(splittedStr[0])'0"
        }
    }
    
    
    
    class func openEmails(){
        let emailActionSheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        emailActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let action = openAction(withURL: "googlegmail:///", andTitleActionTitle: "Gmail") {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "inbox-gmail://", andTitleActionTitle: "Inbox") {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "ms-outlook://", andTitleActionTitle: "Outlook") {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "x-dispatch:///", andTitleActionTitle: "Dispatch") {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "message://", andTitleActionTitle: "Apple") {
            emailActionSheet.addAction(action)
        }
        let topViewController: UIViewController? = HHelper.topMostViewController(rootViewController: HHelper.rootViewController())
        topViewController?.present(emailActionSheet, animated: true, completion: nil)
    }
    
    class func openMapForPinWith(latitude: Double, longitude: Double){
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps-x-callback://")!){
            let urlString = "comgooglemaps-x-callback://?q=\(latitude),\(longitude)"
            if let mapUrl = URL(string: urlString){
                if #available(iOS 10, *) {
                    APPLICATION.open(mapUrl)
                } else {
                    APPLICATION.openURL(mapUrl)
                }
            }
        }
        else{
            let url = "http://maps.apple.com/?q=\(latitude),\(longitude)"
            if let url = URL(string: url), APPLICATION.canOpenURL(url){
                if #available(iOS 10, *) {
                    APPLICATION.open(url)
                } else {
                    APPLICATION.openURL(url)
                }
            }
        }
    }
    
    
    
    class func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
        guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (action) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return action
    }
    
    // MARK: - Open URL For Map
    
    class func openAppMapWithLocation(_ mapURLArray:[String]) -> Bool{
        let mapURL = mapURLArray.joined(separator: "+")
        let encodedStr = mapURL.replacingOccurrences(of: " ", with: "+")
        let appleUrl = NSString(format: "http://maps.apple.com/?q=%@", encodedStr)
        if let url = URL(string: appleUrl as String), APPLICATION.canOpenURL(url){
            if #available(iOS 10, *) {
                APPLICATION.open(url)
            } else {
                APPLICATION.openURL(url)
            }
            return true
        }
        else{
            return false
        }
    }
    
    
    
    
    // MARK: - Method For Status Bar Gradient Color
    
    class func statusBarGradientView() -> UIView {
        
        let view = UIView(frame: CGRect(x:0, y:0, width:(UIScreen.main.bounds.size.width), height:20))
        view.layer.addSublayer(HHelper.getGradientForStatusBar())
        return view
    }
    
    class func getGradientForStatusBar() -> CAGradientLayer{
        
        let gradient = CAGradientLayer()
        let bottomYPoint = 20
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: bottomYPoint)
        gradient.frame = defaultNavigationBarFrame
        
        let color = UIColor(red: 247.0/255.0, green: 154.0/255.0, blue: 172.0/255.0, alpha: 1.0)
        let color2 = UIColor(red: 63.0/255.0, green: 185.0/255.0, blue: 232.0/255.0, alpha: 1.0)
        gradient.colors = [color.cgColor, color2.cgColor]
        gradient.startPoint = CGPoint(x:0.0, y:0.5)
        gradient.endPoint = CGPoint(x:1.0, y:0.5)
        return gradient
    }
    
    class func getThumbnailFrom(path: URL) -> UIImage? {
        
        do {
            
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch _ {
            return nil
        }
    }
    
    class func playVideo(_ urlStr : String, viewController : UIViewController)
    {
        if let videoURL = URL(string: urlStr)
        {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            viewController.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    class func validateName(name: String!) -> Bool{
        let newName = name.trimmingCharacters(in: .whitespaces)
        if newName.count >= 3
        {
            let NAME_REGEX = "[A-Za-z]+"
            let nameTest = NSPredicate(format: "SELF MATCHES %@", NAME_REGEX)
            let result =  nameTest.evaluate(with: name.trimmingCharacters(in: NSCharacterSet.whitespaces))
            return result
        }
        else
        {
            return false
        }
    }
    
    class func getExpireTimeRemaining(expiry: String) -> TimeInterval {
        let formatter1 = DateFormatter()
        let formatter2 = DateFormatter()
        var date1 : Date = Date()
        var date2 : Date = Date()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        formatter1.timeZone = NSTimeZone.init(name: "UTC") as TimeZone?
        date1 = formatter1.date(from: String(expiry))!
        formatter2.timeZone = TimeZone.current
        let dateStr = formatter2.string(from: date1)
        date2 = formatter2.date(from: dateStr)!
        return date2.timeIntervalSince1970
    }
    
    class func getCurrentTimeRemaining(expiryDate: TimeInterval) -> Int {
        let date : Date = Date()
        let seconds = expiryDate-date.timeIntervalSince1970
        if seconds > 25{
            return 25
        }
        else{
            return Int(seconds)
        }
    }
    
    
    
    class func offsetFrom(_ date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone.current
        let date2 : Date = Date()
        let strTodadate = formatter.string(from: date2)
        let datetoday = formatter.date(from: strTodadate)!
        
        
        let dayHourMinuteSecond: NSCalendar.Unit = [.day, .hour, .minute, .second]
        let difference = (Calendar.current as NSCalendar).components(dayHourMinuteSecond, from: date, to: datetoday, options: [])
        
        let seconds = "\(String(describing: difference.second!)) SECONDS AGO"
        let minutes = "\(String(describing: difference.minute!)) MINUTES AGO"
        let hours = "\(String(describing: difference.hour!)) HOURS AGO"
        let days = "\(String(describing: difference.day!)) DAYS AGO"
        
        if difference.day!    > 0 { return days }
        if difference.hour!   > 0 { return hours }
        if difference.minute! > 0 { return minutes }
        if difference.second! > 0 { return seconds }
        return ""
    }
    
   
    
    class func downloadImage(completionHanlder: @escaping ImageDownloadCompletionClosure,imageUrl:URL){
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:imageUrl)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    let rawImageData = NSData(contentsOf: tempLocalUrl)
                    completionHanlder(rawImageData!)
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
            } else {
                print("Error took place while downloading a file. Error description: \(String(describing: error?.localizedDescription))")
            }
        }
        task.resume()
    }
    
    class func loadImageFromURLString(_ urlString:String, imageView:UIImageView, placeholder:UIImage){
        if let escapedAddress = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let imageURL = URL(string: escapedAddress){
            imageView.af_setImage(withURL: imageURL,placeholderImage: placeholder,filter: nil)
        }
        else{
            imageView.image = nil
        }
    }
    class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    class func compareTo(userId:String,friendId:String) -> String{
        if userId < friendId{
            return ("\(friendId)_\(userId)")
        }
        else{
            return ("\(userId)_\(friendId)")
        }
    }
    
    // MARK: - Save Values In User Defaults
    
    class func saveValueInUserDefault(_ value:Any?,_ key:String){
        USER_DEFAULTS.set(value, forKey: key)
        USER_DEFAULTS.synchronize()
    }
    
    // MARK: - Remove Objects From User Defaults
    
    class func removeObjectFromUserDefault(_ key:String){
        USER_DEFAULTS.removeObject(forKey: key)
        USER_DEFAULTS.synchronize()
    }
    
    class func removeAllUserDefaults(){
        let domain = MAIN_BUNDLE.bundleIdentifier!
        USER_DEFAULTS.removePersistentDomain(forName: domain)
        USER_DEFAULTS.synchronize()
    }
    
    class func removeProfileData(){
        USER_DEFAULTS.removeObject(forKey: kAccessToken)
        USER_DEFAULTS.removeObject(forKey: kName)
        USER_DEFAULTS.removeObject(forKey: kEmail)
        USER_DEFAULTS.removeObject(forKey: kUrl)
        USER_DEFAULTS.removeObject(forKey: kIsRefund)
        USER_DEFAULTS.removeObject(forKey: ktknUsd)
        USER_DEFAULTS.removeObject(forKey: ktknKyd)
        USER_DEFAULTS.removeObject(forKey: kDefaultCrncy)
    }
    
    class func version() -> String {
        if let dictionary = Bundle.main.infoDictionary{
            let version = dictionary["CFBundleShortVersionString"] as! String
            //            let build = dictionary["CFBundleVersion"] as! String   *Build Version*
            return "\(version)"
        }
        else{
            return ""
        }
    }
    
    class func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    // MARK: - Trimming CountryCode
    
    class func trimmingCountryCode(_ number:String) -> String{
        var strCode = number.trimmingCharacters(in: .letters)
        strCode = strCode.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        return strCode
    }
    
    class func removePlus(_ number: String) -> String{
        if number.first == "+"{
            let number = String(number.dropFirst())
            return number
        }
        return number
    }
    
    //MARK: Get Device Lacale Country Code and Phone Code
    class func getCountryPhoneCode (country : String) -> String
    {
        let x : [String] = ["972", "IL",
                            "93" , "AF",
                            "355", "AL",
                            "213", "DZ",
                            "1"  , "AS",
                            "376", "AD",
                            "244", "AO",
                            "1"  , "AI",
                            "1"  , "AG",
                            "54" , "AR",
                            "374", "AM",
                            "297", "AW",
                            "61" , "AU",
                            "43" , "AT",
                            "994", "AZ",
                            "1"  , "BS",
                            "973", "BH",
                            "880", "BD",
                            "1"  , "BB",
                            "375", "BY",
                            "32" , "BE",
                            "501", "BZ",
                            "229", "BJ",
                            "1"  , "BM",
                            "975", "BT",
                            "387", "BA",
                            "267", "BW",
                            "55" , "BR",
                            "246", "IO",
                            "359", "BG",
                            "226", "BF",
                            "257", "BI",
                            "855", "KH",
                            "237", "CM",
                            "1"  , "CA",
                            "238", "CV",
                            "345", "KY",
                            "236", "CF",
                            "235", "TD",
                            "56", "CL",
                            "86", "CN",
                            "61", "CX",
                            "57", "CO",
                            "269", "KM",
                            "242", "CG",
                            "682", "CK",
                            "506", "CR",
                            "385", "HR",
                            "53" , "CU" ,
                            "537", "CY",
                            "420", "CZ",
                            "45" , "DK" ,
                            "253", "DJ",
                            "1"  , "DM",
                            "1"  , "DO",
                            "593", "EC",
                            "20" , "EG" ,
                            "503", "SV",
                            "240", "GQ",
                            "291", "ER",
                            "372", "EE",
                            "251", "ET",
                            "298", "FO",
                            "679", "FJ",
                            "358", "FI",
                            "33" , "FR",
                            "594", "GF",
                            "689", "PF",
                            "241", "GA",
                            "220", "GM",
                            "995", "GE",
                            "49" , "DE",
                            "233", "GH",
                            "350", "GI",
                            "30" , "GR",
                            "299", "GL",
                            "1"  , "GD",
                            "590", "GP",
                            "1"  , "GU",
                            "502", "GT",
                            "224", "GN",
                            "245", "GW",
                            "595", "GY",
                            "509", "HT",
                            "504", "HN",
                            "36" , "HU",
                            "354", "IS",
                            "91" , "IN",
                            "62" , "ID",
                            "964", "IQ",
                            "353", "IE",
                            "972", "IL",
                            "39" , "IT",
                            "1"  , "JM",
                            "81", "JP", "962", "JO", "77", "KZ",
                            "254", "KE", "686", "KI", "965", "KW", "996", "KG",
                            "371", "LV", "961", "LB", "266", "LS", "231", "LR",
                            "423", "LI", "370", "LT", "352", "LU", "261", "MG",
                            "265", "MW", "60", "MY", "960", "MV", "223", "ML",
                            "356", "MT", "692", "MH", "596", "MQ", "222", "MR",
                            "230", "MU", "262", "YT", "52","MX", "377", "MC",
                            "976", "MN", "382", "ME", "1", "MS", "212", "MA",
                            "95", "MM", "264", "NA", "674", "NR", "977", "NP",
                            "31", "NL", "599", "AN", "687", "NC", "64", "NZ",
                            "505", "NI", "227", "NE", "234", "NG", "683", "NU",
                            "672", "NF", "1", "MP", "47", "NO", "968", "OM",
                            "92", "PK", "680", "PW", "507", "PA", "675", "PG",
                            "595", "PY", "51", "PE", "63", "PH", "48", "PL",
                            "351", "PT", "1", "PR", "974", "QA", "40", "RO",
                            "250", "RW", "685", "WS", "378", "SM", "966", "SA",
                            "221", "SN", "381", "RS", "248", "SC", "232", "SL",
                            "65", "SG", "421", "SK", "386", "SI", "677", "SB",
                            "27", "ZA", "500", "GS", "34", "ES", "94", "LK",
                            "249", "SD", "597", "SR", "268", "SZ", "46", "SE",
                            "41", "CH", "992", "TJ", "66", "TH", "228", "TG",
                            "690", "TK", "676", "TO", "1", "TT", "216", "TN",
                            "90", "TR", "993", "TM", "1", "TC", "688", "TV",
                            "256", "UG", "380", "UA", "971", "AE", "44", "GB",
                            "1", "US", "598", "UY", "998", "UZ", "678", "VU",
                            "681", "WF", "967", "YE", "260", "ZM", "263", "ZW",
                            "591", "BO", "673", "BN", "61", "CC", "243", "CD",
                            "225", "CI", "500", "FK", "44", "GG", "379", "VA",
                            "852", "HK", "98", "IR", "44", "IM", "44", "JE",
                            "850", "KP", "82", "KR", "856", "LA", "218", "LY",
                            "853", "MO", "389", "MK", "691", "FM", "373", "MD",
                            "258", "MZ", "970", "PS", "872", "PN", "262", "RE",
                            "7", "RU", "590", "BL", "290", "SH", "1", "KN",
                            "1", "LC", "590", "MF", "508", "PM", "1", "VC",
                            "239", "ST", "252", "SO", "47", "SJ",
                            "963","SY",
                            "886",
                            "TW", "255",
                            "TZ", "670",
                            "TL","58",
                            "VE","84",
                            "VN",
                            "284", "VG",
                            "340", "VI",
                            "678","VU",
                            "681","WF",
                            "685","WS",
                            "967","YE",
                            "262","YT",
                            "27","ZA",
                            "260","ZM",
                            "263","ZW"]
        var keys = [String]()
        var values = [String]()
        let whitespace = NSCharacterSet.decimalDigits
        for i in x {
            if  (i.rangeOfCharacter(from: whitespace) != nil) {
                values.append(i)
            }
            else {
                keys.append(i)
            }
        }
        let countryCodeListDict = NSDictionary(objects: values as [String], forKeys: keys as [String] as [NSCopying])
        if countryCodeListDict[country] != nil {
            return countryCodeListDict[country] as! String
        } else
        {
            return ""
        }
    }
    
    class func showBluetoothEnablePopUp(){
        HHelper.showAlertWithAction(title: APP_NAME, message: "Enable Bluetooth to access Services from card Reader", style: .alert, actionTitles: ["Open Settings","Cancel"], action: { (action) in
            if action.title == "Cancel"{}
            else{
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (true) in
                            
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        })
    }
}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class SearchRadius: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

enum AlertType {
    case success
    case error
    case info
}
