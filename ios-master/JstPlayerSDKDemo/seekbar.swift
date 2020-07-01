//
//  seekbar.swift
//  jstPlayerSDK_Example
//
//  Created by Jストリーム 株式会社　開発 on 2020/01/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import jstPlayerSDK


final class JstSeekBar:UISlider{
    public var currentTime:Double? {
           get {
            return playerSDK?.getCurrentTime()
           }
           set(newValue) {
            playerSDK?.seek(time: newValue!)
           }
       }
    public var playerSDK:JstPlayerSDK?
    public var slider:UISlider?
    public var seekableRanges:[JstPlayerSDK.playerTimeRange] = []
    public var isSeeking = false
    public var toleranceBefore = CMTime(seconds: 0.0001, preferredTimescale: 1)
    public var toleranceAfter = CMTime(seconds:0.0001,preferredTimescale: 1)
    //MARK: - initalize
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(self.onSliderTouchDown), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(self.onSliderTouchUp), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(self.onSliderTouchUp), for: UIControl.Event.touchUpOutside)
        
        //loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //loadNib()
    }
//    func loadNib(){
//        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UISlider {
//            view.frame = self.bounds
//            self.addSubview(view)
//        }
//    }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true // どんなtouchでもスライダー調節を行う
    }
    @objc func currentTimeTimerUpdate(){
        updateSliderPosition(currentTime: self.playerSDK?.getCurrentTime() ?? 0)
    }
    @objc func onSliderChangeValue(sender:JstSeekBar){
        print(sender)
    }
    
    @objc func onSliderTouchUp(sender:JstSeekBar){
        let value = sender.value
        let setTime = Double(value) * (self.playerSDK?.getDuration() ?? 0)
        print(String(format:"value:%f time:%f duration:%f",value,setTime,self.playerSDK?.getDuration() ?? 0))
        self.playerSDK?.seek(time: setTime,toleranceBefore: self.toleranceBefore,toleranceAfter: self.toleranceAfter,completion:handler)
    }
    private func handler(isFinished:Bool){
        self.isSeeking = false
        print(String(format:"seeked:%f", self.playerSDK?.getCurrentTime() ?? 0))
    }
    
    @objc func onSliderTouchDown(sender:JstSeekBar){
        print(sender)
        isSeeking = true
    }
    //MARK: - PUBLIC METHOD
    public func updateSliderPosition(currentTime:Double){
        if(isSeeking){
            return
        }
        var position:Double = 0
        let duration:Double = self.playerSDK?.getDuration() ?? 0
        if(duration != 0){
            position = currentTime / duration
        }
        self.value = Float(position)
    }
    public func startUpdateSeekbarWithPlayer(player:JstPlayerSDK){
        self.playerSDK = player
        Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.currentTimeTimerUpdate), userInfo: nil, repeats: true)
    }
    //MARK: - PUBLIC SET METHOD
    //MARK: - PUBLIC GET METHOD
    //MARK: - PRIVATE METHOD
    private func checkSeekable(time:Double) -> Bool{
        if(seekableRanges.count > 0) {
            for range in seekableRanges {
                let start = range.start ?? -1
                let end = range.end ?? -1
                if(start == -1 || end == -1){
                    return true
                }
                if(start <= time && end >= time){
                    return true
                }
            }
            return false
        }else{
            return true
        }
    }
}
