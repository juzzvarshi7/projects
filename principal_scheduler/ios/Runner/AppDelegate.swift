import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let audioChannel = FlutterMethodChannel(name: "audio_recorder",
                                              binaryMessenger: controller.binaryMessenger)
        
        audioChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard call.method == "startRecording" || call.method == "stopRecording" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            if call.method == "startRecording" {
                if let args = call.arguments as? Dictionary<String, Any>,
                   let path = args["path"] as? String {
                    self?.startRecording(path: path, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Path is required", details: nil))
                }
            } else if call.method == "stopRecording" {
                self?.stopRecording(result: result)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private var audioRecorder: AVAudioRecorder?
    
    private func startRecording(path: String, result: @escaping FlutterResult) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let url = URL(fileURLWithPath: path)
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            
            result(true)
        } catch {
            result(FlutterError(code: "RECORDING_ERROR", message: "Failed to start recording: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func stopRecording(result: @escaping FlutterResult) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            result(true)
        } catch {
            result(FlutterError(code: "RECORDING_ERROR", message: "Failed to stop recording: \(error.localizedDescription)", details: nil))
        }
    }
}