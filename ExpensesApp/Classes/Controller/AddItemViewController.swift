//
//  AddItemViewController.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 03/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this class controller is handle when we enter new category or new item details.
 */

import UIKit
import RealmSwift

enum AddItemViewType {
    case AddNewCategory
    case AddNewItemInCategory
    case EditCategoryItem
}

protocol AddItemViewControllerDelegate {
    func categoryAddedFrom(controller: AddItemViewController, index: Int?)
}

class AddItemViewController: UITableViewController  {
    
    var categoryLists: List<Category>?
    var userInfo: UserInformation?
    var categoryItem: CategoryItem?
    var addItemViewType = AddItemViewType.AddNewCategory
    
    var setEnableCategoryAddButton: Bool = false
    var categoryName: NSString? = ""
    var categoryIndex: Int = 0
    var userIndex: Int = 0
    var categoryObject: Category?
    var categoryItemObject: CategoryItem?
    var delegate: AddItemViewControllerDelegate?
    var topInset: CGFloat = 0.0
    
    var amountTextFieldTouchDetection: Bool = false
    var dateTextFieldTouchDetection: Bool = false
    var descriptionTouchDetection: Bool = false
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var astrickCategoryNameImageView: UIImageView!
    
    @IBOutlet weak var astrickItemNameImageView: UIImageView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    // @IBOutlet weak var saveButtonOutlet: UIButton!
    
    lazy var datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        return datePicker
    }()
    
    
    // MARK: - Save Button
    //this method is for save detail either for category or item in Realm and goto Expense Main view controller
    
    func saveItemDetail(){
        if categoryNameTextField.text?.isEmpty == true && itemNameTextField.text?.isEmpty == true  {
            astrickCategoryNameImageView.hidden = false
            astrickItemNameImageView.hidden = false
            errorMessageLabel.hidden = false
            view.endEditing(true)
            return
        }
        else if itemNameTextField.text?.isEmpty == true
        {
            astrickItemNameImageView.hidden = false
            errorMessageLabel.hidden = false
            view.endEditing(true)
            return
        }
        
        if !amountTextFieldTouchDetection && amountTextField.text == ""
        {
            amountTextField.text = "0"
        }
        
        if !dateTextFieldTouchDetection && dateTextField.text == ""
        {
            datePickerValueChanged(datePickerView)
        }
        
        if !descriptionTouchDetection && descriptionTextView.text == "description"
        {
            descriptionTextView.text = ""
        }
        
        if addItemViewType == .EditCategoryItem {
            categoryItemObject?.categoryItemId = categoryItem?.categoryItemId ?? ""
            categoryItemObject?.itemName = itemNameTextField.text ?? ""
            categoryItemObject?.amount = amountTextField.text ?? ""
            categoryItemObject?.date = dateTextField.text ?? ""
            categoryItemObject?.itemDescription = descriptionTextView.userInteractionEnabled ? descriptionTextView.text : ""
            
            try! uiRealm.write({ () -> Void in
                if let categoryItemObject = categoryItemObject {
                    uiRealm.add(categoryItemObject, update: true)
                }
            })
            
        } else {
            categoryItemObject?.categoryItemId = NSUUID().UUIDString
            categoryItemObject?.itemName = itemNameTextField.text ?? ""
            categoryItemObject?.amount = amountTextField.text ?? ""
            categoryItemObject?.date = dateTextField.text ?? ""
            categoryItemObject?.itemDescription = descriptionTextView.userInteractionEnabled ? descriptionTextView.text : ""
            
            if(!setEnableCategoryAddButton){
                categoryObject?.categoryId = NSUUID().UUIDString
                categoryObject?.categoryName = categoryNameTextField.text ?? ""
                categoryObject?.descriptionCategory.append(categoryItemObject!)
                
                try! uiRealm.write({ () -> Void in
                    userInfo!.categories.append(categoryObject!)
                    uiRealm.add(userInfo!.categories)
                })
                
                var index: Int?
                if let userInfo = userInfo {
                    index = userInfo.categories.count - 1
                }
                delegate?.categoryAddedFrom(self, index: index)
            }
            else{
                if let appendItemDetails = categoryLists? [categoryIndex] {
                    if let categoryItemObject = categoryItemObject {
                        try! uiRealm.write({ () -> Void in
                            appendItemDetails.descriptionCategory.append(categoryItemObject)
                            uiRealm.add(appendItemDetails)
                        })
                    }
                }
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRealmData()
        configureCategoryNameLabel(categoryName ?? "")
        configureDateTextField()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddItemViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddItemViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        topInset = navigationController?.navigationBar.frame.height ?? 0
        let edgeInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        tableView.contentInset = edgeInset
        tableView.scrollIndicatorInsets = edgeInset
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Keyboard Notification
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        topInset = tableView.contentInset.top
        let edgeInset = UIEdgeInsetsMake(topInset, 0, keyboardHeight, 0)
        tableView.contentInset = edgeInset
        tableView.scrollIndicatorInsets = edgeInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let edgeInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
        tableView.contentInset = edgeInset
        tableView.scrollIndicatorInsets = edgeInset
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(animated: Bool) {
        descriptionTextView.text = "description"
        descriptionTextView.textColor = UIColor.lightGrayColor()
        astrickCategoryNameImageView.hidden = true
        astrickItemNameImageView.hidden = true
        errorMessageLabel.hidden = true
        
        if addItemViewType == .EditCategoryItem
        {
            itemNameTextField.text = categoryItem?.itemName as? String
            amountTextField.text = categoryItem?.amount as? String
            dateTextField.text = categoryItem?.date as? String
            descriptionTextView.text = categoryItem?.itemDescription as? String
            itemNameTextField.userInteractionEnabled = false
            amountTextField.userInteractionEnabled = false
            dateTextField.userInteractionEnabled = false
            descriptionTextView.textColor = UIColor.blackColor()
            descriptionTextView.editable = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self,action: #selector(AddItemViewController.configureEditButton))
            navigationItem.title = "Item Details"
            //saveButtonOutlet.hidden = true
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self,action: #selector(AddItemViewController.saveItemDetail))
            navigationItem.title = addItemViewType == .AddNewCategory ? "Add Category" : "Add Item"
        }
        
    }
    
    
    // MARK: - Configure items
    func configureEditButton()  {
        itemNameTextField.userInteractionEnabled = true
        amountTextField.userInteractionEnabled = true
        dateTextField.userInteractionEnabled = true
        descriptionTextView.editable = true
        navigationItem.title = "Edit Item Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self,action: #selector(AddItemViewController.saveItemDetail))
    }
    
    //this method is for if we want enter item details in perticular category then this one will call
    func configureCategoryNameLabel(categoryName : NSString)  {
        categoryNameTextField.text = categoryName as String
        categoryNameTextField.userInteractionEnabled = addItemViewType == .AddNewCategory
    }
    
    func configureDateTextField() {
        dateTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddItemViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func configureRealmData()  {
        categoryLists = userInfo?.categories
        categoryObject = Category()
        categoryItemObject = CategoryItem()
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
    }
}

// MARK: - TextFieldDelegate
// Here, handle text field cases

extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField){
        
        if textField == amountTextField
        {
            amountTextFieldTouchDetection = true
        }
        
        if textField == dateTextField
        {
            dateTextFieldTouchDetection = true
        }
        if textField == categoryNameTextField && !astrickCategoryNameImageView.hidden
        {
            astrickCategoryNameImageView.hidden = true
        }
        if textField == itemNameTextField && !astrickItemNameImageView.hidden
        {
            astrickItemNameImageView.hidden = true
        }
        
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == dateTextField && textField.text?.isEmpty != nil {
            datePickerValueChanged(datePickerView)
        }
        else if textField == amountTextField && textField.text?.isEmpty == true {
            amountTextField.text = "0"
        }
    }
}

// MARK: - TextViewDelegate
extension AddItemViewController : UITextViewDelegate
{
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        descriptionTextView.text = addItemViewType == .EditCategoryItem ? categoryItem?.itemDescription as? String : ""
        descriptionTextView.textColor = UIColor.blackColor()
        descriptionTouchDetection = true
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if(descriptionTextView.text.characters.count == 0){
            descriptionTextView.textColor = UIColor.lightGrayColor()
            descriptionTextView.text = descriptionTextView.userInteractionEnabled ? "" : "description"
            descriptionTextView.resignFirstResponder()
        }
        return true
    }
    
}







