//
//  LocalVideoViewManager.swift
//

import Foundation

@objc(LocalVideoViewManager)
class LocalVideoViewManager: RCTViewManager {

  override func view() -> UIView! {
    return LocalVideoView.getInstance()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
