package com.omnichannelvoicevideocallingreactnative

import android.view.View
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class RemoteVideoViewManager : SimpleViewManager<View>() {
  override fun getName() = "RemoteVideoView"

  override fun createViewInstance(reactContext: ThemedReactContext): View {
    return RemoteVideoView.getInstance().createView(reactContext);
  }

  @ReactProp(name = "crop", defaultBoolean = false)
  fun setVideoScalingModeCrop(view: View, crop: Boolean) {
    RemoteVideoView.getInstance().setVideoScalingModeCrop(crop);
  }
}
