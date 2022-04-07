//
//  TabBarController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad()
    {
        // make the VC for the 1st tab, and use a REAL service (not a Mock service)
        let currencyConverterViewController = CurrencyConverterViewController.instance(presenter: CurrencyConverterPresenter(with: CurrencyConverterInteractor(service: CurrencyScoopService())))
        currencyConverterViewController.tabBarItem.image = UIImage(systemName: "arrow.right.arrow.left.circle")

        // makes a navigation controller for the 2nd tab
        let navigationController = UINavigationController()
        navigationController.tabBarItem.image = UIImage(systemName: "star")
        _ = FavoritesRouter(navigationController: navigationController)

        viewControllers = [currencyConverterViewController, navigationController]
        tabBar.backgroundColor = .systemBackground
    }
}
