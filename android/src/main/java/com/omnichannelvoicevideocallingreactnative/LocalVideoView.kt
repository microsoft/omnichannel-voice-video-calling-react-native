package com.omnichannelvoicevideocallingreactnative

import android.util.Log
import android.view.View
import android.widget.LinearLayout
import com.azure.android.communication.calling.ScalingMode
import com.facebook.react.uimanager.ThemedReactContext

class LocalVideoView {
  private lateinit var view: View;
  private var isViewCreated: Boolean = false;
  private var scalingMode: ScalingMode = ScalingMode.FIT;

  companion object {
    private var instance: LocalVideoView? = null;

    fun getInstance(): LocalVideoView {
      if (this.instance == null) {
        this.instance = LocalVideoView();
      }
      return this.instance!!;
    }
  }

  private constructor() {

  }

  public fun createView(reactContext: ThemedReactContext): View {
    if (!this.isViewCreated) {
      Log.i("Native/LocalVideoView/createView", "");
      val linearLayout = LinearLayout(reactContext);
      linearLayout.layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
      this.view = linearLayout;
      this.isViewCreated = true;
    }
    return this.view;
  }

  public fun getView() : View {
    return this.view;
  }

  public fun getScalingMode(): ScalingMode {
    return this.scalingMode;
  }

  public fun setVideoScalingModeCrop(crop: Boolean) {
    Log.i("Native/LocalVideoView/setVideoScalingModeCrop", "$crop");
    this.scalingMode = if (crop) ScalingMode.CROP else ScalingMode.FIT;
  }
}
