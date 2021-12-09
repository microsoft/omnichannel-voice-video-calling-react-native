
//  ReactNativeEventEmitter.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//

import Foundation

@objc(ReactNativeEventEmitter)
open class ReactNativeEventEmitter: RCTEventEmitter {

    override init() {
        super.init()
        CallingEmitter.sharedInstance.registerEventEmitter(eventEmitter: self)
    }

    open override class func requiresMainQueueSetup() -> Bool {
        return false
    }

    /// Base overide for RCTEventEmitter.
    ///
    /// - Returns: all supported events
    @objc open override func supportedEvents() -> [String] {
        return CallingEmitter.sharedInstance.allEvents
    }

}
