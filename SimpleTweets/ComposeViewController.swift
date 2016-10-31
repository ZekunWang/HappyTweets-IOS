//
//  ComposeViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/29/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

protocol ComposeViewControllerDelegate {
    func onComposeTweetSucceeded(tweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {

    let maxCount: Int = 140
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var tweetButton: UIButton!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var hintTextField: UITextField!
    @IBOutlet var replyHintView: UIView!
    @IBOutlet var replyHintLabel: UILabel!
    
    @IBOutlet var tweetButtonBottomMargin: NSLayoutConstraint!
    
    var delegate: ComposeViewControllerDelegate!
    
    var user: User!
    var targetTweet: Tweet!
    var repliedToTweet: Tweet!
    var remainCount: Int! = 140
    var twitterClient: TwitterClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        self.contentTextView.delegate = self
        
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        tweetButton.layer.cornerRadius = 10
        tweetButton.layer.borderWidth = 1
        
        user = User.getCurrentUser()
        
        if repliedToTweet != nil {
            replyHintView.isHidden = false
            targetTweet = repliedToTweet
            if let status = repliedToTweet.retweetedStatus {
                targetTweet = status
            }
            replyHintLabel.text = "In reply to \(targetTweet.user.name)"
            contentTextView.text = "@\(targetTweet.user.screenname) "
            contentTextView.textColor = UIColor.black
            textViewDidChange(contentTextView)
        } else {
            replyHintView.isHidden = true
            showViews()
        }
        
        profileImageView.setImageWith(URL(string: user.profileUrl)!)
        contentTextView.becomeFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        remainCount = maxCount - (contentTextView.text?.characters.count)!
        counterLabel.text = String(remainCount)
        showViews()
    }
    
    func showViews() {
        if remainCount >= 0 && remainCount < 140 {
            if remainCount >= 20 {
                counterLabel.textColor = UIColor.black
            } else {
                counterLabel.textColor = AppConstants.tweet_red
            }
            
            hintTextField.isHidden = true
            tweetButton.backgroundColor = AppConstants.tweet_blue
            tweetButton.setTitleColor(UIColor.white, for: .normal)
            tweetButton.layer.borderColor = AppConstants.tweet_blue.cgColor
        } else {
            if remainCount == 140 {
                hintTextField.isHidden = false
                counterLabel.textColor = UIColor.black
            } else {
                hintTextField.isHidden = true
                counterLabel.textColor = AppConstants.tweet_red
            }
            
            tweetButton.backgroundColor = UIColor.clear
            tweetButton.setTitleColor(AppConstants.tweet_mid_gray, for: .normal)
            tweetButton.layer.borderColor = AppConstants.tweet_mid_gray.cgColor
        }
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        contentTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCompose(_ sender: AnyObject) {
        if remainCount < 0 || remainCount == 140 {
            return
        }
        
        twitterClient = TwitterClient.sharedInstance
        composeTweet()
    }
    
    func composeTweet() {
        let newTweet = Tweet()
        newTweet.text = contentTextView.text
        
        if targetTweet != nil {
            newTweet.inReplyToStatusId = targetTweet.tidStr
        }
        
        twitterClient?.composeTweet(tweet: newTweet, success: { (tweet: Tweet) in
            self.delegate?.onComposeTweetSucceeded(tweet: tweet)
            self.onCancel(self.tweetButton)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        print("keybord height: \(keyboardFrame.size.height)")
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.tweetButtonBottomMargin.constant = keyboardFrame.size.height + 10
        })
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
