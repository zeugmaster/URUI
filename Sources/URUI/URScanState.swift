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
    /// A UR QR code was read.
    case ur(UR)
    
    /// Some other QR code was read.
    case other(String)
    
    /// A part of a multi-part QR code was read.
    case progress(URScanProgress)
    
    /// A part of a multi-part QR code was rejected.
    case reject
    
    /// An error occurred that aborted the scan session.
    case failure(Error)
}

public struct URScanProgress {
    public let estimatedPercentComplete: Double
    public let fragmentStates: [URFragmentBar.FragmentState]
}

/// Tracks and reports state of ongoing capture.
@MainActor
public final class URScanState: ObservableObject {
    public let resultPublisher = PassthroughSubject<URScanResult, Never>()

    private var urDecoder: URDecoder!
    private var bag = Set<AnyCancellable>()

    public init(codesPublisher: URCodesPublisher) {
        codesPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.resultPublisher.send(.failure(error))
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
    }
    
    private var progress: URScanProgress {
        let estimatedPercentComplete = urDecoder.estimatedPercentComplete
        let fragmentStates: [URFragmentBar.FragmentState] = (0 ..< urDecoder.expectedFragmentCount!).map { i in
            if urDecoder.receivedFragmentIndexes.contains(i) {
                return .highlighted
            } else {
                return urDecoder.lastFragmentIndexes.contains(i) ? .on : .off
            }
        }
        return URScanProgress(estimatedPercentComplete: estimatedPercentComplete, fragmentStates: fragmentStates)
    }
    
    func processCode(_ code: String) {
        if urDecoder.receivePart(code.trimmingCharacters(in: .whitespacesAndNewlines)) {
            switch urDecoder.result {
            case .failure(let error)?:
                resultPublisher.send(.failure(error))
                restart()
            case .success(let ur)?:
                resultPublisher.send(.ur(ur))
                restart()
            case nil:
                resultPublisher.send(.progress(progress))
            }
        } else {
            if urDecoder.expectedType == nil {
                resultPublisher.send(.other(code))
            } else {
                resultPublisher.send(.reject)
            }
        }
    }

    func receiveCodes(_ codes: Set<String>) {
        for code in codes {
            processCode(code)
        }
    }
}
