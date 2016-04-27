//
//  Category.swift
//  test1
//
//  Created by Ankit Sharma on 01/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this is model class for storing category information
 */

import Foundation
import RealmSwift

class Category: Object {
    dynamic var categoryId : NSString = ""
    dynamic var categoryName : NSString = ""
    let  descriptionCategory = List<CategoryItem>()
    
    override static func primaryKey() -> String?{
        return "categoryId"
    }
}
