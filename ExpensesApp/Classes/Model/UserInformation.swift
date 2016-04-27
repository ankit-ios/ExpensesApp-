//
//  UserInformation.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 06/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
this is model class for storing user information 
 */

import Foundation
import RealmSwift

class UserInformation: Object {
    dynamic var userId : NSString = ""
    dynamic var userName : NSString = ""
    dynamic var emailId : NSString = ""
    dynamic var password : NSString = ""
    let categories = List<Category>()
    
    override static func primaryKey() -> String?{
        return "userId"
    }
}
