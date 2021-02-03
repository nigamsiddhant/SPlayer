//
//  SPlayerProtocol.swift
//  SPlayer
//
//  Created by mac  on 28/11/20.
//

import Foundation

public protocol SPlayerDelegate {
    func sPlayerTrackers(tracker: SPlayerTracker)
    func onSPlayerFailed(error: String)
}
