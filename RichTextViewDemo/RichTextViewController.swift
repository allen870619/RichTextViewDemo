//
//  RichTextViewController.swift
//  RichTextViewDemo
//
//  Created by Lee Yen Lin on 2022/6/23.
//

import UIKit

/**
 main protocol,
 
 override mainTextView with UI binding
 */
protocol RichTextViewController{
    var mainTextView: UITextView { get }
}

extension RichTextViewController{
    typealias FontRange = (font: UIFont, range: NSRange)
    
    // shorter syntax
    var selectedRange: NSRange{
        mainTextView.selectedRange
    }
    
    // NSRange
    /**
     This is for getting paragraph of selectedRange
     */
    var paragraphRange: NSRange{
        (mainTextView.text as NSString).paragraphRange(for: selectedRange)
    }
        
    // attribute controller
    func getAttribute(_ range: NSRange, type: NSAttributedString.Key) -> [(Any, NSRange)]{
        var list = [(Any, NSRange)]()
        mainTextView.attributedText.enumerateAttributes(in: range){ attrs, range, _ in
            if let attr = attrs[type]{
                list.append((attr, range))
            }
        }
        return list
    }
        
    func setAttribute(_ attribute: NSAttributedString.Key, value: Any?, range: NSRange? = nil){
        let sel = range == nil ? selectedRange : range!
        
        let origin = NSMutableAttributedString(attributedString: mainTextView.attributedText)
        if let value = value {
            origin.addAttribute(attribute, value: value, range: sel)
        }else{
            origin.removeAttribute(attribute, range: sel)
        }
        mainTextView.attributedText = origin
    }
    
    // utils
    /**
     Keep scrollview after set selected
     */
    func setAttrWithKeepingPos(_ view: UITextView, _ todo: (()->Void)?){
        let originLoc = view.contentOffset
        let tmpSelect = selectedRange
        
        todo?()
        
        view.selectedRange = tmpSelect
        view.scrollRectToVisible(CGRect(origin: originLoc, size: view.visibleSize), animated: false)
    }
}

extension UIFont{
    var isBold: Bool{
        get{
            var bold = false
            
            // multi lang. work around before finding a better solution.
            for i in self.fontDescriptor.fontAttributes{
                if let value = i.value as? String{
                    if value.lowercased().contains("bold"){
                        bold = true
                        break
                    }
                }
            }
            
            return bold
        }
    }
}
