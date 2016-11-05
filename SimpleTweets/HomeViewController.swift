//
//  HomeViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/4/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, ComposeViewControllerDelegate, TweetsViewControllerDelegate,TweetDetailViewControllerDelegate {
    
    let composeViewControllerString = "ComposeViewController"
    let tweetDetailViewControllerString = "TweetDetailViewController"
    let tweetsViewControllerString = "TweetsViewController"
    
    var composeButton: UIButton!
    var searchButton: UIButton!
    var hamburgerButton: UIButton!
    
    var selectedIndexPath: IndexPath!
    
    var hamburgerViewController: HamburgerViewController!
    var tweetsViewController: TweetsViewController! {
        didSet {
            tweetsViewController.view?.frame = self.view.frame
            self.view.addSubview(tweetsViewController.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        tweetsViewController = mainStoryboard.instantiateViewController(withIdentifier: self.tweetsViewControllerString) as! TweetsViewController
        //tweetsViewController.timelineViewController = self
        tweetsViewController.delegate = self
        tweetsViewController.addPullToRefresh()
        tweetsViewController.timelineType = .home
        // Do any additional setup after loading the view.
    }
    
    func setupNavigationBar() {
        let imageTitle = UIImage(named: "twitter_logo_blue")
        let logoImageView = UIImageView(image: imageTitle)
        logoImageView.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        logoImageView.contentMode = UIViewContentMode.scaleAspectFit
        navigationItem.titleView = logoImageView
        
        composeButton = UIButton(type: .custom)
        composeButton.contentMode = UIViewContentMode.scaleAspectFit
        composeButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        composeButton.setImage(UIImage(named: "compose"), for: .normal)
        composeButton.addTarget(self, action: #selector(onComposeTouchUp), for: .touchUpInside)
        let composeItem = UIBarButtonItem(customView: composeButton)
        
        searchButton = UIButton(type: .custom)
        searchButton.contentMode = UIViewContentMode.scaleAspectFit
        searchButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        let searchItem = UIBarButtonItem(customView: searchButton)
        
//        hamburgerButton = UIButton(type: .custom)
//        hamburgerButton.contentMode = UIViewContentMode.scaleAspectFit
//        hamburgerButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        hamburgerButton.setImage(UIImage(named: "hamburger"), for: .normal)
//        hamburgerButton.addTarget(self, action: #selector(onHamburgerTouchUp), for: .touchUpInside)
//        let hamburgerItem = UIBarButtonItem(customView: hamburgerButton)
        
        let spaceItem = UIBarButtonItem(customView: UIButton(frame: CGRect(x: 0, y: 0, width: 2, height: 30)))
        let wideSpaceItem = UIBarButtonItem(customView: UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 30)))
        
        navigationItem.rightBarButtonItems = [composeItem, spaceItem, searchItem]
        navigationItem.leftBarButtonItems = [wideSpaceItem, spaceItem, wideSpaceItem]
    }
    
    func onHamburgerTouchUp() {
        hamburgerViewController?.openMenu()
    }
    
    func onComposeTouchUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeViewController = storyboard.instantiateViewController(withIdentifier: self.composeViewControllerString) as! ComposeViewController
        //composeViewController.delegate = self
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    // MARK - ComposeViewControllerDelegate
    func onComposeTweetSucceeded(tweet: Tweet) {
        print("on compose tweet succeeded")
        tweetsViewController.addTweetToTop(tweet: tweet)
    }
    
    // MARK - TweetDetailViewController
    func onTweetUpdated(tweet: Tweet, indexPath: IndexPath) {
        tweetsViewController.onTweetUpdated(tweet: tweet, indexPath: indexPath)
    }
    
    // MARK - TweetsViewControllerDelegate
    func onTweetSelected(indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tweetDetailViewController = storyboard.instantiateViewController(withIdentifier: self.tweetDetailViewControllerString) as! TweetDetailViewController
        
        // Pass the selected object to the new view controller.
        //tweetDetailViewController.timelineViewController = self
        tweetDetailViewController.delegate = self
        tweetDetailViewController.indexPath = indexPath
        tweetDetailViewController.tweet = tweetsViewController.tweets[indexPath.row]
        
        self.navigationController?.pushViewController(tweetDetailViewController, animated: true)
    }
    
    func onLogoutButton() {
        TwitterClient.sharedInstance?.logout()
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
