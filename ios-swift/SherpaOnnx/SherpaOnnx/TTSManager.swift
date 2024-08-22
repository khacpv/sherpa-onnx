//
//  TTSManager.swift
//  SherpaOnnx
//
//  Created by pham khac on 21/8/24.
//

import Foundation
import AVFoundation

class TTSManager {
    var initEngine = false
    
    var ttsWrapper: SherpaOnnxOfflineTtsWrapper?
    //    var audioPlayer: AVAudioPlayer?
    var audioSession: AVAudioSession?
    
    // 2: create the audio player
    var audioPlayer: AVAudioPlayerNode? = nil
    
    var engine: AVAudioEngine? = nil
    var speedControl: AVAudioUnitVarispeed? = nil
    var pitchControl:  AVAudioUnitTimePitch? = nil
    
    init() {
        setupAudio()
        setupTTS()
    }
    
    func setupTTS() {
        print("Setup TTS")
        ttsWrapper = getTtsForVCTK()
        print("TTS init successfully.")
    }
    
    func setModel(model: SherpaOnnxOfflineTtsWrapper){
        ttsWrapper = model
    }
    
    func setupAudio(){
        print("Setup Audio")
        audioPlayer = AVAudioPlayerNode()
        
        engine = AVAudioEngine()
        speedControl = AVAudioUnitVarispeed()
        pitchControl = AVAudioUnitTimePitch()
        
        engine!.attach(audioPlayer!)
        engine!.attach(pitchControl!)
        engine!.attach(speedControl!)
        
        
        // 4: arrange the parts so that output from one is input to another
        engine?.connect(audioPlayer!, to: speedControl!, format: nil)
        engine!.connect(speedControl!, to: pitchControl!, format: nil)
        engine!.connect(pitchControl!, to: engine!.mainMixerNode, format: nil)
        
        
    }
    
    func synthesizeSpeech(text: String, sid: Int, speed: Float, pitch: Float, pitchRate: Float, speedRate: Float) -> URL? {
        guard let ttsWrapper = ttsWrapper else {
            print("TTS wrapper not initialized")
            return nil
        }
        
        // Synthesize speech from the text
        let audio = ttsWrapper.generate(text: text, sid: sid, speed: Float(speed))
        
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let filename = tempDirectoryURL.appendingPathComponent("tts_\(sid)_\(text).wav")
        print(filename)
        
        let result = audio.save(filename: filename.path)
        print("save result \(result)")
        
        do {
            // Audio session
            if(audioSession == nil){
                try audioSession = AVAudioSession.sharedInstance()
            }
            try audioSession!.setCategory(.playAndRecord, mode: .default)
            try audioSession!.overrideOutputAudioPort(.speaker)
            try audioSession!.setActive(true)
            
            //            // Initialize the AVAudioPlayer with the file URL
            //            audioPlayer = try AVAudioPlayer(contentsOf: filename)
            //            audioPlayer!.volume = 1.0
            //            audioPlayer!.prepareToPlay()
            //            audioPlayer!.play()
            
            
            let file = try AVAudioFile(forReading: filename)
            
            // 3: connect the components to our playback engine
            pitchControl!.pitch = pitch
            pitchControl!.rate = pitchRate
            speedControl!.rate = speedRate
            audioPlayer!.volume = 1.0
            
            // 5: prepare the player to play its file from the beginning
            audioPlayer!.scheduleFile(file, at: nil)
            
            // 6: start the engine and player
            try engine!.start()
            audioPlayer!.play()
            print("Played \(filename)")
        } catch let error {
            print("Error playing audio: \(error.localizedDescription)")
        }
        
        return filename
    }
}
