//
//  AppConstants.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/26/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class AppConstants {
    static let baseURL = "https://api.twitter.com"
    static let consumerKey = "pTdf9vNU69mwzQU0nxI6xI9hz"
    static let consumerSecret = "Nb17paJooVPCpfnpdJEO2oQ2pxBYsluINpB8r77O7uXrhMr4LM"
    
    static let verifyCredentials = "1.1/account/verify_credentials.json"
    static let homeTimeline = "1.1/statuses/home_timeline.json"
    static let composeTweet = "1.1/statuses/update.json"
    static let setFavorite = "1.1/favorites/create.json"
    static let unSetFavorite = "1.1/favorites/destroy.json"
    static let setRetweet = "1.1/statuses/retweet/"
    static let unSetRetweet = "1.1/statuses/unretweet/"
    static let setFollow = "1.1/friendships/create.json"
    static let unSetFollow = "1.1/friendships/destroy.json"
    
    // Colors
    static let tweet_blue = UIColor(red:0.00, green:0.67, blue:0.93, alpha:1.0)
    static let tweet_light_gray = UIColor(red:0.80, green:0.84, blue:0.87, alpha:1.0)
    static let tweet_mid_gray = UIColor(red:0.67, green:0.72, blue:0.76, alpha:1.0)
    static let tweet_dark_gray = UIColor(red:0.38, green:0.46, blue:0.51, alpha:1.0)
    static let tweet_red = UIColor(red:0.89, green:0.15, blue:0.30, alpha:1.0)
}
