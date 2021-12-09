//
//  RemoteParticipantObserver.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//

import Foundation
import AzureCommunicationCalling

public class RemoteParticipantObserver : NSObject, RemoteParticipantDelegate {

    public func remoteParticipant(_ remoteParticipant: RemoteParticipant, didUpdateVideoStreams args: RemoteVideoStreamsEventArgs) {
        NSLog("Native/VoiceVideoCalling/didUpdateVideoStreams", "Video streams updated");
        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnRemoteParticipantUpdatedEvent, telemetryType: "ScenarioStarted"))

        for stream in args.addedRemoteVideoStreams {
            if (stream.isAvailable) {
                do {
                    try RemoteVideoView.getInstance().renderRemoteVideo(remoteVideoStream: stream)
                } catch {
                    NSLog("Native/VoiceVideoCalling/didUpdateVideoStreams", "Failed to render remote video: \(String(describing: error))");
                    var logContext = VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName: TelemetryConstants.OnRemoteParticipantUpdatedEvent, telemetryType: "ScenarioFailed")
                    logContext["ExceptionDetails"] = "Failed to render remote video: \(String(describing: error))"
                    CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: logContext)
                    return
                }

                CallingEmitter.sharedInstance.dispatch(name: "remoteVideoStreamAdded", body: [])
                VoiceVideoCalling.getInstance().remoteVideoStream = stream
            }
        }

        for stream in args.removedRemoteVideoStreams {
            if(!stream.isAvailable) {
                RemoteVideoView.getInstance().disposeRemoteVideoStream()
                CallingEmitter.sharedInstance.dispatch(name: "remoteVideoStreamRemoved", body: [])
                VoiceVideoCalling.getInstance().remoteVideoStream = nil
            }
        }

        CallingEmitter.sharedInstance.dispatch(name: "telemetry", body: VoiceVideoCalling.getInstance().getTelemetryContextMap(eventName:TelemetryConstants.OnRemoteParticipantUpdatedEvent, telemetryType: "ScenarioCompleted"))
    }
}
