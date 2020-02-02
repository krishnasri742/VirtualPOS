//
//  BluetoothManager.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 15/01/20.
//  Copyright © 2020 Krishna Srivastava. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject, CBPeripheralManagerDelegate {
    
    static let sharedInstance = BluetoothManager()
    
    var bluetoothPeripheralManager: CBPeripheralManager?
    
    
    override fileprivate init() {
    }
    
    func start() {
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.main, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        
    }
    
    // MARK - CBCentralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        var statusMessage = ""
        
        switch peripheral.state {
        case .poweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case .poweredOff:
            statusMessage = "Bluetooth Status: Turned Off"
            HHelper.showBluetoothEnablePopUp()
        case .resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case .unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case .unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        print(statusMessage)
        
        if peripheral.state == .poweredOff {
            //TODO: Update this property in an App Manager class
        }
    }}
