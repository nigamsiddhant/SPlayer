//
//  SPlayerConfig.swift
//  SPlayer
//
//  Created by mac  on 28/11/20.
//

import Foundation


public class SPlayerConfig: NSObject{
    public var playerView: UIView?
    public var playerUrl: URL?
    public var isPauseButtonNeeded = false
    public var isMuteButtonNeeded = false
    public var isExpandButtonNeeded = false
    public var developerViewController: UIViewController?
    public var playerViewHeightConstraint: NSLayoutConstraint?
}
