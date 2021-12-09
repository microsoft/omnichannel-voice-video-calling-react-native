//
//  LocalVideoView.swift
//  @microsoft/omnichannel-voice-video-calling-react-native
//

import Foundation
import AzureCommunicationCalling

class LocalVideoView: UIView {

    private static var localVideoViewInstance : LocalVideoView!
    private var videoStreamRenderer: VideoStreamRenderer?
    private var rendererView: RendererView?

    static func getInstance() -> LocalVideoView {
        if (self.localVideoViewInstance == nil){
            self.localVideoViewInstance = LocalVideoView()
        }

      return self.localVideoViewInstance
    }

    public func renderLocalVideo(localVideoStream: [LocalVideoStream]?) throws {
        self.videoStreamRenderer = try VideoStreamRenderer(localVideoStream: localVideoStream!.first!)
        try self.updateLocalVideoView()
    }

    public func disposeLocalVideoStream(){
        if(rendererView == nil) {
            return
        }

        DispatchQueue.main.async { () -> Void in
            self.videoStreamRenderer?.dispose()
        }

        rendererView = nil
    }

    private func updateLocalVideoView() throws {
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
