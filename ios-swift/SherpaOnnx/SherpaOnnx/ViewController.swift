//
//  ViewController.swift
//  SherpaOnnx
//
//  Created by fangjun on 2023/1/28.
//

import AVFoundation
import UIKit

extension AudioBuffer {
    func array() -> [Float] {
        return Array(UnsafeBufferPointer(self))
    }
}

extension AVAudioPCMBuffer {
    func array() -> [Float] {
        return self.audioBufferList.pointee.mBuffers.array()
    }
}

struct Model {
    var name: String
    var totalVoices: Int
}

class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UITextView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var ttsTextField: UITextField!
    @IBOutlet weak var sliderSpeed: UISlider!
    @IBOutlet weak var sliderPitch: UISlider!
    @IBOutlet weak var sliderPitchRate: UISlider!
    @IBOutlet weak var sliderSpeedRate: UISlider!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblPitch: UILabel!
    @IBOutlet weak var lblPitchRate: UILabel!
    @IBOutlet weak var lblSpeedRate: UILabel!
    @IBOutlet weak var loadingPrg: UIActivityIndicatorView!
    @IBOutlet weak var voiceIdField: UITextField!
    
    
    var initRecoged = false
    
    var audioEngine: AVAudioEngine? = nil
    var recognizer: SherpaOnnxRecognizer! = nil
    
    var ttsMng: TTSManager! = nil
    
    var sids = [0]
    
    var totalVoice = 109
    
    var selectVoicesPopup: UIAlertController? = nil
    var selectModelsPopup: UIAlertController? = nil
    var selectSampleTextPopup: UIAlertController? = nil
    
    var audioFile: URL? = nil
    
    /// It saves the decoded results so far
    var sentences: [String] = [] {
        didSet {
            updateLabel()
        }
    }
    var lastSentence: String = ""
    let maxSentence: Int = 2000
    var results: String {
        if sentences.isEmpty && lastSentence.isEmpty {
            return ""
        }
        if sentences.isEmpty {
            return "0: \(lastSentence.lowercased())"
        }
        
        let start = max(sentences.count - maxSentence, 0)
        if lastSentence.isEmpty {
            return sentences.enumerated().map { (index, s) in "\(s)" }[start...]
                .joined(separator: "\n")
        } else {
            return sentences.enumerated().map { (index, s) in "\(s)" }[start...]
                .joined(separator: "\n") + "\n\(sentences.count): \(lastSentence)"
        }
    }
    
    func updateLabel() {
        DispatchQueue.main.async {
            self.resultLabel.text = self.results
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.loadingPrg.isHidden = true
        }
        
        updateSliderValue()
        
        //        recordBtn.setTitle("Start Rec", for: .normal)
        //        initRecognizer()
        //        initRecorder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.initTts()
            self.initVoices()
            self.log(message: "Ready!!!!")
        }
    }
    @IBAction func onSampleTextClick(_ sender: Any) {
        // Create a UIAlertController
        if(selectSampleTextPopup == nil){
            let samples: [String] = [
                // EN
                "Hi, Nice to meet you",
                "Oh my gosh! I can’t believe this just happened!",
                "Finally, I achieved my goal! This is amazing!",
                "Why did this happen? This is absolutely unacceptable!",
                "Wow, this dish is incredible! You have to try it right now!",
                "Don’t worry, everything will be okay, trust me.",
                "Hey! What are you thinking? I can’t understand you anymore!",
                "I’ve been waiting for this moment my entire life.",
                "How could you say that? I’m really disappointed.",
                "Yes! We won! This is fantastic!",
                "Please, just give me one more chance; I won’t let you down.",
                // VN
                "Con cáo nâu nhanh nhẹn nhảy qua con chó lười.",
                "Trí tuệ nhân tạo đang thay đổi cách chúng ta sống và làm việc.",
                "Hãy nhớ lưu công việc của bạn thường xuyên để tránh mất dữ liệu.",
                "Ôi trời ơi! Tôi không thể tin được điều này vừa xảy ra!",
                "Cuối cùng thì mình cũng đạt được mục tiêu rồi, thật tuyệt vời!",
                "Tại sao lại như vậy? Chuyện này không thể chấp nhận được!",
                "Wow, món ăn này ngon quá đi! Bạn phải thử ngay!",
                "Đừng lo lắng, mọi chuyện sẽ ổn thôi, tin tôi đi.",
                "Này! Bạn đang nghĩ gì vậy? Tôi không hiểu nổi bạn nữa!",
                "Tôi đã chờ đợi giây phút này suốt cả cuộc đời.",
                "Sao bạn có thể nói như vậy? Tôi thật sự rất thất vọng.",
                "Yeah, chúng ta đã thắng rồi! Tuyệt vời quá!",
                "Làm ơn, hãy cho tôi một cơ hội nữa, tôi sẽ không làm bạn thất vọng.",
                // JP
                "「えっ、まさか！こんなことが起きるなんて信じられない！」",
                "ついに目標達成した！本当に嬉しい！",
                "どうしてこうなったの？これは絶対に許せない！",
                "わあ、この料理すごく美味しい！今すぐ食べてみて！",
                "心配しないで、大丈夫だよ。私を信じて。",
                "ねえ！何を考えてるの？もうあなたのことが理解できない！",
                "この瞬間をずっと待っていたんだ。",
                "どうしてそんなこと言えるの？本当にがっかりした。",
                "やった！私たちが勝った！最高だね！",
                "お願い、もう一度チャンスをください。絶対にがっかりさせないから。"
            ]
            
            selectSampleTextPopup = UIAlertController(title: "Select Sample text", message: nil, preferredStyle: .actionSheet)
            
            // Add an action for each item in the array
            for item in samples {
                let action = UIAlertAction(title: "\(item)", style: .default) { _ in
                    self.ttsTextField.text = item
                }
                selectSampleTextPopup!.addAction(action)
            }
            
            // Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            selectSampleTextPopup!.addAction(cancelAction)
        }
        
        present(selectSampleTextPopup!, animated: true, completion: nil)
    }
    @IBAction func onHideKeyboardBtnClick(_ sender: Any) {
        self.ttsTextField.resignFirstResponder()
        self.voiceIdField.resignFirstResponder()
        self.resultLabel.resignFirstResponder()
    }
    
    @IBAction func onSliderValueChanged(_ sender: UISlider!) {
        updateSliderValue()
    }
    
    @IBAction func onLoadTTSModelClick(_ sender: Any) {
        log(message: "Loading Models.")
        log(message: "Load models list: https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/index.html")
        
        // Create a UIAlertController
        if(selectModelsPopup == nil){
            let models: [Model] = [
                Model(name: "vits-vctk (109 voice)", totalVoices: 109),
                Model(name: "vits-piper-en_US-libritts-medium (904)", totalVoices: 904),
                Model(name: "vits-piper-en_US-libritts-high (904)", totalVoices: 904),
                Model(name: "vits-mimic3-vi_VN-vais1000_low (1)", totalVoices: 1),
                Model(name: "vits-piper-vi_VN-vivos-x_low (65)", totalVoices: 65),
                Model(name: "vits-coqui-es-css10 (1)", totalVoices: 1),
            ]
            
            selectModelsPopup = UIAlertController(title: "Select TTS model", message: nil, preferredStyle: .actionSheet)
            
            // Add an action for each item in the array
            for item in models {
                let action = UIAlertAction(title: "\(item.name)", style: .default) { _ in
                    self.log(message: "Load Model: \(item.name)")
                    if(item.name == "vits-vctk (109 voice)"){
                        self.ttsMng.setModel(model: getTtsForVCTK())
                        self.totalVoice = item.totalVoices
                    }else if(item.name == "vits-piper-en_US-libritts-medium (904)"){
                        self.ttsMng.setModel(model: getTtsForVitPiper())
                        self.totalVoice = item.totalVoices
                    }else if(item.name == "vits-piper-en_US-libritts-high (904)"){
                        self.ttsMng.setModel(model: getTtsForVitPiperHigh())
                        self.totalVoice = item.totalVoices
                    }else if(item.name == "vits-mimic3-vi_VN-vais1000_low (1)"){
                        self.ttsMng.setModel(model: getTtsForMimic3VN())
                        self.totalVoice = item.totalVoices
                    }else if(item.name == "vits-piper-vi_VN-vivos-x_low (65)"){
                        self.ttsMng.setModel(model: getTtsForVitPiperVN())
                        self.totalVoice = item.totalVoices
                    }else if(item.name == "vits-coqui-es-css10 (1)"){
                        self.ttsMng.setModel(model: getTtsForVitCoqui())
                        self.totalVoice = item.totalVoices
                    }
                }
                selectModelsPopup!.addAction(action)
            }
            
            // Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            selectModelsPopup!.addAction(cancelAction)
        }
        
        present(selectModelsPopup!, animated: true, completion: nil)
    }
    
    
    @IBAction func onRecordBtnClick(_ sender: UIButton) {
        //        if recordBtn.currentTitle == "Start Rec" {
        //            startRecorder()
        //            recordBtn.setTitle("Stop", for: .normal)
        //        } else {
        //            stopRecorder()
        //            recordBtn.setTitle("Start Rec", for: .normal)
        //        }
    }
    
    @IBAction func onVoiceBtnClick(_ sender: Any) {
        if(self.totalVoice>100){
            self.log(message: "LOADING \(self.totalVoice) VOICES. This might slow. Wait for few seconds!")
        }
        showSelectSid()
    }
    @IBAction func onTtsBtnClick(_ sender: Any) {
        log(message: "TTS for '\(ttsTextField.text!)'")
        audioFile = ttsMng.synthesizeSpeech(text: ttsTextField.text!,sid: Int("\(voiceIdField.text!)")!, speed: sliderSpeed.value, pitch: sliderPitch.value, pitchRate: sliderPitchRate.value, speedRate: sliderSpeedRate.value/100)
        self.log(message: "Saved to: \(audioFile!.path)")
    }
    @IBAction func onResetBtnClick(_ sender: Any) {
        sliderSpeed.value = 1.0
        sliderPitch.value = 0
        sliderPitchRate.value = 1.0
        sliderSpeedRate.value = 100
        updateSliderValue()
    }
    @IBAction func onShareBtnClick(_ sender: Any) {
        if(audioFile == nil){
            print("Not TTS yet.")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [audioFile!], applicationActivities: nil)
        
        // For iPad, present the activity view controller as a popover
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func updateSliderValue(){
        lblSpeed.text = "\(sliderSpeed.value)"
        lblPitch.text = "\(sliderPitch.value)"
        lblPitchRate.text = "\(sliderPitchRate.value)"
        lblSpeedRate.text = "\(sliderSpeedRate.value)"
    }
    
    func showSelectSid() {
        self.initVoices(show: true)
    }
    
    func log(message: String) {
        self.sentences.insert(message, at: 0)
    }
    
    func initTts(){
        let timestamp = NSDate().timeIntervalSince1970
        log(message: "Loading TTS... Please wait.")
        
        log(message: "Loading Model")
        ttsMng = TTSManager()
        let processedTime = NSDate().timeIntervalSince1970 - timestamp
        log(message: "Model loaded: vits-vctk. (\(Int(processedTime))s)")
    }
    
    func initVoices(show:Bool = false){
        self.loadingPrg.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.voiceIdField.text = "0"
            self.sids.removeAll()
            for i in 0...self.totalVoice-1 {
                self.sids.append(i)
            }
            
            // Create a UIAlertController
            self.selectVoicesPopup = UIAlertController(title: "Select an Item", message: nil, preferredStyle: .actionSheet)
            
            // Add an action for each item in the array
            for item in self.sids {
                let action = UIAlertAction(title: "Voice #\(item)", style: .default) { _ in
                    self.log(message: "Changed to voice: \(item)")
                    // Handle selection here, e.g., update UI or save the selection
                    self.voiceIdField.text = "\(item)"
                }
                self.selectVoicesPopup!.addAction(action)
            }
            
            // Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            self.selectVoicesPopup!.addAction(cancelAction)
            self.log(message: "Init \(self.sids.count) voices")
            self.loadingPrg.isHidden = true
            if(show){
                self.present(self.selectVoicesPopup!, animated: true, completion: nil)
            }
        }
    }
    
    func initRecognizer() {
        // Please select one model that is best suitable for you.
        //
        // You can also modify Model.swift to add new pre-trained models from
        // https://k2-fsa.github.io/sherpa/onnx/pretrained_models/index.html
        
        let modelConfig = getBilingualStreamZhEnZipformer20230220()
        // let modelConfig = getZhZipformer20230615()
        // let modelConfig = getEnZipformer20230626()
        //        let modelConfig = getBilingualStreamingZhEnParaformer()
        
        let featConfig = sherpaOnnxFeatureConfig(
            sampleRate: 16000,
            featureDim: 80)
        
        var config = sherpaOnnxOnlineRecognizerConfig(
            featConfig: featConfig,
            modelConfig: modelConfig,
            enableEndpoint: true,
            rule1MinTrailingSilence: 2.4,
            rule2MinTrailingSilence: 0.8,
            rule3MinUtteranceLength: 30,
            decodingMethod: "greedy_search",
            maxActivePaths: 4
        )
        recognizer = SherpaOnnxRecognizer(config: &config)
    }
    
    func initRecorder() {
        print("init recorder")
        audioEngine = AVAudioEngine()
        let inputNode = self.audioEngine?.inputNode
        let bus = 0
        let inputFormat = inputNode?.outputFormat(forBus: bus)
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000, channels: 1,
            interleaved: false)!
        
        let converter = AVAudioConverter(from: inputFormat!, to: outputFormat)!
        
        inputNode!.installTap(
            onBus: bus,
            bufferSize: 1024,
            format: inputFormat
        ) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            var newBufferAvailable = true
            
            let inputCallback: AVAudioConverterInputBlock = {
                inNumPackets, outStatus in
                if newBufferAvailable {
                    outStatus.pointee = .haveData
                    newBufferAvailable = false
                    
                    return buffer
                } else {
                    outStatus.pointee = .noDataNow
                    return nil
                }
            }
            
            let convertedBuffer = AVAudioPCMBuffer(
                pcmFormat: outputFormat,
                frameCapacity:
                    AVAudioFrameCount(outputFormat.sampleRate)
                * buffer.frameLength
                / AVAudioFrameCount(buffer.format.sampleRate))!
            
            var error: NSError?
            let _ = converter.convert(
                to: convertedBuffer,
                error: &error, withInputFrom: inputCallback)
            
            // TODO(fangjun): Handle status != haveData
            
            let array = convertedBuffer.array()
            if !array.isEmpty {
                self.recognizer.acceptWaveform(samples: array)
                while (self.recognizer.isReady()){
                    self.recognizer.decode()
                }
                let isEndpoint = self.recognizer.isEndpoint()
                let text = self.recognizer.getResult().text
                
                if !text.isEmpty && self.lastSentence != text {
                    self.lastSentence = text
                    self.updateLabel()
                    print(text)
                }
                
                if isEndpoint {
                    if !text.isEmpty {
                        let tmp = self.lastSentence
                        self.lastSentence = ""
                        self.sentences.append(tmp)
                    }
                    self.recognizer.reset()
                }
            }
        }
        
    }
    
    func startRecorder() {
        if(!initRecoged){
            initRecognizer()
            initRecorder()
            initRecoged = true
        }
        lastSentence = ""
        sentences = []
        
        do {
            try self.audioEngine?.start()
        } catch let error as NSError {
            print("Got an error starting audioEngine: \(error.domain), \(error)")
        }
        print("started")
    }
    
    func stopRecorder() {
        audioEngine?.stop()
        print("stopped")
    }
}
