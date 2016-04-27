//
//  CategoryCollectionViewCell.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 03/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this class is for customise collection view cell (category details)
 */

import UIKit

protocol CategoryCollectionViewCellDelegate {
    func renameCategoryFrom(cell: CategoryCollectionViewCell)
    func deleteCategoryFrom(cell: CategoryCollectionViewCell)
}

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var trinagleImageView: UIImageView!
    @IBOutlet weak var categoryRenamingTextField: UITextField!
    
    var delegate: CategoryCollectionViewCellDelegate?
    
    //this method is for customise collection view cell and put label value
    
    func configureCollectionViewCell(lists : Category) {
        categoryNameLabel.text = lists.categoryName as String
        categoryRenamingTextField.text = lists.categoryName as String
        trinagleImageView.hidden = true
        categoryRenamingTextField.hidden = true
    }
    
    // MARK: - MenuItems
    
    func renameCategory ()  {
        categoryRenamingTextField.text = categoryNameLabel.text ?? ""
        categoryNameLabel.text = ""
        categoryRenamingTextField.hidden = false
        categoryRenamingTextField.userInteractionEnabled = true
        categoryRenamingTextField.becomeFirstResponder()
        
        delegate?.renameCategoryFrom(self )
    }
    
    func deleteCategory ()  {
        delegate?.deleteCategoryFrom(self)
    }
    
}



