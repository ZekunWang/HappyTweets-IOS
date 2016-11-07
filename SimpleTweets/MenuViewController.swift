//
//  MenuViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/5/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let menuItemCellString = "MenuItemCell"
    let homeNavigationControllerString = "HomeNavigationController"
    let composeViewControllerString = "ComposeViewController"
    let profileViewControllerString = "ProfileViewController"
    let mentionsNavigationControllerString = "MentionsNavigationController"
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    private var homeTimeline: UIViewController!
    private var mentionsTimeline: UIViewController!
    private var profile: ProfileViewController!
    private var selectedIndexPath: IndexPath!
    var viewControllers: [UIViewController] = []
    
    var hamburgerViewController: HamburgerViewController!
    
    var user: User! {
        didSet {
            print("user is \(self.user)")
            profileImageView.setImageWith(URL(string: user.profileUrl)!)
            nameLabel.text = user.name
            screennameLabel.text = "@\(user.screenname)"
        }
    }
    
    var menuItems: [MenuItem] = [
        MenuItem(icon: UIImage(named: "home")!, label: "Home", menuItemType: .homeTimeline),
        MenuItem(icon: UIImage(named: "notification")!, label: "Mentions", menuItemType: .mentionsTimeline),
        MenuItem(icon: UIImage(named: "profile")!, label: "Me", menuItemType: .profile)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        
        self.tableView.register(UINib(nibName: self.menuItemCellString, bundle: nil), forCellReuseIdentifier: self.menuItemCellString)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.homeTimeline = storyboard.instantiateViewController(withIdentifier: self.homeNavigationControllerString)
        self.mentionsTimeline = storyboard.instantiateViewController(withIdentifier: self.mentionsNavigationControllerString)
        self.profile = storyboard.instantiateViewController(withIdentifier: self.profileViewControllerString) as! ProfileViewController
        self.profile.userId = User.getCurrentUserId()
        viewControllers.append(homeTimeline)
        viewControllers.append(mentionsTimeline)
        viewControllers.append(profile)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("user is \(User.getCurrentUserId())")
        let currentUser = User.getCurrentUser()
        if currentUser == nil {
            TwitterClient.sharedInstance?.curretAccount(success: { (user: User) in
                self.user = user
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        } else {
            self.user = currentUser
        }
        selectMenuItem(indexPath: IndexPath(row: 0, section: 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.menuItemCellString, for: indexPath) as! MenuItemCell
        print("row: \(indexPath.row) section: \(indexPath.section)")
        cell.menuItem = menuItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hamburgerViewController?.closeMenu()
        selectMenuItem(indexPath: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func selectMenuItem(indexPath: IndexPath) {
        if let i = selectedIndexPath {
            let cell = tableView.cellForRow(at: i) as! MenuItemCell
            cell.iconImageView.tintColor = AppConstants.tweet_dark_gray
        }
        print("row: \(indexPath.row) section: \(indexPath.section)")
        let targetCell = tableView.cellForRow(at: indexPath) as! MenuItemCell
        targetCell.iconImageView.tintColor = AppConstants.tweet_blue
        hamburgerViewController?.containerViewController = viewControllers[indexPath.row]
        selectedIndexPath = indexPath
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
