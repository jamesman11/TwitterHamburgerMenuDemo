//
//  TwitterClient.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
let CONSUMER_KEY = "SxJ4ZMAAlkCk8tnngQydQ9esz"
let CONSUMER_SECRET = "i3khPEAppozn3M5jOfVWWUf1LzCVCaxsHNGslBRSfChKBc7g3D"
let TWITTER_URL_PREFIX = "https://api.twitter.com"

class TwitterClient: BDBOAuth1SessionManager {
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: TWITTER_URL_PREFIX)! as URL!, consumerKey: CONSUMER_KEY, consumerSecret: CONSUMER_SECRET)
    static let userDidLogoutNotification = "UserDidLogout"
    static let newTweetNotification = "NewTweet"
    var clientAccessToken:BDBOAuth1Credential?
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func homeTimeline(success:@escaping ([Tweet]) -> (), failure:@escaping (Error) -> ()){
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: {(task: URLSessionDataTask, response: Any?) -> Void in
            let tweetsData = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetsData)
            success(tweets)
        }, failure: {(task: URLSessionDataTask?, error: Error?) -> Void in
            failure(error!)
        })
    }
    
    func handleOpenUrl(url: URL){
        let requestToken = BDBOAuth1Credential(queryString:url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: {(accessToken: BDBOAuth1Credential!) -> Void in
            self.clientAccessToken = accessToken
            self.currentAccount(success: {(user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) -> () in
                self.loginFailure?(error)
            })
        }, failure: {(error: Error!) -> Void in
            self.loginFailure?(error)
        })
    }
    
    func logout(){
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TwitterClient.userDidLogoutNotification), object: nil)
    }
    func login(success:@escaping () -> (), failure:@escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "/oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth"), scope: nil, success: {(requestToken: BDBOAuth1Credential!) -> Void in
            let token = requestToken.token!
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }, failure: {(error: Error!) -> Void in
            self.loginFailure?(error)
        })
        
    }
    
    func tweet(message: String, reply_id:String?, success:@escaping (Any?) -> (), failure:@escaping (Error) -> ()) {
        let endpoint = "1.1/statuses/update.json?"
        var params = "status=\(message)"
        if reply_id != nil {
            params += "&in_reply_to_status_id=\(reply_id!)"
        }
        params = params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        post(endpoint+params, parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask,response: Any?) -> Void in
                success(response)
        }, failure: {(task: URLSessionDataTask?, error: Error?) -> Void in
            failure(error!)
        })
    }
    
    func getUserTimeline(user_id: Int, success:@escaping ([Tweet]?) -> (), failure:@escaping (Error) -> ()) {
        let endpoint = "1.1/statuses/user_timeline.json?"
        var params = "user_id=\(user_id)&count=10"
        params = params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        get(endpoint+params, parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask,response: Any?) -> Void in
            let tweetsData = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetsData)
            success(tweets)
        }, failure: {(task: URLSessionDataTask?, error: Error?) -> Void in
            failure(error!)
        })
    }

    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: {(task: URLSessionDataTask, response: Any?) -> Void in
            let userData = response as! NSDictionary
            let user = User(data: userData)
            success(user)
        }, failure: {(task: URLSessionDataTask?, error: Error?) -> Void in
            failure(error!)
        })
    }
}
