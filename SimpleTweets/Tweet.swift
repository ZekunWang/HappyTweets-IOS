//
//  Tweet.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/3/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import RealmSwift

class Tweet: Object {
    static let ID_STR = "id_str"
    static let TEXT = "text"
    static let CREATED_AT = "created_at"
    static let RETWEETED = "retweeted"
    static let FAVORITED = "favorited"
    static let RETWEET_COUNT = "retweet_count"
    static let FAVORITE_COUNT = "favorite_count"
    static let USER = "user"
    static let RETWEETED_STATUS = "retweeted_status"
    static let IN_REPLY_TO_STATUS_ID = "in_reply_to_status_id_str"
    
    static let isUpdated: Bool = false
    
    dynamic var tidStr = ""
    dynamic var text: String = ""
    dynamic var retweetCount: Int = 0
    dynamic var favoriteCount: Int = 0
    dynamic var favorited: Bool = false
    dynamic var retweeted: Bool = false
    dynamic var inReplyToStatusId: String?
    dynamic var user: User!
    dynamic var timestamp: NSDate?
    dynamic var retweetedStatus: Tweet?
    
    // Remaining useful keys
    /*
    // Get hashtags
    JSONArray mentions = jsonObject.getJSONObject("entities").getJSONArray("user_mentions");
    tweet.userMentions = new String[mentions.length()];
    for (int i = 0; i < mentions.length(); i++) {
    tweet.userMentions[i] = mentions.getJSONObject(i).getString("screen_name");
    }
     // Get media
     if (jsonObject.has("extended_entities")) {
     JSONObject extendedEntities = jsonObject.getJSONObject("extended_entities");
     if (extendedEntities != null) {
     JSONArray media = extendedEntities.getJSONArray("media");
     if (media != null) {
     tweet.media = Medium.fromJSONArray(media, tweet);
     }
     }
     }
    */
    
    override static func primaryKey() -> String? {
        return "tidStr"
    }
    
    override static func indexedProperties() -> [String] {
        return ["tidStr"]
    }
    
    func fromUserDictionary(dictionary: NSDictionary) {
        tidStr = dictionary[Tweet.ID_STR] as! String
        text = dictionary[Tweet.TEXT] as! String
        retweeted = (dictionary[Tweet.RETWEETED] as? Bool) ?? false
        favorited = (dictionary[Tweet.FAVORITED] as? Bool) ?? false
        retweetCount = (dictionary[Tweet.RETWEET_COUNT] as? Int) ?? 0
        favoriteCount = (dictionary[Tweet.FAVORITE_COUNT] as? Int) ?? 0
        
        // Get in reply to status info
        inReplyToStatusId = dictionary[Tweet.IN_REPLY_TO_STATUS_ID] as? String // NSNull or tidStr
        if (dictionary[Tweet.IN_REPLY_TO_STATUS_ID] as? NSNull) != nil {
            inReplyToStatusId = nil
            print("in_reply_to_status_id_str is null")
        } else {
            inReplyToStatusId = dictionary[Tweet.IN_REPLY_TO_STATUS_ID] as? String
            print("in_reply_to_status_id_str is not null: \(inReplyToStatusId)")
        }
        
        // Get user info
        let userDictionary = dictionary[Tweet.USER] as! NSDictionary
        user = User.findOrCreate(dictionary: userDictionary)
        
        // Get date info
        let timeStampString = dictionary[Tweet.CREATED_AT] as? String
        if timeStampString != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            
            timestamp = formatter.date(from: timeStampString! as String) as NSDate?
        }
        
        // Get retweeted status info
        if let status = dictionary[Tweet.RETWEETED_STATUS] {
            retweetedStatus = Tweet.findOrCreate(dictionary: status as! NSDictionary)
        }
    }
    
    // Find existing tweet or create new tweet
    class func findOrCreate(dictionary: NSDictionary) -> Tweet {
        var tweet: Tweet!
        let tid = dictionary[User.ID_STR] as! String
        let realm = try! Realm()
        tweet = realm.objects(Tweet.self).filter("tidStr = %@", tid).first
        if tweet == nil {
            print("tweet is not found")
            tweet = createAndUpdate(dictionary: dictionary)
        }
        return tweet!
    }
    
    class func saveTweet(tweet: Tweet!) {
        if tweet == nil {
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(tweet, update: true)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = findOrCreate(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
    
    class func findTweetById(tid: String) -> Tweet! {
        var tweet:Tweet!
        let realm = try! Realm()
        tweet = realm.objects(Tweet.self).filter("tidStr = %@", tid).first
        return tweet
    }
    
    class func createAndUpdate(dictionary: NSDictionary) -> Tweet {
        let tweet = Tweet()
        tweet.fromUserDictionary(dictionary: dictionary)
        saveTweet(tweet: tweet)
        return tweet
    }
}
