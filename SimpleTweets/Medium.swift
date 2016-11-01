//
//  Medium.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/30/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import RealmSwift

class Medium: Object {
    
//    medium.type = jsonObject.getString("type");
//    medium.mediaUrl = jsonObject.getString("media_url");
//    medium.url = jsonObject.getString("url");
//    medium.tweet = tweet;
    static let ID_STR = "id_str"
    static let TYPE = "type"
    static let MEDIA_URL_HTTPS = "media_url_https"
    static let URL = "url"
    static let VIDEO_INFO = "video_info"
    static let VARIANTS = "variants"
    static let BITRATE = "bitrate"
    
    dynamic var midStr: String = ""
    dynamic var type: String!
    dynamic var mediaUrl: String = ""
    dynamic var url: String!
    dynamic var tIdStr: String!
    dynamic var video: String!
    dynamic var ratio: Float = 1.778
    
    var urlSmall: String! {
        return self.mediaUrl != "" ? self.mediaUrl + ":small" : nil
    }
    
    override static func primaryKey() -> String? {
        return "midStr"
    }
    
    override static func indexedProperties() -> [String] {
        return ["midStr"]
    }
    
    class func mediaWithArray(tweet: Tweet, dictionaries: [NSDictionary]) -> [Medium] {
        var media = [Medium]()
        
        for dictionary in dictionaries {
            let medium = findOrCreate(tweet: tweet, dictionary: dictionary)
            media.append(medium)
        }
        
        return media
    }
    
    // Find existing tweet or create new medium
    class func findOrCreate(tweet: Tweet, dictionary: NSDictionary) -> Medium {
        var medium: Medium!
        let mid = dictionary[Medium.ID_STR] as! String
        let realm = try! Realm()
        medium = realm.objects(Medium.self).filter("midStr = %@", mid).first
        if medium == nil {
            print("medium is not found")
            medium = createAndUpdate(tweet: tweet, dictionary: dictionary)
        }
        return medium
    }
    
    // Create and update medium
    class func createAndUpdate(tweet: Tweet, dictionary: NSDictionary) -> Medium {
        let medium = Medium()
        medium.fromUserDictionary(tweet: tweet, dictionary: dictionary)
        saveMedium(medium: medium)
        return medium
    }
    
    func fromUserDictionary(tweet: Tweet, dictionary: NSDictionary) {
        self.midStr = dictionary[Medium.ID_STR] as! String
        self.mediaUrl = dictionary[Medium.MEDIA_URL_HTTPS] as! String
        self.url = dictionary[Medium.URL] as! String
        print("picture: \(self.url)")
        self.type = dictionary[Medium.TYPE] as! String
        self.tIdStr = tweet.tidStr
        
        if let sizes = dictionary["sizes"] {
            let size = (sizes as! NSDictionary)["medium"] as! NSDictionary
            self.ratio = (size["w"] as! Float) / (size["h"] as! Float)
        }
        
        if let vedioInfo = dictionary[Medium.VIDEO_INFO] {
            if let variants = (vedioInfo as! NSDictionary)[Medium.VARIANTS] {
                for videoDict in (variants as! [NSDictionary]) {
                    if let bitrate = videoDict[Medium.BITRATE] {
                        if (bitrate as! Int) < 832000 {
                            self.video = videoDict[Medium.URL] as! String
                            print("video: \(self.video)")
                            break
                        }
                    }
                }
            }
        }
    }
    
    class func saveMedium(medium: Medium!) {
        if medium == nil {
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(medium, update: true)
        }
    }
}
