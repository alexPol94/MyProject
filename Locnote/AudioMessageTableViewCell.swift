//
//  AudioMessageTableViewCell.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 25.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class AudioMessageTableViewCell: UITableViewCell, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    enum TypeOfAudioSession {
        case player
        case recorder
    }
    
    // MARK: - Outlets
    @IBOutlet weak var playOrRecordButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var timeCounter: UILabel!
    
    
    // MARK: - Properties
    var audioSession : AVAudioSession!
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    var typeOfCellAudio: TypeOfAudioSession!
    
    var startSoundID: SystemSoundID = 1113
    var endSoundID: SystemSoundID = 1114
    
    let fileName = "/audioFile.m4a"
    
    let minRecordTime: Double = 1.00
    var currentTimeForRecorder: TimeInterval = 0.0
    
    var playerIsPlaying: Bool = false
    
    var timerThread: Thread?
    
    var saveRecordDataComplition: ((Data?) -> Void)?
    var dataForPlayer: (() -> Data)?
    var addNewRow: (() -> Void)?
    
    
    // MARK: - Button Actions
    @IBAction func buttonTouchDown(_ sender: UIButton) {
        self.progressBar.progress = 0
        switch self.typeOfCellAudio! {
        case .recorder:
            self.playStartSystemSound(with: { 
                self.startRecorder()
            })
        default:
            print("buttonTouchDown")
        }
    }
    
    @IBAction func buttonTouchUp(_ sender: UIButton) {
        switch self.typeOfCellAudio! {
        case .player:
            if self.soundPlayer != nil && self.soundPlayer.isPlaying {
                self.stopPlayer()
            }
            else {
                self.startPlayer()
            }
        case .recorder:
            self.stopRecorder()
        }
    }
    
    
    // MARK: - Recorder Start/Stop
    private func startRecorder() {
        self.setupAudioSession(with: AVAudioSessionCategoryRecord)
        
        self.timerThread = Thread.init(target: self, selector: #selector(timerForRecorder), object: nil)
        
        self.soundRecorder.record()
        self.timerThread!.start()
    }
    
    @objc private func stopRecorder() {
        if self.soundRecorder.isRecording {
            self.currentTimeForRecorder = soundRecorder.currentTime
            self.soundRecorder.stop()
            self.timerThread!.cancel()
        }
    }
    
    // MARK: - Player Start/Stop
    private func startPlayer() {
        self.timeCounter.text = "00:00"
        self.setupAudioPlayer()
        self.timerThread = Thread.init(target: self, selector: #selector(timerForPlayer), object: nil)
        
        self.soundPlayer.play()
        self.timerThread!.start()
        self.setButtonImage()
    }
    
    private func stopPlayer() {
        if self.soundPlayer.isPlaying {
            self.timerThread!.cancel()
            self.soundPlayer.stop()
            self.progressBar.progress = 1.00
            self.timeCounter.text = self.stringFor(timeInterval: self.soundPlayer.duration)
            let image = UIImage.init(named: "play")
            self.playOrRecordButton.setBackgroundImage(image, for: .normal)
        }
    }
    
    
    // MARK: - AVAudio Delegates
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.progressBar.progress = 1.00
        if self.currentTimeForRecorder > self.minRecordTime {
            self.performSelector(inBackground: #selector(self.playEndSystemSound(with:)), with: nil)
            self.changeTypeOfCellAudio()
            self.timeCounter.text = self.stringFor(timeInterval: self.currentTimeForRecorder)
            self.performSelector(inBackground: #selector(self.saveData), with: nil)
        }
        else {
            self.timeCounter.text = "00:00"
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let image = UIImage.init(named: "play")
        self.playOrRecordButton.setBackgroundImage(image, for: .normal)
        self.progressBar.progress = 1.00
    }
    
    
    // MARK: - AVAudio Setup
    func setupAudioSession(with category: String) {
        self.audioSession = AVAudioSession.sharedInstance()
        try! self.audioSession.setCategory(category)
        try! self.audioSession.setActive(true)
    }
    
    func setupAudioRecorder(){
        let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0 ] as [String : Any]
        
        soundRecorder = try! AVAudioRecorder(url: getFileURL(), settings: recordSettings)
        soundRecorder.delegate = self
        soundRecorder.prepareToRecord()
    }
    
    func setupAudioPlayer(){
        self.setupAudioSession(with: AVAudioSessionCategoryPlayback)
        let data: Data = self.dataForPlayer!()
        if !data.isEmpty {
            self.soundPlayer = try! AVAudioPlayer(data: data)
            self.soundPlayer.delegate = self
            self.soundPlayer.prepareToPlay()
            self.soundPlayer.volume = 1.0
        }
    }
    
    
    // MARK: - Timer Methods
    @objc private func timerForRecorder() {
        var time = Int(self.soundRecorder.currentTime)
        
        while self.soundRecorder.isRecording {
            if Thread.current.isCancelled || !self.playOrRecordButton.isTouchInside{
                self.performSelector(onMainThread: #selector(self.stopRecorder), with: nil, waitUntilDone: false)
                return
            }
            self.performSelector(onMainThread: #selector(self.updateProgressBar), with: nil, waitUntilDone: false)
            
            if time != Int(self.soundRecorder.currentTime) {
                time = Int(self.soundRecorder.currentTime)
                self.performSelector(onMainThread: #selector(self.updateTime), with: nil, waitUntilDone: false)
            }
            
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    @objc private func timerForPlayer() {
        var time = Int(self.soundPlayer.currentTime)
        while self.soundPlayer.isPlaying {
            if Thread.current.isCancelled {
                return
            }
            
            self.performSelector(onMainThread: #selector(self.updateProgressBar), with: nil, waitUntilDone: false)
            if time != Int(self.soundPlayer.currentTime) {
                time = Int(self.soundPlayer.currentTime)
                
                self.performSelector(onMainThread: #selector(self.updateTime), with: nil, waitUntilDone: false)
            }
            
            Thread.sleep(forTimeInterval: 0.05)
        }
    }
    
    
    // MARK: - Update UI
    @objc private func updateTime() {
        
        var timeInterval: TimeInterval! = nil
        
        if self.soundPlayer != nil && self.soundPlayer.isPlaying {
            timeInterval = self.soundPlayer.currentTime
        }
        else if self.soundRecorder != nil && self.soundRecorder.isRecording {
            timeInterval = self.soundRecorder.currentTime
        }
        else {
            return
        }
        
        self.timeCounter.text = self.stringFor(timeInterval: timeInterval)
    }
    
    
    func updateProgressBar() {
        let timeInterval: TimeInterval!
        if self.soundPlayer != nil && self.soundPlayer.isPlaying {
            timeInterval = self.soundPlayer.currentTime
            self.progressBar.progress = Float(timeInterval / self.soundPlayer.duration)
        }
        else if self.soundRecorder != nil && self.soundRecorder.isRecording {
            timeInterval = self.soundRecorder.currentTime
            self.progressBar.progress = Float(timeInterval / (60 * 3))
        }
    }
    
    // MARK: - Start/Stop System Sounds
    @objc private func playStartSystemSound(with complition: (() -> Void)?) {
        self.setupAudioSession(with: AVAudioSessionCategoryPlayback)
        AudioServicesPlaySystemSoundWithCompletion(self.startSoundID, complition)
    }
    
    @objc private func playEndSystemSound(with complition: (() -> Void)?) {
        self.setupAudioSession(with: AVAudioSessionCategoryPlayback)
        AudioServicesPlaySystemSoundWithCompletion(self.endSoundID, complition)
    }
    
    // MARK: - Get File Path Methods
    private func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        return paths[0]
        
    }
    
    private func getFileURL() -> URL{
        let path  = self.getCacheDirectory().appending(fileName)
        let filePath = URL(fileURLWithPath: path)
        return filePath
    }
    
    
    // MARK: - Other Methods
    func stringFor(timeInterval: TimeInterval) -> String {
        let min = Int(timeInterval / 60)
        let sec = Int(timeInterval) % 60
        let x = (min < 10) ? "0" : ""
        let y = (sec < 10) ? "0" : ""
        let string = "\(x)\(min):\(y)\(sec)"
        return string
    }
    
    func setButtonImage() {
        let image: UIImage!
        
        if self.typeOfCellAudio == nil {
            return
        }
        
        switch self.typeOfCellAudio! {
        case .player:
            if self.soundPlayer != nil && self.soundPlayer.isPlaying {
                image = UIImage.init(named: "stop")
            }
            else {
                image = UIImage.init(named: "play")
            }
        case .recorder:
            image = UIImage.init(named: "record")
        }
        self.playOrRecordButton.setBackgroundImage(image, for: .normal)
    }
    
    func changeTypeOfCellAudio() {
        switch self.typeOfCellAudio! {
        case .player:
            self.typeOfCellAudio = .recorder
        case .recorder:
            self.typeOfCellAudio = .player
        }
        self.setButtonImage()
    }

    func addRow() {
        self.addNewRow!()
    }
    
    @objc private func saveData() {
        let data = try! Data(contentsOf: getFileURL())
        if !data.isEmpty {
            self.saveRecordDataComplition!(data)
            self.performSelector(onMainThread: #selector(self.addRow), with: nil, waitUntilDone: false)
        }
    }
}
