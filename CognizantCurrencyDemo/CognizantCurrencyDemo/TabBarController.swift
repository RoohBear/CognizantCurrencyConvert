//
//  TabBarController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let converterViewController = storyboard.instantiateViewController(
            withIdentifier: "converter"
        )
        converterViewController.tabBarItem.image = UIImage(systemName: "percent")

        let navigationController = UINavigationController()
        navigationController.tabBarItem.image = UIImage(systemName: "star")
        _ = FavoritesRouter(navigationController: navigationController)

        viewControllers = [converterViewController, navigationController]
        tabBar.backgroundColor = .systemBackground
    }
}
