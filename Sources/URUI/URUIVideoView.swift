//
//  URUIVideoView.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import UIKit
import AVFoundation
import Dispatch
import Combine

/// A UIKit view that shows video preview, intended to be wrapped by `URVideo`.
public class URUIVideoView: UIView {
    let videoSession: URVideoSession

    init(videoSession: URVideoSession) {
        self.videoSession = videoSession
        super.init(frame: .zero)
        guard videoSession.isSupported else {
            return
        }
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
        guard videoSession.isSupported else {
            return
        }
        if superview == nil {
            videoSession.stopRunning()
        } else {
            DispatchQueue.main.async {
                self.videoSession.startRunning()
            }
        }
    }

    private func syncVideoSizeAndOrientation() {
        guard
            videoSession.isSupported,
            let previewLayer = videoSession.previewLayer
        else {
            return
        }
        previewLayer.frame = bounds
        if let connection = videoSession.captureSession?.connections.last, connection.isVideoOrientationSupported {
            let orientation = UIApplication.shared.windows.first!.windowScene!.interfaceOrientation
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        }
    }
}
