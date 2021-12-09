//
//  IncomingCallHandler.swift
//  @microsoft/omnichannel-voice-video-calling-react-native

import Foundation
import AzureCommunicationCalling
import AVFoundation

final class IncomingCallHandler: NSObject, CallAgentDelegate, IncomingCallDelegate {
    public var incomingCall: IncomingCall?
    private var callObserver: CallObserver?

    private static var instance: IncomingCallHandler?
    static func getOrCreateInstance() -> IncomingCallHandler {
        if let c = instance {
            return c
        }
        instance = IncomingCallHandler()
        return instance!
    }

    // This delegate is invoked when the incoming call is added
    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        NSLog("Native/VoiceVideoCalling/didRecieveIncomingCall", "Incoming call received");

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnIncomingCallListenerEvent, telemetryType: "ScenarioStarted"))

        self.incomingCall = incomingCall
        self.incomingCall?.delegate = self
        CallingEmitter.sharedInstance.dispatch(name: "callAdded", body: [])
        VoiceVideoCalling.getInstance().setIncomingCall(incomingCall: incomingCall)
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnIncomingCallListenerEvent, telemetryType: "ScenarioCompleted"))
    }

    // This delegate is invoked when any updates are made to the call object
    public func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        NSLog("Native/VoiceVideoCalling/didUpdateCalls", "Incoming call update");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnCallsUpdatedListenerEvent, telemetryType: "ScenarioStarted"))

        if(args.removedCalls.count > 0){
            CallingEmitter.sharedInstance.dispatch(name: "callDisconnected", body: [])
            LocalVideoView.getInstance().disposeLocalVideoStream()
            RemoteVideoView.getInstance().disposeRemoteVideoStream()
            LocalVideoView.getInstance().disposeLocalVideoStream()
            RemoteVideoView.getInstance().disposeRemoteVideoStream()
            VoiceVideoCalling.getInstance().incomingCall = nil
            VoiceVideoCalling.getInstance().call = nil
            self.incomingCall = nil
        }

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnCallsUpdatedListenerEvent, telemetryType: "ScenarioCompleted"))
    }

    public func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
        NSLog("Native/VoiceVideoCalling/didEnd", "Incoming call end");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnCallEndedListenerEvent, telemetryType: "ScenarioStarted"))

        CallingEmitter.sharedInstance.dispatch(name: "callEnded", body: [])
        self.incomingCall = nil
        VoiceVideoCalling.getInstance().incomingCall = nil

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnCallEndedListenerEvent, telemetryType: "ScenarioCompleted"))
    }
}
