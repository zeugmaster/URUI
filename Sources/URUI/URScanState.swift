//
//  URScanState.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import SwiftUI
import URKit
import Combine

/// Tracks and reports state of ongoing capture.
public final class URScanState: ObservableObject {
    let feedbackProvider: URScanFeedbackProvider?

    @Published public var isDone = false
    @Published public var result: Result<UR, Error>? {
        didSet { isDone = result != nil }
    }
    @Published public var fragmentStates: [URFragmentBar.FragmentState]!
    @Published public var estimatedPercentComplete: Double!

    let codesPublisher = CodesPublisher()

    private var urDecoder: URDecoder!
    private var bag = Set<AnyCancellable>()
    private var startDate: Date?

    public var elapsedTime: TimeInterval {
        guard let startDate = startDate else { return 0 }
        return Date.timeIntervalSinceReferenceDate - startDate.timeIntervalSinceReferenceDate
    }

    public init(feedbackProvider: URScanFeedbackProvider? = nil) {
        self.feedbackProvider = feedbackProvider

        codesPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.result = .failure(error)
                case .finished:
                    break
                }
            } receiveValue: { codes in
                self.receiveCodes(codes)
            }
            .store(in: &bag)

        restart()
    }

    public func restart() {
        urDecoder = URDecoder()
        result = nil
        fragmentStates = [.off]
        estimatedPercentComplete = 0
        startDate = nil
    }

    func receiveCodes(_ parts: Set<String>) {
        // Stop if we're already done with the decode.
        guard urDecoder.result == nil else { return }

        // Pass the parts we received to the decoder and make
        // a list of the ones it accepted.
        let acceptedParts = parts.filter { part in
            urDecoder.receivePart(part)
        }

        // Stop if the decoder didn't accept any parts.
        guard !acceptedParts.isEmpty else {
            feedbackProvider?.error()
            return
        }

        result = urDecoder.result
        syncToResult()
    }

    private func syncToResult() {
        switch result {
        case .success?:
            fragmentStates = [.highlighted]
            estimatedPercentComplete = 1
            feedbackProvider?.success()
        case .failure(let error)?:
            feedbackProvider?.error()
            print("🛑 \(error)")
        case nil:
            feedbackProvider?.progress()
            if startDate == nil {
                startDate = Date()
            }
            estimatedPercentComplete = urDecoder.estimatedPercentComplete
            fragmentStates = (0 ..< urDecoder.expectedPartCount).map { i in
                if urDecoder.receivedPartIndexes.contains(i) {
                    return .highlighted
                } else {
                    return urDecoder.lastPartIndexes.contains(i) ? .on : .off
                }
            }
        }
    }
}
