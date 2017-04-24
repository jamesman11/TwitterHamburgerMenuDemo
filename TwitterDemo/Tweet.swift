//
//  Tweet.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: String?
    var profileUrl: URL?
    var name: String?
    var screen_name: String?
    var id: Int?
    var tweeter: User?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    init(data: NSDictionary) {
        text = data["text"] as? String
        id = data["id"] as? Int
        retweetCount = (data["retweet_count"] as? Int) ?? 0
        favoritesCount = (data["favorites_count"] as? Int) ?? 0
        let user = data["user"] as? NSDictionary
        tweeter = User(data: user!)
        name = user?["name"] as? String
        screen_name = user?["screen_name"] as? String
        let imageURLString = user?["profile_image_url_https"] as? String
        if imageURLString != nil {
            profileUrl = URL(string: imageURLString!)!
        } else {
            profileUrl = nil
        }
        let timestampString = data["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z Y"
            let date = formatter.date(from: timestampString)
            formatter.dateStyle = .short
            timestamp = formatter.string(from: date!)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        for data in dictionaries {
            let tweet = Tweet(data: data)
            tweets.append(tweet)
        }
        return tweets
    }
}
