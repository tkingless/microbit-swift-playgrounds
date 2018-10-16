//#-hidden-code
//
//  LiveView.swift
//
//#-end-hidden-code

import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let dartboardCtlr = DartboardViewController.controllerFromStoryboard("Dartboard")
page.liveView = dartboardCtlr
