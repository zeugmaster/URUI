//
//  URUIVideoView.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import UIKit
import AVFoundation
import Dispatch

/// A UIKit view that shows video preview, intended to be wrapped by `URVideo`.
public class URUIVideoView: UIView {
    private let videoSession: VideoSession

    init(codesPublisher: CodesPublisher) {
        videoSession = VideoSession(codesPublisher: codesPublisher)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        guard let previewLayer = videoSession.previewLayer else { return }
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        syncVideoSizeAndOrientation()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            videoSession.stopRunning()
        } else {
            DispatchQueue.main.async {
                self.videoSession.startRunning()
            }
        }
    }

    private func syncVideoSizeAndOrientation() {
        guard let previewLayer = videoSession.previewLayer else { return }
        previewLayer.frame = bounds
        if let connection = videoSession.captureSession?.connections.last, connection.isVideoOrientationSupported {
            let orientation = UIApplication.shared.windows.first!.windowScene!.interfaceOrientation
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        }
    }
}
