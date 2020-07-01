//
//  SSAIViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/13.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit
import jstPlayerSDK
import AVFoundation
import AVKit
import CsideReport

class SSAIViewController:UIViewController{
    let urlList = ["https://26c48e7b6f0b48d09e1591fd0614276a.mediatailor.ap-northeast-1.amazonaws.com/v1/session/db31c50d2adf913f91718495adb476b09bb1ce52/ishita_caption_audio_test/master.m3u8"]
    var videoView:JstPlayerSDK = JstPlayerSDK()
    
    var ssaiManager:SSAIManager?
    var trackingTimer:CSRPLegacyTrackingTimerWithAVPlayer?
    var inited:Bool = false
    
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoView.stopPlayer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        if !inited{
            inited = true
            initView()
            initAction()
            initVideo()
        }
    }
    func initView(){
        let boundSize: CGSize = PlayerView.bounds.size
        print(boundSize)
        videoView.frame = CGRect(x: 0, y: 0, width: boundSize.width, height: boundSize.height)
        statusLabel.textColor = UIColor.white
        let layer = statusLabel.layer
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        PlayerView.addSubview(videoView)
    }
    func initAction(){
        
    }
    func initVideo(){
        if let url = UserDefaults.standard.object(forKey: "ssaiCsrUrl") as? String{
            if let playURL = URL(string: url){
                self.ssaiManager = SSAIManager()
                self.ssaiManager?.sessionManager?.startSession(with: playURL, params: self.ssaiManager?.newAdsParams(), onComplete: { manifest in
                    DispatchQueue.main.async{
                        self.onCompleteStartSession(manifest: manifest!)
                        self.initObserve()
                    }
                })
            }
        }
    }
    func initObserve(){
        self.videoView.startPlayerItemObserve()
        self.videoView.setObserver(name:JstPlayerSDK.DidStartVideo, completion: playerObserve(notification:))
        self.videoView.setObserver(name:JstPlayerSDK.DidStopVideo, completion: playerObserve(notification:))
    }
    func onCompleteStartSession(manifest:URL){
        print(manifest)
        trackingTimer = CSRPLegacyTrackingTimerWithAVPlayer(sessionManager: self.ssaiManager?.sessionManager)
        trackingTimer?.playerHolder.player = self.videoView.player
        trackingTimer?.drivers = self.ssaiManager?.newBeaconDrivers()
        self.ssaiManager?.actionTracker = trackingTimer
        trackingTimer?.schedule()
        self.videoView.loadItem(url:manifest,preferredForwardBufferDuration:10,completion:playerLoad)
    }
    func playerLoad(result: MediaLoader.Result){
        switch result {
            case .success(let player):
                print("SUCCESS")
                self.videoView.player = player
                trackingTimer?.playerHolder.player = self.videoView.player
                trackingTimer?.drivers = self.ssaiManager?.newBeaconDrivers()
                self.ssaiManager?.actionTracker = trackingTimer
                trackingTimer?.schedule()
                self.videoView.playbackObserve()
                self.videoView.postLoadObserve(playerItem:player.currentItem!)
                self.videoView.play()
            case .failed:
                print("FAILED")
            case .timedOut:
                print("TIMED OUT")
       }
    }
    func DidSendBeacon(driver:CSRPLegacyBeaconDriver){
        let text:String = String(format:("%@"),driver)
        outputLog(text: text)
    }
    func playerObserve(notification:Notification){
        var text:String! = ""
        switch notification.name{
        case JstPlayerSDK.DidStartVideo:
            text = String(notification.name.rawValue)
        case JstPlayerSDK.DidStopVideo:
            text = String(notification.name.rawValue)
        default:
            text = ""
        }
        self.outputLog(text: text)
    }
    func outputLog(text:String){
        let labelText = self.statusLabel.text ?? ""
        let format = DateFormatter()
        format.dateStyle = .none
        format.timeStyle = .medium
        format.locale = Locale(identifier: "ja_JP")
        let date = Date()
        self.statusLabel.text = labelText + "\r\n" + format.string(from: date) + " " + text
    }
}
