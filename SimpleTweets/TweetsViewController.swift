//
//  TweetsViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/3/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import RealmSwift

protocol TweetsViewControllerDelegate {
    func onTweetSelected(indexPath: IndexPath)
}

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TweetCellDelegate {
    
    let tweetCell = "TweetCell"
    let profileViewControllerString = "ProfileViewController"
    
    @IBOutlet var tweetsTableView: UITableView!
    
    var tweets: [Tweet]!
    var selectedIndexPath: IndexPath!
    
    var delegate: TweetsViewControllerDelegate!
    var tableRefreshControl: UIRefreshControl!
    var twitterClient: TwitterClient!
    var isMoreDataLoading = true
    var loadingMoreView:InfiniteScrollActivityView?
    
    var timelineType: TimelineType! {
        didSet {
            print("timeline type: \(timelineType)")
            onRefresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tweetsTableView.register(UINib(nibName: self.tweetCell, bundle: nil), forCellReuseIdentifier: self.tweetCell)
        
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 120
        
        twitterClient = TwitterClient.sharedInstance
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tweetsTableView.contentInset = insets
    }
    
    // MARK - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleVideos()
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
    
    func handleVideos() {
        let cells = self.tweetsTableView.visibleCells
        if cells.count == 0 {
            return
        }
        print("first cell height: \(cells[0].frame.height)")
        print("first cell bound : \(cells[0].frame.origin.y - tweetsTableView.contentOffset.y)")
        // TODO - control videos
    }
    
    // MARK - TweetDetailViewControllerDelegate, TweetCellDelegate
    func onTweetUpdated(tweet: Tweet, indexPath: IndexPath) {
        tweets[indexPath.row] = tweet
        tweetsTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func onProfileImageSelected(uidStr: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: self.profileViewControllerString) as! ProfileViewController
        profileViewController.userId = uidStr
        present(profileViewController, animated: true, completion: nil)
    }
    
    func addPullToRefresh() {
        // Setup refresh control
        tableRefreshControl = UIRefreshControl()
        tableRefreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tweetsTableView.insertSubview(tableRefreshControl, at: 0)
    }
    
    func onRefresh() {
        self.tableRefreshControl?.beginRefreshing()
        self.loadDataWithParams(refreshing: self.tableRefreshControl?.isRefreshing ?? false, sinceId: nil, maxId: nil)
    }
    
    func addTweetToTop(tweet: Tweet) {
        self.tweets.insert(tweet, at: 0)
        self.tweetsTableView.reloadData()
    }
    
    func loadDataWithParams(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        if self.timelineType == nil {
            print("timeline type is nil")
            return
        }
        
        switch self.timelineType! {
        case .home:
            loadHomeTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId)
        case .mentions:
            loadMentionsTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId)
        default: break
        }
    }
    
    func loadHomeTimeline(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        twitterClient?.homeTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId, success: { (tweets: [Tweet]) in
            if refreshing {
                self.tweets = tweets
            } else {
                self.tweets.append(contentsOf: tweets)
            }
            
            self.tweetsTableView.reloadData()
            print("tweets count: \(self.tweets.count)")
            
            // Stop regreshing sign
            self.tableRefreshControl?.endRefreshing()
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
                // Stop regreshing sign
                self.tableRefreshControl?.endRefreshing()
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
        })
    }
    
    func loadMentionsTimeline(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        twitterClient?.mentionsTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId, success: { (tweets: [Tweet]) in
            if refreshing {
                self.tweets = tweets
            } else {
                self.tweets.append(contentsOf: tweets)
            }
            
            self.tweetsTableView.reloadData()
            print("tweets count: \(self.tweets.count)")
            
            // Stop regreshing sign
            self.tableRefreshControl?.endRefreshing()
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
                // Stop regreshing sign
                self.tableRefreshControl?.endRefreshing()
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
        })
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
        self.delegate.onTweetSelected(indexPath: indexPath)
        self.tweetsTableView.deselectRow(at: indexPath, animated: true)
    }

}
