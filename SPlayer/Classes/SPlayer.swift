
import Foundation
import UIKit
import AVFoundation



public class SPlayer: NSObject {
        
    private var mAvPlayer: AVPlayer?
    private var mAvPlayerLayer: AVPlayerLayer?
    
    private var mplayerView: UIView?
    private var mediaUrl: URL?
    private var isMuteNeeded = false
    private var isExpandNeeded = false
    private var isPauseNeeded = false
    private var viewController: UIViewController?
    private var developerViewHeight: NSLayoutConstraint?
    
    private var progressBar: UIProgressView?
    
    private var playPauseImage: UIImageView?
    
    private var playerItemContext = 0
    
    private var muteButton: UIButton?
    private var expandButton: UIButton?
    
    private var isMute = false
    private var isFullScreen = false
    private var notificationCenter = NotificationCenter.default
    public var delegate: SPlayerDelegate?
    
    private var developerView: UIView?
    private var isPlayerPaused = false
    
    public init(sPlayerConfig: SPlayerConfig) {
        super.init()
        
        if sPlayerConfig.developerViewController == nil {
            self.delegate?.onSPlayerFailed(error: "developer view not assigned")
            return
        }
        
        if sPlayerConfig.playerUrl == nil {
            self.delegate?.onSPlayerFailed(error: "media url not assigned")
            return
        }
        
        if sPlayerConfig.playerView != nil {
            if sPlayerConfig.playerViewHeightConstraint == nil {
                self.delegate?.onSPlayerFailed(error: "missing playerView")
                return
            }
        }
        
        if sPlayerConfig.playerViewHeightConstraint != nil {
            if sPlayerConfig.playerView == nil {
                self.delegate?.onSPlayerFailed(error: "missing playerViewHeightConstraint")
                return
            }
        }
        
        self.developerView = sPlayerConfig.playerView
        self.mediaUrl = sPlayerConfig.playerUrl
        self.isMuteNeeded = sPlayerConfig.isMuteButtonNeeded
        self.isExpandNeeded = sPlayerConfig.isExpandButtonNeeded
        self.viewController = sPlayerConfig.developerViewController
        self.isPauseNeeded = sPlayerConfig.isPauseButtonNeeded
        self.developerViewHeight = sPlayerConfig.playerViewHeightConstraint
        
        DispatchQueue.main.async {
            self.preparePlayer()
            self.setupPlayerViewFrame(isFullScreen: false)
        }
        
    }
    
    deinit {
        self.destoryPlayerClass()
    }
    
    public func destoryPlayerClass(){
        self.mAvPlayer = nil
        self.mAvPlayerLayer = nil
        self.mplayerView = nil
        self.mediaUrl = nil
        self.viewController = nil
        self.progressBar = nil
        self.playPauseImage = nil
        self.muteButton = nil
        self.expandButton = nil
        self.delegate = nil
        self.developerView = nil
        self.notificationCenter.removeObserver(self)
        self.developerViewHeight = nil
    }
    
    private func setupPlayerViewFrame(isFullScreen: Bool){
        
        
        self.mplayerView?.removeFromSuperview()
        self.mplayerView = nil
        self.mplayerView = UIView()
        let height = isFullScreen == true ? UIScreen.main.bounds.height : 250
        let width = UIScreen.main.bounds.width
        if developerView == nil {
            self.mplayerView?.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        else {
            self.mplayerView?.frame = self.developerView!.frame
        }
        
        
        if let playerView = self.mplayerView{
            playerView.backgroundColor = .red
            self.viewController?.view.addSubview(playerView)
            self.viewController?.view.bringSubviewToFront(playerView)
        }
        else {
            self.delegate?.onSPlayerFailed(error: "playerView not found")
        }
        
        if let playerView = self.mplayerView{
            self.mAvPlayerLayer = AVPlayerLayer(player: self.mAvPlayer)
            mAvPlayerLayer?.frame = playerView.bounds
            mAvPlayerLayer?.videoGravity = .resizeAspectFill
            playerView.layer.addSublayer(mAvPlayerLayer!)
            
            self.showMuteButton(isMuteNeeded: self.isMuteNeeded)
            self.showExpandButton(isExpandNeeded: self.isExpandNeeded)
            self.registerPlayPause(isPlayPauseNeeded: self.isPauseNeeded)
            self.addProgressBar()
        }
    }
    
    private func preparePlayer() {
        guard let mediaUrl = self.mediaUrl else {
            self.delegate?.onSPlayerFailed(error: "media url not found")
            return
        }
        self.mAvPlayer = AVPlayer(url: mediaUrl)
        self.mAvPlayer?.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.status),
                                    options: [.old, .new],
                                    context: &playerItemContext)
        self.addContentObserver()
        
        notificationCenter.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        notificationCenter.addObserver(self,
                                       selector:#selector(self.didbecameActive),
                                       name:UIApplication.didBecomeActiveNotification,
                                       object:nil)
        
        notificationCenter.addObserver(self,
                                       selector:#selector(self.didenterBg),
                                       name:UIApplication.didEnterBackgroundNotification,
                                       object:nil)
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.delegate?.sPlayerTrackers(tracker: .completed)
    }
    
    @objc func didbecameActive() {
        self.delegate?.sPlayerTrackers(tracker: .active)
    }
    
    @objc func didenterBg() {
        self.delegate?.sPlayerTrackers(tracker: .backgroud)
    }
    
    private func addContentObserver(){
        self.mAvPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 2), queue: DispatchQueue.global(), using: { (progressTime) in
            guard let progressView = self.progressBar else {
                self.delegate?.onSPlayerFailed(error: "progressView not found")
                return
            }
            
            guard let player = self.mAvPlayer else {
                self.delegate?.onSPlayerFailed(error: "mAvPlayer not found")
                return
            }
            
            let totalVideotime = player.currentItem?.asset.duration.seconds ?? 0.0
            let midQuartitle = totalVideotime/2
            let firstQuartile = midQuartitle/2
            let thirdQuartile = midQuartitle + firstQuartile
            
            let playerCurrentTime = progressTime.seconds.rounded()
            
            if playerCurrentTime == firstQuartile.rounded() {
                self.delegate?.sPlayerTrackers(tracker: .firstQuartile)
            }
            if playerCurrentTime == midQuartitle.rounded() {
                self.delegate?.sPlayerTrackers(tracker: .midpoint)
            }
            if playerCurrentTime == thirdQuartile.rounded() {
                self.delegate?.sPlayerTrackers(tracker: .thirdQuartile)
            }
            
            DispatchQueue.main.async {
                let duration = CMTimeGetSeconds(player.currentItem!.duration)
                progressView.progress = Float((CMTimeGetSeconds(progressTime) / duration))
            }
            
            
        })
    }
    
    private func addProgressBar() {
        self.progressBar?.removeFromSuperview()
        self.progressBar = UIProgressView()
        
        guard let progressView = self.progressBar else {
            self.delegate?.onSPlayerFailed(error: "progressView not found")
            return
        }
        
        guard let playerView = self.mplayerView else {
            self.delegate?.onSPlayerFailed(error: "playerView not found")
            return
        }
        
        guard let playerLayer = self.mAvPlayerLayer else {
            self.delegate?.onSPlayerFailed(error: "playerLayer not found")
            return
        }
        
        let width = playerView.bounds.width
        progressView.backgroundColor = .green
        playerView.addSubview(progressView)
        playerView.bringSubviewToFront(progressView)
        progressView.frame = CGRect(x: 0, y: playerLayer.frame.maxY - 2, width: width, height: 20)
        
        progressView.progress = 0
        
    }
    
    
    
    private func showExpandButton(isExpandNeeded: Bool){
        if isExpandNeeded{
            self.expandButton = UIButton(type: .custom)
            self.expandButton?.removeFromSuperview()
            
            guard let expandButtons = self.expandButton else {
                self.delegate?.onSPlayerFailed(error: "Failed to create mute Button")
                return
            }
            
            guard let playerView = self.mplayerView else {
                self.delegate?.onSPlayerFailed(error: "playerView not found")
                return
            }
            
            guard let playerLayer = self.mAvPlayerLayer else {
                self.delegate?.onSPlayerFailed(error: "playerView not found")
                return
            }
            
            playerView.addSubview(expandButtons)
            expandButtons.frame = CGRect(x: 10, y: playerLayer.frame.maxY - 40, width: 30, height: 30)
            playerView.bringSubviewToFront(expandButtons)
            self.expandButton?.setImage(SPlayerUtilities.shared.expand, for: .normal)
            expandButtons.addTarget(self, action: #selector(self.expandcollapseButtonClicked(sender:)), for: .touchUpInside)
            expandButtons.tintColor = .white
        }
    }
    
    private func showMuteButton(isMuteNeeded: Bool){
        if isMuteNeeded {
            self.muteButton = UIButton(type: .custom)
            self.muteButton?.removeFromSuperview()
            
            guard let muteButtons = self.muteButton else {
                self.delegate?.onSPlayerFailed(error: "Failed to create mute Button")
                return
            }
            
            guard let playerView = self.mplayerView else {
                self.delegate?.onSPlayerFailed(error: "playerView not found")
                return
            }
            
            guard let playerLayer = self.mAvPlayerLayer else {
                self.delegate?.onSPlayerFailed(error: " playerView not found")
                return
            }
            
            
            playerView.addSubview(muteButtons)
            self.muteButton?.frame = CGRect(x: playerLayer.frame.maxX - 40, y: playerLayer.frame.maxY - 40, width: 30, height: 30)
            playerView.bringSubviewToFront(muteButtons)
            muteButtons.setImage(UIImage.init(named: "unmute")?.withRenderingMode(.alwaysTemplate), for: .normal)
            muteButtons.setImage(SPlayerUtilities.shared.unmute, for: .normal)
            muteButtons.addTarget(self, action: #selector(self.muteButtonClicked(sender:)), for: .touchUpInside)
            muteButtons.tintColor = .white
        }
    }
    
    private func registerPlayPause(isPlayPauseNeeded: Bool){
        if isPlayPauseNeeded{
            guard let playerView = self.mplayerView else {
                self.delegate?.onSPlayerFailed(error: "playerView not found")
                return
            }
            
            self.playPauseImage?.removeFromSuperview()
            self.playPauseImage = UIImageView()
            
            guard let playPauseIcon = self.playPauseImage else {
                self.delegate?.onSPlayerFailed(error: "Failed to create playPauseIcon")
                return
            }
            
            guard let playerLayer = self.mAvPlayerLayer else {
                self.delegate?.onSPlayerFailed(error: "mAvPlayerLayer not found")
                return
            }
            
            DispatchQueue.main.async {
                self.playPauseImage?.frame = CGRect(origin: CGPoint(x: playerLayer.frame.midX, y: playerLayer.frame.midY), size: CGSize(width: 30, height: 30))
                playerView.addSubview(playPauseIcon)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewForMediaTapped(_:)))
                self.mplayerView?.addGestureRecognizer(tapGesture)
                playPauseIcon.image = playPauseIcon.image?.withRenderingMode(.alwaysTemplate)
                playPauseIcon.tintColor = UIColor.white
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                self.mAvPlayer?.play()
                self.delegate?.sPlayerTrackers(tracker: .start)
            case .failed:
                self.delegate?.onSPlayerFailed(error: "player failed to play")
            case .unknown:
                self.delegate?.onSPlayerFailed(error: "unknown error")
            @unknown default:
                self.delegate?.onSPlayerFailed(error: "unknown errors")
            }
            
        }
    }
    
    public func sPlayerStop() {
        guard let player = self.mAvPlayer else {
            self.delegate?.onSPlayerFailed(error: "player not found")
            return
        }
        player.pause()
        player.seek(to: .zero)
    }
    
    public func sPlayerPause() {
        guard let player = self.mAvPlayer else {
            self.delegate?.onSPlayerFailed(error: "player not found")
            return
        }
        self.isPlayerPaused = true
        player.pause()
        self.delegate?.sPlayerTrackers(tracker: .pause)
        self.playPauseImage?.image = SPlayerUtilities.shared.play
    }
    
    public func sPlayerPlay() {
        guard let player = self.mAvPlayer else {
            self.delegate?.onSPlayerFailed(error: "player not found")
            return
        }
        self.isPlayerPaused = false
        player.play()
        self.delegate?.sPlayerTrackers(tracker: .resume)
        self.playPauseImage?.image = nil
    }
    
    public func sPlayerReplay() {
        guard let player = self.mAvPlayer else {
            self.delegate?.onSPlayerFailed(error: "player not found")
            return
        }
        player.pause()
        player.seek(to: .zero)
        player.play()
    }
    
    @objc func muteButtonClicked(sender: UIButton){
        if isMute == false{
            self.isMute = true
            self.mAvPlayer?.isMuted = true
            self.muteButton?.setImage(SPlayerUtilities.shared.mute, for: .normal)
            self.delegate?.sPlayerTrackers(tracker: .muted)
        }
        else {
            isMute = false
            self.mAvPlayer?.isMuted = false
            self.muteButton?.setImage(SPlayerUtilities.shared.unmute, for: .normal)
            self.delegate?.sPlayerTrackers(tracker: .unmuted)
        }
    }
    
    @objc func viewForMediaTapped(_ sender: UITapGestureRecognizer? = nil){
        if isPlayerPaused{
            isPlayerPaused = false
            self.sPlayerPlay()
        }
        else {
            isPlayerPaused = true
            self.sPlayerPause()
        }
    }
    
    @objc func expandcollapseButtonClicked(sender: UIButton){
        if isFullScreen == false{
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.isFullScreen = true
            self.expandButton?.setImage(SPlayerUtilities.shared.collapse, for: .normal)
            DispatchQueue.main.async {
                self.setupPlayerViewFrame(isFullScreen: true)
                self.delegate?.sPlayerTrackers(tracker: .expanded)
            }
        }
        else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            isFullScreen = false
            self.expandButton?.setImage(SPlayerUtilities.shared.expand, for: .normal)
            DispatchQueue.main.async {
                self.setupPlayerViewFrame(isFullScreen: false)
                self.delegate?.sPlayerTrackers(tracker: .collapsed)
            }
        }
    }
    
    
}
