//
//  DartboardViewController.swift
//  
//
//  Created by tkingless on 2018/10/16.
//

import UIKit
import PlaygroundSupport

@objc(DartboardViewController)
public class DartboardViewController : UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    public static func controllerFromStoryboard(_ storyboardName: String) -> DartboardViewController {
        
        let bundle = Bundle(for: DartboardViewController.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! DartboardViewController
        
        return controller
    }
    
}


