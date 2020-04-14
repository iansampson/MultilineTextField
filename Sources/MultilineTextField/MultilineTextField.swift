//
//  MultilineTextField.swift
//  
//
//  Created by Ian Sampson on 2020-04-10.
//

import SwiftUI

public struct MultilineTextField: View {
    @Binding private var text: String
    
    private let attributes: Attributes
    @State private var contentSize: CGSize = .zero
    
    public init(
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
    
    public var body: some View {
        TextView(text: self.$text, attributes: self.attributes, contentSize: self.$contentSize)
            .frame(
                height: self.contentSize.height
            )
    }
}
