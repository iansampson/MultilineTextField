//
//  MultilineTextField.swift
//  
//
//  Created by Ian Sampson on 2020-04-10.
//

import Foundation
import SwiftUI

public struct AttributedSpan {
    let range: Range<String.Index>
    let attributes: [NSAttributedString.Key : Any]
}

public struct MultilineTextField: View {
    @Binding private var text: String
    
    private let attributes: Attributes
    private let attributedSpans: [AttributedSpan]
    @State private var contentSize: CGSize = .zero
    
    public init(
        text: Binding<String>,
        font: UIFont = .preferredFont(forTextStyle: .body),
        foregroundColor: UIColor = .label,
        baselineOffset: CGFloat = 0,
        lineHeightMultiple: CGFloat = 1,
        attributedSpans: [AttributedSpan]
    ){
        self._text = text
        self.attributes = Attributes(
            font: font,
            foregroundColor: foregroundColor,
            baselineOffset: baselineOffset,
            lineHeightMultiple: lineHeightMultiple
        )
        self.attributedSpans = attributedSpans
    }
    
    public var body: some View {
        TextView(text: self.$text, attributes: self.attributes, attributedSpans: attributedSpans, contentSize: self.$contentSize)
            .frame(
                height: self.contentSize.height
            )
    }
}
