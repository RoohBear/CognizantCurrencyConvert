//
//  TabBarController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        
        let currencyConverterViewController =
        CurrencyConverterViewController.instance(presenter: CurrencyConverterPresenter(with: CurrencyConverterInteractor(service: CurrencyScoopService())))
        currencyConverterViewController.tabBarItem.image = UIImage(systemName: "arrow.right.arrow.left.circle")

        let navigationController = UINavigationController()
        navigationController.tabBarItem.image = UIImage(systemName: "star")
        _ = FavoritesRouter(navigationController: navigationController)

        viewControllers = [currencyConverterViewController, navigationController]
        tabBar.backgroundColor = .systemBackground
    }
}
