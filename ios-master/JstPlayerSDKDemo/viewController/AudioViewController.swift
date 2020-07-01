//
//  Audio.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/06/23.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
class AudioViewCotroller:UIViewController{
    var inited:Bool = false
    var remoteFileUrl: [String] = ["http://nakano-global-2.jst-lab.com/caption/servlet/master/7432459/master.m3u8",
                                   "https://5b180bc34c6e0.streamlock.net/player_sdk_test/Stream1/playlist.m3u8?DVR",
                                   "https://eqd114dmqf.eq.webcdn.stream.ne.jp/www50/eqd114dmqf/jmc_pub/jmc_pd/00005/3de025097f204317ae9c2b27d82582b6.m3u8"]
    
    var player:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        if !inited{
            if let url = UserDefaults.standard.object(forKey: "liveUrl") as? String{
                remoteFileUrl[0] = url
                remoteFileUrl[1] = url
            }
            initView()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopPlayer()
    }
    func initView(){
        if let url = URL(string: remoteFileUrl[2]){
            //self.player = AVPlayer(url: url)
            //playerPlayTest()
            audioEngineTest()
        }
    }
    func playerPlayTest(){
        if let player = self.player{
            let controller = AVPlayerViewController()
            controller.player = self.player
            present(controller,animated: true){
                player.play()
            }
        }
    }
    func audioEngineTest(){
        //let engin = AVAudioEngine()
        //var audioFile:AVAudioFile!
        var address:String = "http://nakano-global-2.jst-lab.com/caption/servlet/master/8364794/master.m3u8"
        //var address:String = "http://eqa918zteg.eq.webcdn.stream.ne.jp/www50/eqa918zteg/jmc_pub/jmc_mp4/jmc_fms/00001/17dbc198c72c4856a57cd0f70298fdd8_2.mp4"
        
        //        var buffer:AVAudioPCMBuffer!
        //
        //        var frame:Int?
        //        var channel:Int?
        //        var samplingRate:Double?
        if let url = URL(string: address){
            let asset = AVAsset(url: url)
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            let controller = AVPlayerViewController()
            controller.player = self.player

            debugPrint(self.player?.currentItem?.asset)
            debugPrint(self.player?.currentItem?.asset.tracks(withMediaType: AVMediaType.audio))
            debugPrint(self.player?.currentItem?.tracks)
            
                if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                    print(group)
                    print(group.options)
                    for option in group.options{
                        print(option.displayName)
                        print(option)
                    }
                }
//            present(controller,animated: true){
//                self.player?.play()
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
//                //audioTrack = asset.tracksWithMediaType(AVMediaTypeAudio)[0]
//                let audioTracks = asset.tracks(withMediaType: AVMediaType.video)
//
//                if audioTracks.count < 1{
//                    print("error")
//                    return
//                }
//                let audioTrack = audioTracks[0]
//                var assetReader:AVAssetReader!
//                do{
//                    assetReader = try AVAssetReader(asset: asset)
//                }catch{
//
//                }
//                let outputSetting = [AVFormatIDKey:Int(kAudioFormatLinearPCM),
//                                     AVLinearPCMBitDepthKey:16,AVLinearPCMIsBigEndianKey:false,
//                                     AVLinearPCMIsFloatKey:false,
//                                     AVLinearPCMIsNonInterleaved:false] as [String : Any]
//                let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSetting)
//                assetReader.add(output)
//            }
        }
        
    }
    func getVolume(from buffer: AVAudioPCMBuffer, bufferSize: Int) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else {
            return 0
        }
        
        let channelDataArray = Array(UnsafeBufferPointer(start:channelData, count: bufferSize))
        
        var outEnvelope = [Float]()
        var envelopeState:Float = 0
        let envConstantAtk:Float = 0.16
        let envConstantDec:Float = 0.003
        
        for sample in channelDataArray {
            let rectified = abs(sample)
            
            if envelopeState < rectified {
                envelopeState += envConstantAtk * (rectified - envelopeState)
            } else {
                envelopeState += envConstantDec * (rectified - envelopeState)
            }
            outEnvelope.append(envelopeState)
        }
        
        // 0.007 is the low pass filter to prevent
        // getting the noise entering from the microphone
        if let maxVolume = outEnvelope.max(),
            maxVolume > Float(0.015) {
            return maxVolume
        } else {
            return 0.0
        }
    }
    func stopPlayer(){
        if let player = self.player{
            player.pause()
            self.player = nil
        }
    }
}
