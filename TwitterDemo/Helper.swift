//
//  Helper.swift
//  TwitterDemo
//
//  Created by James Man on 4/11/17.
//  Copyright © 2017 James Man. All rights reserved.
//

import UIKit

class Helper {
    static  func UIColorFromHex(rgbValue:UInt, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
