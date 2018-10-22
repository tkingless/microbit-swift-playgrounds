//
//  DartboardViewController.swift
//  
//
//  Created by tkingless on 2018/10/16.
//

import UIKit
import PlaygroundSupport
import CoreBluetooth
import PlaygroundBluetooth

@objc(DartboardViewController)
public class DartboardViewController : UIViewController, PlaygroundLiveViewSafeAreaContainer, BTManagerDelegate, LoggingProtocol {
    
    var bluetoothController: BluetoothConnectionViewController!
    @IBOutlet weak var logTextView: UITextView!
    
    public var btManager: BTManager! {
        didSet {
            btManager.delegate = self
            btManager.messageLogger = self
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let log = self.logTextView {
            //self.liveViewController.logMessage("view did load safe area: \(self.liveViewSafeAreaGuide)")
            log.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                log.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor, constant: 0.0),
                log.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor, constant: 0.0),
                log.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor, constant: 0.0),
                log.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor, constant: 0.0)
                ])
        }
        self.logTextView.isHidden = true

        self.logMessage("Success")
        self.btManager = BTManager()
        if self.btManager != nil {
            self.logMessage("self.btManager  is not nil")
        } else {
            self.logMessage("self.btManager  is nil")
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let devicesMappingDict = self.btManager.pairedDeviceMappings {
            bluetoothController?.view.isHidden = devicesMappingDict.count == 0
            self.logMessage("devicesMappingDict.count is \(devicesMappingDict.count)")
            if self.btManager.microbit == nil {
                _ = self.btManager.bluetoothCentralManager.connectToLastConnectedPeripheral(timeout: 7.0,
                                                                                            callback: {(peripheral: CBPeripheral?, error: Error?) in
                                                                                                // TODO: - Handle the error here - although unlikely
                })
            }
            
        } else {
            bluetoothController?.view.isHidden = true
            self.logMessage("devicesMappingDict is nil")
        }
        
    }
    
    //To instantiate a DartboardViewController from Dartboard.storyboard
    public static func controllerFromStoryboard(_ storyboardName: String) -> DartboardViewController {
        
        let bundle = Bundle(for: DartboardViewController.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! DartboardViewController
        
        return controller
    }
    
    //MARK: - BTManagerDelegate
    
    public func logMessage(_ message: String) {
        
        let string = self.logTextView.text + "\n" + message
        self.logTextView?.text = string
    }
    
    public func btManagerStateDidChange(_ manager: BTManager) {
        
        if (manager.bluetoothCentralManager.state == .poweredOn) {
            self.logMessage("Central manager changed state to 'poweredOn'")
            
            self.bluetoothController = BluetoothConnectionViewController(bluetoothManager: self.btManager)
            self.bluetoothController.messageLogger = self
            if let connectionView = bluetoothController.view {
                let safeAreaGuide = self.liveViewSafeAreaGuide
                self.view.addSubview(connectionView)
                connectionView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    connectionView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor, constant: 12.0),
                    connectionView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: 0.0),
                    connectionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 270.0)
                    ])
            }
        }
    }
    
    public func btManager(_ manager: BTManager,
                          didConnectMicrobit microbit: BTMicrobit) {
        
        let message = PlaygroundValue.fromActionType(.connectionChanged)
        //        self.containerViewController.send(message)
        
        //        self.pairButton.isHidden = true
        self.bluetoothController.view.isHidden = false
        //
        //        self.microbitMimic.isActive = false
        
        //        var characteristicUUID: BTMicrobit.CharacteristicUUID?
        //        // Get the microbit image and cache it.
        //        characteristicUUID = .ledStateUUID
        //        microbit.readValueForCharacteristic(characteristicUUID!,
        //                                            handler: {(characteristic: CBCharacteristic, error: Error?) in
        //
        //                                                if let data = characteristic.value {
        //                                                    //self.logMessage("I got image: \(data as! NSData)")
        //                                                    self.microbitMimic.microbitImage = MicrobitImage(data)
        //                                                }
        //        })
        //
        //        characteristicUUID = .ledScrollingDelayUUID
        //        microbit.readValueForCharacteristic(characteristicUUID!,
        //                                            handler: {(characteristic: CBCharacteristic, error: Error?) in
        //
        //                                                if let data = characteristic.value {
        //                                                    if let scrollingDelay = data.integerFromLittleUInt16 {
        //                                                        //self.logMessage("Default scrolling delay: \(scrollingDelay)")
        //                                                        self.microbitMimic.scrollingDelay = scrollingDelay
        //                                                    }
        //                                                }
        //        })
        //
        //        characteristicUUID = .buttonStateAUUID
        //        microbit.setNotifyValue(true,
        //                                forCharacteristicUUID: characteristicUUID!,
        //                                handler: {(characteristic: CBCharacteristic, error: Error?) in
        //                                    if let data = characteristic.value {
        //                                        let buttonState = BTMicrobit.ButtonState(data) ?? BTMicrobit.ButtonState.notPressed
        //                                        self.microbitMimic.showButtonAPressed(buttonState != .notPressed)
        //                                        return .continueNotifications
        //                                    }
        //                                    return .stopNotifications
        //        })
        //
        //        characteristicUUID = .buttonStateBUUID
        //        microbit.setNotifyValue(true,
        //                                forCharacteristicUUID: characteristicUUID!,
        //                                handler: {(characteristic: CBCharacteristic, error: Error?) in
        //                                    if let data = characteristic.value {
        //                                        let buttonState = BTMicrobit.ButtonState(data) ?? BTMicrobit.ButtonState.notPressed
        //                                        self.microbitMimic.showButtonBPressed(buttonState != .notPressed)
        //                                        return .continueNotifications
        //                                    }
        //                                    return .stopNotifications
        //        })
        //
        //        self.setupValuesTable()
    }
    
    public func btManager(_ manager: BTManager,
                          didDisconnectMicrobit microbit: BTMicrobit?,
                          error: Error?) {
        
        let message = PlaygroundValue.fromActionType(.connectionChanged)
        //        self.containerViewController.send(message)
        //
        //        self.pairButton.isHidden = false
        //        self.microbitMimic.resetInterface()
        //        self.microbitMimic.isActive = true
        //        self.setupValuesTable()
    }
    
    public func btManager(_ manager: BTManager,
                          didFailToConnectToPeripheral peripheral: CBPeripheral,
                          error: Error?) {
        
        // If we fail to connect to a micro:bit then should we remove its UUID from the list of paired devices.
        // This maybe because the pairing information was deleted from the iOS device's Settings
        if error != nil {
            if var devicesMappingDict = manager.pairedDeviceMappings {
                devicesMappingDict[String(describing: peripheral.identifier)] = nil
                manager.pairedDeviceMappings = devicesMappingDict
            }
        }
        
        //        self.pairButton.isHidden = false
        //        self.microbitMimic.isActive = true
    }
    
    // This delegate is not called if the array is empty - there is at least one missing service.
    public func btManager(_ manager: BTManager,
                          didTimeoutReadingServices services: Array<BTMicrobit.ServiceUUID>) {
        
    }
    
    public func btManager(_ manager: BTManager,
                          didPairToMicrobit microbit: BTMicrobit?,
                          error: BTManager.PairingError?) {
        
        if let peripheral = microbit?.peripheral, let microbitName = self.btManager.microbitNameForPeripheral(peripheral) {
            
            // Ensure peripheral is renamed after pairing
            if let btConnectionView = bluetoothController.view as? PlaygroundBluetoothConnectionView {
                btConnectionView.setName(microbitName, forPeripheral: peripheral)
            }
        }
    }
}


