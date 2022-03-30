import React, {useState} from 'react';

import { StyleSheet, View, ScrollView, TextInput, Button, TouchableHighlight, Platform} from 'react-native';

import { OmnichannelChatSDK } from '@microsoft/omnichannel-chat-sdk';
import createVoiceVideoCalling, {LocalVideoView, RemoteVideoView} from '@microsoft/omnichannel-voice-video-calling-react-native';
import fetchOmnichannelConfig from '../utils/fetchOmnichannelConfig';
import IncomingCall from './IncomingCall';
import CurrentCallMenu from './CurrentCallMenu';

export default function App() {
  const [chatSDK, setChatSDK] = useState<OmnichannelChatSDK>();
  const [voiceVideoCallingSDK, setVoiceVideoCallingSDK] = useState();
  const [isReady, setIsReady] = useState(false);
  const [hasChatStarted, setHasChatStarted] = useState(false);
  const [incomingCall, setIncomingCall] = useState(false);
  const [inVideoCall, setInVideoCall] = useState(false);
  const [inVoiceCall, setInVoiceCall] = useState(false);
  const [isLocalVideoEnabled, setIsLocalVideoEnabled] = useState(false);
  const [isMicrophoneMuted, setIsMicrophoneMuted] = useState(false);
  const [isUsingSpeaker, setIsUsingSpeaker] = useState(false); // TODO: Use SDK
  const [widgetId, onChangeWidgetId] = React.useState(null);
  const [organizationId, onChangeOrganizationId] = React.useState(null);
  const [organizationURL, onChangeOrganizationURL] = React.useState(null);

  const onLoadChatWidget = async () => {
    //const omnichannelConfig = fetchOmnichannelConfig();
    if (widgetId && organizationId && organizationURL) {
      console.log("Omnichannel Config");
      let omnichannelConfig = {};
      omnichannelConfig["orgId"] = organizationId;
      omnichannelConfig["orgUrl"] = organizationURL;
      omnichannelConfig["widgetId"] = widgetId;

      const chatSDK = new OmnichannelChatSDK(omnichannelConfig);
      await chatSDK.initialize();
      const voiceVideoCallingSDK = createVoiceVideoCalling(omnichannelConfig, {disable: true});
      setVoiceVideoCallingSDK(voiceVideoCallingSDK);

      setChatSDK(chatSDK);

      voiceVideoCallingSDK.onCallAdded(() => {
        console.log("ExampleApp/onCallAdded");
        setIncomingCall(true);
        console.log("ExampleApp/onCallAdded/setIncomingCall");
      });

      voiceVideoCallingSDK.onCallEnded(() => {
        console.log("ExampleApp/onCallEnded");
        setIncomingCall(false);
        console.log("ExampleApp/onCallEnded/setIncomingCall");
      })

      voiceVideoCallingSDK.onLocalVideoStreamAdded(() => {
        console.log("ExampleApp/onLocalVideoStreamAdded");
        setIsLocalVideoEnabled(true);
        if(!inVideoCall) {
          setInVideoCall(true);
        }
      });

      voiceVideoCallingSDK.onLocalVideoStreamRemoved(() => {
        console.log("ExampleApp/onLocalVideoStreamRemoved");
        setIsLocalVideoEnabled(false);
        if(inVideoCall) {
          setInVideoCall(false);
        }
      });

      voiceVideoCallingSDK.onRemoteVideoStreamAdded(() => {
        console.log("ExampleApp/onRemoteVideoStreamAdded");
        if(!inVideoCall) {
          setInVideoCall(true);
        }
      })

      voiceVideoCallingSDK.onRemoteVideoStreamRemoved(() => {
        console.log("ExampleApp/onRemoteVideoStreamRemoved");
        if(inVideoCall) {
          setInVideoCall(false);
        }
      })

      voiceVideoCallingSDK.onCallDisconnected(() => {
        setIncomingCall(false);
        setInVideoCall(false);
        setInVoiceCall(false);
      });

      setIsReady(true);
    }
  }

  const onStartChatPress = async () => {
    console.log(`ExampleApp/startChat`);

    if (hasChatStarted) {
      console.log(`ExampleApp/startChat/alreadyStarted`);
      return;
    }

    await chatSDK?.startChat();
    const callingToken = await chatSDK?.getCallingToken();
    console.log(callingToken);
    chatSDK?.onAgentEndSession(async () => {
      console.log(`ExampleApp/onAgentEndSession`);
      await chatSDK?.endChat();
      setHasChatStarted(false);
    });

    console.log(`ExampleApp/startChat/getChatToken`);
    const chatToken: any = await chatSDK?.getChatToken();

    voiceVideoCallingSDK?.initialize({
      chatToken,
      callingToken,
      OCClient: chatSDK?.OCClient
    });

    setHasChatStarted(true);
  }

  const onEndChatPress = async () => {
    console.log(`ExampleApp/endChat`);

    if (!hasChatStarted) {
      return;
    }

    await chatSDK?.endChat();
    setHasChatStarted(false);
  }

  const onRejectCall = () => {
    if (!incomingCall) {
      return;
    }

    console.log(`ExampleApp/IncomingCall/rejectCall`);
    voiceVideoCallingSDK.rejectCall();

    setIncomingCall(false);
  }

  const onAcceptVideoCall = async () => {
    if (!incomingCall) {
      return;
    }

    console.log(`ExampleApp/IncomingCall/acceptVideoCall`);
    const withVideo = true;
    voiceVideoCallingSDK.acceptCall(withVideo);

    const isMicrophoneMuted = await voiceVideoCallingSDK.isMicrophoneMuted();
    setIsMicrophoneMuted(isMicrophoneMuted);

    console.log(`ExampleApp/IncomingCall/acceptVideoCall/isMicrophoneMuted ${isMicrophoneMuted}`);

    setIncomingCall(false);
    setInVideoCall(true);
  }

  const onAcceptVoiceCall = async () => {
    if (!incomingCall) {
      return;
    }

    console.log(`ExampleApp/IncomingCall/acceptVoiceCall`);
    voiceVideoCallingSDK.acceptCall();

    const isMicrophoneMuted = await voiceVideoCallingSDK.isMicrophoneMuted();
    setIsMicrophoneMuted(isMicrophoneMuted);

    console.log(`ExampleApp/IncomingCall/acceptVoiceCall/isMicrophoneMuted ${isMicrophoneMuted}`);

    setIncomingCall(false);
    setInVoiceCall(true);
  }

  const onToggleVideo = () => {
    console.log(`ExampleApp/onToggleVideo`);
    voiceVideoCallingSDK.toggleLocalVideo();
  }

  const onToggleMute = async () => {
    console.log(`ExampleApp/onToggleMute`);

    const isMicrophoneMuted = await voiceVideoCallingSDK.toggleMute();
    console.log(`Toggle mute completed`)
    setIsMicrophoneMuted(isMicrophoneMuted);

    console.log(`ExampleApp/onToggleMute/isMicrophoneMuted ${isMicrophoneMuted}`);
  }

  const onStopCall = () => {
    console.log(`ExampleApp/onStopCall`);
    voiceVideoCallingSDK.stopCall();
    setInVideoCall(false);
    setInVoiceCall(false);
  }

  const onToggleSpeaker = () => {
    console.log(`ExampleApp/onToggleSpeaker`);
    voiceVideoCallingSDK.toggleSpeaker();
    setIsUsingSpeaker(!isUsingSpeaker);
  }

  const onToggleCamera = () => {
    console.log(`ExampleApp/onToggleCamera`);
    voiceVideoCallingSDK.toggleCamera();
  }

  return (
      <View style={styles.container}>
      {incomingCall && <IncomingCall onRejectCall={onRejectCall} onAcceptVideoCall={onAcceptVideoCall} onAcceptVoiceCall={onAcceptVoiceCall} />}
      <View style={inVideoCall? styles.videoContainer: styles.noDisplay}>
        <RemoteVideoView style={styles.remoteVideo} />
        <LocalVideoView crop style={styles.localVideo} />
      </View>
      {(inVoiceCall || inVideoCall) && <CurrentCallMenu
        isLocalVideoEnabled={isLocalVideoEnabled} isMicrophoneMuted={isMicrophoneMuted} isUsingSpeaker={isUsingSpeaker}
        onToggleVideo={onToggleVideo} onToggleMute={onToggleMute} onStopCall={onStopCall} onToggleSpeaker={onToggleSpeaker} onToggleCamera={onToggleCamera} />
      }

      <View style={styles.textBoxContainer}>
        <ScrollView>
          <TextInput
            style={styles.input}
            onChangeText={onChangeWidgetId}
            value={widgetId}
            placeholder="Widget/App Id"
          />
          <TextInput
            style={styles.input}
            onChangeText={onChangeOrganizationId}
            value={organizationId}
            placeholder="Organization Id"
          />
          <TextInput
            style={styles.input}
            onChangeText={onChangeOrganizationURL}
            value={organizationURL}
            placeholder="Organization Url"
          />
          <TouchableHighlight style={styles.touchableHighlight}>
          <Button title="Load Widget" onPress={onLoadChatWidget}/>
        </TouchableHighlight>
        </ScrollView>
      </View>
      <View style={styles.buttonContainer}>
        <TouchableHighlight style={styles.touchableHighlight}>
          <Button title="Start Chat" onPress={onStartChatPress} disabled={!isReady || hasChatStarted}/>
        </TouchableHighlight>
        <TouchableHighlight style={styles.touchableHighlight}>
          <Button title="End Chat" onPress={onEndChatPress} disabled={!hasChatStarted}/>
        </TouchableHighlight>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
  },
  textBoxContainer: {
    flexDirection:'row',
    flexWrap:'wrap',
    display: 'flex',
    justifyContent: 'center',
    margin: 5,
    ...Platform.select({
      ios: {
        marginTop: 80
      }
    })
  },
  buttonContainer: {
    flexDirection:'row',
    flexWrap:'wrap',
  },
  touchableHighlight: {
    margin: 3
  },
  videoContainer: {
    position: 'relative',
    width: '100%',
    height: '40%',
    backgroundColor: 'rgb(25, 25, 25)'
  },
  noDisplay: {
    display: 'none',
    height: 0,
    width: 0
  },
  localVideo: {
    position: 'absolute',
    width: '45%',
    height: '50%',
    right: 0,
    bottom: 0,
    backgroundColor: '#258a23',
    elevation: 1
  },
  remoteVideo: {
    width: '100%',
    height: '100%',
    backgroundColor: '#258a23',
  },
  input: {
    height: '15%',
    margin: 12,
    borderWidth: 1,
    padding: 10,
  },
});