//
//  TextView2.swift
//  NonScrollingTextView2
//
//  Created by Ian Sampson on 2020-04-08.
//  Copyright © 2020 Ian Sampson. All rights reserved.
//

import SwiftUI
import UIKit

// TODO: Replace bindings with anchor preferences
// TODO: Add modifiers for font and line spacing
// TODO: Allow adding and removing attributes from NSTextStorage
// TODO: Explore whether you can replace the dummy UITextView
// TODO: Move scroll view to avoid keyboard covering text.
// with a simple calculation. (Unlikely.)
// TODO: Remove error:
//       Snapshotting a view (0x7feb99b28ca0, _UIReplicantView)
//       that has not been rendered at least once requires afterScreenUpdates:YES.

private struct TextView: UIViewRepresentable {
    @Binding var text: String
    let font: UIFont
    //let frameSize: CGSize
    @Binding var contentSize: CGSize
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView.textField
        textView.font = font
        
        // Connect TextView to Coordinator.
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let textView = uiView
        textView.text = text
        DispatchQueue.main.async {
            self.contentSize = textView.sizeThatFits(
                CGSize(width: textView.frame.width,
                       height: .greatestFiniteMagnitude
                )
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Updates the text binding (which also
            // triggers updateUIView and recalculates
            // the frame size).
            DispatchQueue.main.async {
                self.text = textView.text
            }
        }
    }
}

struct MultilineTextField: View {
    @Binding var text: String
    let font: UIFont
    
    @State private var contentSize: CGSize = .zero
    // The size of the actual text, reported by the UITextView
    // inside the SwiftUI TextView.
    
    init(
        text: Binding<String>,
        font: UIFont = .preferredFont(forTextStyle: .body)
    ){
        self._text = text
        self.font = font
    }
    
    var body: some View {
        TextView(text: self.$text, font: self.font, contentSize: self.$contentSize)
            .frame(
                height: self.contentSize.height
            )
    }
}

private extension UITextView {
    // Constructs a UITextView that behaves like a SwiftUI TextField.
    // TODO: Consider making this computed property a function
    // (so the syntax () looks more like an initializer).
    static var textField: UITextView {
        let textView = UITextView()
        
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        
        // Constrain width so text wraps.
        textView.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
        
        // Remove excess padding to match TextField.
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }
}

// TODO: Consider removing these structs if they remain unused.
private struct TextFieldPreferenceData {
    let id: UUID
    let bounds: Anchor<CGRect>
}

private struct TextFieldPreferenceKey: PreferenceKey {
    static var defaultValue: [TextFieldPreferenceData] = []
    static func reduce(value: inout [TextFieldPreferenceData], nextValue: () -> [TextFieldPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}
