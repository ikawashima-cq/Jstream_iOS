//
//  medialoader.swift
//  jstPlayerSDK_Example
//
//  Created by Jストリーム 株式会社　開発 on 2019/12/20.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import AVFoundation

public  class MediaLoader {
    public enum Result {
        case success(AVPlayer)
        case failed
        case timedOut
    }
    
    public var itemUrl: URL {
        return (self.playerItem.asset as! AVURLAsset).url
    }
    
    private let timeoutInterval: TimeInterval
    private let playerItem: AVPlayerItem
    
    private var player: AVPlayer?
    private var observation: NSKeyValueObservation?
    private var timer: Timer?
    private var peakBitRate:Double! = 1000000000
    private var maximumResolution:CGSize! = CGSize(width: 1920, height: 1080)
    
    private var completion: ((Result) -> Void)?
    
    init(_ url: URL, timeoutInterval: TimeInterval,preferredForwardBufferDuration:Double) {
        let asset = AVAsset(url: url)
        self.playerItem = AVPlayerItem(asset:asset)
        //self.playerItem.preferredPeakBitRate = peakBitRate
        if #available(iOS 11.0, *) {
            self.playerItem.preferredMaximumResolution = maximumResolution
        } else {
            // Fallback on earlier versions
        }
        if(preferredForwardBufferDuration > 0 ){
            if #available(iOS 10.0, *) {
                self.playerItem.preferredForwardBufferDuration = preferredForwardBufferDuration
            } else {
                // Fallback on earlier versions
            }
        }
        self.timeoutInterval = timeoutInterval
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        self.completion = completion
        self.startObservation()
        self.startTimer()
        
        // Start request by initializing instance of `AVPlayer`.
        print("Start loading asset on \(self.itemUrl.absoluteString)")
        self.player = AVPlayer(playerItem: self.playerItem)
        
    }
}

private extension MediaLoader {
    @objc func didTimeout() {
        print("Timed out")
        self.finishLoading(.timedOut)
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: timeoutInterval,
                                          target: self,
                                          selector: #selector(didTimeout),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    func startObservation() {
        guard self.observation == nil else { return }
        
        // `AVPlayer.status` becomes .readyToPlay even when remote file does not exist.
        // To avoid that issue, `AVPlayerLoader` observes `AVPlayerItem.status`.
        self.observation = playerItem.observe(\.status) { item, change in
            switch item.status {
            case .readyToPlay:
                print("Completed")
                self.finishLoading(.success(self.player!))
                
            case .failed:
                print("Failed")
                self.finishLoading(.failed)
                
            case .unknown:
                // Since .unknown is initial value of `AVPlayerItem.status`,
                // this code is never executed.
                break
            @unknown default:
                print("Failed")
            }
        }
    }
    
    func finishLoading(_ result: Result) {
        self.timer?.invalidate()
        self.timer = nil
        self.observation?.invalidate()
        self.observation = nil
        
        self.completion?(result)
    }
}
