//
//  Constants.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 22/12/24.
//

import UIKit

func setCustomFont(_ name: Font, _ size: CGFloat) -> UIFont {
    guard let font = UIFont(name: name.rawValue, size: size * widthRatio) else {
        return UIFont.systemFont(ofSize: size * widthRatio)
    }
    return font
}

func createAttributedStringWithColorChange(from text: String, targetText: String, targetColor: UIColor) -> NSAttributedString {
    // Create a mutable attributed string with the full text
    let attributedString = NSMutableAttributedString(string: text)
    
    // Find the range of the target text within the full string
    if let range = text.range(of: targetText) {
        let nsRange = NSRange(range, in: text)
        
        // Apply the target color to the target text
        attributedString.addAttribute(.foregroundColor, value: targetColor, range: nsRange)
    }
    
    // Return the modified attributed string
    return attributedString
}
