//
//  TweetsTableViewCell.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit
class TweetsTableViewCell: UITableViewCell {
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handlerNameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var retweetButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    var tweet: Tweet? 
    var isFavorite: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //instance the UITapGestureRecognizer and inform the method for the action "imageTapped"
        let tap = UITapGestureRecognizer(target: self, action: #selector(TweetsTableViewCell.imageTapped))
        
        //define quantity of taps
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        
        //set the image to the gesture
        profileImage.addGestureRecognizer(tap)
    }
    
    func imageTapped(){
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tapImage"), object: self.tweet)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
