package com.omnichannelvoicevideocallingreactnative

import android.Manifest
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import java.util.ArrayList

class OmnichannelVoiceVideoCallingReactNativeModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "OmnichannelVoiceVideoCallingReactNative"
    }

    @ReactMethod
    fun askPermissions() {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/AskPermissions", "");

      val requiredPermissions = arrayOf<String>(Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_PHONE_STATE)
      val permissionsToAskFor = ArrayList<String>()
      for (permission in requiredPermissions) {
        if (ActivityCompat.checkSelfPermission(reactContext, permission!!) != PackageManager.PERMISSION_GRANTED) {
          permissionsToAskFor.add(permission!!)
        }
      }
      if (permissionsToAskFor.isNotEmpty()) {
        ActivityCompat.requestPermissions(reactContext.currentActivity!!, permissionsToAskFor.toTypedArray(), 1)
      }
    }

    @ReactMethod
    fun initialize(chatToken: String, requestId: String) {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/initialize", "Chat Token $chatToken");
      VoiceVideoCalling.getInstance().initialize(reactContext, chatToken, requestId);
    }

    @ReactMethod
    fun isMicrophoneMuted(promise: Promise) {
      promise.resolve(VoiceVideoCalling.getInstance().isMicrophoneMuted(reactContext));
    }

    @ReactMethod
    fun isRemoteVideoEnabled(promise: Promise) {
      promise.resolve(VoiceVideoCalling.getInstance().isRemoteVideoEnabled(reactContext));
    }

    @ReactMethod
    fun isLocalVideoEnabled(promise: Promise) {
      promise.resolve(VoiceVideoCalling.getInstance().isLocalVideoEnabled(reactContext));
    }

    @ReactMethod
    fun acceptCall(withVideo: Boolean) {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/acceptCall", "withVideo $withVideo");
      VoiceVideoCalling.getInstance().acceptCall(reactContext, withVideo);
    }

    @ReactMethod
    fun rejectCall() {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/rejectCall", "");
      VoiceVideoCalling.getInstance().rejectCall(reactContext);
    }

    @ReactMethod
    fun stopCall() {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/stopCall", "");
      VoiceVideoCalling.getInstance().stopCall(reactContext);
    }

    @ReactMethod
    fun toggleMute(promise: Promise) {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/toggleMute", "");
      promise.resolve(VoiceVideoCalling.getInstance().toggleMute(reactContext));
    }

    @ReactMethod
    fun toggleLocalVideo() {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/toggleLocalVideo", "");
      VoiceVideoCalling.getInstance().toggleLocalVideo(reactContext);
    }

    @ReactMethod
    fun toggleSpeaker() {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/toggleSpeaker", "");
      VoiceVideoCalling.getInstance().toggleSpeaker(reactContext);
    }

    @ReactMethod
    fun toggleCamera() {
      Log.i("Native/OmnichannelVoiceVideoCallingReactNativeModule/toggleCamera", "");
      VoiceVideoCalling.getInstance().toggleCamera(reactContext);
    }
}
