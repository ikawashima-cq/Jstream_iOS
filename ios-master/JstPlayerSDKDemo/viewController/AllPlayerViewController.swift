//
//  PlayerDemoViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/06.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit
import jstPlayerSDK

class AllPlayerViewController: UIViewController {
    
    
    @IBOutlet var BaseView: UIView!
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var RewindButton: UIButton!
    @IBOutlet weak var FastfowordButton: UIButton!
    @IBOutlet weak var MenuBaseView: UIView!
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var MenuCloseButton: UIButton!
    @IBOutlet weak var MenuTableView: UITableView!
    @IBOutlet weak var MenuTitleLabel: UILabel!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    private let slider = JstSeekBar()
    private let timecounter = UILabel()
    private var videoView:JstPlayerSDK!
    private var touchLocation:CGPoint?
    private var isTouchStarted:Bool = false
    private var index = 2
    private var isControllerVisible:Bool = true
    private var scrollTo:String = "none"
    private var timer:Timer!
    var videoViewX:CGFloat = 0
    var translationX:CGFloat = 0
    var animationFlag:Bool = false
    var top:CGFloat!
    // MARK: - 定数
    //let remoteFileUrl: [String] = ["https://eqlive-eqd015yfct-live.eq.hls.wselive.stream.ne.jp/eq-live/1/eqlive-eqd015yfct-live/fmsins-00002/stream-00002-high/chunklist.m3u8",
    //"https://5b180bc34c6e0.streamlock.net/player_sdk_test/Stream1/playlist.m3u8?DVR",
    //"https://eqd114dmqf.eq.webcdn.stream.ne.jp/www50/eqd114dmqf/jmc_pub/jmc_pd/00005/3de025097f204317ae9c2b27d82582b6.m3u8"]
    var remoteFileUrl: [String] = ["http://nakano-global-2.jst-lab.com/caption/servlet/master/7432459/master.m3u8",
    "https://5b180bc34c6e0.streamlock.net/player_sdk_test/Stream1/playlist.m3u8?DVR",
    "https://eqd114dmqf.eq.webcdn.stream.ne.jp/www50/eqd114dmqf/jmc_pub/jmc_pd/00005/3de025097f204317ae9c2b27d82582b6.m3u8"]
    
    var menuLabels:[String] = ["画質","字幕","音声","再生速度"]
    var renditionLabels:[String] = []
    var subtitleLabels:[String] = ["なし"]
    var subtitleValues:[String] = ["-1"]
    var subaudioLabels:[String] = []
    var subaudioValues:[String] = []
    var playbackRateLabels:[String] = ["x0.25","x0.5","x0.75","x1.0","x1.25","x1.5","x1.75","x2.0"]
    var variants:[Variant] = []
    var menuIndex:Int = -1
    
    var inited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //initView()
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
        timer.invalidate()
        videoView.stopPlayer()
    }
    func initView(){
        inited = true
        initPlayerView()
        setPlayerEents(playerSDK: videoView)
        self.videoView.setObserver(name:JstPlayerSDK.DidStartVideo, completion: playerObserve(notification:))
        self.videoView.setObserver(name:JstPlayerSDK.DidStopVideo, completion: playerObserve(notification:))
    }
    func initPlayerView(){
        
        let boundSize: CGSize = PlayerView.bounds.size
        videoView = JstPlayerSDK()
        videoView.frame = CGRect(x: 0, y: 0, width: boundSize.width, height: boundSize.height)
        PlayerView.insertSubview(videoView, at: 0)
        self.videoView.initPlayer(url: remoteFileUrl[index], startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.vod.rawValue, title: "hoge")
        PlayButton.setImage(UIImage(named: "stop_center"), for: UIControl.State.normal)
        timecounter.frame = CGRect(x: boundSize.width-200, y: boundSize.height-50, width:180, height: 50)
        timecounter.text = "NaN:NaN"
        timecounter.textColor = UIColor.white
        let layer = timecounter.layer
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        PlayerView.addSubview(timecounter)
        slider.frame = CGRect(x: 0, y: boundSize.height-50, width: boundSize.width-200, height: 50)
        PlayerView.addSubview(slider)
        slider.startUpdateSeekbarWithPlayer(player:self.videoView)
        fadeOut()
        timer = Timer.scheduledTimer(timeInterval: 1/15, target: self, selector: #selector(self.getPlayerTime), userInfo: nil, repeats: true)
        print(UIScreen.main.bounds)
        print(self.BaseView.bounds)
        print(self.BaseView.safeAreaInsets)
        self.BaseView.layoutSubviews()
        print(PlayerView.frame)
        print(videoView.frame)
    }
    func initMenuTableView(){
        self.menuLabels = ["画質","字幕","音声","再生速度"]
        self.renditionLabels = []
        self.subtitleLabels = ["なし"]
        self.subtitleValues = ["-1"]
        self.subaudioLabels = []
        self.subaudioValues = []
        self.playbackRateLabels = ["x0.25","x0.5","x0.75","x1.0","x1.25","x1.5","x1.75","x2.0"]
        self.variants = []
        self.menuIndex = -1
    }
    func setTableView(index:Int){
        menuIndex = index
        switch index {
        case -1:
            break;
        case 0:
            setRenditionList()
        case 1:
            setSubtitles()
        case 2:
            setSubAudio()
        case 3:
            break;
        default:
            break;
        }
        MenuTableView.dataSource = self
        MenuTableView.delegate = self
        MenuTableView.reloadData()
    }
    func setRenditionList(){
        if self.variants.count == 0{
            if let variants = self.videoView.manifestParser?.variants{
                for i in 0 ..< variants.count{
                    self.variants.append(variants[i])
                    let height:Int = variants[i].size["height"] ?? 0
                    let renditionLabel:String = String(height) + "p"
                    renditionLabels.append(renditionLabel)
                }
            }
        }
    }
    func setSubtitles(){
        subtitleLabels = ["なし"]
        subtitleValues = ["-1"]
        
        let subtitleLabelList:[String] = videoView.subtitleDisplayNameList
        let subtitleLocaleList:[String] = videoView.subtitleLocale
        if(subtitleLabelList.count > 0){
            for subtitle in subtitleLabelList{
                self.subtitleLabels.append(subtitle)
            }
            for subtitle in subtitleLocaleList {
                self.subtitleValues.append(subtitle)
            }
        }
        print(self.subtitleLabels)
        MenuTableView.dataSource = self
        MenuTableView.delegate = self
        MenuTableView.reloadData()
    }
    func setSubAudio(){
        subaudioLabels = []
        subaudioValues = []
        let subaudioLabelList:[String] = videoView.subaudioDisplayNameList
        let subaudioValueList:[String] = videoView.subaudioLocale
        if(subaudioLabelList.count > 0){
            for subaudio in subaudioLabelList{
                self.subaudioLabels.append(subaudio)
            }
            for subaudio in subaudioValueList {
                self.subaudioValues.append(subaudio)
            }
        }
    }
    @objc func getPlayerTime(){
        let playerSDK:JstPlayerSDK = self.videoView
        var current:Double! = playerSDK.getCurrentTime()
        let duration:Double! = playerSDK.getDuration()
        var minus = ""
        if current.isNaN || duration.isNaN{
            return
        }
        
        if((duration-current) < 0){
            minus = "-"
            current = duration-current
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
                index = 0
            }
            offset = PlayerView.bounds.size.width - 300
            
        }else if(goto == "prev"){
            index -= 1
            if(index < 0){
                index = remoteFileUrl.count-1
            }
            offset = -300
        }
        PlayerView.frame = CGRect(x: offset, y: self.BaseView.safeAreaInsets.top, width: PlayerView.bounds.size.width, height: PlayerView.bounds.size.height)
        self.videoView.stopPlayer()
        changeURL(index: index)
    }
    func changeURL(index:Int){
        switch index {
        case 0:
            self.PlayButton.isHidden = false
            self.RewindButton.isHidden = true
            self.FastfowordButton.isHidden = true
            self.slider.isHidden = true
            self.timecounter.isHidden = true
            NavigationItem.title = "Live"
        case 1:
            self.PlayButton.isHidden = false
            self.RewindButton.isHidden = false
            self.FastfowordButton.isHidden = false
            self.slider.isHidden = false
            self.timecounter.isHidden = false
            NavigationItem.title = "DVR"
        case 2:
            self.PlayButton.isHidden = false
            self.RewindButton.isHidden = false
            self.FastfowordButton.isHidden = false
            self.slider.isHidden = false
            self.timecounter.isHidden = false
            NavigationItem.title = "VOD"
        default:
            self.PlayButton.isHidden = true
            self.RewindButton.isHidden = true
            self.FastfowordButton.isHidden = true
            self.slider.isHidden = true
            self.timecounter.isHidden = true
        }
        initMenuTableView()
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
    @IBAction func ClickMenuButton(_ sender: Any) {
        if(menuIndex < 0){
            MenuTitleLabel.text = ""
        }else{
            MenuTitleLabel.text = menuLabels[menuIndex]
        }
        setTableView(index: menuIndex)
        self.MenuBaseView.isHidden = false
    }
    @IBAction func ClickMenuCloseButton(_ sender: Any) {
        menuIndex = -1
        self.MenuBaseView.isHidden = true
    }
    func playerObserve(notification:Notification){
        print(notification.name)
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
        print(format.string(from: date) + text as Any)
    }
}
extension AllPlayerViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        switch menuIndex {
        case -1:
            count = menuLabels.count
        case 0:
            count = renditionLabels.count
        case 1:
            count = subtitleLabels.count
        case 2:
            count = subaudioLabels.count
        case 3:
            count = playbackRateLabels.count
        default:
            count = 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var text:String = ""
        switch menuIndex {
        case -1:
            text = menuLabels[indexPath.row]
        case 0:
            text = renditionLabels[indexPath.row]
        case 1:
            text = subtitleLabels[indexPath.row]
        case 2:
            text = subaudioLabels[indexPath.row]
        case 3:
            text = playbackRateLabels[indexPath.row]
        default:
            text = ""
        }
        cell.textLabel?.text = text
        return cell
    }
}
extension AllPlayerViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuIndex {
        case -1:
            setTableView(index: indexPath.row)
        case 0:
            let urlstring = self.variants[indexPath.row].url
            if urlstring.count > 0{
                var startPosition:Double = 0.0
                if(index == 2){
                    startPosition = self.videoView.getCurrentTime()
                }
                self.videoView.initPlayer(url: urlstring, startPosition: startPosition, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.vod.rawValue, title: "hoge")
            }
        case 1:
            self.videoView.setSubtitle(identifier: subtitleValues[indexPath.row])
        case 2:
            self.videoView.setSubAudio(identifier: subaudioValues[indexPath.row])
        case 3:
            var playbackRateText = playbackRateLabels[indexPath.row]
            playbackRateText = String(playbackRateText[ playbackRateText.index(playbackRateText.startIndex, offsetBy: 1)...])
            self.videoView.playbackRate = Float(playbackRateText)
        default: break
            
        }
    }
}
