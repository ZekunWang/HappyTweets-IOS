//
//  TwitterClient.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/3/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import RealmSwift

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: AppConstants.baseURL), consumerKey: AppConstants.consumerKey, consumerSecret: AppConstants.consumerSecret)
    
    func homeTimeline(refreshing: Bool, sinceId: Int64?, maxId: Int64?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String : AnyObject]()
        parameters["count"] = 20 as AnyObject
        
        if let sinceId = sinceId {
            parameters["since_id"] = sinceId as AnyObject
        }
        
        if let maxId = maxId {
            parameters["max_id"] = maxId as AnyObject
        }

        get(AppConstants.homeTimeline, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            if refreshing {
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                self.curretAccount(success: { (user: User) in
                }) { (error: Error) in
                }
            }
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
            }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func composeTweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String : AnyObject]()
        
        parameters["status"] = tweet.text as AnyObject!
        if tweet.inReplyToStatusId != "" {
            parameters["in_reply_to_status_id"] = tweet.inReplyToStatusId as AnyObject!
        }
        
        post(AppConstants.composeTweet, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet.findOrCreate(dictionary: dictionary)
            
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("compose tweet error")
            failure(error)
        })
    }
    
    func setFavorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String : AnyObject]()
        
        parameters["id"] = tweet.tidStr as AnyObject!
        
        post(AppConstants.setFavorite, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet()
            tweet.fromUserDictionary(dictionary: dictionary)
            
            success(tweet)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("set favorite error")
                failure(error)
        })
    }
    
    func unSetFavorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String : AnyObject]()
        
        parameters["id"] = tweet.tidStr as AnyObject!
        
        post(AppConstants.unSetFavorite, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet()
            tweet.fromUserDictionary(dictionary: dictionary)
            
            success(tweet)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("unset favorite error")
                failure(error)
        })
    }
    
    func setRetweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(AppConstants.setRetweet + "\(tweet.tidStr).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet()
            tweet.fromUserDictionary(dictionary: dictionary)
            
            success(tweet)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("set retweet error")
                failure(error)
        })
    }
    
    func unSetRetweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(AppConstants.unSetRetweet + "\(tweet.tidStr).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let tweet = Tweet()
            tweet.fromUserDictionary(dictionary: dictionary)
            
            success(tweet)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("unset retweet error")
                failure(error)
        })
    }
    
    func curretAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(AppConstants.verifyCredentials, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let user = User.findOrCreate(dictionary: response as! NSDictionary)
            
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func setFollow(user: User, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String : AnyObject]()
        
        parameters["user_id"] = user.uidStr as AnyObject!
        
        post(AppConstants.setFollow, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let user = User.createAndUpdate(dictionary: dictionary)
            
            success(user)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("set follow error")
                failure(error)
        })
    }
    
    func unSetFollow(user: User, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String : AnyObject]()
        
        parameters["user_id"] = user.uidStr as AnyObject!
        
        post(AppConstants.unSetFollow, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionary = response as! NSDictionary
            let user = User.createAndUpdate(dictionary: dictionary)
            
            success(user)
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print("unset follow error")
                failure(error)
        })
    }
    
    var loginSeccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSeccess = success
        loginFailure = failure
        
        let callbackURL = URL(string: "SimpleTweets://oauth")
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: callbackURL, scope: nil, success: {(requestToken: BDBOAuth1Credential?) -> Void in
            
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\((requestToken?.token)!)")
            print("url: \(url)")
            
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }, failure: { (error: Error?) -> Void in
            print("Error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        })
    }
    
    func logout() {
        // Clear current user
        User.currentUserId = nil
        // Log out from twitter
        deauthorize()
        // Go to login page
        NotificationCenter.default.post(name: NSNotification.Name(User.USER_DID_LOG_OUT), object: nil)
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print("Got the token")
            
            self.curretAccount(success: { (user: User) in
                User.currentUserId = user.uidStr
                self.loginSeccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
            
        }, failure: { (error: Error?) in
            print("Error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        })
    
    }
}
