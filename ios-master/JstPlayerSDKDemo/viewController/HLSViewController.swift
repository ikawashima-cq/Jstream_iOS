//
//  HLSViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/13.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import Foundation
import jstPlayerSDK

class HLSViewController: UIViewController {
    
    
    @IBOutlet weak var LiveButton: UIButton!
    @IBOutlet weak var DVRButton: UIButton!
    @IBOutlet weak var VODButton: UIButton!
    @IBOutlet weak var ABRButton: UIButton!
    @IBOutlet weak var FailoverButton: UIButton!
    @IBOutlet weak var PlayerView: UIView!
    
    let urlList = ["https://eqlive-eqd015yfct-live.eq.hls.wselive.stream.ne.jp/eq-live/1/eqlive-eqd015yfct-live/fmsins-00002/stream-00002-high/chunklist.m3u8","https://5b180bc34c6e0.streamlock.net/player_sdk_test/Stream1/playlist.m3u8?DVR","https://eqd114dmqf.eq.webcdn.stream.ne.jp/www50/eqd114dmqf/jmc_pub/jmc_pd/00005/3de025097f204317ae9c2b27d82582b6.m3u8","","",""]
    var videoView:JstPlayerSDK = JstPlayerSDK()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoView.stopPlayer()
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
        self.videoView.initPlayer(url: urlList[1], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.dvr.rawValue, title: "hoge")
    }
    func initAction(){
        LiveButton.addTarget(self, action: #selector(ClickLiveButton(_:)), for: .touchUpInside)
        DVRButton.addTarget(self, action: #selector(ClickDVRButton(_:)), for: .touchUpInside)
        VODButton.addTarget(self, action: #selector(ClickVODButton(_:)), for: .touchUpInside)
        ABRButton.addTarget(self, action: #selector(ClickABRButton(_:)), for: .touchUpInside)
        FailoverButton.addTarget(self, action: #selector(ClickFailoverButton(_:)), for: .touchUpInside)
    }
    @objc func ClickLiveButton(_ sender:UIButton){
        self.videoView.initPlayer(url: urlList[0], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.live.rawValue, title: "hoge")
    }
    @objc func ClickDVRButton(_ sender:UIButton){
        self.videoView.initPlayer(url: urlList[1], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.dvr.rawValue, title: "hoge")
    }
    @objc func ClickVODButton(_ sender:UIButton){
        self.videoView.initPlayer(url: urlList[2], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.vod.rawValue, title: "hoge")
    }
    @objc func ClickABRButton(_ sender:UIButton){
        self.videoView.initPlayer(url: urlList[3], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.live.rawValue, title: "hoge")
    }
    @objc func ClickFailoverButton(_ sender:UIButton){
        self.videoView.initPlayer(url: urlList[4], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.live.rawValue, title: "hoge")
    }
}
