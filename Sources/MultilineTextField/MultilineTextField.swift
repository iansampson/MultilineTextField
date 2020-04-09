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
// TODO: Add modifiers for font and line spacing
// TODO: Allow adding and removing attributes from NSTextStorage
// TODO: Explore whether you can replace the dummy UITextView
// with a simple calculation. (Unlikely.)

private struct TextView: UIViewRepresentable {
    @Binding var text: String
    let font: UIFont
    let geometry: GeometryProxy
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
            self.contentSize = textView.sizeThatFits(self.geometry.size)
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
        GeometryReader { geometry in
            TextView(
                text: self.$text,
                font: self.font,
                geometry: geometry,
                contentSize: self.$contentSize
            )
                .frame(
                    height: self.contentSize == .zero
                        // If this is the first update, use a dummy UITextView
                        // to calculate the content size.
                        ? MultilineTextField
                            .initialContentSize(
                                text: self.text, font: self.font, geometry: geometry
                            ).height
                        // Otherwise use the content size provided by the actual UITextView
                        // wrapped by the SwiftUI TextView.
                        : self.contentSize.height
                )
        }
    }
    
    // Constructs a dummy UITextView that matches
    // the actual UITextView used by the SwiftUI TextView
    // and asks it to calculate its content size.
    private static func initialContentSize(
        text: String,
        font: UIFont,
        geometry: GeometryProxy
    ) -> CGSize {
        let textView = UITextView.textField
        textView.text = text
        textView.font = font
        
        // Remove excess padding to match TextView.
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView.sizeThatFits(geometry.size)
    }
}

private extension UITextView {
    // Make a UITextView that behaves like a SwiftUI TextField.
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
