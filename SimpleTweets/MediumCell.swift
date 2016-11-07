//
//  MediumCell.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/6/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class MediumCell: UITableViewCell {

    @IBOutlet var mediumImageView: UIImageView!
    
    var tweet: Tweet! {
        didSet {
            mediumImageView.setImageWith(URL(string: tweet.medium.mediaUrl)!, placeholderImage: #imageLiteral(resourceName: "default-placeholder"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
