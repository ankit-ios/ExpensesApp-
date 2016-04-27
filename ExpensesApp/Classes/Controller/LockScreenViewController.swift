//
//  LockScreenViewController.swift
//  ExpensesApp
//
//  Created by Ankit Sharma on 07/04/16.
//  Copyright © 2016 Robosoft Technology. All rights reserved.
//

import UIKit

class LockScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    var userName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePanGesture()
        configureTimeAndDate()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LockScreenViewController.configureTimeAndDate), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        alertLabel.hidden = false
        configureDefaultLabel()
    }
    
    func configurePanGesture() {
        let pangesture = UIPanGestureRecognizer(target: self , action: #selector(LockScreenViewController.handlePanGesture(_:)))
        view.multipleTouchEnabled = true
        view.userInteractionEnabled = true
        view.addGestureRecognizer(pangesture)
    }
    
    func configureDefaultLabel()  {
        timeLabel.frame = CGRectMake(186.0, 200.5, 13.0, 21.0)
        timeLabel.font = timeLabel.font.fontWithSize(30.0)
        //timeLabel.font = timeLabel.font.f
        timeLabel.alpha = 1.0
    }
    
    func configureTimeAndDate() {
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, .Second], fromDate: currentDate)
        let hours = dateComponents.hour
        let minute = dateComponents.minute
        let seconds = dateComponents.second
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let date = dateFormatter.stringFromDate(currentDate)
        
        timeLabel.text = ("\(hours) : \(minute) : \(seconds)  \n\(date)")
    }
    
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translationInView(view)
        let velocity = panGesture.velocityInView(view)
        panGesture.setTranslation(CGPointZero, inView: view)
        
        if panGesture.state == UIGestureRecognizerState.Began{
            alertLabel.hidden = true
        }
        
        if panGesture.state == UIGestureRecognizerState.Changed {
            
            if translation.y < 0 {
                timeLabel.frame = CGRectMake(timeLabel.frame.origin.x + 1 , timeLabel.frame.origin.y + 1, timeLabel.frame.width - 2 , timeLabel.frame.height - 2)
                timeLabel.font = timeLabel.font.fontWithSize(timeLabel.font.pointSize - 1)
                timeLabel.alpha -= 0.03
            }
                
            else if translation.y > 0 {
                if timeLabel.frame.height > 118.5 {
                    return
                }
                else {
                    timeLabel.frame = CGRectMake(timeLabel.frame.origin.x - 1 , timeLabel.frame.origin.y - 1, timeLabel.frame.width + 2 , timeLabel.frame.height + 2)
                    timeLabel.font = timeLabel.font.fontWithSize(timeLabel.font.pointSize + 1)
                    timeLabel.alpha += 0.03
                }
                
            }
            
            if velocity.y < -1000.0 && translation.y < -15.0 {
                if let loginNavigationController = storyboard?.instantiateViewControllerWithIdentifier("navigationController") as? UINavigationController {
                    presentViewController(loginNavigationController, animated: true, completion: nil)
                }
            }
        }
        
        if panGesture.state == UIGestureRecognizerState.Ended {
            configureDefaultLabel()
            alertLabel.hidden = false
        }
        
    }
}



