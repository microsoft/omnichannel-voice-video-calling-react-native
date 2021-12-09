package com.omnichannelvoicevideocallingreactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule

class EventEmitter {
  companion object {
    fun emit(reactContext: ReactApplicationContext, event: Event, data: WritableMap = Arguments.createMap()) {
      reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java).emit(event.toString(), data);
    }
  }
}
