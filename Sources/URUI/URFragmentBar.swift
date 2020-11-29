//
//  URFragmentBar.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import SwiftUI

/// Displays which fragments of a multi-part UR are currently displayed or being captured.
public struct URFragmentBar: View {
    @Binding var states: [FragmentState]

    public enum FragmentState {
        case off
        case on
        case highlighted
    }

    public init(states: Binding<[FragmentState]>) {
        self._states = states
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<states.count, id: \.self) { i in
                view(for: self.states[i])
            }
        }
        .frame(height: 20)
    }

    private func view(for state: FragmentState) -> AnyView {
        switch state {
        case .off:
            return AnyView(Color.blue)
        case .on:
            return AnyView(Color.blue.brightness(0.2))
        case .highlighted:
            return AnyView(Color.white)
        }
    }
}

struct FragmentBar_Previews: PreviewProvider {
    static let states: [URFragmentBar.FragmentState] = [.off, .on, .highlighted]

    static var previews: some View {
        NavigationView {
            URFragmentBar(states: Binding.constant(Self.states))
                .padding()
        }
        .darkMode()
    }
}
