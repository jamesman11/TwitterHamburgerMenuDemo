//
//  NewTweetViewController.swift
//  TwitterDemo
//
//  Created by James Man on 4/12/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate {
    let LIMIT = 140
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var handlerLabel: UILabel!
    @IBOutlet var remainWordsLabel: UILabel!
    @IBOutlet var contentText: UITextView!
    var wordsRemains: Int = 140
    override func viewDidLoad() {
        super.viewDidLoad()
        contentText.delegate = self
        setCurrentUserProfile()
        
        navigationController?.navigationBar.barTintColor = Helper.UIColorFromHex(rgbValue: 0x3ec8ef, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        contentText.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = contentText.text.characters.count
        wordsRemains = LIMIT - count
        remainWordsLabel.text = String(wordsRemains)
        
        if (wordsRemains > 0) {
            remainWordsLabel.textColor = UIColor.green
        } else {
            remainWordsLabel.textColor = UIColor.red
        }
    }
    
    func setCurrentUserProfile(){
        let user = User.currentUser!
        nameLabel.text = user.name
        if user.screenname != nil {
            handlerLabel.text = "@\(String(describing: user.screenname!))"
        }
        remainWordsLabel.text = String(wordsRemains)
        profileImage.setImageWith((user.profileUrl)!)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func tweetMessage(_ sender: Any) {
        if (wordsRemains > 0) {
            let text = contentText.text
            TwitterClient.sharedInstance?.tweet(message: text!, reply_id: nil, success: {(response: Any) -> () in
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TwitterClient.newTweetNotification), object: response)
            }, failure: {(error:Error) -> () in
                print(error.localizedDescription)
            })
        } else {
            let alertController = UIAlertController(title: "Out of Limit", message: "You can't tweet a message with more than \(String(LIMIT)) characters!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
