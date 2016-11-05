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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    private var homeTimeline: UIViewController!
    private var selectedIndexPath: IndexPath!
    var viewControllers: [UIViewController] = []
    
    var hamburgerViewController: HamburgerViewController!
    
    var user: User! {
        didSet {
            profileImageView.setImageWith(URL(string: user.profileUrl)!)
            nameLabel.text = user.name
            screennameLabel.text = "@\(user.screenname)"
        }
    }
    
    var menuItems: [MenuItem] = [
        MenuItem(icon: UIImage(named: "home")!, label: "Home", menuItemType: .homeTimeline)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        
        self.tableView.register(UINib(nibName: self.menuItemCellString, bundle: nil), forCellReuseIdentifier: self.menuItemCellString)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.homeTimeline = storyboard.instantiateViewController(withIdentifier: self.homeNavigationControllerString)
        viewControllers.append(homeTimeline)
        
        self.user = User.getCurrentUser()
        // Do any additional setup after loading the view.
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
