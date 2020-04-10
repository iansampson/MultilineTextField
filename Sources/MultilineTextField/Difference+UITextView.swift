//
//  Difference+UITextView.swift
//  
//
//  Created by Ian Sampson on 2020-04-10.
//

import UIKit

extension UITextView {
    func apply(_ difference: CollectionDifference<Character>) {
        func textPosition(from offset: Int) -> UITextPosition? {
            let index = text.index(text.startIndex, offsetBy: offset)
            let utf16Offset = index.utf16Offset(in: text)
            return position(from: beginningOfDocument, offset: utf16Offset)
        }
        
        difference.forEach { change in
            switch change {
            case let .remove(offset, _, _):
                guard
                    let lowerBound = textPosition(from: offset),
                    let upperBound = position(from: lowerBound, offset: 1),
                    let textRange = self.textRange(from: lowerBound, to: upperBound)
                else {
                    fatalError()
                }
                replace(textRange, withText: "")
                
            case let .insert(offset, newElement, _):
                guard
                    let lowerBound = textPosition(from: offset),
                    let textRange = self.textRange(from: lowerBound, to: lowerBound)
                else {
                    fatalError()
                }
                replace(textRange, withText: String(newElement))
            }
        }
    }
}
