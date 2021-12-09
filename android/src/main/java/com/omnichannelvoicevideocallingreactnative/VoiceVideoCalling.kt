package com.omnichannelvoicevideocallingreactnative

import android.content.Context
import android.media.AudioManager
import android.util.Log
import android.widget.LinearLayout
import com.azure.android.communication.calling.*
import com.azure.android.communication.calling.BuildConfig
import com.azure.android.communication.common.CommunicationTokenCredential
import com.facebook.react.bridge.*
import com.facebook.react.bridge.UiThreadUtil.runOnUiThread

class VoiceVideoCalling {
  private var callClient: CallClient? = null;
  private var callAgent: CallAgent? = null;
  private var deviceManager: DeviceManager? = null;
  private var isInitialized: Boolean = false;
  private var incomingCall: IncomingCall? = null;
  private var call: Call? = null;
  private var localVideoStream: LocalVideoStream? = null;
  private var frontCameraDeviceInfo: VideoDeviceInfo? = null;
  private var backCameraDeviceInfo: VideoDeviceInfo? = null;
  private var localVideoStreamRenderer: VideoStreamRenderer? = null;
  private var remoteVideoStreamRenderer: VideoStreamRenderer? = null;
  private var requestId: String? = ""

  companion object {
    private var instance: VoiceVideoCalling? = null;
    fun getInstance(): VoiceVideoCalling {
      if (this.instance == null) {
        this.instance = VoiceVideoCalling();
      }
      return this.instance!!;
    }
  }

  fun initialize(reactContext: ReactApplicationContext, callingToken: String, requestId: String) {
    Log.i("Native/VoiceVideoCalling/initialize", "ACS Initialization started");
    this.requestId = requestId

    EventEmitter.emit(reactContext, Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.InitializeNativeSDKEvent, "ScenarioStarted")
    );

    var communicationUser: CommunicationTokenCredential? = null;

    try {
      communicationUser = CommunicationTokenCredential(callingToken);
      Log.i("Native/VoiceVideoCalling/initialize", "Created CommunicationTokenCredential");
    } catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/Initialize", "Failed to create CommunicationUserCredential: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.InitializeNativeSDKEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to create CommunicationUserCredential: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
      return
    }

    try {
      this.callClient = CallClient();
      this.callAgent = this.callClient?.createCallAgent(reactContext, communicationUser)?.get();
      this.addListeners(reactContext);
      Log.i("Native/VoiceVideoCalling/CreateCallAgent", "Created CallAgent");
    } catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/CreateCallAgent", "Failed to create CallAgent: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.InitializeNativeSDKEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to create CallAgent: $e)")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
      return
    }

    try {
      this.deviceManager = this.callClient?.getDeviceManager(reactContext)?.get()
      Log.i("Native/VoiceVideoCalling/DeviceManager", "Successfully got DeviceManager");

      // Find default devices
      for (camera in this.deviceManager!!.cameras) {
        Log.i("Native/VoiceVideoCalling/DeviceManager/camera", "Camera '${camera.name}' facing '${camera.cameraFacing}'");
        if (camera.cameraFacing === CameraFacing.FRONT) {
          this.frontCameraDeviceInfo = camera;
        }

        if (camera.cameraFacing === CameraFacing.BACK) {
          this.backCameraDeviceInfo = camera;
        }
      }
    } catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/DeviceManager", "Failed to get DeviceManager: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.InitializeNativeSDKEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to get DeviceManager: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
      return
    }

    EventEmitter.emit(reactContext, Event.telemetry, this.getTelemetryContextMap(TelemetryConstants.InitializeNativeSDKEvent,"ScenarioCompleted"));
    this.isInitialized = true;
  }

  fun isMicrophoneMuted(reactContext: ReactApplicationContext): Boolean {
    EventEmitter.emit(reactContext, Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.IsMicrophoneMutedEvent, "ScenarioStarted")
    );

    if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.IsMicrophoneMutedEvent)) {
      return false;
    }

    Log.i("Native/VoiceVideoCalling/isMicrophoneMuted", "${this.call!!.isMuted}");
    EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.IsMicrophoneMutedEvent, "ScenarioCompleted"))
    return this.call!!.isMuted;
  }

  fun isRemoteVideoEnabled(reactContext: ReactApplicationContext): Boolean {
    EventEmitter.emit(reactContext, Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.IsRemoteVideoEnabled, "ScenarioStarted")
    );

    if (!this.isInitialized) {
      Log.i("Native/VoiceVideoCalling/isRemoteVideoEnabled", "Calling SDK not initialized");
      val logContext = getTelemetryContextMap(TelemetryConstants.IsRemoteVideoEnabled, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Calling SDK not initialized")
      EventEmitter.emit(reactContext, Event.telemetry, logContext)
      return false;
    }

    Log.i("Native/VoiceVideoCalling/isRemoteVideoEnabled", "${this.remoteVideoStreamRenderer != null}");
    EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.IsRemoteVideoEnabled, "ScenarioCompleted"))
    return this.remoteVideoStreamRenderer != null;
  }

  fun isLocalVideoEnabled(reactContext: ReactApplicationContext): Boolean {
    EventEmitter.emit(reactContext, Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.IsLocalVideoEnabled, "ScenarioStarted")
    );

    if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.IsLocalVideoEnabled)) {
      return false;
    }

    Log.i("Native/VoiceVideoCalling/isLocalVideoEnabled", "${this.call != null && this.call?.localVideoStreams?.size!! > 0}");
    EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.IsLocalVideoEnabled, "ScenarioCompleted"))
    return this.call?.localVideoStreams?.size!! > 0;
  }

  fun acceptCall(reactContext: ReactApplicationContext, withVideo: Boolean) {
    Log.i("Native/VoiceVideoCalling/acceptCall", "withVideo $withVideo");
    EventEmitter.emit(reactContext, Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.AcceptCallEvent, "ScenarioStarted")
    );

    if (!this.isInitialized) {
      Log.i("Native/VoiceVideoCalling/AcceptCallEvent", "SDK not initialized");
      val logContext = getTelemetryContextMap(TelemetryConstants.AcceptCallEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Calling SDK not initialized")
      EventEmitter.emit(reactContext, Event.telemetry, logContext)
      return;
    }

    try {
      val options = AcceptCallOptions();
      if (withVideo) {
        val camera = this.deviceManager?.cameras?.get(0);
        this.localVideoStream = LocalVideoStream(camera, reactContext);
        val videoOptions = VideoOptions(arrayOf(this.localVideoStream));
        options.videoOptions = videoOptions;
      }

      this.call = this.incomingCall!!.accept(reactContext, options).get();
      val logContext = WritableNativeMap()
      // send this with event to add secondary channel event request
      logContext.putBoolean("withVideo", withVideo)
      EventEmitter.emit(reactContext, Event.callAccepted, logContext)
      val remoteParticipants = this.call!!.remoteParticipants

      for (remoteParticipant in remoteParticipants) {
        for (remoteStream in remoteParticipant.videoStreams) {
          if (remoteStream.isAvailable) {
            // Renders C1 stream
            runOnUiThread {
              val renderer = VideoStreamRenderer(remoteStream, reactContext);
              this.remoteVideoStreamRenderer = renderer;
              val view = remoteVideoStreamRenderer!!.createView(CreateViewOptions(RemoteVideoView.getInstance().getScalingMode()));
              (RemoteVideoView.getInstance().getView() as LinearLayout).addView(view);

              Log.i("Native/VoiceVideoCalling/Event", "Sending remoteVideoStreamAdded");
              EventEmitter.emit(reactContext, Event.remoteVideoStreamAdded);
            }
          }
        }

        remoteParticipant.addOnVideoStreamsUpdatedListener { remoteVideoStreamsEvent ->
          val addedRemoteVideoStreams = remoteVideoStreamsEvent.addedRemoteVideoStreams;
          val removedRemoteVideoStreams = remoteVideoStreamsEvent.removedRemoteVideoStreams;
          for (remoteVideoStream in addedRemoteVideoStreams) {
            Log.i("Native/VoiceVideoCalling/addOnRemoteParticipantsUpdatedListener/addedRemoteVideoStream/available", "${remoteVideoStream.isAvailable}");
            if (remoteVideoStream.isAvailable) {
              // Renders C1 stream
              runOnUiThread {
                val renderer = VideoStreamRenderer(remoteVideoStream, reactContext);
                this.remoteVideoStreamRenderer = renderer;
                val view = remoteVideoStreamRenderer!!.createView(CreateViewOptions(RemoteVideoView.getInstance().getScalingMode()));
                (RemoteVideoView.getInstance().getView() as LinearLayout).addView(view);

                Log.i("Native/VoiceVideoCalling/Event", "Sending remoteVideoStreamAdded");
                EventEmitter.emit(reactContext, Event.remoteVideoStreamAdded);
              }
            }
          }

          for (remoteVideoStream in removedRemoteVideoStreams) {
            if (!remoteVideoStream.isAvailable) {
              (RemoteVideoView.getInstance().getView() as LinearLayout).removeAllViews();
              Log.i("Native/VoiceVideoCalling/Event", "Sending remoteVideoStreamRemoved");
              EventEmitter.emit(reactContext, Event.remoteVideoStreamRemoved);

              this.remoteVideoStreamRenderer = null;
            }
          }
        }
      }

      if (withVideo) {
        runOnUiThread {
          val renderer = VideoStreamRenderer(this.localVideoStream, reactContext);
          this.localVideoStreamRenderer = renderer;
          val view: VideoStreamRendererView = renderer.createView(CreateViewOptions(LocalVideoView.getInstance().getScalingMode()));
          (LocalVideoView.getInstance().getView() as LinearLayout).addView(view);
          this.call!!.stopVideo(reactContext,this.localVideoStream);
          this.call!!.startVideo(reactContext, this.localVideoStream);
          Log.i("Native/VoiceVideoCalling/Event", "Sending localVideoStreamAdded");
          EventEmitter.emit(reactContext, Event.localVideoStreamAdded);
        }
      }

      EventEmitter.emit(
        reactContext,
        Event.telemetry,
        getTelemetryContextMap(TelemetryConstants.AcceptCallEvent, "ScenarioCompleted")
      );
    }
    catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/acceptCall", "Failed to accept call: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.AcceptCallEvent, "\"ScenarioFailed\"")
      logContext.putString("ExceptionDetails", "Failed to accept call: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
    }
  }

  fun rejectCall(reactContext: ReactApplicationContext) {
    Log.i("Native/VoiceVideoCalling/rejectCall", "Reject Call");

    EventEmitter.emit(
      reactContext,
      Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.RejectCallEvent, "ScenarioStarted")
    );

    if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.RejectCallEvent)) {
      return;
    }

    try {
      this.incomingCall!!.reject().get();
      EventEmitter.emit(reactContext, Event.callRejected)
      this.incomingCall = null;
      EventEmitter.emit(
        reactContext,
        Event.telemetry,
        getTelemetryContextMap(TelemetryConstants.RejectCallEvent, "ScenarioCompleted")
      );
    }
    catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/rejectCall", "Failed to toggle mute: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.RejectCallEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to reject call: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
    }
  }

  fun stopCall(reactContext: ReactApplicationContext) {
    Log.i("Native/VoiceVideoCalling/stopCall", "Stop Call");
    EventEmitter.emit(
      reactContext,
      Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.StopCallEvent, "ScenarioStarted")
    );

    if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.StopCallEvent)) {
      return;
    }

    try {
      this.localVideoStreamRenderer?.dispose();
      this.remoteVideoStreamRenderer?.dispose();
      val hangUpOptions = HangUpOptions();
      hangUpOptions.isForEveryone = true;
      this.call!!.hangUp(hangUpOptions);
      this.call = null;
      this.localVideoStream = null;
      this.localVideoStreamRenderer = null;
      this.remoteVideoStreamRenderer = null;
      EventEmitter.emit(
        reactContext,
        Event.telemetry,
        getTelemetryContextMap(TelemetryConstants.StopCallEvent, "ScenarioCompleted")
      );
    }
    catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/rejectCall", "Failed to end call: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.StopCallEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to reject call: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
    }
  }

  fun toggleMute(reactContext: ReactApplicationContext): Boolean {
    Log.i("Native/VoiceVideoCalling/toggleMute", "Toggle Mute");
    EventEmitter.emit(
      reactContext,
      Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.ToggleMuteEvent, "ScenarioStarted")
    );

    if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.ToggleMuteEvent)) {
      return false;
    }

    try {
      if (this.call!!.isMuted) {
        this.call!!.unmute(reactContext).get()
      } else {
        this.call!!.mute(reactContext).get()
      }
    } catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/toggleMute", "Failed to toggle mute: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.ToggleMuteEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to toggle mute: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
      return false;
    }

    EventEmitter.emit(
      reactContext,
      Event.telemetry,
      getTelemetryContextMap(TelemetryConstants.ToggleMuteEvent, "ScenarioCompleted")
    );

    return this.call!!.isMuted
  }

  fun toggleLocalVideo(reactContext: ReactApplicationContext) {
    Log.i("Native/VoiceVideoCalling/toggleLocalVideo", "Toggle Local Video");
    EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleLocalVideoEvent, "ScenarioStarted"));
    if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.ToggleLocalVideoEvent)) {
      return;
    }

    try {
      if (this.isLocalVideoEnabled(reactContext)) {
        this.call!!.stopVideo(reactContext, this.localVideoStream);
        Log.i("Native/VoiceVideoCalling/Event", "Sending localVideoStreamRemoved");
        EventEmitter.emit(reactContext, Event.localVideoStreamRemoved);
        EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleLocalVideoEvent, "ScenarioCompleted"));
      }
      else {
        if(this.localVideoStream == null) {
          val camera = this.deviceManager?.cameras?.get(0);
          this.localVideoStream = LocalVideoStream(camera, reactContext);
          runOnUiThread {
            val renderer = VideoStreamRenderer(this.localVideoStream, reactContext);
            this.localVideoStreamRenderer = renderer;

            val view: VideoStreamRendererView =
              renderer.createView(CreateViewOptions(LocalVideoView.getInstance().getScalingMode()));
            (LocalVideoView.getInstance().getView() as LinearLayout).addView(view);
          }
        }

        this.call!!.startVideo(reactContext, this.localVideoStream);
        Log.i("Native/VoiceVideoCalling/Event", "Sending localVideoStreamAdded");
        EventEmitter.emit(reactContext, Event.localVideoStreamAdded);
        EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleLocalVideoEvent, "ScenarioCompleted"));
      }
    }
    catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/toggleLocalVideo", "Failed to toggle local video: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.ToggleLocalVideoEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to toggle local video: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
    }
  }

  fun toggleSpeaker(reactContext: ReactApplicationContext) {
    Log.i("Native/VoiceVideoCalling/toggleSpeaker", "Toggle Speaker");
    EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleSpeakerEvent, "ScenarioStarted"));
    try {
      if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.ToggleSpeakerEvent)) {
        return;
      }

      val audioManager: AudioManager = reactContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager
      audioManager.isSpeakerphoneOn = !audioManager.isSpeakerphoneOn
      EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleSpeakerEvent, "ScenarioCompleted"));
    }
    catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/toggleSpeaker", "Failed to toggle speaker: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.ToggleSpeakerEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed to toggle speaker: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
    }
  }

  fun toggleCamera(reactContext: ReactApplicationContext) {
    Log.i("Native/VoiceVideoCalling/toggleCamera", "Toggle Camera")
    EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleCameraEvent, "ScenarioStarted"));
    try {
      if(!isSDKAndCallInitialized(reactContext, TelemetryConstants.ToggleCameraEvent)) {
        return;
      }

      if (this.localVideoStream!!.source.cameraFacing === CameraFacing.FRONT) {
        this.localVideoStream!!.switchSource(this.backCameraDeviceInfo);
      } else {
        this.localVideoStream!!.switchSource(this.frontCameraDeviceInfo);
      }

      EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.ToggleCameraEvent, "ScenarioCompleted"));
    }
    catch (e: Exception) {
      Log.i("Native/VoiceVideoCalling/toggleCamera", "Failed to toggle camera: $e");
      val logContext = getTelemetryContextMap(TelemetryConstants.ToggleCameraEvent, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Failed on toggle camera: $e")
      EventEmitter.emit(reactContext, Event.telemetry, logContext);
    }
  }

  private fun addListeners(reactContext: ReactApplicationContext) {
    Log.i("Native/VoiceVideoCalling/addListeners", "Adding event listeners on Native Started");
    this.callAgent?.addOnIncomingCallListener { incomingCall ->
      Log.i("Native/VoiceVideoCalling/CallAgent/addOnIncomingCallListener", "${incomingCall.callerInfo}");
      EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnIncomingCallListenerEvent, "ScenarioStarted"));
      EventEmitter.emit(reactContext, Event.callAdded);
      this.incomingCall = incomingCall;
      this.incomingCall?.addOnCallEndedListener{ _ ->
        Log.i("Native/VoiceVideoCalling/CallAgent/addOnCallEndedListener", "Call ended event listener");
        EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnCallEndedListenerEvent, "ScenarioStarted"));
        EventEmitter.emit(reactContext, Event.callEnded);
        this.incomingCall = null;
        EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnCallEndedListenerEvent, "ScenarioCompleted"));
      }
      EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnIncomingCallListenerEvent, "ScenarioCompleted"));
    }

    this.callAgent?.addOnCallsUpdatedListener { callsUpdatedEvent ->
      Log.i("Native/VoiceVideoCalling/CallAgent/addOnCallsUpdatedListener", "Calls update listener started");
      EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnCallsUpdatedListenerEvent, "ScenarioStarted"));
      try {
        val calls = callsUpdatedEvent.addedCalls;
        Log.i("Native/VoiceVideoCalling/addOnCallsUpdatedListener", "Calls size ${calls.size}");
        if (calls.size == 0) {
          Log.i("Native/VoiceVideoCalling/Event", "Sending callDisconnected");
          EventEmitter.emit(reactContext, Event.callDisconnected);
          Log.i("Native/VoiceVideoCalling/localViewStreamRenderer/dispose", "");
          this.localVideoStreamRenderer?.dispose();
          Log.i("Native/VoiceVideoCalling/remoteVideoStreamRenderer/dispose", "");
          this.remoteVideoStreamRenderer?.dispose();
          this.call = null;
          this.localVideoStream = null;
          this.localVideoStreamRenderer = null;
          this.remoteVideoStreamRenderer = null;
        }

        for (call in calls) {
          call.addOnStateChangedListener { _ ->
            Log.i("Native/VoiceVideoCalling/CallAgent/addOnStateChangedListener", call.state.name);
            EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnStateChangedListenerEvent, "ScenarioStarted"));
            try {
              if (call.state.name == CallState.DISCONNECTED.toString()) {
                Log.i("Native/VoiceVideoCalling/Event", "Sending callDisconnected");
                EventEmitter.emit(reactContext, Event.callDisconnected);

                Log.i("Native/VoiceVideoCalling/localViewStreamRenderer/dispose", "");
                this.localVideoStreamRenderer?.dispose();

                Log.i("Native/VoiceVideoCalling/remoteVideoStreamRenderer/dispose", "");
                this.remoteVideoStreamRenderer?.dispose();

                this.call = null;
                this.localVideoStream = null;
                this.localVideoStreamRenderer = null;
                this.remoteVideoStreamRenderer = null;
                EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnStateChangedListenerEvent, "ScenarioCompleted"));
              }
            } catch (e: Exception) {
              Log.i("Native/VoiceVideoCalling/addOnStateChangedListener", "Failed on state change listener: $e");
              val logContext = getTelemetryContextMap(TelemetryConstants.OnStateChangedListenerEvent, "ScenarioFailed")
              logContext.putString("ExceptionDetails", "Failed on state change listener: $e")
              EventEmitter.emit(reactContext, Event.telemetry, logContext);
            }
          }
        }

        EventEmitter.emit(reactContext, Event.telemetry, getTelemetryContextMap(TelemetryConstants.OnCallsUpdatedListenerEvent, "ScenarioCompleted"));
      } catch (e: Exception) {
        Log.i("Native/VoiceVideoCalling/addOnCallsUpdatedListener", "Failed on update call listener: $e");
        val logContext = getTelemetryContextMap(TelemetryConstants.OnCallsUpdatedListenerEvent, "ScenarioFailed")
        logContext.putString("ExceptionDetails", "Failed on update call listener: $e")
        EventEmitter.emit(reactContext, Event.telemetry, logContext);
      }
    }
  }

  private fun getTelemetryContextMap(eventName: String, telemetryType: String): WritableNativeMap {
    val logContext = WritableNativeMap();
    logContext.putString("EventName", eventName)
    logContext.putString("RequestId", this.requestId)
    logContext.putString("Platform", TelemetryConstants.Platform)
    logContext.putString("ACSCallingVersion", BuildConfig.VERSION_NAME)
    logContext.putString("ScenarioType", telemetryType)
    return logContext
  }

  private fun isSDKAndCallInitialized(reactContext: ReactApplicationContext, eventName: String): Boolean {
    if (!this.isInitialized) {
      Log.i("Native/VoiceVideoCalling/$eventName", "SDK not initialized");
      val logContext = getTelemetryContextMap(eventName, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Calling SDK not initialized")
      EventEmitter.emit(reactContext, Event.telemetry, logContext)
      return false;
    }

    if (this.call == null) {
      Log.i("Native/VoiceVideoCalling/$eventName", "Call Object is not initialized");
      val logContext = getTelemetryContextMap(eventName, "ScenarioFailed")
      logContext.putString("ExceptionDetails", "Call object is not initialized")
      EventEmitter.emit(reactContext, Event.telemetry, logContext)
      return false;
    }

    return true;
  }
}
