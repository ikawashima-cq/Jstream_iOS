## GetStarted
### Require
* swift5以上が動作する
* COCOAPODSでのライブラリインストールができる
### Getting
* SDKのソースコードを取得する
### SetUp
* SDKのソースコードを利用するワークスペースに配置する
* ワークスペースのPodfileに以下を追記する
```
  pod 'jstPlayerSDK', :path => './JSTPlayerSDK'
```
* ターミナルでワークスペースに移動し以下のコマンドを実行

```$ pod install```
### CreatePlayer
* jstPlayerSDKをインポートしJstPlayerSDKクラスを親Viewに追加する
```swift
import UIKit
import jstPlayerSDK
//中略
var videoView:JstPlayerSDK = JstPlayerSDK()
parentView.addSubView(videoView)
```
* initPlayerメソッドを利用しプレイヤーを初期化して表示する
```
videoView.initPlayer(url: yourRemoteFileURL, startPosition: 0, autoPlay: true, mediaMode: JstPlayerSDK.mediaMode.vod.rawValue, title: "yourContentTitle")
```