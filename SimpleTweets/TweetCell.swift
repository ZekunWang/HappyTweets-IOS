//
//  TweetCell.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/26/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import NSDateMinimalTimeAgo
import RealmSwift

protocol TweetCellDelegate {
    func onTweetUpdated(tweet: Tweet, indexPath: IndexPath)
}

class TweetCell: UITableViewCell {
    
    let composeViewController = "ComposeViewController"
    
    @IBOutlet var retweetMessageImageView: UIImageView!
    @IBOutlet var retweetMessageLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var timeDiffLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var retweetButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var retweetMessageView: UIView!
    @IBOutlet var mediaView: UIView!
    @IBOutlet var mediaImageView: UIImageView!
    
    var tweetsViewController: TweetsViewController!
    var delegate: TweetCellDelegate!
    var indexPath: IndexPath!
    var targetTweet: Tweet!
    var tweet: Tweet! {
        didSet {
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
            
            if let medium = targetTweet.medium {
                mediaImageView.setImageWith(URL(string: medium.mediaUrl)!)
                mediaView.isHidden = false
            } else {
                mediaView.isHidden = true
            }
            
            profileImageView.setImageWith(URL(string: targetTweet.user.profileUrl)!)
            nameLabel.text = targetTweet.user.name
            screennameLabel.text = "@\(targetTweet.user.screenname)"
            contentLabel.text = targetTweet.text
            timeDiffLabel.text = targetTweet.timestamp?.timeAgo()
            retweetCountLabel.text = Helper.formatNumber(number: NSNumber(value: targetTweet.retweetCount))
            favoriteCountLabel.text = Helper.formatNumber(number: NSNumber(value: targetTweet.favoriteCount))
            
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
    }
    
    @IBAction func onRetweetChanged(_ sender: AnyObject) {
        if targetTweet.retweeted {
            TwitterClient.sharedInstance?.unSetRetweet(tweet: targetTweet, success: { (tweet: Tweet) in
                let realm = try! Realm()
                try! realm.write {
                    self.targetTweet.retweeted = false
                    self.targetTweet.retweetCount -= 1
                }
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
                self.delegate?.onTweetUpdated(tweet: self.tweet, indexPath: self.indexPath)
            }, failure: { (error: Error) in
                return
            })
        }
    }
    
    @IBAction func onReply(_ sender: AnyObject) {
        onComposeTouchUp()
    }
    
    func onComposeTouchUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeViewController = storyboard.instantiateViewController(withIdentifier: self.composeViewController) as! ComposeViewController
        composeViewController.delegate = tweetsViewController
        composeViewController.repliedToTweet = tweet
        tweetsViewController.present(composeViewController, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        mediaImageView.layer.cornerRadius = 10
        mediaImageView.clipsToBounds = true
        
        let retweetImage = UIImage(named: "retweet")?.withRenderingMode(.alwaysTemplate)
        let favoriteImage = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
        retweetButton.setImage(retweetImage, for: .normal)
        favoriteButton.setImage(favoriteImage, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
