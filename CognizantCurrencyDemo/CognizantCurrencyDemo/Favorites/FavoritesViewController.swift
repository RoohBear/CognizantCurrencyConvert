//
//  FavoritesViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

class FavoritesViewController: UIViewController {

    private var presenter: FavoritesPresenterProtocol!

    convenience init(presenter: FavoritesPresenterProtocol) {
        self.init()
        self.presenter = presenter
    }

    override func viewDidLoad() {
        navigationItem.title = "Favorites"
        view.backgroundColor = .systemPink
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    @objc private func handleTap() {
        presenter.handleTap()
    }
}
