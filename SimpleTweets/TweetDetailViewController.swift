//
//  TweetDetailViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/29/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import RealmSwift

protocol TweetDetailViewControllerDelegate {
    func onTweetUpdated(tweet: Tweet, indexPath: IndexPath)
}

class TweetDetailViewController: UIViewController {
    
    let composeViewController = "ComposeViewController"
    
    @IBOutlet var retweetMessageView: UIView!
    @IBOutlet var retweetMessageLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var retweetButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var mediaView: UIView!
    @IBOutlet var mediaImageView: UIImageView!
    
    @IBOutlet var mediaImageWidth: NSLayoutConstraint!
    @IBOutlet var mediaImageHeight: NSLayoutConstraint!
    var targetTweet: Tweet!
    var tweet: Tweet!
    
    var composeButton: UIButton!
    var searchButton: UIButton!
    
    var delegate: TweetDetailViewControllerDelegate!
    var tweetsViewController: TweetsViewController!
    var indexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("tweet detail viewDidLoad")
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        mediaImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        
        setupNavigationBar()
        
        let searchTweet = Tweet.findTweetById(tid: tweet.tidStr)
        print("      tweet: \(tweet.tidStr)")
        print("searchTweet: \(searchTweet?.tidStr)")
        
        if tweet == nil {
            return
        }
        self.targetTweet = self.tweet
        
        if let retweetedStatus = self.tweet.retweetedStatus {
            targetTweet = retweetedStatus
            
            retweetMessageLabel.text = "\(self.tweet.user.name) Retweeted"
            retweetMessageView.isHidden = false
        } else {
            retweetMessageView.isHidden = true
        }
        
        profileImageView.setImageWith(URL(string: targetTweet.user.profileUrl)!)
        nameLabel.text = targetTweet.user.name
        screennameLabel.text = "@\(targetTweet.user.screenname)"
        contentLabel.text = targetTweet.text
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy, HH:mm"
        timeLabel.text = formatter.string(from: targetTweet.timestamp as! Date)
        
        if let medium = targetTweet.medium {
            mediaImageHeight.constant = (mediaImageWidth.constant) / CGFloat(medium.ratio)
            mediaImageView.setImageWith(URL(string: medium.mediaUrl)!)
            mediaView.isHidden = false
        } else {
            mediaView.isHidden = true
        }
        
        showActionViews()
    }
    
    func showActionViews() {
        retweetCountLabel.text = Helper.formatNumber(number: NSNumber(value: targetTweet.retweetCount))
        favoriteCountLabel.text = Helper.formatNumber(number: NSNumber(value: targetTweet.favoriteCount))
        
        let retweetImage = UIImage(named: "retweet")?.withRenderingMode(.alwaysTemplate)
        let favoriteImage = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
        retweetButton.setImage(retweetImage, for: .normal)
        favoriteButton.setImage(favoriteImage, for: .normal)
        print("targetTweet favorited: \(targetTweet.favorited)")
        if targetTweet.favorited {
            favoriteButton.tintColor = AppConstants.tweet_red
        } else {
            favoriteButton.tintColor = AppConstants.tweet_mid_gray
        }
    
        if targetTweet.retweeted {
            retweetButton.tintColor = AppConstants.tweet_blue
        } else {
            retweetButton.tintColor = AppConstants.tweet_mid_gray
        }
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Tweet"
        
        composeButton = UIButton(type: .custom)
        composeButton.setImage(UIImage(named: "compose"), for: .normal)
        composeButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        composeButton.addTarget(self, action: #selector(onComposeTouchUp), for: .touchUpInside)
        let composeItem = UIBarButtonItem(customView: composeButton)
        
        searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        let searchItem = UIBarButtonItem(customView: searchButton)
        
        let spaceItem = UIBarButtonItem(customView: UIButton(frame: CGRect(x: 0, y: 0, width: 2, height: 30)))
        
        navigationItem.rightBarButtonItems = [composeItem, spaceItem, searchItem]
    }
    
    @IBAction func onReply(_ sender: AnyObject) {
        onComposeTouchUp()
    }
    
    func onComposeTouchUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeViewController = storyboard.instantiateViewController(withIdentifier: self.composeViewController) as! ComposeViewController
        composeViewController.delegate = tweetsViewController
        composeViewController.repliedToTweet = tweet
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    @IBAction func onRetweetChanged(_ sender: AnyObject) {
        if targetTweet.retweeted {
            TwitterClient.sharedInstance?.unSetRetweet(tweet: targetTweet, success: { (tweet: Tweet) in
                let realm = try! Realm()
                try! realm.write {
                    self.targetTweet.retweeted = false
                    self.targetTweet.retweetCount -= 1
                }
                self.showActionViews()
                self.delegate?.onTweetUpdated(tweet: self.tweet, indexPath: self.indexPath)
                }, failure: { (error: Error) in
                    return
            })
        } else {
            TwitterClient.sharedInstance?.setRetweet(tweet: targetTweet, success: { (tweet: Tweet) in
                let realm = try! Realm()
                try! realm.write {
                    self.targetTweet.retweeted = true
                    self.targetTweet.retweetCount += 1
                }
                self.showActionViews()
                self.delegate?.onTweetUpdated(tweet: self.tweet, indexPath: self.indexPath)
                }, failure: { (error: Error) in
                    return
            })
        }
    }
    
    @IBAction func onFavoriteChanged(_ sender: AnyObject) {
        if targetTweet.favorited {
            TwitterClient.sharedInstance?.unSetFavorite(tweet: targetTweet, success: { (tweet: Tweet) in
                let realm = try! Realm()
                try! realm.write {
                    self.targetTweet.favorited = false
                    self.targetTweet.favoriteCount -= 1
                }
                self.showActionViews()
                self.delegate?.onTweetUpdated(tweet: self.tweet, indexPath: self.indexPath)
                }, failure: { (error: Error) in
                    return
            })
        } else {
            TwitterClient.sharedInstance?.setFavorite(tweet: targetTweet, success: { (tweet: Tweet) in
                let realm = try! Realm()
                try! realm.write {
                    self.targetTweet.favorited = true
                    self.targetTweet.favoriteCount += 1
                }
                self.showActionViews()
                self.delegate?.onTweetUpdated(tweet: self.tweet, indexPath: self.indexPath)
                }, failure: { (error: Error) in
                    return
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
