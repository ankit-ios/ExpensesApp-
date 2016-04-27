//
//  ExpenseAppMainViewController.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 03/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

/**
 this class controller is main controller for this application, in this controller we handle all category and item information.
 */

import UIKit
import RealmSwift

class ExpenseAppMainViewController : UIViewController {
    
    @IBOutlet weak var tableViewInstance: UITableView!
    @IBOutlet weak var collectionViewInstance: UICollectionView!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var addCategoryButton: UIButton!
    
    var userInfo: UserInformation?
    var categoryLists: List<Category>?
    var categoryItemLists: List<CategoryItem>?
    
    let collectionCellIdentifier = "collectionCell"
    let TableCellIdentifier = "tableCell"
    let NoRecordFoundCellIdentifier = "noRecordFoundCell"
    
    var userIndex: Int? = 0
    var categoryItemCellCount : Int? = 0
    var selectedCategoryName : NSString?
    
    var menuItemPresent: Bool = true
    var menuItemController: MenuItemViewController?
    
    var categoryIndex : Int = 0 {
        didSet {
            reloadCategoryItems()
        }
    }
    
    // MARK: - ViewDidLoad
    // viewDidLoad method
    
    override func viewDidLoad() {
        
        addItemButton.enabled = false
        if let userIndex = userIndex {
            userInfo = (uiRealm.objects(UserInformation))[userIndex]
            categoryLists = userInfo?.categories
        }
        //leftBarItemConfigure()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "signout"), style: .Plain, target: self, action: #selector(ExpenseAppMainViewController.signOut))
        navigationItem.leftBarButtonItem = UIBarButtonItem( image: UIImage(named: "menu-1"), style: .Plain ,  target: self , action:  #selector(ExpenseAppMainViewController.menuConfigure))
        
        categoryIndex = 0
        super.viewDidLoad()
        
        tableViewInstance.rowHeight = UITableViewAutomaticDimension
        tableViewInstance.estimatedRowHeight = 44
    }
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(animated: Bool) {
        updateUIandDataSource()
    }
    
    //this method is for update UI when data is updated
    
    func updateUIandDataSource()  {
        collectionViewInstance.reloadData()
        reloadCategoryItems()
        addItemButton.enabled = categoryLists != nil ? categoryLists!.count > 0 : false
    }
    
    // MARK: - Menu Item Configure
    
    func menuConfigure()  {
        
        if (menuItemPresent) {
            menuItemController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuItemController") as? MenuItemViewController
            if let menuItemController = menuItemController
            {
                self.addChildViewController(menuItemController)
                self.view.addSubview(menuItemController.view)
                menuItemController.didMoveToParentViewController(self)
                menuItemController.delegate = self
                menuItemPresent = false
                navigationItem.leftBarButtonItem?.image =  UIImage(named: "menu-2")
            }
        }
        else {
            if let menuItemController = menuItemController {
                menuItemController.handleTap()
                navigationItem.leftBarButtonItem?.image =  UIImage(named: "menu-1")
            }
        }
    }
    
    
    
    // MARK: - Reload CategoryItems
    
    func reloadCategoryItems() {
        let indexPath = NSIndexPath(forItem: categoryIndex, inSection: 0)
        if let categoryLists = categoryLists {
            if categoryLists.count > indexPath.row {
                categoryItemLists = categoryLists[indexPath.row].descriptionCategory
                
                if categoryItemLists?.count == 0 {
                    categoryLists
                }
                categoryItemCellCount = categoryLists[indexPath.row].descriptionCategory.count ?? 0
                selectedCategoryName = categoryLists[indexPath.row].categoryName
            } else {
                categoryItemCellCount = 0
            }
        }
        
        tableViewInstance.reloadData()
    }
    
    // MARK: - Signout Button
    // this method is for signout and goto Login page
    
    func signOut() {
        
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - PrepareForSegue
    // this is for sending the data and getting value from user for entering category details or item details
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addItemViewControllerInstance = segue.destinationViewController as? AddItemViewController
        if(segue.identifier == "itemSegue") {
            if let indexPath = tableViewInstance.indexPathForSelectedRow {
                addItemViewControllerInstance?.addItemViewType = .EditCategoryItem
                if let selectedItem =  userInfo?.categories[categoryIndex].descriptionCategory[indexPath.row] {
                    addItemViewControllerInstance?.categoryItem = selectedItem
                }
            } else {
                addItemViewControllerInstance?.addItemViewType = .AddNewItemInCategory
            }
            addItemViewControllerInstance?.categoryName = selectedCategoryName
            addItemViewControllerInstance?.userIndex = userIndex!
            addItemViewControllerInstance?.categoryIndex = categoryIndex
            addItemViewControllerInstance?.setEnableCategoryAddButton = true
            addItemViewControllerInstance?.userInfo = userInfo
        } else if segue.identifier == "categorySegue" {
            addItemViewControllerInstance?.userInfo = userInfo
            addItemViewControllerInstance?.delegate = self
        }
    }
}

// MARK: - AddItemViewControllerDelegate Protocol

extension ExpenseAppMainViewController: AddItemViewControllerDelegate {
    func categoryAddedFrom(controller: AddItemViewController, index: Int?) {
        if let index = index {
            categoryIndex = index
            collectionViewInstance.reloadData()
            collectionViewInstance.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .Right, animated: true)
        }
    }
}

// MARK: - CollectionViewDataSource method
//Here, define collection view or category data source

extension ExpenseAppMainViewController : UICollectionViewDataSource
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //  return categoryLists.count
        return categoryLists?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionCellIdentifier, forIndexPath: indexPath) as? CategoryCollectionViewCell
        if let categoryLists = categoryLists where categoryLists.count > indexPath.row {
            let collectionViewObject = categoryLists[indexPath.row]
            cell?.configureCollectionViewCell(collectionViewObject)
            cell?.delegate = self
            
            if(indexPath.row == categoryIndex) {
                cell?.trinagleImageView.hidden = false
            }
        }
        
        return cell ?? UICollectionViewCell()
        
    }
    
}



// MARK: - Collection view delegate

extension ExpenseAppMainViewController : UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        // Get the prev cell
        if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: categoryIndex, inSection: 0)) as? CategoryCollectionViewCell {
            cell.trinagleImageView.hidden = true
        }
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CategoryCollectionViewCell
        cell?.trinagleImageView.hidden = false
        //cell?.categoryRenamingTextField.hidden = true
        addItemButton.enabled = true
        
        categoryIndex = indexPath.row
        
    }
    
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if indexPath.row < 5
        {
            return false
        }
        else {
            let rename = UIMenuItem(title: "rename", action:(#selector(CategoryCollectionViewCell.renameCategory)))
            let delete = UIMenuItem(title: "delete", action: (#selector(CategoryCollectionViewCell.deleteCategory))  )
            UIMenuController.sharedMenuController().menuItems = [rename, delete]
            return true
        }
    }
    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool
    {
        return (action == #selector(CategoryCollectionViewCell.renameCategory)) || (action == #selector(CategoryCollectionViewCell.deleteCategory))
    }
    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?)
    {
        print("fsgdd")
        if action == #selector(CategoryCollectionViewCell.renameCategory) {
            print ("copying ")
        }
        else if action == #selector(CategoryCollectionViewCell.deleteCategory) {
            print("shdfah")
        }
    }
    
}



// MARK: -  Table view Data source

extension ExpenseAppMainViewController : UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if categoryItemCellCount == 0 {
            return 1
        }
        return categoryItemCellCount ?? 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if categoryItemCellCount == 0
        { if let cell = tableView.dequeueReusableCellWithIdentifier(NoRecordFoundCellIdentifier, forIndexPath: indexPath) as? NoRecordFoundCell
        {
            cell.noRecordFoundImageView.image = UIImage(named: "noRecordFound")
            return cell ?? UITableViewCell()
            }}
        else {
            if let cell = tableView.dequeueReusableCellWithIdentifier(TableCellIdentifier , forIndexPath: indexPath) as? CategoryItemTableViewCell
            { if let categoryItemLists = categoryItemLists where categoryItemLists.count > indexPath.row {
                let tableViewObject = categoryItemLists[indexPath.row]
                cell.configureTableCell(tableViewObject)
                }
                return cell ?? UITableViewCell()
            }
        }
        return UITableViewCell()
    }
}

// MARK: - Table view delegates

extension ExpenseAppMainViewController : UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("itemSegue", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            if let categoryItemLists = categoryItemLists {
                if categoryItemLists.count > indexPath.row {
                    
                    let deleteObject = categoryItemLists[indexPath.row]
                    try! uiRealm.write({ () -> Void in
                        uiRealm.delete(deleteObject)
                        reloadCategoryItems();
                    })
                }
            }
        }
    }
}

// MARK: - CategoryCollectionViewCellDelegate delegate

extension ExpenseAppMainViewController: CategoryCollectionViewCellDelegate
{
    func renameCategoryFrom(cell: CategoryCollectionViewCell)
    {
        if let indexPath = collectionViewInstance.indexPathForCell(cell) {
            categoryIndex = indexPath.row
        }
    }
    
    func deleteCategoryFrom(cell: CategoryCollectionViewCell)
    {
        if let indexPath = collectionViewInstance.indexPathForCell(cell) {
            if let categoryInfo = userInfo?.categories [indexPath.row] {
                try! uiRealm.write({ () -> Void in
                    
                    uiRealm.delete(categoryInfo)
                })
                categoryIndex = indexPath.row - 1
            }
            updateUIandDataSource()
        }
        print("delete")
    }
}

// MARK: - TextField delegate

extension ExpenseAppMainViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if let categoryInfo = userInfo?.categories [categoryIndex] {
            try! uiRealm.write({ () -> Void in
                categoryInfo.categoryName = textField.text ?? ""
                uiRealm.add(categoryInfo, update: true)
            })
        }
        textField.hidden = true
        updateUIandDataSource()
        return true
    }
}


extension ExpenseAppMainViewController : MenuItemViewControllerDelegate
{
    func  menuItemState(controller: MenuItemViewController , menuItemStateBool: Bool) {
        menuItemPresent = menuItemStateBool
        navigationItem.leftBarButtonItem?.image =  UIImage(named: "menu-1")
    }
}
