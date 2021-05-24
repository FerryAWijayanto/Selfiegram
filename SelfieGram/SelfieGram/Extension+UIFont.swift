//
//  Extension+UIFont.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 16/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit.UIFont

extension UIFont {
    convenience init?(familyName: String, size: CGFloat = UIFont.systemFontSize, variantName: String? = nil) {
        guard let name = UIFont.familyNames.filter({ $0.contains(familyName)}).flatMap({ UIFont.fontNames(forFamilyName: $0)}).filter({ variantName != nil ? $0.contains(variantName!) : true}).first else { return nil }
        
        self.init(name: name, size: size)
    }
}
