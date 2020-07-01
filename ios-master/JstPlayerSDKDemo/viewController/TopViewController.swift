//
//  ViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/06.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
    let baseURL = "http://nakano-global-2.jst-lab.com/caption/servlet/"
    let baseURLOption = "&originm3u8=https%3A%2F%2Fscp-test.webcdn.stream.ne.jp%2Fwww11%2Fscp-test%2Fssai_alternative_audio05%2Fmaster_plain.m3u8&duration=735.0&self_delivery=true&webvtt_jpn=https%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Ftest.mediaconvert.out%2FTOS-JP.vtt&webvtt_eng=https%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Ftest.mediaconvert.out%2FTOS-en.vtt&webvtt_chi=https%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Ftest.mediaconvert.out%2FTOS-CH-traditional.vtt&audio_ja=https%3A%2F%2Fscp-test.webcdn.stream.ne.jp%2Fwww11%2Fscp-test%2Fssai_alternative_audio05%2Faudio_jp%2Ftears_of_steel_1080p_high.m3u8&audio_en=https%3A%2F%2Fscp-test.webcdn.stream.ne.jp%2Fwww11%2Fscp-test%2Fssai_alternative_audio05%2Faudio_en%2Ftears_of_steel_1080p_high.m3u8"
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var ServerStatusLabel: UILabel!
    @IBOutlet weak var ChannelTextField: UITextField!
    
    @IBOutlet weak var PlayerButton: UIButton!
    @IBOutlet weak var AdPlayerButton: UIButton!
    @IBOutlet weak var OtherTestButton: UIButton!
    
    enum serverstatus:String{
        case starting = "starting..."
        case runnning = "runnning"
        case stopping = "stopping..."
        case stop = "stop"
        case error = "error"
    }
    var channelId = "7432459"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let channelId = UserDefaults.standard.object(forKey: "channelId") as? String{
            self.channelId = channelId
        }else{
            let randomInt = Int.random(in: 1..<10000000)
            self.channelId = String(randomInt)
        }
        self.ChannelTextField.text = self.channelId
        self.StartButton.isEnabled = false
        self.StopButton.isEnabled = false
        self.PlayerButton.isEnabled = false
        self.AdPlayerButton.isEnabled = false
        self.OtherTestButton.isEnabled = false
        self.ServerStatusLabel.text = serverstatus.starting.rawValue
        dvrStop()
        stopStream(prepare: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        dvrStop()
//        stopStream()
    }
    func getStreamURL(){
        self.ServerStatusLabel.text = serverstatus.starting.rawValue
        if let textfield = self.ChannelTextField.text{
            self.channelId = textfield
            UserDefaults.standard.set(self.channelId,forKey: "channelId")
            let requestURL = baseURL + "caption" + "?channel_id=" + channelId + baseURLOption
            print(requestURL)
            if let url = URL(string: requestURL){
                let request = URLRequest(url: url)
                let session = URLSession.shared
                session.dataTask(with: request){(data,response,error) in
                    if error == nil ,let data = data,let response = response as? HTTPURLResponse{
                        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                        print("statusCode: \(response.statusCode)")
                        let stringData:String = String(data: data, encoding: String.Encoding.utf8) ?? ""
                        print(stringData)
                        do{
                            try self.parse(json: stringData)
                        }
                        catch{
                            print("JSON_ERROR")
                        }
                        self.dvrStart()
                    }
                }.resume()
            }
        }
    }
    func stopStream(prepare:Bool){
        let requestURL = baseURL + "stop" + "?channel_id=" + channelId
        print(requestURL)
        if let url = URL(string: requestURL){
            let request = URLRequest(url: url)
            let session = URLSession.shared
            session.dataTask(with: request){(data,response,error) in
                if error == nil ,let data = data,let response = response as? HTTPURLResponse{
                    print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                    print("statusCode: \(response.statusCode)")
                    let stringData:String = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    print(stringData)
                    if prepare{
                        DispatchQueue.main.async {
                            self.getStreamURL()
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.ServerStatusLabel.text = serverstatus.stop.rawValue
                            self.StartButton.isEnabled = true
                            self.StopButton.isEnabled = false
                            self.PlayerButton.isEnabled = false
                            self.AdPlayerButton.isEnabled = false
                            self.OtherTestButton.isEnabled = false
                        }
                    }
                }
            }.resume()
        }
    }
    func dvrStart(){
        let requestURL = baseURL + "dvr" + "?channel_id=" + channelId + "&action=start"
        print(requestURL)
        if let url = URL(string: requestURL){
            let request = URLRequest(url: url)
            let session = URLSession.shared
            session.dataTask(with: request){(data,response,error) in
                if error == nil ,let data = data,let response = response as? HTTPURLResponse{
                    print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                    print("statusCode: \(response.statusCode)")
                    let stringData:String = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    print(stringData)
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    self.StartButton.isEnabled = false
                    self.StopButton.isEnabled = true
                    self.PlayerButton.isEnabled = true
                    self.AdPlayerButton.isEnabled = true
                    self.OtherTestButton.isEnabled = true
                    self.ServerStatusLabel.text = serverstatus.runnning.rawValue
                }
                
            }.resume()
        }
    }
    func dvrStop(){
        let requestURL = baseURL + "dvr" + "?channel_id=" + channelId + "&action=stop"
        print(requestURL)
        if let url = URL(string: requestURL){
            let request = URLRequest(url: url)
            let session = URLSession.shared
            session.dataTask(with: request){(data,response,error) in
                if error == nil ,let data = data,let response = response as? HTTPURLResponse{
                    print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                    print("statusCode: \(response.statusCode)")
                    let stringData:String = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    print(stringData)
                    
                }
            }.resume()
        }
    }
    struct ParseError: Error {}
    func parse(json: String) throws {
        guard let data = json.data(using: .utf8) else {
             throw ParseError()
         }
        let json = try JSONSerialization.jsonObject(with: data)
        guard let rows = json as? NSDictionary else {
            throw ParseError()
        }
        let liveUrl = rows.value(forKey: "url") as? String ?? ""
            UserDefaults.standard.set(liveUrl,forKey: "liveUrl")
        let ssai_csr_url = rows.value(forKey: "ssai_csr_url") as? String ?? ""
            UserDefaults.standard.set(ssai_csr_url,forKey: "ssaiCsrUrl")
        let ssai_url = rows.value(forKey: "ssai_url") as? String ?? ""
            UserDefaults.standard.set(ssai_url,forKey: "ssaiUrl")
    }
    @IBAction func didClickStartButton(_ sender: Any) {
        dvrStop()
        stopStream(prepare: true)
    }
    
    @IBAction func didClickStopButton(_ sender: Any) {
        self.ServerStatusLabel.text = serverstatus.stopping.rawValue
        dvrStop()
        stopStream(prepare: false)
    }
    
}

