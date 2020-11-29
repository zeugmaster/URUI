//
//  Utils.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation

extension String {
    var utf8: Data {
        return data(using: .utf8)!
    }
}
