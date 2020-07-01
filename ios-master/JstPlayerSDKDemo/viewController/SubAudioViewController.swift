//
//  PlayerDemoViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/06.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit
import jstPlayerSDK
class SubAudioButton:UIButton {
    var stringValue:String?
}
class SubAudioViewController: UIViewController {
   
    @IBOutlet var BaseView: UIView!
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var RewindButton: UIButton!
    @IBOutlet weak var FastfowordButton: UIButton!
    @IBOutlet weak var SubAudioStackView: UIStackView!
    
    
    private let slider = JstSeekBar()
    private let timecounter = UILabel()
    private var videoView:JstPlayerSDK!
    private var touchLocation:CGPoint?
    private var isTouchStarted:Bool = false
    private var index = 0
    private var isControllerVisible:Bool = true
    private var scrollTo:String = "none"
    private var timer:Timer!
    var videoViewX:CGFloat = 0
    var translationX:CGFloat = 0
    var animationFlag:Bool = false
    var top:CGFloat!
    // MARK: - 定数
    let remoteFileUrl: [String] = ["https://s3-ap-northeast-1.amazonaws.com/test.mediaconvert.out/tears_of_steel_video/master.m3u8",
                                   "https://s3-ap-northeast-1.amazonaws.com/test.mediaconvert.out/tears_of_steel_video/master.m3u8",
                                   "https://s3-ap-northeast-1.amazonaws.com/test.mediaconvert.out/tears_of_steel_video/master.m3u8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        videoView.stopPlayer()
    }
    func initView(){
        initPlayerView()
        setPlayerEents(playerSDK: videoView)
    }
    func initPlayerView(){
        
        let boundSize: CGSize = PlayerView.bounds.size
        
        videoView = JstPlayerSDK()
        videoView.frame = CGRect(x: 0, y: 0, width: boundSize.width, height: boundSize.height)
        PlayerView.insertSubview(videoView, at: 0)
        //self.videoView.initPlayer(url: remoteFileUrl[index], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.live.rawValue, title: "hoge")
    
        if let playURL = URL(string: remoteFileUrl[index]){ self.videoView.loadItem(url:playURL,preferredForwardBufferDuration:10,completion:playerLoad)
        }
        PlayButton.setImage(UIImage(named: "stop_center"), for: UIControl.State.normal)
        timecounter.frame = CGRect(x: boundSize.width-200, y: boundSize.height-50, width:180, height: 50)
        timecounter.text = "NaN:NaN"
        timecounter.textColor = UIColor.white
        let layer = timecounter.layer
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        //PlayerView.addSubview(timecounter)
        slider.frame = CGRect(x: 0, y: boundSize.height-50, width: boundSize.width-200, height: 50)
        //PlayerView.addSubview(slider)
        slider.startUpdateSeekbarWithPlayer(player:self.videoView)
        fadeOut()
        timer = Timer.scheduledTimer(timeInterval: 1/15, target: self, selector: #selector(self.getPlayerTime), userInfo: nil, repeats: true)
        print(UIScreen.main.bounds)
        print(self.BaseView.safeAreaInsets)
        print(PlayerView.frame)
        print(videoView.frame)
    }
    
    func setSubtitles(){
        let subtitleList:[String] = videoView.subtitleLocale
        if(subtitleList.count > 0){
            let stackViewHeight:CGFloat = CGFloat((subtitleList.count+1) * 50)
            self.SubAudioStackView.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
            let offButton = SubtitleButton()
            offButton.setTitle("off",for: .normal)
            offButton.stringValue = ""
            offButton.addTarget(self, action: #selector(self.changeSubtitle), for: .touchUpInside)
            offButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            self.SubAudioStackView.addArrangedSubview(offButton)
            for subtitle in subtitleList{
                
                let button = SubtitleButton()
                button.setTitle(subtitle, for: .normal)
                button.stringValue = subtitle
                button.addTarget(self, action: #selector(self.changeSubtitle), for: .touchUpInside)
                button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
                self.SubAudioStackView.addArrangedSubview(button)
            }
        }
    }
    func setSubAudio(){
        let subaudioList:[String] = videoView.subaudioLocale
        if(subaudioList.count > 0){
            let stackViewHeight:CGFloat = CGFloat((subaudioList.count+1) * 50)
            self.SubAudioStackView.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
            let offButton = SubAudioButton()
            offButton.setTitle("off",for: .normal)
            offButton.stringValue = ""
            offButton.addTarget(self, action: #selector(self.changeSubAudio), for: .touchUpInside)
            offButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            self.SubAudioStackView.addArrangedSubview(offButton)
            for subAudio in subaudioList{
                
                let button = SubAudioButton()
                button.setTitle(subAudio, for: .normal)
                button.stringValue = subAudio
                button.addTarget(self, action: #selector(self.changeSubAudio), for: .touchUpInside)
                button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
                self.SubAudioStackView.addArrangedSubview(button)
            }
        }
    }
    func playerLoad(result: MediaLoader.Result){
        switch result {
            case .success(let player):
                print("SUCCESS")
                self.videoView.player = player
                self.videoView.playbackObserve()
                self.videoView.postLoadObserve(playerItem:player.currentItem!)
                self.videoView.initSubtitle()
                self.videoView.initSubAudio()
                self.setSubtitles()
                self.setSubAudio()
                self.videoView.play()
            case .failed:
                print("FAILED")
            case .timedOut:
                print("TIMED OUT")
       }
    }
    @objc func changeSubtitle(_ sender:SubtitleButton){
        self.videoView.setSubtitle(identifier: sender.stringValue ?? "")
    }
    @objc func changeSubAudio(_ sender:SubtitleButton){
        self.videoView.setSubAudio(identifier: sender.stringValue ?? "")
    }
    @objc func getPlayerTime(){
        let playerSDK:JstPlayerSDK = self.videoView
        var current:Double! = playerSDK.getCurrentTime()
        let duration:Double! = playerSDK.getDuration()
        var minus = ""
        if current.isNaN || duration.isNaN{
            return
        }
        
        current = duration-current
        if(current < 0){
            minus = "-"
        }
        let text = String(format:"%@%@ / %@",minus,formatTime(time: current),formatTime(time: duration))
        timecounter.text = text
    }
    func formatTime(time:Double) -> String{
        let intTime = Int(time)
        let hour = intTime / (60*60)
        let minit = (intTime % (60*60)) / 60
        let second = (intTime % 60)
        let value = String(format:"%@:%@:%@",formatTimeSeg(segment: hour),formatTimeSeg(segment: minit),formatTimeSeg(segment: second))
        return value
    }
    func formatTimeSeg(segment:Int) -> String{
        var value=""
        if(segment < 10){
            if(segment < 0){
                if(segment > -10){
                    value = String(format:"0%d",segment * -1)
                }else{
                    value = String(format:"%d",segment * -1)
                }
                
            }else{
                value = String(format:"0%d",segment)
            }
        }else{
            value = String(segment)
        }
        return value
    }
    func setPlayerEents(playerSDK:JstPlayerSDK){
        PlayButton.addTarget(self, action:#selector(ClickPlayButton(_:)), for: .touchUpInside)
        RewindButton.addTarget(self, action: #selector(ClickRewindButton(_:)), for: .touchUpInside)
        FastfowordButton.addTarget(self, action: #selector(ClickFastfowordButton(_:)), for: .touchUpInside)
    }
    
    func changePlayback(playerSDK:JstPlayerSDK){
        if(playerSDK.isPlaying){
            playerSDK.pause()
            self.PlayButton.alpha = 1.00
            self.RewindButton.alpha = 1.00
            self.FastfowordButton.alpha = 1.00
            self.slider.alpha = 1.00
        }else{
            playerSDK.play()
            fadeOut()
        }
        changePlayButton(playbutton: self.PlayButton,isPlaying: playerSDK.isPlaying)
    }
    func changePlayButton(playbutton:UIButton,isPlaying:Bool){
        if(isPlaying){
            playbutton.setImage(UIImage(named: "stop_center"), for: UIControl.State.normal)
        }else{
            playbutton.setImage(UIImage(named: "play_center"), for: UIControl.State.normal)
        }
    }
    func fadeOut(){
        self.PlayButton.layer.removeAllAnimations()
        self.RewindButton.layer.removeAllAnimations()
        self.FastfowordButton.layer.removeAllAnimations()
        self.slider.layer.removeAllAnimations()
        self.timecounter.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 3.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.PlayButton.alpha = 0.05
            self.RewindButton.alpha = 0.05
            self.FastfowordButton.alpha = 0.05
            self.slider.alpha = 0.05
            self.timecounter.alpha = 0.05
        }) { (completed) in
            self.PlayButton.alpha = 0.00
            self.RewindButton.alpha = 0.00
            self.FastfowordButton.alpha = 0.00
            self.slider.alpha = 0.00
            self.timecounter.alpha = 0.00
            self.isControllerVisible = false
        }
    }
    func fadeIn(){
        self.PlayButton.layer.removeAllAnimations()
        self.RewindButton.layer.removeAllAnimations()
        self.FastfowordButton.layer.removeAllAnimations()
        self.slider.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 0.2, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.PlayButton.alpha = 1.00
            self.RewindButton.alpha = 1.00
            self.FastfowordButton.alpha = 1.00
            self.slider.alpha = 1.00
            self.timecounter.alpha = 1.00
        }) { (completed) in
            self.PlayButton.alpha = 1.00
            self.RewindButton.alpha = 1.00
            self.FastfowordButton.alpha = 1.00
            self.slider.alpha = 1.00
            self.timecounter.alpha = 1.00
            self.isControllerVisible = true
            self.fadeOut()
        }
    }
    func changeTitle(goto:String){
        var offset:CGFloat = 0
        if(goto == "next"){
            index += 1
            if(remoteFileUrl.count <= index){
                index = remoteFileUrl.count - 1
                return
            }
            offset = PlayerView.bounds.size.width - 300
            
        }else if(goto == "prev"){
            index -= 1
            if(index < 0){
                index = 0
                return
            }
            offset = -300
        }
        PlayerView.frame = CGRect(x: offset, y: self.BaseView.safeAreaInsets.top, width: PlayerView.bounds.size.width, height: PlayerView.bounds.size.height)
        self.videoView.stopPlayer()
        changeURL(index: index)
    }
    func changeURL(index:Int){
        self.videoView.initPlayer(url: remoteFileUrl[index], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.vod.rawValue, title: "hoge")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view = touch.view else { return }
        
        if view != self {
            if(view == self.PlayerView || view == self.videoView){
                if(isControllerVisible){
                    self.fadeOut()
                }else{
                    self.fadeIn()
                }
                touchLocation = touch.location(in: BaseView)
                isTouchStarted = true
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!isTouchStarted){
            return
        }
        guard let touch = touches.first, let view = touch.view else { return }
        
        if view != self {
            if(view == self.PlayerView || view == self.videoView){
                let location = touch.location(in: BaseView)
                let locationDiff = (touchLocation?.x ?? 0) - location.x
                PlayerView.transform = CGAffineTransform(translationX: -locationDiff, y: 0)
                
                if(scrollTo == "next"){
                    if(locationDiff <= 300){
                        scrollTo = ""
                        changeTitle(goto:"prev")
                    }
                }else if(scrollTo == "prev"){
                    if(locationDiff >= -300){
                        scrollTo = ""
                        changeTitle(goto:"next")
                    }
                }else{
                    if(locationDiff > 300 || -300 > locationDiff){
                        if(locationDiff > 0){
                            scrollTo = "next"
                            changeTitle(goto:scrollTo)
                        }else{
                            scrollTo = "prev"
                            changeTitle(goto:scrollTo)
                        }
                    }
                }
                if(locationDiff > view.safeAreaInsets.left || -locationDiff > view.safeAreaInsets.left){
                    animationFlag = true
                }else{
                    animationFlag = false
                }
                
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view = touch.view else { return }
        
        if view != self {
            touchLocation = nil
            if(view == self.PlayerView || view == self.videoView){
                
                touchLocation = nil
                if(animationFlag){
                    UIView.animate(withDuration: 0.2, animations: {
                        self.PlayerView.frame =  CGRect(x: self.BaseView.safeAreaInsets.left, y: self.BaseView.safeAreaInsets.top, width: self.PlayerView.bounds.size.width, height: self.PlayerView.bounds.size.height)
                    }){(completion) in
                        self.PlayerView.transform = CGAffineTransform(translationX: 0, y: 0)
                        self.PlayerView.frame =  CGRect(x: self.BaseView.safeAreaInsets.left, y: self.BaseView.safeAreaInsets.top, width: self.PlayerView.bounds.size.width, height: self.PlayerView.bounds.size.height)
                    }
                }else{
                    self.PlayerView.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.PlayerView.frame =  CGRect(x: self.PlayerView
                        .safeAreaInsets.left, y: self.BaseView.safeAreaInsets.top, width: self.BaseView.bounds.size.width, height: self.PlayerView.bounds.size.height)
                }
                animationFlag = false
                
                isTouchStarted = false
                scrollTo = ""
            }
        }
    }
    //MARK: - @objc func
    @objc func ClickPlayButton(_ sneder:UIButton){
        changePlayback(playerSDK: videoView)
    }
    @objc func ClickFastfowordButton(_ sender:UIButton){
        videoView.forwardTo(time:10.00)
    }
    @objc func ClickRewindButton(_ sender:UIButton){
        videoView.backwardTo(time: 10.00)
    }
}
