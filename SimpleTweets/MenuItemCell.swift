//
//  MenuItemCell.swift
//  SimpleTweets
//
//  Created by Zekun Wang on 11/5/16.
//  Copyright © 2016 Zekun Wang. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var iconLabel: UILabel!
    
    var menuItem: MenuItem! {
        didSet {
            iconImageView.image = menuItem.icon
            iconLabel.text = menuItem.label
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
