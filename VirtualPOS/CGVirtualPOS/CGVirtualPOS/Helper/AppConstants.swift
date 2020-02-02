//
//  AppConstants.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 18/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import UIKit

let NOTIFICATION_CENTER = NotificationCenter.default
let FILE_MANAGER = FileManager.default
let MAIN_BUNDLE = Bundle.main
let MAIN_THREAD = Thread.main
let MAIN_SCREEN = UIScreen.main
let MAIN_SCREEN_WIDTH = MAIN_SCREEN.bounds.width
let MAIN_SCREEN_HEIGHT = MAIN_SCREEN.bounds.height
let USER_DEFAULTS = UserDefaults.standard
let APPLICATION = UIApplication.shared
let CURRENT_DEVICE = UIDevice.current
let MAIN_RUN_LOOP = RunLoop.main
let GENERAL_PASTEBOARD = UIPasteboard.general
let CURRENT_LANGUAGE = NSLocale.current.languageCode
let kAppDelegate = APPLICATION.delegate as! AppDelegate

let STATUS_BAR_DEFAULT_HEIGHT = 20
let NAVIGATION_BAR_DEFAULT_HEIGHT = 44
let TOOLBAR_DEFAULT_HEIGHT = 44
let TABBAR_DEFAULT_HEIGHT = 49


// Network
let kNoInterNet = "No internet"

let NETWORK_ACTIVITY = APPLICATION.isNetworkActivityIndicatorVisible

//Keys
let ErrorMessageKey = "errorMessage"
let NotParsable = "Error occured. Please try again."

// Application informations

let APP_BUNDLE_NAME = MAIN_BUNDLE.infoDictionary?[kCFBundleNameKey as String]
let APP_NAME = "CGVirtualPOS"
let APP_VERSION = MAIN_BUNDLE.object(forInfoDictionaryKey: "CFBundleVersion")
let IN_SIMULATOR = (TARGET_IPHONE_SIMULATOR != 0)
let ACCEPTABLE_CHARACTERS = "0123456789 "
var IS_CARD_SWIPED = false
var IS_INVALID_SWIPE = 0
var API_KEY = "0j2Od6WbVXJr42fTIRBKvIWHMELjYb9tRd9OLUKaCbP0EVNr3cypLAI3YlWeRtlTWgIcHRratZar5STGJE4ukl1e5h6OG0x44ErEfdARSXKGnO7pnoKxxsogsWYtfujNbCIZGNRLh4vhSa4e7NnoTzpB30odAjfJooc6xposax3x6GtLAzSW54e0XCQOgIjsNtT1WB1rdZM6Ycdz5OgTy6JKJDy6oGBadUYCSAtYZW5dycDU5CP4rXE1HVosFQ7aJpYf5cF4aUewaOfZOQlUrBPnSef95gJZDyYrm0lkF4Be"
let CURRENCY_ARR = ["USD","KYD"]
var bluetoothData = BluetoothDataResponseModel()
var filterFrmDate = Date()
var filterToDate = Date()
var tagForDatePicker = 0
var isEditDate = false
//let terminalArr = [["plc": "InVoice Number #" ,"value":""],["plc": "Amount" ,"value":""],["plc": "Select Currency" ,"value":""],["plc": "First Name" ,"value":""],["plc": "Last Name" ,"value":""],["plc": "Customer Email" ,"value":""],["plc": "Phone Number" ,"value":""],["plc": "Address1" ,"value":""],["plc": "Address2" ,"value":""],["plc": "State" ,"value":""],["plc": "City" ,"value":""],["plc": "Postal Code" ,"value":""],["plc": "Select Country" ,"value":""]]


// User Default

let kAccessToken        = "Access Token"
let kName               = "Name"
let kEmail              = "Email"
let kUrl                = "Url"
let kloginEmail         = "loginEmail"
let kloginPass          = "loginPassword"
let kloginType          = "loginType"
let kInvoicePresent     = "invoicePresent"
let kVTerminalPresent   = "terminalPresent"
let kIsRefund           = "isRefund"
let kDefaultCrncy       = "defaultCrncy"
let ktknKyd             = "tknKyd"
let ktknUsd             = "tknUsd"

