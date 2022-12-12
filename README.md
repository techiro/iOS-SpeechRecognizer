
# iOS-SpeechRecognizer

# Use Framework

- SFSpeechRecognizer
- Microsoft Translator
- AVFoundation

# SFSpeechRecognizer

音声入力には、SFSpeechRecognizerを使用

## SFSpeechRecognizerの特徴
音声入力ライブラリで
- リアルタイム音声
- 録音済み音声
に対応


## ユーザの許可（info.plist)
- NSMicrophoneUsageDescription（マイクの用途について）
- NSSpeechRecognitionUsageDescription（音声認識の用途について）


## マイク利用(AVAudioEngine)

## SFSpeechRecognizerの生成
## リクエストの作成
マイク等のオーディオバッファを利用する場合は、SFSpeechAudioBufferRecognitionRequestを使用します。



リクエストの開始とデータ取得




## textView

UITextViewを配置（認識された音声をテキスト表示: textView）
背景・テキストカラー・フォントサイズを変更
インスペクタエリアから*isUserInteractionプロパティ*を無効にする


## recognitionRequest
録音完了前に途中の結果を報告してくれる（デフォルトはfalse）
```swift
recognitionRequest.shouldReportPartialResults = true

speechRecognizer.delegate = self

 recognitionRequest?.endAudio()
 
```

### デリゲート処理
ViewControllerクラスにデリゲートを採用する
speechRecognizerの状態変化を受け取れるようになる
`SFSpeechRecognitionTaskDelegate`

```swift

// MARK: SFSpeechRecognizerDelegate
//speechRecognizerが使用可能かどうかでボタンのisEnabledを変更する
public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
        recordButton.isEnabled = true
        recordButton.setTitle("Start Recording", for: [])
        
    } else {
        recordButton.isEnabled = false
        recordButton.setTitle("Recognition not available", for: .disabled)
    }
}
```

## オーディオセッションの設定

アプリでオーディオをどのように使用するかをシステムに伝えるオブジェクト。

let audioSession = AVAudioSession.sharedInstance()
try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
try audioSession.setActive(true, options: .notifyOthersOnDeactivation)


## 端末のマイクを使う準備
let inputNode = audioEngine.inputNode


##RecordButtonの実装

```swift

@IBAction func recordButtonTapped() {
    if audioEngine.isRunning {
    // 音声エンジン動作中なら停止
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recordButton.isEnabled = false
        recordButton.setTitle("Stopping", for: .disabled)
        recordButton.backgroundColor = UIColor.lightGray
        return
    }
    // 録音を開始する
    try! startRecording()
    recordButton.setTitle("認識を完了する", for: [])
    recordButton.backgroundColor = UIColor.red
}

```


```swift

private func speak(message: String) {
       defer {
           disableAVSession()
       }
       do {
           try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
           try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
       } catch {
           print("audioSession properties weren't set because of an error.")
       }
       let utterance = AVSpeechUtterance(string: message)
       utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
       utterance.pitchMultiplier = 1
       self.speechSynthesizer.speak(utterance)
   }
   
   private func disableAVSession() {
       do {
           try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
       } catch {
           print("audioSession properties weren't disable.")
       }
   }

```


```swift

private func requestRecognizerAuthorization() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        // メインスレッドで処理したい内容のため、OperationQueue.main.addOperationを使う
        OperationQueue.main.addOperation { [weak self] in
            guard let `self` = self else { return }
            switch authStatus {
            case .authorized:
                self.textView.text = "音声認識へのアクセスが許可されています。"
            case .denied:
                self.textView.text = "音声認識へのアクセスが拒否されています。"
            case .restricted:
                self.textView.text = "音声認識へのアクセスが制限されています。"
            case .notDetermined:
                self.textView.text = "音声認識はまだ許可されていません。"
            }
        }
    }
}

```


# 参考文献

https://swiswiswift.com/2017-05-13/

https://terakoya.site/ios_dic/ios-dic-voice-recog/

https://swift-ios.keicode.com/ios/speechrecognition-live.php

https://github.com/furuya02/SpeechRecognizerSample/blob/master/SpeechRecognizerSample/ViewController.swift
