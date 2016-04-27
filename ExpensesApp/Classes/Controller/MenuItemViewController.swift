//
//  MenuItemViewController.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 18/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

import UIKit

protocol MenuItemViewControllerDelegate {
    func  menuItemState(controller: MenuItemViewController , menuItemStateBool: Bool)
}

class MenuItemViewController: UIViewController , UIGestureRecognizerDelegate {
    
    enum MenuItem: Int {
        case Profile
        case AddCategory
        case Settings
        case Logout
        
        func title() -> String {
            var title = ""
            switch self {
            case .Profile:
                title = "Profile"
            case .AddCategory:
                title = "Add Category"
            case .Settings:
                title = "Settings"
            case .Logout:
                title = "Logout"
            }
            return title
        }
    }
    
    @IBOutlet var sideDrawerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MenuItemViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuItemViewController.handleTap))
        tap.delegate = self
        sideDrawerView.addGestureRecognizer(tap)
    }
    
    func handleTap()  {
        self.willMoveToParentViewController(navigationController)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        delegate?.menuItemState(self, menuItemStateBool: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MenuItemViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if  let cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell", forIndexPath: indexPath) as? MenuItemTableViewCell {
            if let index = MenuItem(rawValue: indexPath.row) {
                cell.menuItemtitleLabel.text = index.title()
            }
            return cell
        }
        return UITableViewCell()
    }
    
}

extension MenuItemViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let index = MenuItem(rawValue: indexPath.row) {
            switch index {
                
            case .Profile: break
                
            case .AddCategory:
                parentViewController?.performSegueWithIdentifier("categorySegue", sender: nil)
                handleTap()
                break
            case .Settings:break
                
            case .Logout:
                navigationController?.dismissViewControllerAnimated(true, completion: nil)
                break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
}