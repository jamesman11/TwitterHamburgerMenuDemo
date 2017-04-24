//
//  TweetDetailViewController.swift
//  TwitterDemo
//
//  Created by James Man on 4/13/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
    var tweet:Tweet?
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var favoriteBtn: UIButton!
    @IBOutlet var replyView: UIView!
    @IBOutlet var replyCancel: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var replySend: UIButton!
    var isFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = Helper.UIColorFromHex(rgbValue: 0x3ec8ef, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        setTweet()
    }

    @IBAction func onReplySend(_ sender: Any) {
        let message = textField.text!
        let reply_id = tweet?.id?.description
        TwitterClient.sharedInstance?.tweet(message: message, reply_id: reply_id, success: {(response: Any) -> () in
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TwitterClient.newTweetNotification), object: response)
        }, failure: {(error:Error) -> () in
            print(error.localizedDescription)
        })

    }
    
    @IBAction func onReply(_ sender: Any) {
        let authorName:String = "@\(tweet!.screen_name!)"
        replyView.isHidden = false
        textField.becomeFirstResponder()
        textField.text = "Reply to \(authorName):"
    }
    
    @IBAction func onCancelReply(_ sender: Any) {
        replyView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        isFavorite = !isFavorite
        var image:UIImage?
        if isFavorite {
            image = UIImage(named: "star-filled")
        } else {
            image = UIImage(named: "star")
        }
        favoriteBtn.setImage(image, for: .normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTweet(){
        contentLabel.text = tweet?.text
        timeLabel.text = tweet?.timestamp
        if tweet?.screen_name != nil {
            screenNameLabel.text = "@\(String(describing: tweet!.screen_name!))"
        }
        nameLabel.text = tweet?.name
        imageView.setImageWith((tweet?.profileUrl)!)
    }
}
