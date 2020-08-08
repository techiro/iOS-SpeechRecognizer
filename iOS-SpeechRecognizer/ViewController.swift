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
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        audioEngine = AVAudioEngine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SFSpeechRecognizer.requestAuthorization { (status) in
            if status != .authorized{
                self.recordButton.isEnabled = false
                self.recordButton.setTitle("Can't record", for: .normal)
            }
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        
    }
    
}

