package com.omnichannelvoicevideocallingreactnative

import android.view.View
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class LocalVideoViewManager : SimpleViewManager<View>() {
  override fun getName() = "LocalVideoView"

  override fun createViewInstance(reactContext: ThemedReactContext): View {
    return LocalVideoView.getInstance().createView(reactContext);
  }

  @ReactProp(name = "crop", defaultBoolean = false)
  fun setVideoScalingModeCrop(view: View, crop: Boolean) {
    LocalVideoView.getInstance().setVideoScalingModeCrop(crop);
  }
}
