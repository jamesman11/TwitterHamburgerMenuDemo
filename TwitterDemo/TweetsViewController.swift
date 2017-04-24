//
//  TweetsViewController.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tweets: [Tweet] = []
    var profileTweets: [Tweet] = []
    var currentProfileUser: User?
    var originalLeftMargin: CGFloat!
    @IBOutlet var leftMarginConstraint: NSLayoutConstraint!
    @IBOutlet var menuView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var tweetsTableView: UITableView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var profileFollowerCount: UILabel!
    @IBOutlet var profileFollowingCount: UILabel!
    @IBOutlet var profileTweetCount: UILabel!
    @IBOutlet var profileScreenName: UILabel!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileTweetsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        profileTweetsTableView.delegate = self
        profileTweetsTableView.dataSource = self
        profileTweetsTableView.estimatedRowHeight = 100
        profileTweetsTableView.rowHeight = UITableViewAutomaticDimension
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.fetchTimeline(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tweetsTableView.insertSubview(refreshControl, at: 0)
        fetchTimeline(refreshControl)
        
        navigationController?.navigationBar.barTintColor = Helper.UIColorFromHex(rgbValue: 0x3ec8ef, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: TwitterClient.newTweetNotification), object: nil, queue: OperationQueue.main, using: {
            (Notification) -> Void in
                let tweetObject = Notification.object as! NSDictionary
                let tweet = Tweet(data: tweetObject)
                self.tweets.insert(tweet, at: 0)
                self.tweetsTableView.reloadData()
        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "tapImage"), object: nil, queue: OperationQueue.main, using: {
            (Notification) -> Void in
            let tweet = Notification.object as! Tweet
            self.currentProfileUser = tweet.tweeter
            self.setProfileView()
            self.profileView.isHidden = false
            self.tweetsTableView.isHidden = true
            TwitterClient.sharedInstance?.getUserTimeline(user_id: self.currentProfileUser!.id!, success:
                {(tweetsUserTimeline: [Tweet]?) -> () in
                    self.profileTweets = tweetsUserTimeline!
                    self.profileTweetsTableView.reloadData()
            } , failure: {(error:Error) -> () in
                print(error.localizedDescription)
            })
        })
        tweetsTableView.isHidden = false
        profileView.isHidden = true
    }
    
    func fetchTimeline(_ refreshControl:UIRefreshControl){
        TwitterClient.sharedInstance?.homeTimeline(success: {(tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: {(error:Error) -> () in
            print(error.localizedDescription)
        })
    }

    @IBAction func onFavorite(_ sender: AnyObject) {
        let row = sender.tag
        let indexPath = IndexPath(row: row!, section: 0)
        let cell = self.tweetsTableView.cellForRow(at: indexPath) as! TweetsTableViewCell
        cell.isFavorite = !cell.isFavorite
        var image:UIImage?
        if cell.isFavorite {
            image = UIImage(named: "star-filled")
        } else {
            image = UIImage(named: "star")
        }
        cell.favoriteButton.setImage(image, for: .normal)
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == UIGestureRecognizerState.began {
            originalLeftMargin = leftMarginConstraint.constant
        } else if sender.state == UIGestureRecognizerState.changed {
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        } else if sender.state == UIGestureRecognizerState.ended {
            
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = 150
                } else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        }

    }
    @IBAction func onRetweet(_ sender: AnyObject) {
    }
    @IBAction func onReply(_ sender: AnyObject) {
    }
    
    @IBAction func profileOpen(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.profileView.isHidden = false
            self.tweetsTableView.isHidden = true
        })

        self.currentProfileUser = User.currentUser
        setProfileView()
        collapseMenu()
        
        TwitterClient.sharedInstance?.getUserTimeline(user_id: self.currentProfileUser!.id!, success:
            {(tweetsUserTimeline: [Tweet]?) -> () in
            self.profileTweets = tweetsUserTimeline!
            self.profileTweetsTableView.reloadData()
        } , failure: {(error:Error) -> () in
            print(error.localizedDescription)
        })
    }
    @IBAction func timelineOpen(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.tweetsTableView.isHidden = false
            self.profileView.isHidden = true
        })

        collapseMenu()
    }

    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tweetsTableView) {
            return tweets.count
        }
        
        if (tableView == self.profileTweetsTableView){
            return profileTweets.count
        }
        
        return 0
    }
    
    func setProfileView(){
        let user = self.currentProfileUser!
        profileName.text = user.name
        if user.screenname != nil {
            profileScreenName.text = "@\(String(describing: user.screenname!))"
        }
        profileImage.setImageWith((user.profileUrl)!)
        profileTweetCount.text = "\(String(describing: user.tweets_count!))"
        profileFollowerCount.text = "\(String(describing: user.followers_count!))"
        profileFollowingCount.text = "\(String(describing: user.following_count!))"
    }
    
    func collapseMenu(){
        UIView.animate(withDuration: 0.3, animations: {
            self.leftMarginConstraint.constant = 0
            self.view.layoutIfNeeded()
        })

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweetDetailSegue" {
            let cell = sender as! TweetsTableViewCell
            let dc = segue.destination as! TweetDetailViewController
            dc.tweet = cell.tweet
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:TweetsTableViewCell!
        var tweet:Tweet!
        if (tableView == self.tweetsTableView) {
            cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetsTableViewCell
            tweet = tweets[indexPath.row]
        }
        
        if (self.profileTweetsTableView != nil && tableView == self.profileTweetsTableView){
            cell = tableView.dequeueReusableCell(withIdentifier: "profileTweetCell", for: indexPath) as! TweetsTableViewCell
            tweet = profileTweets[indexPath.row]
        }
        
        cell.tweet = tweet
        cell.contentLabel.text = tweet.text
        cell.nameLabel.text = tweet.name
        cell.handlerNameLabel.text = tweet.screen_name
        cell.timeLabel.text = tweet.timestamp
        cell.profileImage.setImageWith(tweet.profileUrl!)
        if cell.favoriteButton != nil {
            cell.favoriteButton.tag = indexPath.row
            cell.replyButton.tag = indexPath.row
            cell.retweetButton.tag = indexPath.row
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.profileTweetsTableView != nil && tableView == self.profileTweetsTableView){
           return 120.0
        }
        return 137.0
    }
}
