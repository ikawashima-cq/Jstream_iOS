//
//  ManifestParser.swift
//  jstPlayerSDK
//
//  Created by 開発部のMacBookPro on 2020/06/05.
//


public class ManifestParser{
    public var variants:[Variant] = []
    public var path:URL?
    init(url:URL){
        let request = URLRequest(url: url)
        self.path = url.deletingLastPathComponent()
        print("\(self.path!)")
        let session = URLSession.shared
        session.dataTask(with: request){(data,response,error) in
            if error == nil ,let data = data,let response = response as? HTTPURLResponse{
                //print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                //print("statusCode: \(response.statusCode)")
                let stringData:String = String(data: data, encoding: String.Encoding.utf8) ?? ""
                print(stringData)
                self.parse(data: stringData)
            }
        }.resume()
    }
    private func parse(data:String){
        var streamInfoList = data.components(separatedBy: "#EXT-X-STREAM-INF:")
        streamInfoList.removeFirst()
        for info in streamInfoList {
            var lines = [String]()
            info.enumerateLines { (line, stop) -> () in
                lines.append(line)
            }
            let variant = Variant()
            variant.url = lines[1]
            if !variant.url.contains("://") {
                if let url = self.path?.appendingPathComponent(variant.url){
                    variant.url = url.absoluteString
                }
            }
            variant.bandwidth = Int(patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "^BANDWIDTH=([0-9]+)", options: []))) ?? 0
            variant.averageBandwidth = Int(patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "AVERAGE-BANDWIDTH=([0-9]+)", options: []))) ?? 0
            variant.frameRate = Float(patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "FRAME-RATE=([0-9]+.[0-9]+)", options: []))) ?? 0.0
            variant.codec["video"] = (patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "CODECS=\"([^=]+),[^=]+\",", options: [])))
            variant.codec["audio"] = (patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "CODECS=\"[^=]+,([^=]+)\",", options: [])))
            variant.size["height"] = Int(patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "RESOLUTION=[0-9]{1,4}x([0-9]{1,4})", options: []))) ?? 0
            variant.size["width"] = Int(patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "RESOLUTION=([0-9]{1,4})x[0-9]{1,4}", options: []))) ?? 0
            variant.subtitles = (patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "SUBTITLES=\"([^=]+)\"", options: [])))
            variant.captions = (patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "CLOSED-CAPTIONS=\"[^=]+\"", options: [])))
            variant.video = (patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "VIDEO=\"([^=]+)\"", options: [])))
            variant.audio = (patternMatcher(input: lines[0], regex: try! NSRegularExpression(pattern: "AUDIO=\"([^=]+)\"", options: [])))
            variants.append(variant)
        }
        
    }
    private func patternMatcher(input:String,regex:NSRegularExpression) -> String {
        if let result = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.count)){
            return (input as NSString).substring(with: result.range(at:1)) as String
        }
        return ""
    }
    
}
public class Variant{
    public var url:String
    public var bandwidth:Int
    public var averageBandwidth:Int
    public var codec:Dictionary = ["video":"","audio":""]
    public var size:Dictionary = ["height":0,"width":0]
    public var frameRate:Float
    public var subtitles:String
    public var captions:String
    public var audio:String
    public var video:String
    public var hdcplevel:String
    init(){
        url = ""
        bandwidth = 0
        averageBandwidth = 0
        frameRate = 0.0
        subtitles = ""
        captions = ""
        audio = ""
        video = ""
        hdcplevel = ""
    }
}
