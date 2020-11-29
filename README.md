# URUI

## Cross-Apple-Platform UI for displaying and scanning URs

by Wolf McNally and Christopher Allen<br/>
© 2020 Blockchain Commons

---

### Introduction

This framework depends on [URKit](https://github.com/blockchaincommons/URKit) and implements SwiftUI interfaces for displaying URs in (possibly animated) QR code form and scanning those same QR codes back into UR form. This framework compiles for iOS devices or Mac Catalyst. Video capture not supported under the iOS simulator.

### Use

Use of this framework is demonstrated in the [URDemo](https://github.com/blockchaincommons/URDemo) app. The main types of interest are:

#### Displaying URs

|   |   |   |
|:--|:--|:--|
| URDisplayState | class | Tracks state of ongoing display of (possibly multi-part) UR.
| URFragmentBar | View | Displays which fragments of a multi-part UR are currently displayed or being captured.
| URQRCode | View | Displays a (possibly animated) QR code.

#### Scanning URs

|   |   |   |
|:--|:--|:--|
| URFragmentBar | View | Displays which fragments of a multi-part UR are currently displayed or being captured.
| URProgressBar | View | Displays a linear progress bar.
| URScanFeedbackProvider | protocol | Used to add sound effects or haptic feedback to an ongoing capture.
| URScanState | class | Tracks and reports state of ongoing capture.
| URVideo | View | Displays video preview and captures QR codes.

### Requirements

* Swift 5.3, iOS 13 or macOS 10.15 (Big Sur), and Xcode 12.2

### Building

* Build or include like any other Swift package.
