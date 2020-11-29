//
//  URVideo.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import SwiftUI

/// A View that displays video from the camera and relays
/// values of scanned QR codes to to the provided `URScanState`.
public struct URVideo: UIViewRepresentable {
    let codesPublisher: CodesPublisher

    public init(scanState: URScanState) {
        self.codesPublisher = scanState.codesPublisher
    }

    public func makeUIView(context: Context) -> URUIVideoView {
        URUIVideoView(codesPublisher: codesPublisher)
    }

    public func updateUIView(_ uiView: URUIVideoView, context: Context) {
    }
}
