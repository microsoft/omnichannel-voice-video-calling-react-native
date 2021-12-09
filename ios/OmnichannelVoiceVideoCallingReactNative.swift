@objc(OmnichannelVoiceVideoCallingReactNative)
class OmnichannelVoiceVideoCallingReactNative: NSObject {

    private static var omnichannelVoiceVideoInstance : OmnichannelVoiceVideoCallingReactNative!

    static func getInstance() -> OmnichannelVoiceVideoCallingReactNative {
        if (self.omnichannelVoiceVideoInstance == nil){
            self.omnichannelVoiceVideoInstance = OmnichannelVoiceVideoCallingReactNative()
        }

      return self.omnichannelVoiceVideoInstance
    }

    @objc(initialize:withRequestId:withResolver:withRejecter:)
    func initialize(callingToken: String, requestId: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        VoiceVideoCalling.getInstance().initialize(callingToken:callingToken, requestId:requestId)
    }

    @objc(acceptCall:withResolver:withRejecter:)
    func acceptCall(withVideo: Bool, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void
    {
        VoiceVideoCalling.getInstance().acceptCall(withVideo: withVideo)
    }

    @objc(toggleMute:rejecter:)
    func toggleMute(_ resolve: RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        resolve(VoiceVideoCalling.getInstance().toggleMute())
    }

    @objc public func rejectCall() -> Void
    {
        VoiceVideoCalling.getInstance().rejectCall()
    }

    @objc public func stopCall() -> Void
    {
        VoiceVideoCalling.getInstance().stopCall()
    }

    @objc public func toggleSpeaker() -> Void
    {
        VoiceVideoCalling.getInstance().toggleSpeaker()
    }

    @objc public func toggleLocalVideo() -> Void
    {
        VoiceVideoCalling.getInstance().toggleLocalVideo()
    }

    @objc public func toggleCamera() -> Void
    {
        VoiceVideoCalling.getInstance().toggleCamera()
    }

    @objc(isMicrophoneMuted:rejecter:)
    func isMicrophoneMuted(_ resolve: RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        resolve(VoiceVideoCalling.getInstance().isMicrophoneMuted())
    }

    @objc(isRemoteVideoEnabled:rejecter:)
    func isRemoteVideoEnabled(_ resolve: RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        resolve(VoiceVideoCalling.getInstance().isRemoteVideoEnabled())
    }

    @objc(isLocalVideoEnabled:rejecter:)
    func isLocalVideoEnabled(_ resolve: RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        resolve(VoiceVideoCalling.getInstance().isLocalVideoEnabled())
    }
}
