//
//  RichTextWriter.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-23.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented any types that can provide
 a writable rich text string.

 The protocol is used to extend all types within the library
 that can provide a writable rich text.
 */
public protocol RichTextWriter {

    /**
     Get the writable rich text provided by this type.
     */
    var mutableAttributedString: NSMutableAttributedString? { get }
}

extension NSMutableAttributedString: RichTextWriter {

    public var mutableAttributedString: NSMutableAttributedString? {
        self
    }
}