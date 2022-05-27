//
//  RichTextProvider.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-23.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented any types that can provide
 a rich text string.

 The protocol is used by types in the library, to extend all
 types that can provide a rich text.
 */
public protocol RichTextProvider {

    /**
     Get the rich text provided by this type.
     */
    var attributedString: NSAttributedString { get }
}

extension NSAttributedString: RichTextProvider {

    /**
     Get the rich text that is defined within this string.
     */
    public var attributedString: NSAttributedString {
        self
    }
}