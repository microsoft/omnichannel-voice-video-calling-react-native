//
//  RemoteVideoViewManager.swift
//

import Foundation

@objc(RemoteVideoViewManager)
class RemoteVideoViewManager: RCTViewManager {

  override func view() -> UIView! {
    return RemoteVideoView.getInstance()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}