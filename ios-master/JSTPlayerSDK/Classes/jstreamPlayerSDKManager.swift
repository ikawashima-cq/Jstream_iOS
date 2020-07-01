//
//  jstreamPlayerSDKManager.swift
//  jstPlayerSDK_Example
//
//  Created by Jストリーム 株式会社　開発 on 2019/12/20.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

//Playerを含むUI View Class
public class JstPlayerSDK: UIView {
    //MARK: - Public properties
    public var player: AVPlayer? {
        get {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            return layer.player
        }
        set(newValue) {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            layer.player = newValue
        }
    }
    public var playbackRate:Float?{
        get{
            return player?.rate
        }
        set(newValue){
            let rate:Float = newValue!
            player?.rate = rate
        }
    }
    public var isPlaying:Bool{
        get{
            return self.player?.rate != 0 && self.player?.error == nil
        }
    }
    public var preferredPeakBitRate:Double?{
        get{
            return self.player?.currentItem?.preferredPeakBitRate
        }
        set(newValue){
            let bitRate = newValue!
            player?.currentItem?.preferredPeakBitRate = bitRate
        }
    }
    private var _preferredMaximumResolution:CGSize?
    public var preferredMaximumResolution:CGSize?{
        get{
            if #available(iOS 11.0, *) {
                return self._preferredMaximumResolution
            } else {
                return nil
            }
        }
        set(newValue){
            if #available(iOS 11.0, *) {
                let size = newValue!
                self._preferredMaximumResolution = size
                self.player?.currentItem?.preferredMaximumResolution = size
            } else {
            }
        }
    }
    public var presentationSize:CGSize?{
        get{
            return player?.currentItem?.presentationSize
        }
    }
    public var loadedTimeRange:NSArray?
    public var title:String = ""
    public var autoPlay:Bool = false
    public var mediaMode:String = "live"
    public var startPosition:CMTime = CMTime(seconds: 0, preferredTimescale: 1000)
    public var subtitleLocale:[String] = []
    public var subtitleDisplayNameList:[String] = []
    public var subaudioLocale:[String] = []
    public var subaudioDisplayNameList:[String] = []
    public var naturalSizeList:[CGSize] = []
    public var manifestParser:ManifestParser?
    //MARK: - Struct
    public struct playerTimeRange {
        public var start:Double?
        public var end:Double?
        public var duration:Double?
    }
    
    //MARK: - static properties
    //playerItme
    public static let ReadyToPlay = Notification.Name("ReadyToPlay")
    public static let LoadFaild = Notification.Name("LoadFaild")
    public static let LoadTimedout = Notification.Name("LoadTimedout")
    public static let DidPlayToEndTime = Notification.Name("DidPlayToEndTime")
    public static let TimeJumped = Notification.Name("TimeJumped")
    public static let PlaybackStalled = Notification.Name("PlaybackStalled")
    public static let FailedToPlayToEndTime = Notification.Name("FailedToPlayToEndTime")
    public static let PlayBackBufferFull = Notification.Name("PlayBackBufferFull")
    public static let PreSeek = Notification.Name("PreSeek")
    public static let DidSeek = Notification.Name("DidSeek")
    public static let DidPresentationSizeChange = Notification.Name("DidPresentationSizeChange")
    public static let DidStartVideo = Notification.Name("DidstartVideo")
    public static let DidStopVideo = Notification.Name("DidStopVideo")
    public static let DidChangePresentationSize = Notification.Name("DidChangePresentationSize")
    
    //enum
    public enum mediaMode:String{
        case live = "live"
        case dvr = "dvr"
        case vod = "vod"
    }
    
    //MARK: - private properties
    private let mainQueue = OperationQueue.main
    private let timeoutSec = 30.0
    private let toleranceBefore = CMTime(seconds:0.001,preferredTimescale: 1)
    private let toleranceAfter = CMTime(seconds:0.001,preferredTimescale: 1)
    private var waitPlayingTimer:Timer!
    private var _isSeeking:Bool! = false
    private var visibility:Bool! = true
    
    private var isPlaybackBufferEmptyObserver: NSKeyValueObservation?
    private var isPlaybackBufferFullObserver: NSKeyValueObservation?
    private var isPlaybackLikelyToKeepUpObserver: NSKeyValueObservation?
    private var loadedTimeRangesObserver:NSKeyValueObservation?
    private var presentationSizeObserver:NSKeyValueObservation?
    
    private var observers:[Any] = []
    // MARK: - OverrideMethod
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    //字幕初期化
    //字幕を検索するためlocaleをキーとして保存
    public func initSubtitle(){
        if let asset = self.player?.currentItem?.asset {
            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                for option in group.options{
                    if let identifier = option.locale?.identifier{
                        subtitleLocale.append(identifier)
                        subtitleDisplayNameList.append(option.displayName)
                    }
                }
                print("caption:" + subtitleLocale.joined(separator: ","))
            }
        }
    }
    //多重音声初期化
    //音声を検索するためlocaleをキーとして保存
    public func initSubAudio(){
        if let asset = self.player?.currentItem?.asset {
            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                for option in group.options{
                    print(option.displayName)
                    if let identifier = option.locale?.identifier{
                        subaudioLocale.append(identifier)
                        let dictionary:NSDictionary = option.value(forKey: "dictionary") as! NSDictionary
                        let name = dictionary.value(forKey:"MediaSelectionOptionsName") as! String
                        subaudioDisplayNameList.append(name)
                    }
                }
                let str = "audio:" + subaudioLocale.joined(separator: ",")
                print(str)
            }
        }
    }
    // MARK: - Observer Set Method
    public func setObserver(name:NSNotification.Name,completion:@escaping (Notification) -> Void){
        observers.append(NotificationCenter.default.addObserver(forName: name, object: self.player?.currentItem,queue: mainQueue, using: completion))
    }
    public func startPlayerItemObserve(){
        observers.append(NotificationCenter.default.addObserver(
        forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem,queue: mainQueue){
            using in NotificationCenter.default.post(name: JstPlayerSDK.DidPlayToEndTime, object: self)
            print(JstPlayerSDK.DidPlayToEndTime)
        })
        observers.append(NotificationCenter.default.addObserver(
        forName: Notification.Name.AVPlayerItemTimeJumped, object: self.player?.currentItem,queue: mainQueue){
            using in NotificationCenter.default.post(name: JstPlayerSDK.TimeJumped, object: self)
        })
        observers.append(NotificationCenter.default.addObserver(
        forName: Notification.Name.AVPlayerItemPlaybackStalled, object: self.player?.currentItem,queue: mainQueue){
            using in NotificationCenter.default.post(name: JstPlayerSDK.PlaybackStalled, object: self)
        })
        observers.append(NotificationCenter.default.addObserver(
        forName: Notification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.player?.currentItem,queue: mainQueue){
            using in NotificationCenter.default.post(name: JstPlayerSDK.FailedToPlayToEndTime, object: self)
        })
    }
    private var durationObserver: NSKeyValueObservation?
    public func postLoadObserve(playerItem: AVPlayerItem) {
        isPlaybackBufferEmptyObserver = playerItem.observe(\.isPlaybackBufferEmpty){
            (item:AVPlayerItem,value:NSKeyValueObservedChange<Bool>) -> Void in
            if let isStall = self.player?.currentItem?.isPlaybackBufferEmpty{
                if(isStall){
                    self.postStall(cause:"BufferEmpty")
                }
            }
        }
        isPlaybackBufferFullObserver = playerItem.observe(\.isPlaybackBufferFull){
            (item:AVPlayerItem,value:NSKeyValueObservedChange<Bool>) -> Void in
            if let result = self.player?.currentItem?.isPlaybackBufferFull{
                if(result){
                    NotificationCenter.default.post(name: JstPlayerSDK.PlayBackBufferFull, object: self)
                }
            }
        }
        isPlaybackLikelyToKeepUpObserver = playerItem.observe(\.isPlaybackLikelyToKeepUp){
            (item:AVPlayerItem,value:NSKeyValueObservedChange<Bool>) -> Void in
            if let isStall = self.player?.currentItem?.isPlaybackLikelyToKeepUp{
                if(!isStall){
                    self.postStall(cause:"PlaybackLikelyToKeepUp")
                }
            }
        }
        presentationSizeObserver = player?.currentItem?.observe(\.presentationSize){
            (item:AVPlayerItem,value:NSKeyValueObservedChange<CGSize>) -> Void in
            NotificationCenter.default.post(name: JstPlayerSDK.DidPresentationSizeChange, object: self)
        }
    }
    private func postStall(cause:String){
        NotificationCenter.default.post(name: JstPlayerSDK.FailedToPlayToEndTime, object: self)
    }
    private func postNotification(name:Notification.Name){
        NotificationCenter.default.post(name: name, object: self)
    }
    
    @objc private func checkPlayable(){
        if(!(player?.currentItem?.isPlaybackLikelyToKeepUp ?? false) || player?.currentItem?.isPlaybackBufferEmpty ?? false){
            print("noBuffer")
            
        }else{
            waitPlayingTimer.invalidate()
            self.player!.play()
        }
    }
    //initPlayerで初期化すした場合のPlayerItem読み込み後の処理
    private func didLoadItem(result:MediaLoader.Result){
        switch result {
        case .success(let player):
            self.player = player
            self.playbackObserve()
            self.postLoadObserve(playerItem: (player.currentItem)!)
            self.startPlayerItemObserve()
            self.initSubtitle()
            self.initSubAudio()
            if(self.subtitleLocale.count > 0){
                self.setSubtitle(identifier: "")
            }
            if(self.autoPlay){
                self.play()
            }
        case .failed:
            NotificationCenter.default.post(name:JstPlayerSDK.LoadFaild,object:self)
        case .timedOut:
            NotificationCenter.default.post(name:JstPlayerSDK.LoadTimedout,object:self)
        }
    }
    public func playbackObserve(){
        player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.old, context: nil)
        player!.addObserver(self, forKeyPath: "error", options: NSKeyValueObservingOptions.old, context: nil)
        player!.currentItem!.addObserver(self, forKeyPath: "presentationSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if player == nil {
            return
        }
        if keyPath == "rate" {
            if player!.rate > 0 {
                print("video started")
                NotificationCenter.default.post(name: JstPlayerSDK.DidStartVideo, object: self)
            }else{
                print("video stoped")
                NotificationCenter.default.post(name: JstPlayerSDK.DidStopVideo, object: self)
            }
        }
        if keyPath == "presentationSize"{
            NotificationCenter.default.post(name:JstPlayerSDK.DidChangePresentationSize,object:self)
        }
        if keyPath == "error" {
            NotificationCenter.default.post(name: JstPlayerSDK.DidStopVideo, object: self)
        }
    }
    // MARK: - Public Set Method
    public func play(){
        self.player!.play()
    }
    public func pause(){
        self.player!.pause()
    }
    public func seek(time:Double){
        let cmtime = CMTime(seconds: time, preferredTimescale: 1000)
        print(String(format:"preseek:%f to:%f",(self.player?.currentItem?.currentTime().seconds)!,cmtime.seconds))
        self._isSeeking = true
        self.postNotification(name:JstPlayerSDK.PreSeek)
        self.player?.currentItem?.seek(to:cmtime,toleranceBefore: self.toleranceBefore,toleranceAfter: self.toleranceAfter,completionHandler: { (isFinished:Bool) -> Void in
            self._isSeeking = false
            self.postNotification(name:JstPlayerSDK.DidSeek)
        })
    }
    public func seekAndPause(time:Double){
        let cmtime = CMTime(seconds: time, preferredTimescale: 1000)
        print(String(format:"preseek:%f to:%f",(self.player?.currentItem?.currentTime().seconds)!,cmtime.seconds))
        self._isSeeking = true
        self.postNotification(name:JstPlayerSDK.PreSeek)
        self.player?.currentItem?.seek(to:cmtime,toleranceBefore: self.toleranceBefore,toleranceAfter: self.toleranceAfter,completionHandler: { (isFinished:Bool) -> Void in
            self.pause()
            self._isSeeking = false
            self.postNotification(name:JstPlayerSDK.DidSeek)
        })
    }
    public func seekAndPlay(time:Double){
        let cmtime = CMTime(seconds: time, preferredTimescale: 1000)
        print(String(format:"preseek:%f to:%f",(self.player?.currentItem?.currentTime().seconds)!,cmtime.seconds))
        self._isSeeking = true
        self.postNotification(name:JstPlayerSDK.PreSeek)
        self.player?.currentItem?.seek(to:cmtime,toleranceBefore: self.toleranceBefore,toleranceAfter: self.toleranceAfter,completionHandler: { (isFinished:Bool) -> Void in
            self.play()
            self._isSeeking = false
            self.postNotification(name:JstPlayerSDK.DidSeek)
        })
    }
    public func seek(time:Double,completion:((Bool)->Void)?){
        let cmtime = CMTime(seconds: time, preferredTimescale: 1000)
        print(String(format:"preseek:%f to:%f",(self.player?.currentItem?.currentTime().seconds)!,cmtime.seconds))
        self._isSeeking = true
        self.postNotification(name:JstPlayerSDK.PreSeek)
        self.player?.currentItem?.seek(to:cmtime,toleranceBefore: self.toleranceBefore,toleranceAfter: self.toleranceAfter,completionHandler: { (isFinished:Bool) -> Void in
            self._isSeeking = false
            self.postNotification(name:JstPlayerSDK.DidSeek)
            if(completion != nil){
                completion!(isFinished)
            }
        })
    }
    public func seek(time:Double,toleranceBefore:CMTime,toleranceAfter:CMTime,completion:((Bool)->Void)?){
        let cmtime = CMTime(seconds: time, preferredTimescale: 1000)
        print(String(format:"preseek:%f to:%f",(self.player?.currentItem?.currentTime().seconds)!,cmtime.seconds))
        self._isSeeking = true
        self.postNotification(name:JstPlayerSDK.PreSeek)
        self.player?.currentItem?.seek(to:cmtime,toleranceBefore: toleranceBefore,toleranceAfter: toleranceAfter,completionHandler: { (isFinished:Bool) -> Void in
            self._isSeeking = false
            self.postNotification(name:JstPlayerSDK.DidSeek)
            if(completion != nil){
                completion!(isFinished)
            }
        })
    }
    public func forwardTo(time:Double){
        let currentTime:Double! = self.player?.currentItem?.currentTime().seconds
        self.seek(time: currentTime + time)
    }
    public func backwardTo(time:Double){
        let currentTime:Double! = self.player?.currentItem?.currentTime().seconds
        self.seek(time: currentTime - time)
    }
    // auto setting player
    
    /// プレイヤー生成
    /// - Parameters:
    ///   - url: url
    ///   - startPosition: 再生開始位置
    ///   - autoPlay: 自動再生するか
    ///   - mediaMode: live,dvr,vod
    ///   - title: title
    public func initPlayer(url:String,startPosition:Double,autoPlay:Bool,mediaMode:String,title:String){
        self.startPosition = CMTime(seconds: startPosition, preferredTimescale: 1000)
        self.autoPlay = autoPlay
        self.mediaMode = mediaMode
        self.title = title
        let playerURL:URL! = URL(string:url)
        manifestParser = ManifestParser(url: playerURL)
        loadItem(url:playerURL,preferredForwardBufferDuration:10,completion:didLoadItem)
        self.player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        setVideoFillMode(mode: AVLayerVideoGravity.resizeAspect.rawValue)
    }
    public func setVisiblity(visibility:Bool){
        self.isHidden = visibility
    }
    public func setSubtitle(identifier:String){
        if self.subtitleLocale.contains(identifier){
            if let asset = self.player?.currentItem?.asset {
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                    let locale = Locale(identifier: identifier)
                    let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                    if let option = options.first {
                        self.player?.currentItem?.select(option, in: group)
                    }
                }
            }
        }else{
            if let asset = self.player?.currentItem?.asset {
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                    self.player?.currentItem?.select(nil, in: group)
                }
            }
        }
    }
    public func setSubAudio(identifier:String){
        if self.subaudioLocale.contains(identifier){
            if let asset = self.player?.currentItem?.asset {
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                    let locale = Locale(identifier: identifier)
                    let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                    if let option = options.first {
                        self.player?.currentItem?.select(option, in: group)
                    }
                }
            }
        }else{
            if let asset = self.player?.currentItem?.asset {
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                    self.player?.currentItem?.select(nil, in: group)
                }
            }
        }
    }
    /// アスペクト比を維持
    ///
    /// - Parameter mode: AVLayerVideoGravity
    public func setVideoFillMode(mode: String) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.videoGravity = AVLayerVideoGravity(rawValue: mode)
    }
    public func loadItem(url:URL,preferredForwardBufferDuration:Double = 60 ,completion:@escaping (MediaLoader.Result) -> Void) {
        let loader = MediaLoader(url,timeoutInterval:timeoutSec,preferredForwardBufferDuration:preferredForwardBufferDuration)
        loader.load(completion: completion)
        
    }
    public func loadItem(url:URL,preferredForwardBufferDuration:Double = 60,success:@escaping (AVPlayer) -> Void,faild:@escaping () -> Void,timeout:@escaping () -> Void) {
        
        let loader = MediaLoader(url,timeoutInterval:timeoutSec,preferredForwardBufferDuration:preferredForwardBufferDuration)
        loader.load() { result in
            switch result {
            case .success(let player):
                print("SUCCESS")
                self.playbackObserve()
                self.postLoadObserve(playerItem:player.currentItem!)
                success(player)
            case .failed:
                print("FAILED")
                faild()
            case .timedOut:
                print("TIMED OUT")
                timeout()
            }
        }
    }
    public func stopPlayer(){
        if(self.player != nil && self.isPlaying){
            self.pause()
        }
        self.disposePlayer()
    }
    public func disposePlayer(){
        for observer in self.observers{
            NotificationCenter.default.removeObserver(observer)
        }
        self.player = nil
    }
    // MARK: - Public Get Method
    public func getCurrentTime() -> Double{
        if let currentTime = self.player?.currentTime(){
            return currentTime.seconds
        }
        return CMTimeMake(value: 0, timescale: 1).seconds
    }
    public func getDuration() -> Double{
        if let duration = self.player?.currentItem?.asset.duration{
            if duration.seconds.isNaN{
                let ranges = self.getSeekableTimeRangesAll()
                var sktr = self.getSeekableTimeRanges()
                if ranges.count > 1 {
                    sktr = ranges
                }
                let end = sktr.last?.end ?? 0
                let start = sktr.last?.start ?? 0
                return end - start
            }
            return duration.seconds
        }
        return CMTimeMake(value: 0, timescale: 1).seconds
    }
    public func getLoadedTimeRanges() -> [playerTimeRange]{
        var returnValue:[playerTimeRange]=[]
        if let playerItem = self.player?.currentItem{
            if(playerItem.loadedTimeRanges.count > 0){
                let timeRange:CMTimeRange =  playerItem.loadedTimeRanges[0] as! CMTimeRange
                let start = timeRange.start.seconds
                let duration = timeRange.duration.seconds
                let end = timeRange.end.seconds
                let value = playerTimeRange(start:start,end:end,duration: duration)
                returnValue.append(value)
            }
        }
        return returnValue
    }
    public func getSeekableTimeRanges() -> [playerTimeRange]{
        var returnValue:[playerTimeRange]=[]
        if let playerItem = self.player?.currentItem{
            if(playerItem.seekableTimeRanges.count > 0){
                let timeRange:CMTimeRange =  playerItem.seekableTimeRanges[0] as! CMTimeRange
                let start = timeRange.start.seconds
                let duration = timeRange.duration.seconds
                let end = timeRange.end.seconds
                let value = playerTimeRange(start:start,end:end,duration: duration)
                returnValue.append(value)
            }
        }
        return returnValue
    }
    public func getSeekableTimeRangesAll() -> [playerTimeRange]{
        var returnValue:[playerTimeRange]=[]
        if let playerItem = self.player?.currentItem{
            if(playerItem.seekableTimeRanges.count > 0){
                for range in playerItem.seekableTimeRanges{
                    let timeRange:CMTimeRange =  range as! CMTimeRange
                    let start = timeRange.start.seconds
                    let duration = timeRange.duration.seconds
                    let end = timeRange.end.seconds
                    let value = playerTimeRange(start:start,end:end,duration: duration)
                    returnValue.append(value)
                }
            }
        }
        return returnValue
    }
    public func getPlaybackRate() -> Float?{
        return self.player?.rate
    }
    public func getWidth() -> CGFloat{
        return self.presentationSize?.width ?? 0
    }
    public func getHeight() -> CGFloat{
        return self.presentationSize?.height ?? 0
    }
    public func getViewHeight() -> CGFloat{
        return self.frame.size.height
    }
    public func getViewWidth() -> CGFloat{
        return self.frame.size.width
    }
    public func isSeeking() -> Bool{
        return _isSeeking
    }
    public func getProgramDateTime() -> Int64{
        let currentTime = self.player?.currentItem?.currentDate()
        //GMT
        return Int64((currentTime?.timeIntervalSince1970 ?? 0) * 1000)
    }
}
