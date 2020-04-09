//
//  TextView2.swift
//  NonScrollingTextView2
//
//  Created by Ian Sampson on 2020-04-08.
//  Copyright © 2020 Ian Sampson. All rights reserved.
//

import SwiftUI
import UIKit

// TODO: Reduce height of Geometry Reader
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
            //self.contentSize = textView.sizeThatFits(self.frameSize)
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
    @State private var id = UUID()
        // TODO: Is it possible to make this property a constant?
        // Or retrieve the ID that SwiftUI uses internally?
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
        //GeometryReader { geometry in
            TextView(
                text: self.$text,
                font: self.font,
                //frameSize: CGSize(width: 343, height: CGFloat.greatestFiniteMagnitude),
                contentSize: self.$contentSize
            )
                .anchorPreference(key: TextFieldPreferenceKey.self, value: .bounds) {
                    [TextFieldPreferenceData(id: self.id, bounds: $0)]
                }
                .frame(
                    height: self.contentSize.height
                    /*height: self.contentSize == .zero
                        // If this is the first update, use a dummy UITextView
                        // to calculate the content size.
                        ? MultilineTextField
                            .initialContentSize(
                                //text: self.text, font: self.font, frameSize: geometry.size
                                text: self.text, font: self.font, frameSize: CGSize(width: 343, height: CGFloat.greatestFiniteMagnitude)
                            ).height
                        // Otherwise use the content size provided by the actual UITextView
                        // wrapped by the SwiftUI TextView.
                        : self.contentSize.height*/
                )
                .background(Color.red)
        //}
        //.background(Color.blue)
    }
    
    // Constructs a dummy UITextView that matches
    // the actual UITextView used by the SwiftUI TextView
    // and asks for its content size.
    private static func initialContentSize(
        text: String,
        font: UIFont,
        frameSize: CGSize
    ) -> CGSize {
        let textView = UITextView.textField
        textView.text = text
        textView.font = font
        
        // Remove excess padding to match TextView.
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView.sizeThatFits(frameSize)
    }
}

private extension UITextView {
    // Constructs a UITextView that behaves like a SwiftUI TextField.
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
