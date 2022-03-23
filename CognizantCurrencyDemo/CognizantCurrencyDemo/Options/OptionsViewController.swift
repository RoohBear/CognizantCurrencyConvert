//
//  OptionsViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

class OptionsViewController: UIViewController {

    private var presenter: OptionsPresenterProtocol!

    convenience init(presenter: OptionsPresenterProtocol) {
        self.init()
        self.presenter = presenter
    }

    override func viewDidLoad() {
        navigationItem.title = "Options"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(handleDone)
        )
        navigationController?.navigationBar.tintColor = .label
        view.backgroundColor = .systemRed
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    @objc private func handleDone() {
        presenter.handleDone()
    }

    @objc private func handleTap() {
        presenter.handleTap()
    }
}
