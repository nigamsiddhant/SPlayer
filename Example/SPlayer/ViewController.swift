//
//  ViewController.swift
//  SPlayer
//
//  Created by siddhant nigam on 11/28/2020.
//  Copyright (c) 2020 siddhant nigam. All rights reserved.
//

import UIKit
import SPlayer

class ViewController: UIViewController ,SPlayerDelegate {

    @IBOutlet weak var playerHeight: NSLayoutConstraint!
    @IBOutlet weak var devView: UIView!
    var sPlayer: SPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard let url = URL(string: "https://adsmedia.zee5.com/stg/v/s/vast/77515_1603825487187_sd.mp4/master.m3u8") else {
            return
        }
        
        let sPlayerConfig = SPlayerConfig()
        sPlayerConfig.developerViewController = self
        sPlayerConfig.playerUrl = url
        sPlayerConfig.isPauseButtonNeeded = true
        sPlayerConfig.isExpandButtonNeeded = true
        sPlayerConfig.isMuteButtonNeeded = true
        sPlayerConfig.playerView = self.devView
        sPlayerConfig.playerViewHeightConstraint = self.playerHeight
        self.sPlayer = SPlayer(sPlayerConfig: sPlayerConfig)
        sPlayer?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sPlayerTrackers(tracker: SPlayerTracker) {
        print(tracker)
    }
    
    func onSPlayerFailed(error: String) {
        print("error: \(error)")
    }

}

