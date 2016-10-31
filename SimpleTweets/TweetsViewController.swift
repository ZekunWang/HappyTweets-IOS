//
//  TweetsViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/3/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import RealmSwift

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate, TweetDetailViewControllerDelegate, TweetCellDelegate {
    
    let tweetCell = "TweetCell"
    let tweetDetailViewControllerSegueId = "TweetDetailViewControllerSegueId"
    let composeViewController = "ComposeViewController"
    
    @IBOutlet var tweetsTableView: UITableView!
    
    var tweets: [Tweet]!
    var selectedIndexPath: IndexPath!
    var composeButton: UIButton!
    var searchButton: UIButton!
    
    var tableRefreshControl: UIRefreshControl!
    var twitterClient: TwitterClient!
    var isMoreDataLoading = true
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tweetsTableView.register(UINib(nibName: self.tweetCell, bundle: nil), forCellReuseIdentifier: self.tweetCell)
        
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 120
        
        setupNavigationBar()
        
        // Setup refresh control
        tableRefreshControl = UIRefreshControl()
        tableRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tweetsTableView.insertSubview(tableRefreshControl, at: 0)
        
        twitterClient = TwitterClient.sharedInstance
        onRefresh()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tweetsTableView.contentInset = insets
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
        
        let spaceItem = UIBarButtonItem(customView: UIButton(frame: CGRect(x: 0, y: 0, width: 2, height: 30)))
        
        navigationItem.rightBarButtonItems = [composeItem, spaceItem, searchItem]
        navigationItem.leftBarButtonItems?.append(spaceItem)
    }
    
    func onComposeTouchUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeViewController = storyboard.instantiateViewController(withIdentifier: self.composeViewController) as! ComposeViewController
        composeViewController.delegate = self
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    // MARK - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                isMoreDataLoading = true
                
                if tweets == nil || tweets.count == 0 {
                    return
                }
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                let lastTidStr = self.tweets[self.tweets.count - 1].tidStr
                loadDataWithParams(refreshing: self.tableRefreshControl.isRefreshing, sinceId: nil, maxId: Int64(lastTidStr)! - 1)
            }
        }
    }
    
    // MARK - ComposeViewControllerDelegate
    func onComposeTweetSucceeded(tweet: Tweet) {
        print("on compose tweet succeeded")
        self.tweets.insert(tweet, at: 0)
        self.tweetsTableView.reloadData()
    }
    
    // MARK - TweetDetailViewControllerDelegate, TweetCellDelegate
    func onTweetUpdated(tweet: Tweet, indexPath: IndexPath) {
        tweets[indexPath.row] = tweet
        tweetsTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func onRefresh() {
        self.tableRefreshControl.beginRefreshing()
        self.loadDataWithParams(refreshing: self.tableRefreshControl.isRefreshing, sinceId: nil, maxId: nil)
    }
    
    func loadDataWithParams(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        twitterClient?.homeTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId, success: { (tweets: [Tweet]) in
            if self.tableRefreshControl.isRefreshing {
                self.tweets = tweets
            } else {
                self.tweets.append(contentsOf: tweets)
            }
            
            self.tweetsTableView.reloadData()
            print("tweets count: \(self.tweets.count)")
            
            // Stop regreshing sign
            self.tableRefreshControl.endRefreshing()
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
                // Stop regreshing sign
                self.tableRefreshControl.endRefreshing()
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
        })
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets == nil {
            return 0
        }
        
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTableView.dequeueReusableCell(withIdentifier: self.tweetCell, for: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.tweetsViewController = self
        cell.indexPath = indexPath
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        performSegue(withIdentifier: self.tweetDetailViewControllerSegueId, sender: self.tweetsTableView)
        self.tweetsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == self.tweetDetailViewControllerSegueId {
            // Get the new view controller using segue.destinationViewController.
            let tweetDetailViewController = segue.destination as! TweetDetailViewController
            // Pass the selected object to the new view controller.
            tweetDetailViewController.tweetsViewController = self
            tweetDetailViewController.delegate = self
            tweetDetailViewController.indexPath = self.selectedIndexPath
            tweetDetailViewController.tweet = self.tweets[selectedIndexPath.row]
        }
    }

}
