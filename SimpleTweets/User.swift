//
//  User.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/3/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {
    static let ID_STR = "id_str"
    static let NAME = "name"
    static let SCREEN_NAME = "screen_name"
    static let PROFILE_IMAGE_URL = "profile_image_url_https"
    static let PROFILE_BANNER_URL = "profile_banner_url"
    static let DESCRIPTION = "description"  // tagline in data field
    static let FRIENDS_COUNT = "friends_count"
    static let FOLLOWERS_COUNT = "followers_count"
    static let FOLLOWING = "following"
    
    static let userIdKey = "userIdKey"
    
    dynamic var uidStr: String = ""
    dynamic var name: String = ""
    dynamic var screenname: String = ""
    dynamic var profileUrl: String = ""
    dynamic var friendsCount: Int = 0
    dynamic var followersCount: Int = 0
    dynamic var following: Bool = false
    dynamic var bannerUrl: String?
    dynamic var tagline: String?
    
    override static func primaryKey() -> String? {
        return "uidStr"
    }
    
    override static func indexedProperties() -> [String] {
        return ["uidStr"]
    }
    
    func fromUserDictionary(dictionary: NSDictionary) {
        uidStr = (dictionary[User.ID_STR] as? String)!
        name = (dictionary[User.NAME] as? String)!
        screenname = (dictionary[User.SCREEN_NAME] as? String)!
        profileUrl = (dictionary[User.PROFILE_IMAGE_URL] as? String)!
        friendsCount = (dictionary[User.FRIENDS_COUNT] as? Int) ?? 0
        followersCount = (dictionary[User.FOLLOWERS_COUNT] as? Int) ?? 0
        following = (dictionary[User.FOLLOWING] as? Bool) ?? false
        
        if let taglineString = (dictionary[User.DESCRIPTION] as? String) {
            tagline = taglineString
        }
        if let bannerUrlString = dictionary[User.PROFILE_BANNER_URL] as? String {
            bannerUrl = bannerUrlString
        }
    }
    
    static let CURRENT_USER_ID = "currentUserId"
    static let USER_DID_LOG_OUT = "userDidLogout"
    static var _currentUserId: String?
    
    static var currentUserId: String? {
        get {
            if _currentUserId == nil {
                let defaults = UserDefaults.standard
                _currentUserId = defaults.string(forKey: User.CURRENT_USER_ID)
            }
            return _currentUserId
        }
        
        set(userId) {
            _currentUserId = userId
            
            let defaults = UserDefaults.standard
            
            if let userId = userId {
                defaults.set(userId, forKey: User.CURRENT_USER_ID)
            } else {
                defaults.set(nil, forKey: User.CURRENT_USER_ID)
            }
            
            defaults.synchronize()
        }
    }
    
    // Find existing user or create new user
    class func findOrCreate(dictionary: NSDictionary) -> User {
        var user: User!
        let uid = dictionary[User.ID_STR] as! String
        let realm = try! Realm()
        user = realm.objects(User.self).filter("uidStr = %@", uid).first
        if user == nil {
            print("user is nil")
            user = createAndUpdate(dictionary: dictionary)
        }
        return user!
    }
    
    class func saveUser(user: User!) {
        if user == nil {
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(user, update: true)
        }
    }
    
    class func findUserById(uid: String) -> User! {
        var user: User!
        let realm = try! Realm()
        user = realm.objects(User.self).filter("uidStr = %@", uid).first
        return user
    }
    
    class func saveCurrentUserId(userId: String) {
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: self.userIdKey)
        defaults.synchronize()
    }
    
    class func getCurrentUserId() -> String! {
        var userId: String!
        let defaults = UserDefaults.standard
        userId = defaults.string(forKey: self.userIdKey)
        return userId
    }
    
    class func getCurrentUser() -> User! {
        var user: User!
        let userId = getCurrentUserId()
        user = findUserById(uid: userId!)
        return user
    }
    
    class func createAndUpdate(dictionary: NSDictionary) -> User {
        let user = User()
        user.fromUserDictionary(dictionary: dictionary)
        saveUser(user: user)
        return user
    }
}
