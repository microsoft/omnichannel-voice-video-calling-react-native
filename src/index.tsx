import React, {useState, useEffect} from 'react';
import 'react-native-gesture-handler'
import { NativeAppEventEmitter, ViewProps, requireNativeComponent, ViewStyle, StyleSheet} from 'react-native';
import createVoiceVideoCalling from './createVoiceVideoCalling';

type LocalVideoViewReactNativeProps = {
  crop?: boolean;
  style?: ViewStyle;
};

type RemoteVideoViewReactNativeProps = {
  crop?: boolean;
  style?: ViewStyle;
};

const LocalVideoViewManagerViewRaw = requireNativeComponent<LocalVideoViewReactNativeProps>(
  'LocalVideoView'
);

type LocalVideoProps = ViewProps & LocalVideoViewReactNativeProps;
type RemoteVideoProps = ViewProps & RemoteVideoViewReactNativeProps;

const RemoteVideoViewManagerViewRaw = requireNativeComponent<RemoteVideoViewReactNativeProps>(
  'RemoteVideoView'
);

export const LocalVideoView: React.FC<LocalVideoProps> = (props) => {
  const [displayLocalVideo, setDisplayLocalVideo] = useState(false);

  useEffect(() => {

    NativeAppEventEmitter.addListener('localVideoStreamAdded', () => {
      console.log('[LocalVideoView][Event][localVideoStreamAdded]');

      setDisplayLocalVideo(true);

      // Fix for local video not showing up
      setDisplayLocalVideo(false);
      setDisplayLocalVideo(true);
    });

    NativeAppEventEmitter.addListener('localVideoStreamRemoved', () => {
      console.log('[LocalVideoView][Event][localVideoStreamRemoved]');

      setDisplayLocalVideo(false);
    });

    NativeAppEventEmitter.addListener('callDisconnected', () => {
      console.log('[LocalVideoView][Event][callDisconnected]');

      setDisplayLocalVideo(false);
    });
  }, []);

    const style = displayLocalVideo? {...(props.style as object)}: {...(props.style as object), ...styles.noDisplay};
    return <LocalVideoViewManagerViewRaw style={style} />
}

export const RemoteVideoView: React.FC<RemoteVideoProps> = (props) => {
  const [displayRemoteVideo, setDisplayRemoteVideo] = useState(false);

  useEffect(() => {
    NativeAppEventEmitter.addListener('remoteVideoStreamAdded', () => {
      console.log('[RemoteVideoView][Event][remoteVideoStreamAdded]');

      setDisplayRemoteVideo(true);

      // Fix for remote video taking longer time to show up in Android
      setDisplayRemoteVideo(false);
      setDisplayRemoteVideo(true);
    });

    NativeAppEventEmitter.addListener('remoteVideoStreamRemoved', () => {
      console.log('[RemoteVideoView][Event][remoteVideoStreamRemoved]');

      setDisplayRemoteVideo(false);
    });

    NativeAppEventEmitter.addListener('callDisconnected', () => {
      console.log('[RemoteVideoView][Event][callDisconnected]');

      setDisplayRemoteVideo(false);
    });
  }, []);

  const style = displayRemoteVideo? {...(props.style as object)}: {...(props.style as object), ...styles.noDisplay};
  return <RemoteVideoViewManagerViewRaw {...props} style={style} />
}

const styles = StyleSheet.create({
  noDisplay: {
    display: 'none',
    height: 0,
    width: 0
  }
});

export default createVoiceVideoCalling;
