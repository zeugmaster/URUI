//
//  URDisplayState.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import URKit
import Combine
import SwiftUI

/// Tracks state of ongoing display of (possibly multi-part) UR.
public class URDisplayState: ObservableObject {
    public let ur: UR
    public let maxFragmentLen: Int

    public var isSinglePart: Bool { encoder.isSinglePart }
    public var seqNum: UInt32 { encoder.seqNum }
    public var seqLen: Int { encoder.seqLen }

    @Published public var framesPerSecond: Double = 1 / defaultInterval {
        didSet { interval = 1 / framesPerSecond }
    }
    @Published public private(set) var part: Data!
    @Published public private(set) var fragmentStates: [URFragmentBar.FragmentState] = [.off]

    private static let defaultInterval: TimeInterval = 1.0 / 10
    private var encoder: UREncoder!
    private var lastPartIndexes: Set<Int> { encoder.lastPartIndexes }
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    private var timerCanceler: AnyCancellable?
    private var lastSwitch: Date!
    private var interval: TimeInterval = defaultInterval

    public init(ur: UR, maxFragmentLen: Int) {
        self.ur = ur
        self.maxFragmentLen = maxFragmentLen
        restart()
    }

    public func restart() {
        encoder = UREncoder(ur, maxFragmentLen: maxFragmentLen)
        lastSwitch = Date()
        self.nextPart()
    }

    public func run() {
        guard !self.isSinglePart else { return }
        timerCanceler = timer.sink { [unowned self] date in
            guard date > self.lastSwitch + self.interval else { return }
            self.lastSwitch = date
            //click.play()
            self.nextPart()
        }
    }

    public func stop() {
        timerCanceler?.cancel()
        timerCanceler = nil
    }

    private func nextPart() {
        part = encoder.nextQRPart()
        fragmentStates = (0 ..< seqLen).map { i in
            encoder.lastPartIndexes.contains(i) ? .on : .off
        }
    }
}
