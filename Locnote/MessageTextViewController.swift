//
//  MessageTextViewController.swift
//  Locnote
//
//  Created by Alexandr Polukhin on 03.12.16.
//  Copyright © 2016 Ruzhin Alexey. All rights reserved.
//

import UIKit

class MessageTextViewController: UIViewController, UITextViewDelegate {
    
    var exitComplition: ((NSAttributedString, String) -> (Void))?
    var textForInit: NSAttributedString? = nil
    
    // MARK: - Properties
    private var isList = false
    private var isCenter = false
    private var isBold = false
    private var textCurrentlyChanged = false
    let listBullet = "  \u{2022} "
    
    // MARK: - Outlets
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var centerAlingmentButton: UIBarButtonItem!
    @IBOutlet weak var boldButton: UIBarButtonItem!
    
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.textView.attributedText = textForInit
    }
    
    
    //MARK: - UITextViewDelegate
    func textView( _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String ) -> Bool {
        self.textCurrentlyChanged = true
        if range.length > 0 {
            return true
        }
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }
        if( text == "\n" ) {
            if self.isCenter == true {
                self.alignToCenterSelectedText()
                let newParagraphStyle = NSMutableParagraphStyle()
                newParagraphStyle.alignment = .left
                let dict: Dictionary = [NSParagraphStyleAttributeName: newParagraphStyle]
                self.textView.typingAttributes = dict
//                return true
            }
            if self.hasListBulletPrefix(at: range) {
                let index = range.location
                let length = self.textView.text.length()
                
                if index < length {
                    self.textView.text = self.textView.text.insert(string: "\n", index: index)
                }
                else {
                    self.textView.text.append("\n")
                }
                self.makeNewListLine(range: NSMakeRange(index+1, 0))
                return false
            }
            
//            if self.isBold == true {
//                self.makeBoldSymbol(text: text)
//            }
//            else {
//                self.makeStandartSymbol(text: text)
//            }
            return true
        }
        else {
            
            if self.isBold == true {
                self.makeBoldSymbol(text: text)
            }
            else {
                self.makeStandartSymbol(text: text)
            }
            if textView.leftChar(from: range) == "\n" && self.isCenter == true {
                self.alignToCenterSelectedText()
            }
            return false
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.textCurrentlyChanged == true {
            self.textCurrentlyChanged = false
            return
        }
        if textView.text.isEmpty {
            return
        }
        if self.hasListBulletPrefix(at: textView.selectedRange) {
            self.listOn()
        }
        else {
            self.listOff()
        }
        
        if textView.isTextBold(at: textView.selectedRange) {
            self.boldOn()
        }
        else {
            self.boldOff()
        }
        
//        if self.isTextAlignCenter(at: selectedRange) == true {
//            self.centerOn()
//        }
//        else {
//            self.centerOff()
//        }
        self.textCurrentlyChanged = false
    }
    
    
    // MARK: -
    private func boldOn() {
        self.isBold = true
        self.boldButton.image = UIImage(imageLiteralResourceName: "BoldIcon_pressed")
    }
    
    private func boldOff() {
        self.isBold = false
        self.boldButton.image = UIImage(imageLiteralResourceName: "BoldIcon")
    }
    
    private func listOn() {
        self.isList = true
        self.listButton.image = UIImage(imageLiteralResourceName: "ListIcon_pressed")
    }
    
    private func listOff() {
        self.isList = false
        self.listButton.image = UIImage(imageLiteralResourceName: "ListIcon")
    }
    
    private func centerOn() {
        self.isCenter = true
        self.centerAlingmentButton.image = UIImage(imageLiteralResourceName: "AlignmentIcon_pressed")
    }
    private func centerOff() {
        self.isCenter = false
        self.centerAlingmentButton.image = UIImage(imageLiteralResourceName: "AlignmentIcon")
    }
    
    
    // MARK: -
    @IBAction func testButtonClicked(_ sender: Any) {
//        print("Location = \(self.textView.selectedRange.location)")
//        print("Text Length = \(self.textView.text.length())")
//        let range = self.textView.selectedRange
//        print("Start index: \(self.beginIndexOfSelectedLine(range: range))")
//        print("End index: \(self.endIndexOfSelectedLine(range: range))")
//        print(".\(self.getSelectedLine(range: range)).")
//            let b = self.isTextAlignCenter(at: range)
        
    }
    
    // MARK: - Text Edit Buttons
    @IBAction func listButtonClicked(_ sender: UIBarButtonItem) {
        let range = self.textView.selectedRange
        if self.isList == false {
            self.listOn()
            self.makeNewListLine(range: range)
        }
        else {
            self.listOff()
            self.deleteListBullet(range: range)
        }
    }
    
    @IBAction func centerAlingmentButtonClicked(_ sender: UIBarButtonItem) {
        if self.isCenter == false {
            self.alignToCenterSelectedText()
            self.centerOn()
        }
        else {
            self.alignToLeftSelectedText()
            self.centerOff()
        }
    }
    
    @IBAction func boldButtonClicked (_ sender: UIBarButtonItem) {
        
        if self.isBold == false {
            self.boldOn()
        }
        else {
            self.boldOff()
        }
        self.makeSelectedTextBold()
    }
    
    
    // MARK: - Make List Method
    
    private func makeNewListLine(range: NSRange) {
        let selectedRange = range
        let beginingIndex = self.beginIndexOfSelectedLine(range: selectedRange)
        if beginingIndex == self.textView.text.length() {
//            self.textView.text.append(listBullet)
            self.textView.text = self.textView.text.insert(string: listBullet, index: beginingIndex)
        }
        else {
            self.textView.text = self.textView.text.insert(string: listBullet, index: beginingIndex)
        }
        self.textView.selectedRange = NSMakeRange(range.location+listBullet.length(), range.length)
    }
    
    private func deleteListBullet(range: NSRange) {
        let selectedRange = range
        var beginingIndex = self.beginIndexOfSelectedLine(range: selectedRange)
        if selectedRange.location != self.textView.text.length() {
            let char = (self.textView.text as NSString).substring(with: NSMakeRange(selectedRange.location, 1))
            if char == "\n" {
                beginingIndex = self.beginIndexOfSelectedLine(range: NSMakeRange(selectedRange.location-1, 0))
            }
        }
        var wholeText = self.textView.text
        let startIndex = self.stringIndexFromInt(index: beginingIndex)
        let listBulletEndIndex = stringIndexFromInt(index: beginingIndex+listBullet.length())
        if  self.hasListBulletPrefix(at: selectedRange) {
            wholeText!.removeSubrange(startIndex..<listBulletEndIndex)
        }
        self.textView.text = wholeText!
        let tempRange = NSMakeRange(range.location-listBullet.length(), range.length)
        if tempRange.location < beginingIndex {
            self.textView.selectedRange = NSMakeRange(beginingIndex, range.length)
        }
        else {
            self.textView.selectedRange = tempRange
        }
    }
    
    private func getSelectedLine(range: NSRange) -> String {
        let startIntIndex = self.beginIndexOfSelectedLine(range: range)
        let endIntIndex = self.endIndexOfSelectedLine(range: range)
        let wholeText = self.textView.text
        var subString = ""
        if wholeText!.length() > 0 {
            if startIntIndex <= endIntIndex {
                let lengthOfLine = endIntIndex - startIntIndex + 1
                subString = (wholeText! as NSString).substring(with: NSMakeRange(startIntIndex, lengthOfLine))
            }
        }
        return subString
    }
    
    private func hasListBulletPrefix(at range: NSRange) -> Bool {
        var range = range
        if range.location == self.textView.text.length() {
            range = NSMakeRange(range.location-1, 1)
            let char = (self.textView.text as NSString).substring(with: range)
            if char == "\n" {
                return false
            }
            
        }
        range.length = 1
        let char = (self.textView.text as NSString).substring(with: range)
        if char == "\n" {
            let char2 = (self.textView.text as NSString).substring(with: NSMakeRange(range.location-1, range.length))
            if char2 == "\n" {
                return false
            }
        }
        let string = self.getSelectedLine(range: range)
        if !string.isEmpty && (string.hasPrefix(listBullet) || string == listBullet) {
            return true
        }
        return false
    }
    
    // MARK: - Start/End Indexes of Selected Line
    private func beginIndexOfSelectedLine(range: NSRange) -> Int {
        if self.textView.text.isEmpty {
            return 0
        }
        let currentIndex = range.location
        var index = currentIndex
        if self.textView.text[index]! == "\n" {
            index -= 1
        }
        while (index > 0) {
            let char = self.textView.text[index]!
            if char == "\n" {
                return index+1
            }
            else {
                index -= 1
            }
        }
        if index == self.textView.text.length() {
            index -= 1
        }
        return index
        
    }
    
    private func endIndexOfSelectedLine(range: NSRange) -> Int {
        if self.textView.text.isEmpty {
            return 0
        }
        let lengthOfWholeText = self.textView.text.length()
        let currentIndex = range.location
        if currentIndex == lengthOfWholeText {
            return lengthOfWholeText - 1
        }
        var char = self.textView.text[currentIndex]
        if char == "\n" {
            return currentIndex-1
        }
        var index = currentIndex
        
        while (index < lengthOfWholeText) {
            char = self.textView.text[index]
            if char == "\n" {
                return index-1
            }
            else {
                index += 1
            }
        }
        return index-1
    }
    
    private func stringIndexFromInt(index: Int) -> String.Index {
        let wholeText = self.textView.text
        if index == wholeText?.length() {
            let stringIndex = wholeText!.index(wholeText!.startIndex, offsetBy: index-1)
            return stringIndex
        }
        
        let stringIndex = wholeText!.index(wholeText!.startIndex, offsetBy: index)
        return stringIndex
    }
    
    
    // MARK: - Text Align Methods
    private func alignToCenterSelectedText() {
        if self.textView.text.isEmpty {
            return
        }
        let selectedRange : NSRange = self.textView.selectedRange
        let startIndex = self.beginIndexOfSelectedLine(range: selectedRange)
        var newRange: NSRange?
        if startIndex == self.textView.text.length() {
            newRange = NSMakeRange(startIndex-1, 1)
        }
        else {
            newRange = NSMakeRange(startIndex, 1)
        }
        
        let newParagraphStyle = NSMutableParagraphStyle()
        newParagraphStyle.alignment = .center
        self.textView.textStorage.beginEditing()
        self.textView.textStorage.addAttribute(NSParagraphStyleAttributeName, value: newParagraphStyle, range: newRange!)
        self.textView.textStorage.endEditing()
    }
    
    private func alignToLeftSelectedText() {
        if self.textView.text.isEmpty {
            return
        }
        let selectedRange : NSRange = self.textView.selectedRange
        let startIndex = self.beginIndexOfSelectedLine(range: selectedRange)
        var newRange: NSRange?
        if startIndex == self.textView.text.length() {
            newRange = NSMakeRange(startIndex-1, 1)
        }
        else {
            newRange = NSMakeRange(startIndex, 1)
        }
        
        let newParagraphStyle = NSMutableParagraphStyle()
        newParagraphStyle.alignment = .left
        self.textView.textStorage.beginEditing()
        self.textView.textStorage.addAttribute(NSParagraphStyleAttributeName, value: newParagraphStyle, range: newRange!)
        self.textView.textStorage.endEditing()
    }
    
    private func isTextAlignCenter(at range: NSRange) -> Bool {
        if self.textView.text.isEmpty {
            return false
        }
        let startIndex = self.beginIndexOfSelectedLine(range: range)
        var newRange: NSRange?
//        if startIndex == self.textView.text.length() {
            newRange = NSMakeRange(startIndex-1, 1)
//        }
//        else {
//            newRange = NSMakeRange(startIndex, 1)
//        }
        let char = (self.textView.text as NSString).substring(with: newRange!)
        print(char)
        
        let attributesDictionary = self.textView.textStorage.attributes(at: newRange!.location, effectiveRange: nil)
//        let attributesDictionary2 = self.textView.typingAttributes
//        let newParagrphStyle: NSParagraphStyle? = attributesDictionary2[NSParagraphStyleAttributeName] as? NSParagraphStyle
        
        let paragrphStyle: NSParagraphStyle? = attributesDictionary[NSParagraphStyleAttributeName] as? NSParagraphStyle
        if paragrphStyle?.alignment == .center {
            return true
        }
        return false
    }
    
    // MARK: - Make text Bold
    private func makeBoldSymbol(text : String) {
        let selectedRange = self.textView.selectedRange
        let attributedStringForInsert = NSAttributedString(string: text, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)])
        let attributedStringBeforeCursor = self.textView.attributedText.attributedSubstring(from: NSRange(location: 0,length: selectedRange.location))
        let attributedStringAfterCursor = self.textView.attributedText.attributedSubstring(from: NSRange(location: selectedRange.location, length: self.textView.attributedText.length - selectedRange.location))
        let mutableString = NSMutableAttributedString(attributedString: attributedStringBeforeCursor)
        mutableString.append(attributedStringForInsert)
        mutableString.append(attributedStringAfterCursor)
        self.textView.attributedText = mutableString
        self.textView.selectedRange = NSRange(location: selectedRange.location + text.length(), length: 0)
    }
    
    private func makeStandartSymbol(text : String) {
        let selectedRange = self.textView.selectedRange
        let attributedStringForInsert = NSAttributedString(string: text, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
        let attributedStringBeforeCursor = self.textView.attributedText.attributedSubstring(from: NSRange(location: 0,length: selectedRange.location))
        let attributedStringAfterCursor = self.textView.attributedText.attributedSubstring(from: NSRange(location: selectedRange.location, length: self.textView.attributedText.length - selectedRange.location))
        let mutableString = NSMutableAttributedString(attributedString: attributedStringBeforeCursor)
        mutableString.append(attributedStringForInsert)
        mutableString.append(attributedStringAfterCursor)
        self.textView.attributedText = mutableString
        self.textView.selectedRange = NSRange(location: selectedRange.location + text.length(), length: 0)
    }
    
    private func makeSelectedTextBold() {
        var selectedRange : NSRange = self.textView.selectedRange
        if selectedRange.length == 0 || self.textView.text.isEmpty {
            return
        }
        if selectedRange.location == self.textView.text.length() {
            selectedRange.location -= 1
        }
        let currentAttributesDict : NSDictionary = self.textView.textStorage.attributes( at: selectedRange.location, effectiveRange: nil ) as NSDictionary
        let currentFont : UIFont = currentAttributesDict.object( forKey: NSFontAttributeName ) as! UIFont
        let fontDescriptor = currentFont.fontDescriptor
        var changedFontDescriptor : UIFontDescriptor?
        if self.isBold == true {
            changedFontDescriptor = fontDescriptor.withSymbolicTraits( .traitBold )!
        }
        else {
            changedFontDescriptor = fontDescriptor.withSymbolicTraits( .traitUIOptimized )!
        }
        
        let updatedFont : UIFont = UIFont.init( descriptor: changedFontDescriptor!, size: 0.0 )
        let dict : NSDictionary = [ NSFontAttributeName : updatedFont ]
        self.textView.textStorage.beginEditing()
        self.textView.textStorage.setAttributes( dict as? [String : Any], range: selectedRange )
        self.textView.textStorage.endEditing()
    }
    
    
    // MARK: - NavigationController Buttons
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
        exitComplition!(self.textView.attributedText, self.textView.text)
    }
    
    
    // MARK: - KeyboardNotifications
    func keyboardWillHide(notification:NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) { () -> Void in
            self.toolbarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let info = notification.userInfo
        let keyboardFrame: CGRect = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) { () -> Void in
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            self.view.layoutIfNeeded()
            
        }
    }
    
}
