//
//  HamburgerViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/4/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    let menuViewControllerString = "MenuViewController"
    
    @IBOutlet var menuView: UIView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var containerViewLeadingConstraint: NSLayoutConstraint!
    
    var containerOriginalLeftMargin: CGFloat!
    var containerOpenedLeftMargin: CGFloat!
    var isOpened: Bool = false
    
    var menuViewController: MenuViewController! {
        didSet {
            menuViewController.view.frame = menuView.frame
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var containerViewController: UIViewController! {
        didSet(oldContainerViewController) {
            if oldContainerViewController != nil {
                oldContainerViewController.willMove(toParentViewController: nil)
                oldContainerViewController.view.removeFromSuperview()
                oldContainerViewController.didMove(toParentViewController: nil)
            }
            
            containerViewController.willMove(toParentViewController: self)
            containerView.addSubview(containerViewController.view)
            containerViewController.didMove(toParentViewController: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.menuViewController = storyboard.instantiateViewController(withIdentifier: self.menuViewControllerString) as! MenuViewController
        self.menuViewController.hamburgerViewController = self
        
        // status bar
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerOpenedLeftMargin = menuView.bounds.width
    }
    
    @IBAction func onContainerPanned(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self.view)
        let transition = sender.translation(in: self.view)
        let velocity = sender.velocity(in: self.view)
        
        if sender.state == .began {
            containerOriginalLeftMargin = containerViewLeadingConstraint.constant
        } else if sender.state == .changed {
            let currentLeftMargin = containerOriginalLeftMargin + transition.x
            if currentLeftMargin < 0 || currentLeftMargin > menuView.bounds.width {
                return
            }
            containerViewLeadingConstraint.constant = currentLeftMargin
        } else if sender.state == .ended {
            print("pan closed")
            if velocity.x > 0 {
                openMenu()
            } else if velocity.x < 0 {
                closeMenu()
            }
        }
    }
    
    func openMenu() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewLeadingConstraint.constant = CGFloat(self.containerOpenedLeftMargin)
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.94)
            self.view.layoutIfNeeded()
        }
        self.isOpened = true
    }
    
    func closeMenu() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewLeadingConstraint.constant = CGFloat(0)
            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.layoutIfNeeded()
        }
        self.isOpened = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
