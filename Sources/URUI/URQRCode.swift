//
//  URQRCode.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

/// Displays a (possibly animated) QR code.
public struct URQRCode: View {
    @Binding var data: Data
    let foregroundColor: Color
    let backgroundColor: Color

    public init(data: Binding<Data>, foregroundColor: Color = .primary, backgroundColor: Color = .clear) {
        self._data = data
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        return makeQRCode(data, correctionLevel: .low)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
    }
}

#if DEBUG
struct QRCode_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            URQRCode(data: Binding.constant("Hello".utf8))
        }.darkMode()
    }
}
#endif


public enum QRCorrectionLevel: String {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"
}

public func makeQRCode(_ message: Data, correctionLevel: QRCorrectionLevel = .medium) -> Image {
    let qrCodeGenerator = CIFilter.qrCodeGenerator()
    qrCodeGenerator.correctionLevel = correctionLevel.rawValue
    qrCodeGenerator.message = message

    let falseColor = CIFilter.falseColor()
    falseColor.inputImage = qrCodeGenerator.outputImage
    falseColor.color0 = .black
    falseColor.color1 = .clear

    let output = falseColor.outputImage!

    let cgImage = CIContext().createCGImage(output, from: output.extent)!
    return Image(uiImage: UIImage(cgImage: cgImage, scale: 1, orientation: .up))
        .renderingMode(.template)
        .interpolation(.none)
}
