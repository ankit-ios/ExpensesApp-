//
//  CategoryItem.swift
//  test1
//
//  Created by Ankit Sharma on 01/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this is model class for storing category item details
 */

import Foundation
import RealmSwift

class CategoryItem: Object {
    
    dynamic var categoryItemId : NSString = ""
    dynamic var itemName : NSString = ""
    dynamic var amount : NSString = ""
    dynamic var date : NSString = ""
    dynamic var itemDescription : NSString = ""
    
    // itemName is a primary key so that must be Unique
    override static func primaryKey() -> String?{
        return "categoryItemId"
    }
}
