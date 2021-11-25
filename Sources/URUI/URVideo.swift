//
//  URVideo.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import SwiftUI
import AVFoundation
import Combine
import WolfBase

/// A View that displays video from the camera and relays
/// values of scanned QR codes to to the provided `URScanState`.
public struct URVideo: UIViewRepresentable {
    let codesPublisher: CodesPublisher
    @Binding var captureDevices: [AVCaptureDevice]
    @Binding var currentCaptureDevice: AVCaptureDevice?
    @State private var cancellables = Set<AnyCancellable>()

    public init(scanState: URScanState, captureDevices: Binding<[AVCaptureDevice]>, currentCaptureDevice: Binding<AVCaptureDevice?>) {
        self.codesPublisher = scanState.codesPublisher
        self._captureDevices = captureDevices
        self._currentCaptureDevice = currentCaptureDevice
    }

    public func makeUIView(context: Context) -> URUIVideoView {
        let view = URUIVideoView(codesPublisher: codesPublisher)
        if let videoSession = view.videoSession {
            cancellables.insert(videoSession.$captureDevices.sink { devices in
                self.captureDevices = devices
            })

            cancellables.insert(videoSession.$currentCaptureDevice.sink { device in
                self.currentCaptureDevice = device
            })
        }
            
        return view
    }

    public func updateUIView(_ uiView: URUIVideoView, context: Context) {
        if let device = currentCaptureDevice {
            uiView.videoSession?.setCaptureDevice(device)
        }
    }
}
