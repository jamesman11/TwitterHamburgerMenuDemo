//
//  User.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

let STATE_KEY = "currentUserData"
let defaults = UserDefaults.standard

class User: NSObject {
    var name: String?
    var id: Int?
    var screenname: String?
    var followers_count: Int?
    var tweets_count: Int?
    var following_count: Int?
    var profileUrl: URL?
    var tagline: String?
    var dictionary: NSDictionary?
    
    init(data: NSDictionary) {
        dictionary = data
        id = data["id"] as? Int
        name = data["name"] as? String
        followers_count = data["followers_count"] as? Int
        tweets_count = data["statuses_count"] as? Int
        following_count = data["friends_count"] as? Int ?? 0
        screenname = data["screen_name"] as? String
        let profileUrlString = data["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
        tagline = data["description"] as? String
    }
    
    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let userData = defaults.object(forKey: STATE_KEY) as? Data
                
                if let userData = userData {
                    let data = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(data: data)
                }
                
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            if let user = user {
                let jsonData = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(jsonData, forKey: STATE_KEY)
            } else {
                defaults.set(nil, forKey: STATE_KEY)
            }
            defaults.synchronize()
        }
    }
}
