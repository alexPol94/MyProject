//
//  File.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 04.01.17.
//  Copyright © 2017 Ruzhin Alexey. All rights reserved.
//

import Foundation
import UIKit
extension UITextView {
    
    func isTextBold(at range: NSRange) -> Bool {
        
        if self.text.isEmpty {
            return false
        }

        if range.location > 0 && range.location == self.text.length() {
            var range = range
            range.location -= 1
            return self.containsTraitBold(at: range)
        }
        return self.containsTraitBold(at: range)
    }
    
    
    private func containsTraitBold(at range: NSRange) -> Bool {
        let currentAttributesDict : NSDictionary = self.textStorage.attributes(at: range.location, effectiveRange: nil) as NSDictionary
        let currentFont : UIFont = currentAttributesDict.object( forKey: NSFontAttributeName ) as! UIFont
        let fontDescriptor = currentFont.fontDescriptor
        if fontDescriptor.symbolicTraits.contains(.traitBold) {
            return true
        }
        return false
    }
    func rightChar(from range:NSRange) -> String {
        if self.text.isEmpty {
            return ""
        }
        let index = range.location + range.length
        var char = ""
        if index < self.text.length() {
            char = (self.text as NSString).substring(with: NSMakeRange(index, 1))
        }
        return char
        
    }
    func leftChar(from range:NSRange) -> String {
        if self.text.isEmpty || range.location == 0 {
            return ""
        }
        let index = range.location + range.length
        var char = ""
        if index > 0 && index <= self.text.length() {
            char = (self.text as NSString).substring(with: NSMakeRange(index-1, 1))
        }
        return char
        
    }
    func fixRange(range: NSRange) -> NSRange {
        var tempRange = range
        if tempRange.location == self.text.length() && !self.text.isEmpty{
            tempRange.location -= 1
        }
        return tempRange
    }
}
