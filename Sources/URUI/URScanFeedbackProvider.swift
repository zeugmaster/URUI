//
//  URScanFeedbackProvider.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation

// Pass a type conforming to this protocol to your call to the URScanState constructor.
// See URDemo for an example of how this can be used.
public protocol URScanFeedbackProvider {
    func progress() // Called each time a fragment QR code is scanned.
    func success() // Called when a complete UR is scanned.
    func error() // Called when a QR code is read that isn't part of the current UR.
}
