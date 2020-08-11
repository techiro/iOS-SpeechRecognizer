//
//  ViewController.swift
//  iOS-SpeechRecognizer
//
//  Created by TanakaHirokazu on 2020/08/06.
//  Copyright © 2020 TanakaHirokazu. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecord = false
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        audioEngine = AVAudioEngine()
        recognizer.delegate = self
        setAudioSession()
        textView.text = ""
    }
    
    /*Description：関数の説明
    Parameters：引数の説明
    Returns：戻り値の説明
 */
    
    override func viewDidAppear(_ animated: Bool) {
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            if status != .authorized{
                self.recordButton.isEnabled = false
                self.recordButton.setTitle("Can't record", for: .normal)
            }
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        if isRecord {
            stopRecognition()
            isRecord = false
        } else {
            try! startRecognition()
            isRecord = true
        }
    }
    
        

    func startRecognition() throws {
        
        refreshTask()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        guard let inputNode = audioEngine?.inputNode else { fatalError("Audio engine has no input node") }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self else {
                return
            }
            
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                self.textView.text = result.bestTranscription.formattedString
            }

            if error != nil || isFinal {
                //エラーかisFinalフラグが立つと終了ストップ
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recordButton.setTitle("スタート", for: .normal)
            }
    }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
        }

        try startAudioEngine()
    }
    
    private func setAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            fatalError("Unable to set audioSession")
        }
        
        }
    
    /// audioEngine.stop()
    /// inputNode.removeTap(onBus: 0)
    ///recognitionRequest?.endAudio()
    ///recordButton.setTitle("Start", for: .normal)
    private func stopRecognition() {
      audioEngine.stop()
      audioEngine.inputNode.removeTap(onBus: 0)
      recognitionRequest?.endAudio()
      recordButton.setTitle("Start", for: .normal)
    }
    
    private func refreshTask() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    
    private func startAudioEngine() throws {
        audioEngine.prepare()
        try audioEngine.start()
        recordButton.setTitle("Stop", for: .normal)
    }
}


extension ViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            recordButton.isEnabled = true
            print("recognizer is available")
        }else {
            isRecord = false
            recordButton.isEnabled = false
            print("recognizer is not available")
        }
    }


}
