//
//  RemoteVideoView.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//

import Foundation
import AzureCommunicationCalling

class RemoteVideoView: UIView {

    private static var remoteVideoViewInstance : RemoteVideoView!
    private var videoStreamRenderer: VideoStreamRenderer?
    public var rendererView: RendererView?

    static func getInstance() -> RemoteVideoView {
        if (self.remoteVideoViewInstance == nil){
            self.remoteVideoViewInstance = RemoteVideoView()
        }

      return self.remoteVideoViewInstance
    }

    public func renderRemoteVideo(remoteVideoStream: RemoteVideoStream?) throws {
        self.videoStreamRenderer = try VideoStreamRenderer(remoteVideoStream: remoteVideoStream!)
        try self.updateRemoteVideoView()
    }

    public func disposeRemoteVideoStream() {
        if(rendererView == nil) {
            return
        }

        DispatchQueue.main.async { () -> Void in
            self.videoStreamRenderer?.dispose()
        }
        rendererView = nil
    }

    private func updateRemoteVideoView() throws {
        self.rendererView = try self.videoStreamRenderer!.createView()
        self.attachRendererView(rendererView: self.rendererView!)
    }

    private func attachRendererView(rendererView: RendererView) {
        rendererView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(rendererView)

        let constraints = [
            rendererView.topAnchor.constraint(equalTo: self.topAnchor),
            rendererView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rendererView.leftAnchor.constraint(equalTo: self.leftAnchor),
            rendererView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
