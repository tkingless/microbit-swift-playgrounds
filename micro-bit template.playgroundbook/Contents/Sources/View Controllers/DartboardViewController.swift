//
//  DartboardViewController.swift
//  
//
//  Created by tkingless on 24/10/2018.
//

import UIKit
import CoreBluetooth
import PlaygroundSupport
import PlaygroundBluetooth

@objc(DartboardViewController)
public class DartboardViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer, BTManagerDelegate, LoggingProtocol {
    
    public static func controllerFromStoryboard(_ storyboardName: String) ->
        DartboardViewController {
            
            let bundle = Bundle(for: DartboardViewController.self)
            let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
            let controller = storyboard.instantiateInitialViewController() as! DartboardViewController
            
            return controller
    }
    
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
//        self.logTextView.isHidden = true
        self.btManager = BTManager()
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        if let devicesMappingDict = self.btManager.pairedDeviceMappings {
            bluetoothController?.view.isHidden = devicesMappingDict.count == 0
            if self.btManager.microbit == nil {
                _ = self.btManager.bluetoothCentralManager.connectToLastConnectedPeripheral(timeout: 7.0,
                                                                                            callback: {(peripheral: CBPeripheral?, error: Error?) in
                                                                                                // TODO: - Handle the error here - although unlikely
                })
            }
        } else {
            bluetoothController?.view.isHidden = true
        }
        
    }
    
    //Mark: - BTManagerDelegate
    
    public func logMessage(_ message: String) {
        
        let string = (self.logTextView?.text ?? "") + "\n" + message
        self.logTextView?.text = string
    }
    
    public func btManagerStateDidChange(_ manager: BTManager){
        
        if (manager.bluetoothCentralManager.state == .poweredOn) {
            self.logMessage("Central manager changed state to 'poweredOn'")

            self.bluetoothController = BluetoothConnectionViewController(bluetoothManager: self.btManager)
            self.bluetoothController.messageLogger = self
            if let connectionView = bluetoothController.view {
                self.view.addSubview(connectionView)
                connectionView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    connectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12.0),
                    connectionView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor, constant: 0.0),
                    connectionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 270.0)
                    ])
            }
        }
    }
    
    public func btManager(_ manager: BTManager,
                   didConnectMicrobit microbit: BTMicrobit){
        
        self.bluetoothController.view.isHidden = false
        
    }
    
    public func btManager(_ manager: BTManager,
                   didDisconnectMicrobit microbit: BTMicrobit?,
                   error: Error?){
        
    }
    
    public func btManager(_ manager: BTManager,
                   didFailToConnectToPeripheral peripheral: CBPeripheral,
                   error: Error?){
        // If we fail to connect to a micro:bit then should we remove its UUID from the list of paired devices.
        // This maybe because the pairing information was deleted from the iOS device's Settings
        if error != nil {
            if var devicesMappingDict = manager.pairedDeviceMappings {
                devicesMappingDict[String(describing: peripheral.identifier)] = nil
                manager.pairedDeviceMappings = devicesMappingDict
            }
        }
    }
    
    public func btManager(_ manager: BTManager,
                   didTimeoutReadingServices services: Array<BTMicrobit.ServiceUUID>){
        
    }
    
    public func btManager(_ manager: BTManager,
                   didPairToMicrobit microbit: BTMicrobit?,
                   error: BTManager.PairingError?){
        if let peripheral = microbit?.peripheral, let microbitName = self.btManager.microbitNameForPeripheral(peripheral) {

            // Ensure peripheral is renamed after pairing
            if let btConnectionView = bluetoothController.view as? PlaygroundBluetoothConnectionView {
                btConnectionView.setName(microbitName, forPeripheral: peripheral)
            }
        }
    }
    
}
