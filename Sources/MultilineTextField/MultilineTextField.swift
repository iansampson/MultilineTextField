//
//  TextView2.swift
//  NonScrollingTextView2
//
//  Created by Ian Sampson on 2020-04-08.
//  Copyright © 2020 Ian Sampson. All rights reserved.
//

import SwiftUI
import UIKit

private struct TextView: UIViewRepresentable {
    @Binding var text: String
    let attributes: MultilineTextField.Attributes
    @Binding private(set) var contentSize: CGSize
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView.textField
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let textView = uiView
        
        // Update text view from model
        let difference = text.difference(from: textView.text)
        textView.apply(difference)
        
        // Construct paragraph style
        // TODO: Consider making this a method on Attributes
        let paragraphStyle = NSMutableParagraphStyle()
            // TODO: Avoid initializing a new paragraph style every render call
        //paragraphStyle.allowsDefaultTighteningForTruncation = context.environment.allowsTightening
        //paragraphStyle.lineSpacing = context.environment.lineSpacing
        paragraphStyle.lineHeightMultiple = attributes.lineHeightMultiple
        
        // Construct attributes
            // TODO: Consider making this a method on MultilineTextField.Attributes
            // TODO: Diff attributes and update only the ones that have changed
            // (and in the ranges where they are needed)
        let attributeDictionary: [NSAttributedString.Key : Any] = [
            .font: attributes.font,
            .foregroundColor: attributes.foregroundColor,
            .baselineOffset: attributes.baselineOffset,
            .paragraphStyle: paragraphStyle
        ]
        
        // Update string attributes
        textView.textStorage.addAttributes(
            attributeDictionary,
            range: NSRange(location: 0, length: textView.textStorage.length)
        )
        
        // Update typing attributes
        textView.typingAttributes = attributeDictionary
        
        // Update autocorrection setting
        if context.environment.disableAutocorrection == true {
            textView.autocorrectionType = .no
        } else {
            textView.autocorrectionType = .default
        }
        
        // Update content size.
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
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // TODO: Make this method more efficient by updating
            // only the part of the string that changed
            let newText = (textView.text as NSString)
                .replacingCharacters(in: range, with: text)
            DispatchQueue.main.async {
                self.text = newText
            }
            
            // Prevent text view from mutating its own text storage
            // and instead update the model
            return false
        }
    }
}

struct MultilineTextField: View {
    @Binding var text: String

    fileprivate struct Attributes {
        let font: UIFont
        let foregroundColor: UIColor
        let baselineOffset: CGFloat
        let lineHeightMultiple: CGFloat
    }
    
    private let attributes: Attributes
    @State private var contentSize: CGSize = .zero
    
    init(
        text: Binding<String>,
        font: UIFont = .preferredFont(forTextStyle: .body),
        foregroundColor: UIColor = .label,
        baselineOffset: CGFloat = 0,
        lineHeightMultiple: CGFloat = 1
    ){
        self._text = text
        self.attributes = Attributes(
            font: font,
            foregroundColor: foregroundColor,
            baselineOffset: baselineOffset,
            lineHeightMultiple: lineHeightMultiple
        )
    }
    
    var body: some View {
        TextView(text: self.$text, attributes: self.attributes, contentSize: self.$contentSize)
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
