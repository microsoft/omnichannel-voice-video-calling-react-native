enum TelemetryEvent {
    InitializeE2VVSDK = "InitializeE2VVSDK",
    ToggleMuteButtonClick = "ToggleMuteButtonClick",
    ToggleLocalVideoButtonClick = "ToggleLocalVideoButtonClick",
    ToggleSpeakerButtonClick = "ToggleSpeakerButtonClick",
    ToggleCameraButtonClicked = "ToggleCameraButtonClicked",
    AcceptWithVideoButtonClicked = "AcceptWithVideoButtonClicked",
    AcceptWithVoiceButtonClicked = "AcceptWithVoiceButtonClicked",
    RejectCallButtonClicked = "RejectCallButtonClicked",
    StopCallButtonClicked = "StopCallButtonClicked",
    RegisterNativeScenarioMarkerInitiated = "RegisterNativeScenarioMarkerInitiated"
}

export default TelemetryEvent;