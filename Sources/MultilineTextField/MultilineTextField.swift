//
//  TextView2.swift
//  NonScrollingTextView2
//
//  Created by Ian Sampson on 2020-04-08.
//  Copyright © 2020 Ian Sampson. All rights reserved.
//

import SwiftUI
import UIKit

// TODO: Allow adding and removing attributes from NSTextStorage
// TODO: Move scroll view to avoid keyboard covering text
// with a simple calculation. (Unlikely.)
// TODO: Avoid resetting text and attributes every time you type a character.

// TODO: Add support for NSTextView
// TODO: Prevent TextView from overrunning the screen.
// TODO: Replace bindings with preference keys if possible
// TODO: Remove error:
//       Snapshotting a view (0x7feb99b28ca0, _UIReplicantView)
//       that has not been rendered at least once requires afterScreenUpdates:YES

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
        textView.text = text
        
        textView.font = attributes.font
        textView.textColor = attributes.foregroundColor
        
        if context.environment.disableAutocorrection == true {
            textView.autocorrectionType = .no
        } else {
            textView.autocorrectionType = .default
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.allowsDefaultTighteningForTruncation = context.environment.allowsTightening
        paragraphStyle.lineSpacing = context.environment.lineSpacing
        textView.textStorage.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: text.utf16.count)
        )
        // TODO: Avoid initializing a new paragraph style every render call
        
        // UIFont is a class
        // UIColor is a class
        // Both conform to Equatable
        // TODO: Consider replacing them with structs
        // similar to Color and Font
        
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
        
        func textViewDidChange(_ textView: UITextView) {
            // Updates the text binding (which also
            // triggers updateUIView and recalculates
            // the frame size).
            DispatchQueue.main.async {
                self.text = textView.text
            }
        }
        
        /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Prevent UITextView from scrolling vertically.
            // TODO: Seems like a hack. Consider alternatives.
            scrollView.setContentOffset(
                CGPoint(x: scrollView.contentOffset.x, y: 0),
                animated: false
            )
        }*/
    }
}

struct MultilineTextField: View {
    @Binding var text: String

    fileprivate struct Attributes {
        let font: UIFont
        let foregroundColor: UIColor
    }
    
    private let attributes: Attributes
    @State private var contentSize: CGSize = .zero
    
    init(
        text: Binding<String>,
        font: UIFont = .preferredFont(forTextStyle: .body),
        foregroundColor: UIColor = .label
    ){
        self._text = text
        self.attributes = Attributes(
            font: font,
            foregroundColor: foregroundColor
        )
    }
    
    var body: some View {
        TextView(text: self.$text, attributes: self.attributes, contentSize: self.$contentSize)
            .frame(
                height: self.contentSize.height
                // TODO: Or the maximum height of the frame.
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

/*extension NSTextAlignment {
    init(textAlignment: TextAlignment) {
        switch textAlignment {
        case .center:
            self = .center
        case .leading:
            self = .natural
        case .trailing:
            self = .right
            // TODO: Not strictly correct.
            // Trailing could also be left in LTR languages.
        }
    }
}*/

// # Modifiers
// baselineOffset
// bold()
// font
// fontWeight
// foregroundColor
// italic
// kerning
// strikethrough(active:color:)
// underline(active:color:)
// accentColor(color:)
// textFieldStyle
// multilineTextAlignment

// allowsTightening?
// editMode
// isEnabled
// lineLimit
// lineSpacing
