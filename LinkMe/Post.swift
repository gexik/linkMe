//
//  Post.swift
//  LinkMe
//
//  Created by Roman Bogomolov on 09.04.17.
//  Copyright © 2017 Roman Bogomolov. All rights reserved.
//

import Foundation

struct Post {
    var id: String?
    
    let user: User
    let userProfileImageUrl: String
    
    let imageUrl: String
    let caption: String
    let creationDateString: String
    let creationDate: Date
    
    var hasLiked = false

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.userProfileImageUrl = user.profileImageUrl
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        self.creationDate = Date(timeIntervalSince1970: dictionary["creationDate"] as! TimeInterval)
        self.creationDateString = timeAgoSinceDate(date: self.creationDate as NSDate, numericDates: false)
    }
}

fileprivate func formatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.doesRelativeDateFormatting = false
    
    return dateFormatter
    
}

fileprivate func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = NSDate()
    let earliest = now.earlierDate(date as Date)
    let latest = (earliest == now as Date) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
    
}
