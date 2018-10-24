//
//  DartboardViewController.swift
//  
//
//  Created by tkingless on 24/10/2018.
//

import UIKit
import CoreBluetooth
import PlaygroundSupport

@objc(DartboardViewController)
public class DartboardViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    public static func controllerFromStoryboard(_ storyboardName: String) ->
        DartboardViewController {
        
        let bundle = Bundle(for: DartboardViewController.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! DartboardViewController
        
        return controller
    }
    
}
