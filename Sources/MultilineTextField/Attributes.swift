//
//  Attributes.swift
//  
//
//  Created by Ian Sampson on 2020-04-10.
//

import UIKit
// TODO: Make platform agnostic

struct Attributes {
    let font: UIFont
    let foregroundColor: UIColor
    let baselineOffset: CGFloat
    let lineHeightMultiple: CGFloat
}

public struct AttributedSpan {
    public let range: Range<String.Index>
    public let attributes: [NSAttributedString.Key : Any]
    public init(range: Range<String.Index>, attributes: [NSAttributedString.Key : Any]) {
        self.range = range
        self.attributes = attributes
    }
}
