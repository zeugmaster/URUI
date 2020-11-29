//
//  UREncoderExtensions.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import URKit

extension UREncoder {
    func nextQRPart() -> Data {
        nextPart().uppercased().utf8
    }
}
