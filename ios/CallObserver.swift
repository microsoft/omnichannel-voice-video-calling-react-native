//
//  CallObserver.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//

import Foundation
import AVFoundation
import AzureCommunicationCalling

public class CallObserver: NSObject, CallDelegate {
    private var cli: CallClient?
    private var call: Call?
    private var remoteParticipant: RemoteParticipant?
    public var deviceManager: DeviceManager?
    private var remoteView: RemoteVideoView?
    private var callingInstance: VoiceVideoCalling?

    init(_ view: VoiceVideoCalling) {
        callingInstance = view
        remoteView = RemoteVideoView.getInstance()
    }

    public func call(_ call: Call, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs) {
        NSLog("Native/VoiceVideoCalling/didUpdateRemoteParticipant", "Remote Participant updated in CallObserver")
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnCallRemoteParticipantUpdateEvent, telemetryType: "ScenarioStarted"))

        for participant in args.addedParticipants {
            participant.delegate = VoiceVideoCalling.getInstance().remoteParticipantObserver
            for stream in participant.videoStreams {
                do {
                    try RemoteVideoView.getInstance().renderRemoteVideo(remoteVideoStream: stream)
                }
                catch {
                    NSLog("Native/VoiceVideoCalling/didUpdateRemoteParticipant", "Failed to render remote video: \(String(describing: error))");
                    var logContext = VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName: TelemetryConstants.OnCallRemoteParticipantUpdateEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to render remote video: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "remoteVideoStreamAdded", body: [])
                VoiceVideoCalling.getInstance().remoteVideoStream = stream
            }

            VoiceVideoCalling.getInstance().remoteParticipant = participant
        }

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnCallRemoteParticipantUpdateEvent, telemetryType: "ScenarioCompleted"))
    }

    public func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        if(call.state == CallState.connected) {
            self.initialCallParticipant(call: call)
        }
    }

    private func initialCallParticipant(call: Call!) {
        NSLog("Native/VoiceVideoCalling/didStateChange", "Call State Changed")
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnStateChangedListenerEvent, telemetryType: "ScenarioStarted"))

        for participant in call!.remoteParticipants {
            participant.delegate = VoiceVideoCalling.getInstance().remoteParticipantObserver
            for stream in participant.videoStreams {
                do {
                    try RemoteVideoView.getInstance().renderRemoteVideo(remoteVideoStream: stream)
                } catch {
                    NSLog("Native/VoiceVideoCalling/didStateChange", "Failed to render remote video: \(String(describing: error))");
                    var logContext = VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName: TelemetryConstants.OnStateChangedListenerEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to render remote video: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "remoteVideoStreamAdded", body: [])
                VoiceVideoCalling.getInstance().remoteVideoStream = stream

            }

            VoiceVideoCalling.getInstance().remoteParticipant = participant
        }

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnStateChangedListenerEvent, telemetryType: "ScenarioCompleted"))
    }
}
