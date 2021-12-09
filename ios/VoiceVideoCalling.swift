//
//  VoiceVideoCalling.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling
import AVFoundation

class VoiceVideoCalling{

    private static var voiceVideoCallingInstance : VoiceVideoCalling!
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var frontCameraDeviceInfo: VideoDeviceInfo?
    private var backCameraDeviceInfo: VideoDeviceInfo?
    private var isInitialized: Bool = false
    private var callObserver: CallObserver?
    private var deviceManager: DeviceManager?
    private var azureCommunicationCallingVersion: String?
    private var azureCommunicationCommonVersion: String?
    private var requestId: String = ""
    var remoteVideoStream: RemoteVideoStream?
    var localVideoStream: [LocalVideoStream]?
    var incomingCall: IncomingCall?
    var call: Call?
    var remoteParticipant: RemoteParticipant?
    var remoteParticipantObserver:RemoteParticipantObserver?

    static func getInstance() -> VoiceVideoCalling {
        if (self.voiceVideoCallingInstance == nil){
            self.voiceVideoCallingInstance = VoiceVideoCalling()
        }

        return self.voiceVideoCallingInstance
    }

    public func initialize(callingToken: String, requestId: String) {
        NSLog("Native/VoiceVideoCalling/initialize", "ACS Initialization started")
        self.requestId = requestId;
        if let acsCallingVersion = Bundle(identifier: TelemetryConstants.AzureCommunicationCallingPackageName)?.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.azureCommunicationCallingVersion = acsCallingVersion
        }

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.InitializeNativeSDKEvent, telemetryType: "ScenarioStarted"))

        var userCredential: CommunicationTokenCredential?
        do {
            userCredential = try CommunicationTokenCredential(token: callingToken)
            NSLog("Native/VoiceVideoCalling/initialize", "Created CommunicationTokenCredential");
            NSLog("Native/VoiceVideoCalling/initialize", "Created CommunicationTokenCredential")
        } catch {
            NSLog("Native/VoiceVideoCalling/Initialize", "Failed to create CommunicationUserCredential: \(error)");
            var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.InitializeNativeSDKEvent, telemetryType: "ScenarioFailed")
            logContext["ExceptionDetails"] = "Failed to create CommunicationUserCredential: \(error)"
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
            return
        }

        self.callClient = CallClient()
        self.callClient?.createCallAgent(userCredential: userCredential!) { (agent, error) -> Void in
            if error != nil {
                NSLog("Native/VoiceVideoCalling/CreateCallAgent", "Failed to create CallAgent: \(String(describing: error))");
                var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.InitializeNativeSDKEvent, telemetryType: "ScenarioFailed")
                logContext["ExceptionDetails"] = "Failed to create CallAgent: \(String(describing: error))"
                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                return
            }

            self.callAgent = agent
            let incomingCallHandler = IncomingCallHandler.getOrCreateInstance()
            self.callAgent?.delegate = incomingCallHandler
            self.callObserver = CallObserver(self)
            self.initializeDeviceManager()
            self.isInitialized = true
        }
    }

    public func setIncomingCall(incomingCall: IncomingCall) {
        self.incomingCall = incomingCall
    }

    public func acceptCall(withVideo: Bool) {
        NSLog("Native/VoiceVideoCalling/acceptCall", "withVideo \(String(describing: withVideo))")
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.AcceptCallEvent, telemetryType: "ScenarioStarted"))

        if (!self.isInitialized){
            NSLog("Native/VoiceVideoCalling/AcceptCallEvent", "SDK not initialized")
            var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.AcceptCallEvent, telemetryType: "ScenarioFailed")
            logContext["ExceptionDetails"] = "Calling SDK not initialized"
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
            return
        }

        let acceptCallOptions = AcceptCallOptions()

        if(withVideo){
            let camera = self.deviceManager!.cameras.first
            if (self.localVideoStream == nil) {
                self.localVideoStream = [LocalVideoStream]()
            }

            self.localVideoStream!.append(LocalVideoStream(camera: camera!))
            let videoOptions = VideoOptions(localVideoStreams: self.localVideoStream!)
            acceptCallOptions.videoOptions = videoOptions
            DispatchQueue.main.async { () -> Void in
                do {
                    try LocalVideoView.getInstance().renderLocalVideo(localVideoStream: self.localVideoStream)
                    CallingEmitter.sharedInstance.dispatch(name: "localVideoStreamAdded", body: [withVideo: withVideo])
                }
                catch {
                    NSLog("Native/VoiceVideoCalling/acceptCall", "Unable to render local video while accepting the call");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.AcceptCallEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Unable to render local video: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }
            }
        }

        if(self.incomingCall == nil) {
            NSLog("Native/VoiceVideoCalling/acceptCall", "No incoming call");
            var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.AcceptCallEvent, telemetryType: "ScenarioFailed")
            logContext["ExceptionDetails"] = "Incoming call object is not initialized"
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
            return
        }

        self.incomingCall!.accept(options: acceptCallOptions) { (call, error) in
            if error != nil{
                NSLog("Native/VoiceVideoCalling/AcceptCall", "Failed to accept call: \(String(describing: error))");
                var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.AcceptCallEvent, telemetryType: "ScenarioFailed")
                logContext["ExceptionDetails"] = "Failed to accept call: \(String(describing: error))"
                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                return
            }

            CallingEmitter.sharedInstance.dispatch(name: "callAccepted", body: [])
            self.setCallAndObersever(call: call, error: error)
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.AcceptCallEvent, telemetryType: "ScenarioCompleted"))
        }
    }

    public func toggleMute() -> Bool {
        NSLog("Native/VoiceVideoCalling/toggleMute", "Toggle Mute");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleMuteEvent, telemetryType: "ScenarioStarted"))
        if(!self.isSDKAndCallInitialized(eventName: TelemetryConstants.ToggleMuteEvent)){
            return false
        }

        var isCallMuted = false
        if(self.call?.isMuted == true) {
            self.call?.unmute(completionHandler: { (error) in
                if error != nil {
                    NSLog("Native/VoiceVideoCalling/ToggleMute", "Failed to unmute call: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleMuteEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to unmute call: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleMuteEvent, telemetryType: "ScenarioCompleted"))
            })
        }
        else {
            self.call?.mute(completionHandler: { (error) in
                if error != nil {
                    NSLog("Native/VoiceVideoCalling/ToggleMute", "Failed to mute call: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleMuteEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to mute call: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleMuteEvent, telemetryType: "ScenarioCompleted"))
            })

            isCallMuted = true
        }

        return isCallMuted
    }

    public func isMicrophoneMuted() -> Bool {
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.IsMicrophoneMutedEvent, telemetryType: "ScenarioStarted"))

        if (!self.isSDKAndCallInitialized(eventName: TelemetryConstants.IsMicrophoneMutedEvent)) {
            return false
        }

        NSLog("Native/VoiceVideoCalling/isMicrophoneMuted", "\(String(describing: self.call?.isMuted))");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.IsMicrophoneMutedEvent, telemetryType: "ScenarioCompleted"))
        return self.call?.isMuted == true ? true : false
    }

    public func isRemoteVideoEnabled() -> Bool? {
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.IsRemoteVideoEnabled, telemetryType: "ScenarioStarted"))

        if (self.incomingCall == nil) {
            NSLog("Native/VoiceVideoCalling/isRemoteVideoEnabled", "No incoming call");
            var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.IsRemoteVideoEnabled, telemetryType: "ScenarioFailed")
            logContext["ExceptionDetails"] = "Incoming call object is not initialized"
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
            return false
        }

        NSLog("Native/VoiceVideoCalling/isRemoteVideoEnabled", "\(String(describing: self.incomingCall?.isVideoEnabled))");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.IsRemoteVideoEnabled, telemetryType: "ScenarioCompleted"))
        return self.incomingCall?.isVideoEnabled
    }

    public func isLocalVideoEnabled() -> Bool {
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.IsLocalVideoEnabled, telemetryType: "ScenarioStarted"))

        if (!self.isSDKAndCallInitialized(eventName: TelemetryConstants.IsLocalVideoEnabled)) {
            return false
        }

        NSLog("Native/VoiceVideoCalling/isRemoteVideoEnabled", "\(String(describing: (self.call?.localVideoStreams.count)! > 0))");

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.IsLocalVideoEnabled, telemetryType: "ScenarioCompleted"))
        return (self.call?.localVideoStreams.count)! > 0
    }

    public func rejectCall() {
        NSLog("Native/VoiceVideoCalling/rejectCall", "Reject Call");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.RejectCallEvent, telemetryType: "ScenarioStarted"))

        if(!self.isSDKAndCallInitialized(eventName: TelemetryConstants.RejectCallEvent)){
            return
        }

        self.incomingCall!.reject { (error) in
            if error != nil {
                NSLog("Native/VoiceVideoCalling/RejectCall", "Failed to get reject call: \(String(describing: error))");
                var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.RejectCallEvent, telemetryType: "ScenarioFailed")
                logContext["ExceptionDetails"] = "Failed to get reject call: \(String(describing: error))"
                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                return
            }

            CallingEmitter.sharedInstance.dispatch(name: "callRejected", body: [])
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.RejectCallEvent, telemetryType: "ScenarioCompleted"))
        }
    }

    public func stopCall() {
        NSLog("Native/VoiceVideoCalling/stopCall", "Stop Call");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.StopCallEvent, telemetryType: "ScenarioStarted"))

        if(!self.isSDKAndCallInitialized(eventName: TelemetryConstants.StopCallEvent)){
            return
        }

        LocalVideoView.getInstance().disposeLocalVideoStream()
        RemoteVideoView.getInstance().disposeRemoteVideoStream()
        let hangUpOptions = HangUpOptions()
        hangUpOptions.forEveryone = true

        self.call?.hangUp(options: hangUpOptions, completionHandler: { error in
            if error != nil{
                NSLog("Native/VoiceVideoCalling/StopCall", "Failed to end call: \(String(describing: error))");
                var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.StopCallEvent, telemetryType: "ScenarioFailed")
                logContext["ExceptionDetails"] = "Failed to end call: \(String(describing: error))"
                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                return
            }

            self.call = nil
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.StopCallEvent, telemetryType: "ScenarioCompleted"))
        })
    }

    public func toggleSpeaker() {
        NSLog("Native/VoiceVideoCalling/toggleSpeaker", "Toggle Speaker");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleSpeakerEvent, telemetryType: "ScenarioStarted"))

        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for description in currentRoute.outputs {
            if description.portType == AVAudioSession.Port.builtInReceiver {
                do {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                    try AVAudioSession.sharedInstance().setActive(true)
                }
                catch {
                    NSLog("Native/VoiceVideoCalling/ToggleSpeaker", "Failed to turn off speaker: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleSpeakerEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to turn off speaker: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }
            }
            else if description.portType == AVAudioSession.Port.builtInSpeaker {
                do {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                    try AVAudioSession.sharedInstance().setActive(true)
                }
                catch {
                    NSLog("Native/VoiceVideoCalling/ToggleSpeaker", "Failed to turn on speaker: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleSpeakerEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to turn off speaker: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }
            }
        }

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleSpeakerEvent, telemetryType: "ScenarioCompleted"))
    }

    public func toggleLocalVideo() {
        NSLog("Native/VoiceVideoCalling/toggleLocalVideo", "Toggle Local Video");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioStarted"))

        if(!self.isSDKAndCallInitialized(eventName: TelemetryConstants.ToggleLocalVideoEvent)){
            return
        }

        if(self.isLocalVideoEnabled()){
            self.call?.stopVideo(stream: self.localVideoStream!.first!, completionHandler: { error in
                if error != nil {
                    NSLog("Native/VoiceVideoCalling/ToggleLocalVideo", "Failed to stop local video: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to stop local video: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioCompleted"))
            })

            NSLog("Native/VoiceVideoCalling/Event", "Sending localVideoStreamRemoved");
            CallingEmitter.sharedInstance.dispatch(name: "localVideoStreamRemoved", body: [])
        }
        else{
            if(self.localVideoStream == nil) {
                let camera = self.deviceManager!.cameras.first
                if (self.localVideoStream == nil) {
                    self.localVideoStream = [LocalVideoStream]()
                }

                self.localVideoStream!.append(LocalVideoStream(camera: camera!))
                DispatchQueue.main.async { () -> Void in
                    do {
                        try LocalVideoView.getInstance().renderLocalVideo(localVideoStream: self.localVideoStream)
                    }
                    catch {
                        NSLog("Native/VoiceVideoCalling/ToggleLocalVideo", "Failed to start local video: \(String(describing: error))");
                        var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioFailed")
                        logContext["ExceptionDetails"] = "Failed to start local video: \(String(describing: error))"
                        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                        return
                    }
                }
            }

            self.call?.startVideo(stream: self.localVideoStream!.first!, completionHandler: { error in
                if error != nil {
                    NSLog("Native/VoiceVideoCalling/ToggleLocalVideo", "Failed to start local video: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to start local video: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioCompleted"))
            })

            NSLog("Native/VoiceVideoCalling/Event", "Sending localVideoStreamAdded");
            CallingEmitter.sharedInstance.dispatch(name: "localVideoStreamAdded", body: [])
        }
    }

    public func toggleCamera(){
        NSLog("Native/VoiceVideoCalling/toggleCamera", "Toggle Camera")
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleCameraEvent, telemetryType: "ScenarioStarted"))

        DispatchQueue.main.async { () -> Void in
            if(self.localVideoStream!.first!.source.cameraFacing == CameraFacing.front) {
                self.localVideoStream!.first!.switchSource(camera: self.backCameraDeviceInfo!, completionHandler: { error in
                    if error != nil {
                        NSLog("Native/VoiceVideoCalling/ToggleCamera", "Failed to toggle to front camera: \(String(describing: error))");
                        var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleCameraEvent, telemetryType: "ScenarioFailed")
                        logContext["ExceptionDetails"] = "Failed to toggle to front camera: \(String(describing: error))"
                        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                        return
                    }

                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleCameraEvent, telemetryType: "ScenarioCompleted"))
                })
            }
            else {
                self.localVideoStream!.first!.switchSource(camera: self.frontCameraDeviceInfo!, completionHandler: { error in
                    if error != nil {
                        NSLog("Native/VoiceVideoCalling/ToggleCamera", "Failed to toggle to back camera: \(String(describing: error))");
                        var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.ToggleLocalVideoEvent, telemetryType: "ScenarioFailed")
                        logContext["ExceptionDetails"] = "Failed to toggle to back camera: \(String(describing: error))"
                        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                        return
                    }

                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.ToggleCameraEvent, telemetryType: "ScenarioCompleted"))
                })
            }
        }
    }

    func setCallAndObersever(call:Call!, error:Error?) {
        if (error == nil) {
            self.call = call
            self.callObserver = CallObserver(self)
            self.call!.delegate = self.callObserver
            self.remoteParticipantObserver = RemoteParticipantObserver()
        } else {
            NSLog("Native/VoiceVideoCalling/setCallObserver", "Failed to get call object: \(String(describing: error))");
        }
    }

    public func getTelemetryContextMap(eventName: String, telemetryType: String) -> Dictionary<String, String> {
        var telemetryData: Dictionary<String, String> = [:]
        telemetryData["EventName"] = eventName
        telemetryData["RequestId"] = self.requestId
        telemetryData["Platform"] = TelemetryConstants.Platform
        telemetryData["ACSCallingVersion"] = self.azureCommunicationCallingVersion!
        telemetryData["ScenarioType"] = telemetryType
        if (self.call != nil) {
            telemetryData["CallId"] = self.call!.id
        }

        return telemetryData
    }

    private func initializeDeviceManager() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                AVCaptureDevice.requestAccess(for: .video) {(videoGranted) in /* NOOP */}
            }

            self.callClient?.getDeviceManager(completionHandler: { (deviceManager, error) in
                if error != nil {
                    NSLog("Native/VoiceVideoCalling/DeviceManager", "Failed to get DeviceManager: \(String(describing: error))");
                    var logContext = self.getTelemetryContextMap(eventName: TelemetryConstants.InitializeNativeSDKEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to get DeviceManager: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                NSLog("Native/VoiceVideoCalling/DeviceManager", "Successfully got DeviceManager");
                self.deviceManager = deviceManager

                for camera in self.deviceManager!.cameras {
                    NSLog("Native/VoiceVideoCalling/DeviceManager/camera", "Camera \(camera.name) facing \(camera.cameraFacing)")
                    if camera.cameraFacing == CameraFacing.front {
                        self.frontCameraDeviceInfo = camera
                    }
                    else if camera.cameraFacing == CameraFacing.back {
                        self.backCameraDeviceInfo = camera
                    }
                }

                CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: self.getTelemetryContextMap(eventName:TelemetryConstants.InitializeNativeSDKEvent, telemetryType: "ScenarioCompleted"))
            })
        }
    }

    private func isSDKAndCallInitialized(eventName: String) -> Bool {
        if (!self.isInitialized){
            NSLog("Native/VoiceVideoCalling/\(eventName)", "SDK not initialized")
            var logContext = self.getTelemetryContextMap(eventName: eventName, telemetryType: "ScenarioFailed")
            logContext["ExceptionDetails"] = "Calling SDK not initialized"
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
            return false
        }

        if (self.call == nil) {
            NSLog("Native/VoiceVideoCalling/\(eventName)", "Call Object is not initialized")
            var logContext = self.getTelemetryContextMap(eventName: eventName, telemetryType: "ScenarioFailed")
            logContext["ExceptionDetails"] = "Incoming Call Not Initialized"
            CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
            return false
        }

        return true
    }
}
