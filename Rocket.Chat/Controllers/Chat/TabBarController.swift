//
//  TabBarController.swift
//  Rocket.Chat
//
//  Created by Bobby Kain on 10/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create Tab one
        let calendar = CalendarViewController()
        let calendarBarItem = UITabBarItem(title: "Tab 1", image: UIImage(named: "calendar.png"), selectedImage: UIImage(named: "calendar.png"))
        
        calendar.tabBarItem = calendarBarItem
        
        
        // Create Tab two
        let chat = ChatViewController()
        let chatBarItem = UITabBarItem(title: "Tab 2", image: UIImage(named: "message.png"), selectedImage: UIImage(named: "message.png"))
        
        chat.tabBarItem = chatBarItem
        
        
        self.viewControllers = [calendar, chat]
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected \(viewController.title!)")
    }
}

