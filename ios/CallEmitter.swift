//
//  CallingEmitter.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//
//
import Foundation

class CallingEmitter{

    public static var sharedInstance = CallingEmitter()

    // ReactNativeEventEmitter is instantiated by React Native with the bridge.
    private var eventEmitter: ReactNativeEventEmitter!

    // When React Native instantiates the emitter it is registered here.
    func registerEventEmitter(eventEmitter: ReactNativeEventEmitter) {
        self.eventEmitter = eventEmitter
    }

    func dispatch(name: String, body: Any?) {
        self.eventEmitter.sendEvent(withName: name, body: body)
    }

    lazy var allEvents: [String] = {
        var allEventNames: [String] = ["callAdded", "callEnded", "localVideoStreamAdded", "remoteVideoStreamAdded", "localVideoStreamRemoved", "remoteVideoStreamRemoved", "callDisconnected", "telemetry", "callAccepted", "callRejected"]
        return allEventNames
    }()
}
