import React, {useState} from 'react';
import { StyleSheet, View, TouchableHighlight, Image, Text} from 'react-native';
import video from '../assets/video-white.png';
import videoOff from '../assets/video-off-white.png';
import phoneOff from '../assets/phone-off-white.png';
import mic from '../assets/mic-white.png';
import micOff from '../assets/mic-off-white.png';
import speaker from '../assets/speaker.png';
import speakerOff from '../assets/speaker-white.png';
import flip from '../assets/flip-white.png';

interface CurrentCallMenuProps {
  isLocalVideoEnabled?: Boolean;
  isMicrophoneMuted?: Boolean;
  isUsingSpeaker?: Boolean;
  onToggleVideo?: CallableFunction;
  onToggleMute?: CallableFunction;
  onStopCall?: CallableFunction;
  onToggleSpeaker?: CallableFunction;
  onToggleCamera?: CallableFunction;
}

const CurrentCallMenu = (props: CurrentCallMenuProps) => {

  const toggleVideo = () => {
    props.onToggleVideo && props.onToggleVideo();
  }

  const toggleMute = () => {
    props.onToggleMute && props.onToggleMute();
  }

  const stopCall = () => {
    props.onStopCall && props.onStopCall();
  }

  const toggleSpeakerButton = () => {
    props.onToggleSpeaker && props.onToggleSpeaker();
  }

  const toggleCameraButton = () => {
    props.onToggleCamera && props.onToggleCamera();
  }

  return (
    <View style={styles.container}>
      <TouchableHighlight style={styles.toggleVideoButton} onPress={toggleVideo}>
        <Image source={props.isLocalVideoEnabled? video: videoOff} style={styles.image}/>
      </TouchableHighlight>
      <TouchableHighlight style={styles.toggleMuteButton} onPress={toggleMute}>
        <Image source={props.isMicrophoneMuted? micOff: mic} style={styles.image}/>
      </TouchableHighlight>
      <TouchableHighlight style={{...styles.toggleSpeakerButton, ...(props.isUsingSpeaker? {backgroundColor: 'white'}: {backgroundColor: 'rgb(60, 60, 61)'})}} onPress={toggleSpeakerButton}>
        <Image source={props.isUsingSpeaker? speaker: speakerOff} style={styles.image}/>
      </TouchableHighlight>
      <TouchableHighlight style={styles.toggleCameraButton} onPress={toggleCameraButton}>
        <Image source={flip} style={styles.image}/>
      </TouchableHighlight>
      <TouchableHighlight style={styles.stopCallButton} onPress={stopCall}>
        <Image source={phoneOff} style={styles.image}/>
      </TouchableHighlight>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    backgroundColor: 'rgb(41, 40, 40)',
    padding: 40,
  },
  image: {
    height: 24,
    width: 24
  },
  stopCallButton: {
    backgroundColor: 'red',
    padding: 10
  },
  toggleVideoButton: {
    backgroundColor: 'rgb(60, 60, 61)',
    padding: 10
  },
  toggleMuteButton: {
    backgroundColor: 'rgb(60, 60, 61)',
    padding: 10
  },
  toggleSpeakerButton: {
    padding: 10
  },
  toggleCameraButton: {
    backgroundColor: 'rgb(60, 60, 61)',
    padding: 10
  }
});

export default CurrentCallMenu;
