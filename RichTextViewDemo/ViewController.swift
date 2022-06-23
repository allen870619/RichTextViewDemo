//
//  ViewController.swift
//  RichTextViewDemo
//
//  Created by Lee Yen Lin on 2022/6/22.
//

import UIKit
import iOSCommonUtils

class ViewController: KBShifterViewController, RichTextViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segFont: UISegmentedControl!
    @IBOutlet var textCtrlList: [UIButton]!
    
    // font
    private var fontSize: CGFloat = 16
    private let fontSizeList: [CGFloat] = [16, 20 ,24]
    
    // protocol
    var mainTextView: UITextView{
        textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shiftMode = .kbHeight // iOSCommonUtils
        
        // start here
        mainTextView.delegate = self
        
        // font size
        segFont.addAction(UIAction{[self] _ in
            let index = segFont.selectedSegmentIndex
            fontSize = fontSizeList[index]
            
            // if text selected, adjust it, otherwise set typeAttribute
            if selectedRange.length == 0{
                let attr = mainTextView.typingAttributes[.font] as? UIFont
                let isBold = attr?.isBold ?? false
                mainTextView.typingAttributes[.font] = UIFont.systemFont(ofSize: fontSize, weight: isBold ? .bold : .regular)
            }else{
                setAttrWithKeepingPos(mainTextView){ [self] in
                    if let originAttr = getAttribute(selectedRange, type: .font) as? [FontRange]{
                        for i in originAttr{
                            let isBold = i.font.isBold
                            setAttribute(.font, value: UIFont.systemFont(ofSize: fontSize, weight: isBold ? .bold : .regular), range: i.range)
                        }
                    }
                }
            }
        }, for: .valueChanged)
        
        // Bold
        textCtrlList[0].addAction(UIAction{ [self] _ in
            if selectedRange.length == 0{
                let attr = mainTextView.typingAttributes[.font] as? UIFont
                let isBold = attr?.isBold ?? false
                mainTextView.typingAttributes[.font] = UIFont.systemFont(ofSize: fontSize, weight: !isBold ? .bold : .regular)
            }else{
                if let attrList = getAttribute(selectedRange, type: .font) as? [FontRange]{
                    setAttrWithKeepingPos(mainTextView){ [self] in
                        var allBold = true
                        for i in attrList{
                            if i.font.isBold == false{
                                allBold = false
                            }
                        }
                        
                        for i in attrList{
                            let size = i.font.pointSize
                            setAttribute(.font, value: UIFont.systemFont(ofSize: size, weight: allBold ? .regular : .bold), range: i.range)
                        }
                    }
                }
            }
        }, for: .touchUpInside)
        
        // I
        textCtrlList[1].addAction(UIAction{ [self] _ in
            if selectedRange.length == 0{
                let attr = mainTextView.typingAttributes[.obliqueness] as? Double
                mainTextView.typingAttributes[.obliqueness] = attr == nil ? 0.3 : nil
            }else{
                setAttrWithKeepingPos(mainTextView){ [self] in
                    let attr = getAttribute(selectedRange, type: .obliqueness) as? [(Double, NSRange)]
                    setAttribute(.obliqueness, value: attr?.last?.0 == nil ? 0.3 : nil)
                }
            }
        }, for: .touchUpInside)
        
        // D
        textCtrlList[2].addAction(UIAction{ [self] _ in
            if selectedRange.length == 0{
                let attr = mainTextView.typingAttributes[.strikethroughStyle] as? Int
                mainTextView.typingAttributes[.strikethroughStyle] = attr == nil ? 1 : nil
            }else{
                setAttrWithKeepingPos(mainTextView){ [self] in
                    let attr = getAttribute(selectedRange, type: .strikethroughStyle) as? [(Int, NSRange)]
                    setAttribute(.strikethroughStyle, value: attr?.last?.0 == nil ? 1 : nil)
                }
            }
        }, for: .touchUpInside)
        
        // U
        textCtrlList[3].addAction(UIAction{ [self] _ in
            
            if selectedRange.length == 0{
                let attr = mainTextView.typingAttributes[.underlineStyle] as? Int
                mainTextView.typingAttributes[.underlineStyle] = attr == nil ? 1 : nil
            }else{
                setAttrWithKeepingPos(mainTextView){ [self] in
                    let attr = getAttribute(selectedRange, type: .underlineStyle) as? [(Int, NSRange)]
                    setAttribute(.underlineStyle, value: attr?.last?.0 == nil ? 1 : nil)
                }
            }
        }, for: .touchUpInside)
        
        // set attribute
        let atrB = NSMutableAttributedString(string: "B")
        atrB.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 0, length: 1))
        textCtrlList[0].setAttributedTitle(atrB, for: .normal)
        
        let atrI = NSMutableAttributedString(string: "I ")
        atrI.addAttribute(.obliqueness, value: 0.3, range: NSRange(location: 0, length: 1))
        textCtrlList[1].setAttributedTitle(atrI, for: .normal)
        
        let atrD = NSMutableAttributedString(string: "D")
        atrD.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: 1))
        textCtrlList[2].setAttributedTitle(atrD, for: .normal)
        
        let atrU = NSMutableAttributedString(string: "U")
        atrU.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 0, length: 1))
        textCtrlList[3].setAttributedTitle(atrU, for: .normal)
        toolbar()
    }
    
    private func toolbar(){
        let bar = UIToolbar()
        let finish = UIBarButtonItem(title: "finish", image: nil, primaryAction: UIAction{[self] _ in
            view.endEditing(true)
        }, menu: nil)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [spacer, finish]
        bar.sizeToFit()
        mainTextView.inputAccessoryView = bar
    }
}

extension ViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDidChangeSelection(textView)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if selectedRange.length == 0{
            // get type attribute
            if let attr = textView.typingAttributes[.font] as? UIFont {
                segFont.selectedSegmentIndex = fontSizeList.firstIndex(of: attr.pointSize) ?? 0
            }
        }else{
            // get selection attribute
            if let attrList = getAttribute(selectedRange, type: .font) as? [FontRange] {
                let set = Set(attrList.map { $0.font.pointSize })
               
                if set.count == 1, let size = set.first{
                    segFont.selectedSegmentIndex = fontSizeList.firstIndex(of: size) ?? 0
                }else{
                    segFont.selectedSegmentIndex = -1
                }
            }
        }
    }
}
