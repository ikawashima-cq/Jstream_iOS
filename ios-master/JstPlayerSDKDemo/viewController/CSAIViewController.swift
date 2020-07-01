//
//  CSAIViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/13.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//
import AVFoundation
import GoogleInteractiveMediaAds
import UIKit
import jstPlayerSDK

class CSAIViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    static let kTestAppContentUrl_MP4 = "https://eqd114dmqf.eq.webcdn.stream.ne.jp/www50/eqd114dmqf/jmc_pub/jmc_pd/00005/3de025097f204317ae9c2b27d82582b6.m3u8"
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    //@IBOutlet weak var playButton: UIButton!
    //@IBOutlet weak var videoView: UIView!
    var jstPlayerSDK:JstPlayerSDK?
    var contentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    var inited:Bool = false
    
    static let kTestAppAdTagUrl =
        "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&" +
            "iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&" +
            "output=vast&unviewed_position_start=1&" +
    "cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jstPlayerSDK?.stopPlayer()
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        if !inited{
            inited = true
            playButton.layer.zPosition = CGFloat.greatestFiniteMagnitude
            
            setUpContentPlayer()
            setUpAdsLoader()
        }
    }
    @IBAction func onPlayButtonTouch(_ sender: AnyObject) {
        //jstPlayerSDK?.play()
        requestAds()
        playButton.isHidden = true
    }
    
    func setUpContentPlayer() {
        // Load AVPlayer with path to our content.
        let contentURL = CSAIViewController.kTestAppContentUrl_MP4
        //contentPlayer = AVPlayer(url: contentURL)
        
        // Create a player layer for the player.
        //playerLayer = AVPlayerLayer(player: contentPlayer)
        jstPlayerSDK = JstPlayerSDK()
        contentPlayer = jstPlayerSDK?.player
        jstPlayerSDK?.initPlayer(url: contentURL, startPosition: 0, autoPlay: false, mediaMode: JstPlayerSDK.mediaMode.vod.rawValue, title: "csaidemo")
        
        // Size, position, and display the AVPlayer.
        jstPlayerSDK?.frame = videoView.bounds
        videoView.insertSubview(jstPlayerSDK!,at:0)
        
        // Set up our content playhead and contentComplete callback.
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
        jstPlayerSDK?.setObserver(name: JstPlayerSDK.DidPlayToEndTime, completion: contentDidFinishPlaying(notification:))
        //    NotificationCenter.default.addObserver(
        //      self,
        //      selector: #selector(CSAIViewController.contentDidFinishPlaying(_:)),
        //      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
        //      object: jstPlayerSDK?.player?.currentItem);
    }
    
    func contentDidFinishPlaying(notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        adsLoader.contentComplete()
    }
    
    func setUpAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }
    
    func requestAds() {
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: videoView, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: CSAIViewController.kTestAppAdTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        
        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = self
        
        // Initialize the ads manager.
        adsManager.initialize(with: adsRenderingSettings)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: \(adErrorData.adError.message)")
        jstPlayerSDK?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        print("AdsManager error: \(error.message)")
        jstPlayerSDK?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // The SDK is going to play ads, so pause the content.
        jstPlayerSDK?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now), so resume the content.
        jstPlayerSDK?.play()
    }
}

