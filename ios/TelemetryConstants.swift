//
//  TelemetryConstants.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//
//  Created by rpteam on 11/8/21.
//

import Foundation

class TelemetryConstants{
    public static let AzureCommunicationCallingPackageName: String = "com.microsoft.AzureCommunicationCalling"
    public static let InitializeNativeSDKEvent = "InitializeNativeSDKEvent"
    public static let IsMicrophoneMutedEvent = "IsMicrophoneMutedEvent"
    public static let AddEventListeners = "AddEventListeners"
    public static let IsRemoteVideoEnabled = "IsRemoteVideoEnabled"
    public static let IsLocalVideoEnabled = "IsLocalVideoEnabled"
    public static let OnIncomingCallListenerEvent = "AddOnIncomingCallListenerEvent"
    public static let OnCallEndedListenerEvent = "AddOnCallEndedListenerEvent"
    public static let OnCallsUpdatedListenerEvent = "OnCallsUpdatedListenerEvent"
    public static let OnStateChangedListenerEvent = "OnStateChangedListenerEvent"
    public static let ToggleCameraEvent = "ToggleCameraEvent"
    public static let ToggleSpeakerEvent = "ToggleSpeakerEvent"
    public static let ToggleLocalVideoEvent = "ToggleLocalVideoEvent"
    public static let ToggleMuteEvent = "ToggleMuteEvent"
    public static let RejectCallEvent = "RejectCallEvent"
    public static let StopCallEvent = "StopCallEvent"
    public static let AcceptCallEvent = "AcceptCallEvent"
    public static let DidStateChangeEvent = "DidStateChangeEvent"
    public static let UpdateRemoteParticipantEvent = "UpdateRemoteParticipantEvent"
    public static let OnRemoteParticipantUpdatedEvent = "OnRemoteParticipantUpdatedEvent"
    public static let OnRemoteParticipantStateChanged = "OnRemoteParticipantStateChanged"
    public static let OnCallRemoteParticipantUpdateEvent = "OnCallRemoteParticipantUpdateEvent"
    public static let Platform: String = "iOS"
}
