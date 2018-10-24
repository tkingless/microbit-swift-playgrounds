//#-hidden-code
//
//  LiveView.swift
//
//#-end-hidden-code

import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let dartboardController = DartboardViewController.controllerFromStoryboard("Dartboard")
page.liveView = dartboardController
