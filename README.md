  # Omnichannel Voice Video Calling React Native

Voice and Video Calling SDK on React Native to use calling feature of react native mobile applications against Dynamics 365 Omnichannel Services

Please make sure you have a omnichannel chat widget configured before using this package or you can follow this [link](https://docs.microsoft.com/en-us/dynamics365/customer-service/configure-live-chat)

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [API Reference](#api-reference)
- [Usage](#usage)
- [Guidance](#guidance)
- [Telemetry](#telemetry)
- [Contributing](#contributing)
- [Trademarks](#trademarks)

## Prerequisites
- [React Native](https://reactnative.dev/docs/environment-setup)
- [@microsoft/omnichannel-chat-sdk](https://www.npmjs.com/package/@microsoft/omnichannel-chat-sdk)
- [Omnichannel Chat SDK React Native Installation](https://www.npmjs.com/package/@microsoft/omnichannel-chat-sdk#installation-on-react-native)

## Installation
```sh
npm install @microsoft/omnichannel-voice-video-calling-react-native
```

## Dependencies
The following steps will be required to run Omnichannel voice video calling package:
- Run `npm install react-native-gesture-handler --save`
- For iOS:
  - Add following Information property list in Info.plist to ask for permissions for microphone and camera:
    - Privacy - Camera Usage Description
    - Privacy - Microphone Usage Description
  - Add use_frameworks! in Podfile. Make sure you remove use_flipper! if present in Podfile
  - Update the ios version >= 14.0 in Podfile. Make sure deployment target is >= 14.0
- For android
  - Please make sure the minSdkVersion in build.gradle of project is >= 26
  - Please add `System.loadLibrary("c++_shared");` in MainApplication.java under onCreate() for support of RN version 0.63 and greater
  - Add the following in build.gradle of .app module
    ```groovy
    packagingOptions {
        pickFirst 'lib/x86/libc++_shared.so'
        pickFirst 'lib/arm64-v8a/libc++_shared.so'
        pickFirst 'lib/x86_64/libc++_shared.so'
        pickFirst 'lib/armeabi-v7a/libc++_shared.so'
    }
    ```

## API Reference

| Component | Description | Usage |
| --- | --- | --- |
| LocalVideoView | Component to render local video stream | <LocalVideoView style={Add your style here} /> |
| RemoteVideoView | Component to render remote video stream | <RemoteVideoView style={Add your style here} /> |

| Method | Description | Notes |
| --- | --- | --- |
| createVoiceVideoCalling | Creates Voice Video calling SDK | Omnichannel config with this required with this method |
| VoiceVideoCallingSDK.askPermissions() | Ask for permissions | Use this for android. For iOS add permissions in Info.plist |
| VoiceVideoCallingSDK.initialize() | Initialize Voice Video calling SDK | Need to pass ChatToken, CallingToken, and OCClient with this method |
| VoiceVideoCallingSDK.onCallAdded() | Triggered when there's an incoming call | |
| VoiceVideoCallingSDK.onLocalVideoStreamAdded() | Triggered when local video stream is available (e.g.: Local video stream added succesfully in LocalVideoView) | |
| VoiceVideoCallingSDK.onLocalVideoStreamRemoved() | Triggered when local video stream is unavailable (e.g.: Local video stream removed from LocalVideoView) | |
| VoiceVideoCallingSDK.onRemoteVideoStreamAdded() | Triggered when remote video stream is available (e.g.: Remote video stream added succesfully in RemoteVideoView) | |
| VoiceVideoCallingSDK.onRemoteVideoStreamRemoved() | Triggered when remote video stream is unavailable (e.g.: Remote video stream removed from RemoteVideoView) | |
| VoiceVideoCallingSDK.onCallDisconnected() | Triggered when current call has ended or disconnected regardless the party | |
| VoiceVideoCallingSDK.isMicrophoneMuted() | Check if microphone is muted | |
| VoiceVideoCallingSDK.isLocalVideoEnabled() | Check if local video is available | |
| VoiceVideoCallingSDK.isRemoteVideoEnabled() | Check if remote video is available | |
| VoiceVideoCallingSDK.acceptCall() | Accept voice/video call | Pass withVideo boolean flag with this method |
| VoiceVideoCallingSDK.rejectCall() | Reject current incoming call | |
| VoiceVideoCallingSDK.stopCall() | Ends/Stops current call | |
| VoiceVideoCallingSDK.toggleMute() | Mute/Unmute current call | |
| VoiceVideoCallingSDK.toggleLocalVideo() | Display/Hide local video of current call | |
| VoiceVideoCallingSDK.toggleSpeaker() | Turn on/off speaker | |
| VoiceVideoCallingSDK.toggleCamera() | Toggle front/back camera | |

## Usage

```js
import { OmnichannelChatSDK } from '@microsoft/omnichannel-chat-sdk';

import createVoiceVideoCalling, {LocalVideoView, RemoteVideoView} from "@microsoft/omnichannel-voice-video-calling-react-native";

// Initialize OmnichannelChatSDK
const chatSDK = new OmnichannelChatSDK(omnichannelConfig);
await chatSDK.initialize();

// Create VoiceVideoCallingSDK
const voiceVideoCallingSDK = createVoiceVideoCalling(omnichannelConfig);

// Start Omnichannel chat
await chatSDK?.startChat();

// Get chat token
const chatToken: any = await chatSDK?.getChatToken();

// Ask permissions for android
voiceVideoCallingSDK.askPermissions();

// Initialize VoiceVideoCallingSDK
voiceVideoCallingSDK.initialize({
  chatToken,
  OCClient: chatSDK.OCClient
});

// Triggered when there's an incoming call
voiceVideoCallingSDK.onCallAdded(() => {
  ...
});

// Triggered when local video stream is available (e.g.: Local video stream added succesfully in LocalVideoView)
voiceVideoCallingSDK.onLocalVideoStreamAdded(() => {
  ...
});

// Triggered when local video stream is unavailable (e.g.: Local video stream removed from LocalVideoView)
voiceVideoCallingSDK.onLocalVideoStreamRemoved(() => {
  ...
});

// Triggered when remote video stream is available (e.g.: Remote video stream added succesfully in RemoteVideoView)
voiceVideoCallingSDK.onRemoteVideoStreamAdded(() => {
  ...
});

// Triggered when remote video stream is unavailable (e.g.: Remote video stream removed from RemoteVideoView)
voiceVideoCallingSDK.onRemoteVideoStreamRemoved(() => {
  ...
});

// Triggered when current call has ended or disconnected regardless the party
voiceVideoCallingSDK.onCallDisconnected(() => {
  ...
});

// Check if microphone is muted
const isMicrophoneMuted = await voiceVideoCallingSDK.isMicrophoneMuted();

// Check if local video is available
const isLocalVideoEnabled = await voiceVideoCallingSDK.isLocalVideoEnabled();

// Check if remote video is available
const isRemoteVideoEnabled = await voiceVideoCallingSDK.isRemoteVideoEnabled();

// Accept Voice Call
voiceVideoCallingSDK.acceptCall(with);

// Accept Video Call
const withVideo = true;
voiceVideoCallingSDK.accept(withVideo);

// Reject current call
await voiceVideoCallingSDK.rejectCall();

// Ends/Stops current call
await voiceVideoCallingSDK.stopCall();

// Mute/Unmute current call
voiceVideoCallingSDK.toggleMute();

// Display/Hide local video of current call
voiceVideoCallingSDK.toggleLocalVideo();

// Turn on/off speaker
voiceVideoCallingSDK.toggleSpeaker();

// Toggle front/back camera
voiceVideoCallingSDK.toggleCamera();

...

// Render RemoteVideoView & LocalVideoView
return (
  <View>
    <RemoteVideoView/>
    <LocalVideoView/>
  </View>
)
```

## Guidance

### Do not hide/display `LocalVideoView` & `RemoteVideoView` based on a variable value

e.g.: **Incorrect**
```js
const [display, setDisplay] = useState(false);
...
return (
  {
    display && <View>
      <RemoteVideoView/>
      <LocalVideoView/>
    </View>
  }
)
```
- Both components `ALWAYS` need to be rendered or the app will crash otherwise
- Instead, use `style` to hide/display the components

e.g.: **Correct**
```js
const [display, setDisplay] = useState(false);
...

return (
  <View style={display? styles.videoContainer: styles.noDisplay}>
    <RemoteVideoView/>
    <LocalVideoView/>
  </View>
);

...

const styles = StyleSheet.create({
  videoContainer: {
    // ...
  },
  noDisplay: { // Style to hide the video container view
    display: 'none',
    height: 0,
    width: 0
  }
});
```

## Telemetry

Omnichannel voice video calling package collects telemetry by default to improve the feature’s capabilities, reliability, and performance over time by helping Microsoft understand usage patterns, plan new features, and troubleshoot and fix problem areas.

Some of the data being collected are the following:

| Field | Sample |
| --- | --- |
| Organization Id | `e00e67ee-a60e-4b49-b28c-9d279bf42547` |
| Organization Url | `org60082947.crm.oc.crmlivetie.com` |
| Widget Id | `1893e4ae-2859-4ac4-9cf5-97cffbb9c01b` |
| Platform Name | `iOS` |
| ChatSDKVersion | `1.0.0` |
| Anonymized IP Address (last octet redacted) | `19.207.000.000` |

If your organization is concerned about the data collected by the omnichannel voice video sdk, you have the option to turn off automatic data collection by adding a flag while creating the SDK.

```ts
    const omnichannelConfig = {
        orgUrl: "e00e67ee-a60e-4b49-b28c-9d279bf42547",
        orgId: "org60082947.crm.oc.crmlivetie.com",
        widgetId: "1893e4ae-2859-4ac4-9cf5-97cffbb9c01b"
    };

    const voiceVideoCallingSDK = createVoiceVideoCalling(omnichannelConfig, {disable: false}));
    await voiceVideoCallingSDK.initialize();
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
