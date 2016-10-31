//
//  Helper.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/30/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class Helper {
    class func formatNumber(number: NSNumber) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter.string(from: number)!
    }
}
