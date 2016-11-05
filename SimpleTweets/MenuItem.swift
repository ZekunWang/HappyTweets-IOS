//
//  MenuItem.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/5/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class MenuItem: NSObject {

    var icon: UIImage!
    var label: String!
    var menuItemType: MenuItemType!
    
    init(icon: UIImage, label: String, menuItemType: MenuItemType) {
        self.icon = icon.withRenderingMode(.alwaysTemplate)
        self.label = label
        self.menuItemType = menuItemType
    }
}
