//
//  URScanState.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import SwiftUI
import URKit
import Combine

public enum URScanResult {
    case ur(UR)
    case other(String)
    case failure(Error)
}

/// Tracks and reports state of ongoing capture.
public final class URScanState: ObservableObject {
    let feedbackProvider: URScanFeedbackProvider?

    @Published public var isDone = false
    @Published public var result: URScanResult? {
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
        guard result == nil else { return }

        // Pass the parts we received to the decoder and make
        // a list of the ones it accepted.
        let acceptedParts = parts.filter { part in
            urDecoder.receivePart(part)
        }

        // If we haven't yet received the start of a multi-part UR
        // and get some other QR code, then that's our result.
        if urDecoder.expectedType == nil && acceptedParts.isEmpty {
            result = .other(parts.first!)
        } else {
            switch urDecoder.result {
            case .failure(let error)?:
                result = .failure(error)
            case .success(let ur)?:
                result = .ur(ur)
            case nil:
                break
            }
        }
        syncToResult()
    }

    private func syncToResult() {
        switch result {
        case .ur?, .other?:
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
