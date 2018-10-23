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
    
    var proxyConnectionIsOpen = false
    var receivingEvents = false
    
    public var btManager: BTManager! {
        didSet {
            btManager.delegate = self
            btManager.messageLogger = self
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        if let log = self.logTextView {
//            //self.liveViewController.logMessage("view did load safe area: \(self.liveViewSafeAreaGuide)")
//            log.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                log.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor, constant: 0.0),
//                log.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor, constant: 0.0),
//                log.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor, constant: 0.0),
//                log.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor, constant: 0.0)
//                ])
//        }
        self.logTextView.isHidden = false

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
    
    @IBAction func OnBtnLeftClicked (_ sender: UIButton) {
        let delimitedText =  "L."
        if let microbit = self.btManager.microbit {
            microbit.writeValue(delimitedText.microbitData, forCharacteristicUUID: .uartRX,
                                 handler: {(characteristic, error) in
                                    self.logMessage("error happened")
            })
        }
        //self.btManager.microbit!.writeValue(delimitedText.microbitData, forCharacteristicUUID: .uartRX,
                                            handler: {(characteristic, error) in
                                                self.logMessage("error happened")
        })
    }
    
    @IBAction func OnBtnRightClicked (_ sender: UIButton) {
        let delimitedText =  "R."
        if let microbit = self.btManager.microbit {
            microbit.writeValue(delimitedText.microbitData, forCharacteristicUUID: .uartRX,
                                handler: {(characteristic, error) in
                                    self.logMessage("error happened")
            })
        }
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
        self.bluetoothController.view.isHidden = false
    }
    
    public func btManager(_ manager: BTManager,
                          didDisconnectMicrobit microbit: BTMicrobit?,
                          error: Error?) {
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

extension DartboardViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened() {
        
        self.proxyConnectionIsOpen = true
        //self.liveViewController.dataActivityItem = nil
        //liveViewController.logMessage("liveViewMessageConnectionOpened")
        
        // When the connection opens register for event notifications
        if let microbit = self.btManager.microbit {
            if !receivingEvents {
                microbit.setNotifyValueForMicrobitEvent(true, handler: {
                    (characteristic: CBCharacteristic, error: Error?) in
                    
                    if let eventData = characteristic.value {
                        if eventData.count % MemoryLayout<BTMicrobit.Event>.stride == 0 {
                            //let eventArray = eventData.toArray(type: BTMicrobit.Event.self)
                            //self.liveViewController.logMessage("micro:bit event array: + \(eventData as NSData)")
                            let message = PlaygroundValue.fromActionType(.requestEvent,
                                                                         data: eventData)
                            self.send(message)
                        }
                    }
                    return self.proxyConnectionIsOpen ? .continueNotifications : .stopNotifications
                })
                receivingEvents = true
            }
        }
    }
    
    public func liveViewMessageConnectionClosed() {
        
        self.proxyConnectionIsOpen = false
        //self.liveViewController.logMessage("liveViewMessageConnectionClosed")
        // We need to stop receiving events otherwise they appear more than once when re-running content code.
        // We do not however clear the micro:bit's handlers when the connection closes as
        // this stops the values table from updating - instead we need to just clear the handlers from the content code.
        if let microbit = self.btManager.microbit {
            microbit.setNotifyValueForMicrobitEvent(false)
            receivingEvents = false
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        
        if let actionType = message.actionType {
            
            let microbit = self.btManager.microbit
            
            switch actionType {
                
            case .readData:
                guard let characteristicUUID = message.characteristicUUID else { return }

                    microbit?.readValueForCharacteristic(characteristicUUID,
                                                         handler: {(characteristic, error) in
                                                            let returnedMessage = PlaygroundValue.fromActionType(actionType,
                                                                                                                 characteristicUUID: characteristicUUID,
                                                                                                                 data: characteristic.value)
                                                            //liveViewController.logMessage("Received data: \(characteristic.value as! NSData)")
                                                            self.send(returnedMessage)
                    })

                
            case .writeData:
                guard let characteristicUUID = message.characteristicUUID else { return }
                if let data = message.data {
                    
                    microbit?.writeValue(data,
                                         forCharacteristicUUID: characteristicUUID,
                                         handler: {(characteristic, error) in
                                            let returnedMessage = PlaygroundValue.fromActionType(actionType,
                                                                                                 characteristicUUID: characteristicUUID,
                                                                                                 data: characteristic.value)
                                            self.send(returnedMessage)
                    })
                }
                
            case .startNotifications:
                guard let characteristicUUID = message.characteristicUUID else { return }
                microbit?.setNotifyValue(true,
                                         forCharacteristicUUID: characteristicUUID,
                                         handler: notificationsHandler)
                break
                
            case .stopNotifications:
                break
            
            default:
                break
            }
        }
    }
    
    //MARK: - Private Functions
    
    func notificationsHandler(characteristic: CBCharacteristic, error: Error?) -> BTPeripheral.NotificationAction {
        
        guard let characteristicUUID = BTMicrobit.CharacteristicUUID(rawValue: characteristic.uuid.uuidString) else { return .stopNotifications}
        let returnedMessage = PlaygroundValue.fromActionType(.startNotifications,
                                                             characteristicUUID: characteristicUUID,
                                                             data: characteristic.value)
        self.send(returnedMessage)
        return self.proxyConnectionIsOpen ? .continueNotifications : .stopNotifications
    }
}
