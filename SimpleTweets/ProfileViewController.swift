//
//  ProfileViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/5/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, TweetCellDelegate {
    
    let tweetCell = "TweetCell"
    let mediumCell = "MediumCell"
    let composeViewControllerString = "ComposeViewController"
    let profileViewControllerString = "ProfileViewController"
    let minHeaderHeight: CGFloat = 40
    let minDistance: CGFloat = 30

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var taglineLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCount: UILabel!
    
    @IBOutlet var bannerImageView: UIImageView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var composeButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var headerInfoView: UIView!
    @IBOutlet var headerNameLabel: UILabel!
    @IBOutlet var headerStatusesCountLabel: UILabel!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var segmentedView: UIView!
    
    var isMoreDataLoading = true
    var loadingMoreView:InfiniteScrollActivityView?
    var twitterClient: TwitterClient!
    
    var blurView: UIVisualEffectView!
    var tweets: [Tweet]!
    var timelineType: TimelineType = .user
    var userId: String!
    var user: User! {
        didSet {
            if user == nil {
                return
            }
            //bannerImageView.setImageWith(URL(string: user.bannerUrl)!, placeholderImage: #imageLiteral(resourceName: "default-placeholder"))
            print("bannerUrl; \(user.bannerUrl)")
            profileImageView.setImageWith(URL(string: user.profileUrl)!)
            nameLabel.text = user.name
            screennameLabel.text = "@\(user.screenname)"
            taglineLabel.text = user.tagline
            followersCount.text = Helper.formatNumber(number: NSNumber(value: user.followersCount))
            followingCountLabel.text = Helper.formatNumber(number: NSNumber(value: user.friendsCount))
            
            headerNameLabel.text = user.name
            let formattedCount = Helper.formatNumber(number: NSNumber(value: user.statusesCount))
            headerStatusesCountLabel.text = "\(formattedCount) Tweets"

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Profile imageview
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        twitterClient = TwitterClient.sharedInstance
        self.tableView.register(UINib(nibName: self.tweetCell, bundle: nil), forCellReuseIdentifier: self.tweetCell)
        self.tableView.register(UINib(nibName: self.mediumCell, bundle: nil), forCellReuseIdentifier: self.mediumCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // status bar
        UIApplication.shared.statusBarStyle = .lightContent
        user = User.findUserById(uid: self.userId!)
        onReloadTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Button
        let backImageView = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysTemplate)
        let searchImageView = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        let composeImageView = UIImage(named: "compose")?.withRenderingMode(.alwaysTemplate)
        
        backButton.setImage(backImageView, for: .normal)
        searchButton.setImage(searchImageView, for: .normal)
        composeButton.setImage(composeImageView, for: .normal)
        
        backButton.tintColor = UIColor.white
        searchButton.tintColor = UIColor.white
        composeButton.tintColor = UIColor.white
        
        if userId == User.getCurrentUserId() {
            backButton.isHidden = true
        } else {
            backButton.isHidden = false
        }
        
        // Add blur effect
        let headerImageView = UIImageView(frame: headerView.bounds)
        headerImageView.setImageWith(URL(string: user.bannerUrl)!)
        headerImageView.contentMode = UIViewContentMode.scaleAspectFill
        headerView.insertSubview(headerImageView, belowSubview:  headerInfoView)
        
        let lightBlurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: lightBlurEffect)
        blurView.frame = bannerImageView.frame
        blurView.alpha = 0
        headerView.insertSubview(blurView, belowSubview: headerInfoView)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        print("headerview   Height: \(headerView.frame.height)")
        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        // Set segmentedView position according to changing tagline
        let profileViewHeight = followersCount.frame.maxY + segmentedView.frame.height
        print("profileView   Height: \(profileViewHeight)")
        profileView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: profileViewHeight)
        print("origin before: x:\(segmentedView.frame.origin.x) y: \(segmentedView.frame.origin.y)")
        segmentedView.frame.origin = CGPoint(x: 0, y: profileViewHeight - segmentedView.frame.height + headerView.frame.height)
        print("origin now   : x:\(segmentedView.frame.origin.x) y: \(segmentedView.frame.origin.y)")
    }
    
    // MARK - TweetDetailViewControllerDelegate, TweetCellDelegate
    func onTweetUpdated(tweet: Tweet, indexPath: IndexPath) {
        tweets[indexPath.row] = tweet
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func onProfileImageSelected(uidStr: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: self.profileViewControllerString) as! ProfileViewController
        profileViewController.userId = uidStr
        present(profileViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSwitchSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: timelineType = .user
        case 1: timelineType = .media
        case 2: timelineType = .favorites
        default: timelineType = .user
        }
        onReloadTableView()
    }
    
    func onReloadTableView() {
        tweets = [Tweet]()
        tableView.reloadData()
        
        loadDataWithParams(refreshing: false, sinceId: nil, maxId: nil)
    }
    
    func loadDataWithParams(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        switch self.timelineType {
        case .user: loadUserTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId)
        case .media: loadMediaTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId)
        case .favorites: loadFavoritesTimeline(refreshing: refreshing, sinceId: sinceId, maxId: maxId)
        default: break
        }
    }
    
    func loadUserTimeline(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        twitterClient?.userTimeline(uidStr: userId, refreshing: refreshing, sinceId: sinceId, maxId: maxId, success: { (tweets: [Tweet]) in
            if refreshing {
                self.tweets = tweets
            } else {
                self.tweets.append(contentsOf: tweets)
            }
            
            self.tableView.reloadData()
            print("tweets count: \(self.tweets.count)")
            
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
        })
    }
    
    func loadMediaTimeline(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        twitterClient?.userTimeline(uidStr: userId, refreshing: refreshing, sinceId: sinceId, maxId: maxId, success: { (tweets: [Tweet]) in
            let validTweets = self.getValidTweets(tweets: tweets)
            if refreshing {
                self.tweets = validTweets
            } else {
                self.tweets.append(contentsOf: validTweets)
            }
            
            self.tableView.reloadData()
            print("tweets count: \(self.tweets.count)")
            
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
        })
    }
    
    func getValidTweets(tweets: [Tweet]) -> [Tweet] {
        var validTweets = [Tweet]()
        for tweet in tweets {
            if tweet.user.uidStr == userId && tweet.medium != nil {
                validTweets.append(tweet)
            }
        }
        return validTweets
    }
    
    func loadFavoritesTimeline(refreshing: Bool, sinceId: Int64?, maxId: Int64?) {
        twitterClient?.favoritesTimeline(uidStr: userId, refreshing: refreshing, sinceId: sinceId, maxId: maxId, success: { (tweets: [Tweet]) in
            if refreshing {
                self.tweets = tweets
            } else {
                self.tweets.append(contentsOf: tweets)
            }
            
            self.tableView.reloadData()
            print("tweets count: \(self.tweets.count)")
            
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
        })
    }
    
    @IBAction func onBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCompuse(_ sender: AnyObject) {
        onComposeTouchUp()
    }
    
    func onComposeTouchUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeViewController = storyboard.instantiateViewController(withIdentifier: self.composeViewControllerString) as! ComposeViewController
        //composeViewController.delegate = self
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        if offset < 0 {     // pull down and scale banner image
            let headerScaleFactor = -offset / headerView.bounds.height
            let headerHeightDiff = headerView.bounds.height * headerScaleFactor / 2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerHeightDiff, 0)
            headerTransform = CATransform3DScale(headerTransform, 1 + headerScaleFactor, 1 + headerScaleFactor, 0)
            
            blurView.alpha = min(1, headerHeightDiff / minHeaderHeight)
        } else {        // scroll table view
            // Header view
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-minHeaderHeight, -offset), 0)
            
            // Header label
            let headerInfoOriginHeight = headerView.frame.height + headerInfoView.frame.height + minHeaderHeight - offset
            headerInfoView.frame.origin = CGPoint(x: headerInfoView.frame.origin.x, y: max(headerInfoOriginHeight, minHeaderHeight + minDistance))
            
            // Blur
            blurView.alpha = min(1, (offset - headerInfoOriginHeight) / minDistance)
            
            // Profile image
            let avatarScaleFactor = min(offset, minHeaderHeight) / profileImageView.bounds.height / 1.4
            let avatarHeightDiff = profileImageView.bounds.height * avatarScaleFactor / 2
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarHeightDiff, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1 - avatarScaleFactor, 1 - avatarScaleFactor, 0)
        
            if offset < minHeaderHeight {
                headerView.layer.zPosition = 0
            } else {
                headerView.layer.zPosition = 2
            }
        }
        
        // Apply transforms
        headerView.layer.transform = headerTransform
        profileImageView.layer.transform = avatarTransform
        
        // Update segmented control position
        let segmentHeightDiff = profileView.frame.height - segmentedView.frame.height - offset
        let segmentTransform = CATransform3DTranslate(CATransform3DIdentity, 0, max(segmentHeightDiff, -minHeaderHeight), 0)
        segmentedView.layer.transform = segmentTransform
        
        // Table view scroll indicator
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets == nil ? 0 : tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if timelineType == .media {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.mediumCell, for: indexPath) as! MediumCell
            cell.tweet = tweets[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.tweetCell, for: indexPath) as! TweetCell
            cell.tweet = tweets[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // status bar
        UIApplication.shared.statusBarStyle = .default
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
