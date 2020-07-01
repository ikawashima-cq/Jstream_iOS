//
//  NetWorkViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/13.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit
import Network
import jstPlayerSDK

class NetWorkViewController:UIViewController{
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let urlList = ["https://eqlive-eqd015yfct-live.eq.hls.wselive.stream.ne.jp/eq-live/1/eqlive-eqd015yfct-live/fmsins-00002/stream-00002-high/chunklist.m3u8","https://5b180bc34c6e0.streamlock.net/player_sdk_test/Stream1/playlist.m3u8?DVR","https://eqd114dmqf.eq.webcdn.stream.ne.jp/www50/eqd114dmqf/jmc_pub/jmc_pd/00005/3de025097f204317ae9c2b27d82582b6.m3u8","","",""]
    var videoView:JstPlayerSDK = JstPlayerSDK()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        self.videoView.stopPlayer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initAction()
    }
    func initView(){
        initPlayerView()
    }
    func initPlayerView(){
        let boundSize: CGSize = PlayerView.bounds.size
        
        videoView.frame = CGRect(x: 0, y: 0, width: boundSize.width, height: boundSize.height)
        PlayerView.insertSubview(videoView, at: 0)
        self.videoView.initPlayer(url: urlList[2], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.dvr.rawValue, title: "hoge")
        self.observeManage()
    }
    func initAction(){
        
    }
    func getNetWork(){
        
    }
    func observeManage(){
        self.videoView.startPlayerItemObserve()
        //self.videoView.setObserver(name:JstPlayerSDK.ReadyToPlay,completion:playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.DidPlayToEndTime, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.TimeJumped, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.PlaybackStalled, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.FailedToPlayToEndTime, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.PlayBackBufferFull, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.PreSeek, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.DidSeek, completion: playerObserve(notification:))
        //self.videoView.setObserver(name:JstPlayerSDK.DidPresentationSizeChange, completion: playerObserve(notification:))
        //self.videoView.playbackObserve()
        self.videoView.setObserver(name:JstPlayerSDK.DidStartVideo, completion: playerObserve(notification:))
        self.videoView.setObserver(name:JstPlayerSDK.DidStopVideo, completion: playerObserve(notification:))
    }
    func playerObserve(notification:Notification){
        print(notification.name)
        let labelText = self.statusLabel.text ?? ""
        var text:String = ""
        let format = DateFormatter()
        format.dateStyle = .none
        format.timeStyle = .medium
        format.locale = Locale(identifier: "ja_JP")
        let date = Date()
        switch notification.name{
        case JstPlayerSDK.DidStartVideo:
            text = String(notification.name.rawValue)
        case JstPlayerSDK.DidStopVideo:
            text = String(notification.name.rawValue)
        default:
            text = ""
        }
        self.statusLabel.text = labelText + "\r\n" + format.string(from: date) + text
        print(self.statusLabel.text as Any)
    }
}
