//
//  String+Email.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 21/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> String? {
        if i == self.length() || i < 0{
            return ""
        }
        
        let string = self
        if string.isEmpty {
            print("index: \(i) out of range in string:\n\(self)")
            return ""
        }
        let index = self.index(self.startIndex, offsetBy: i)
        return String(string[index])
    }
    
    func length() -> Int {
        return self.characters.count
    }
    
    func insert(string:String,index:Int) -> String {
        return  String(self.characters.prefix(index)) + string + String(self.characters.suffix(self.characters.count-index))
    }

    func isEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: NSRegularExpression.Options.caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
        } catch { return false }
    }
    
    
    
}
