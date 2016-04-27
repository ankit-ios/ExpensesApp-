//
//  CategoryItemTableViewCell.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 03/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this class is for customise table view data (item details)
 */

import UIKit
import RealmSwift

class CategoryItemTableViewCell: UITableViewCell {
    
    var tableViewLists : Results<CategoryItem>!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    //@IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var customView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // this method is for customise table view cell and put value for all labels
    
    func configureTableCell(lists: CategoryItem) {
        itemNameLabel.text = lists.itemName as String
        amountLabel.text = lists.amount as String
        dateLabel.text = lists.date as String
    }
    
}
