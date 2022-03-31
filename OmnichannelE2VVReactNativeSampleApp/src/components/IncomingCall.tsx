import React from 'react';
import { StyleSheet, View, TouchableHighlight, Image, Text} from 'react-native';
import phone from '../assets/phone-white.png';
import video from '../assets/video-white.png';
import phoneOff from '../assets/phone-off-white.png';

interface IncomingCallProps {
  onRejectCall: CallableFunction;
  onAcceptVideoCall: CallableFunction;
  onAcceptVoiceCall: CallableFunction;
}

const IncomingCall = (props: IncomingCallProps) => {
  return (
    <View style={styles.container}>
      <Text style={styles.containerTitle}> Incoming Call </Text>
      <View style={styles.buttonContainer}>
        <TouchableHighlight style={styles.rejectCallButton} onPress={props.onRejectCall}>
          <Image source={phoneOff}/>
        </TouchableHighlight>
        <TouchableHighlight style={styles.acceptVideoCallButton} onPress={props.onAcceptVideoCall}>
          <Image source={video}/>
        </TouchableHighlight>
        <TouchableHighlight style={styles.acceptVoiceCallButton} onPress={props.onAcceptVoiceCall}>
          <Image source={phone}/>
        </TouchableHighlight>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    backgroundColor: 'rgb(41, 40, 40)',
    padding: 40
  },
  containerTitle: {
    color: 'white',
    fontSize: 18,
    paddingLeft: 15,
  },
  buttonContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  rejectCallButton: {
    margin: 5,
    padding: 10,
    borderRadius: 25,
    backgroundColor: 'rgb(240, 73, 27)'
  },
  acceptVideoCallButton: {
    margin: 5,
    padding: 10,
    borderRadius: 25,
    backgroundColor: 'rgb(0, 128, 0)'
  },
  acceptVoiceCallButton: {
    margin: 5,
    padding: 10,
    borderRadius: 25,
    backgroundColor: 'rgb(0, 128, 0)'
  }
});

export default IncomingCall;
