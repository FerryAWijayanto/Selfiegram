//
//  Theme.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 16/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit.UIFont

struct Theme {
    static func apply() {
        guard let headerFont = UIFont(name: "Lobster", size: UIFont.systemFontSize * 2) else {
            NSLog("Failed to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else {
            NSLog("Failed to load application font")
            return
        }
        
        let tintColor = #colorLiteral(red: 0.2196078431, green: 0.137254902, blue: 0.3803921569, alpha: 1)
        
        UIApplication.shared.delegate?.window??.tintColor = tintColor
        
        let navBarLabel = UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        
        let barButton = UIBarButtonItem.appearance()
        let buttonLabel = UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])
        let navBar = UINavigationBar.appearance()
        let label = UILabel.appearance()
        
        // Theming the navigation bar
        navBar.titleTextAttributes = [.font: headerFont]
        
        navBarLabel.font = primaryFont
        
        // Theming label
        label.font = primaryFont
        
        // Theming the button text
        barButton.setTitleTextAttributes([.font: primaryFont], for: .normal)
        barButton.setTitleTextAttributes([.font: primaryFont], for: .highlighted)
        buttonLabel.font = primaryFont
    }
}
