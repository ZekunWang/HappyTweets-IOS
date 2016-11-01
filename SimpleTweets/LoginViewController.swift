//
//  LoginViewController.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 10/2/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var iconVerticalCenter: NSLayoutConstraint!
    
    var hasPlayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10
        self.loginButton.alpha = 0
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if hasPlayed {
            self.logoImageView.center = CGPoint(x: self.logoImageView.center.x, y: self.logoImageView.center.y - 100)
            self.loginButton.alpha = 1
            return
        }
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.logoImageView.center = CGPoint(x: self.logoImageView.center.x, y: self.logoImageView.center.y - 100)
        })
        
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.loginButton.alpha = 1
        })
        hasPlayed = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        let twitterClient = TwitterClient.sharedInstance
        twitterClient?.login(success: {
            twitterClient?.curretAccount(success: { (user: User) in
                User.saveCurrentUserId(userId: user.uidStr)
                // Jump to login success page
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }, failure: { (error: Error) in
                    print("Get current user error")
                    twitterClient?.logout()
            })
        }, failure: { (error: Error) in
                
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
