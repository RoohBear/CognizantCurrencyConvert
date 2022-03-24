//
//  FavoritesViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

final class FavoritesViewController: UIViewController {
    
    private let favorites = "Favorites"
    private var cellIdentifier: String { "cellIdentifier" }
    private var presenter: FavoritesPresenterProtocol!
    private var favoriteList: [Currency] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    convenience init(presenter: FavoritesPresenterProtocol) {
        self.init()
        self.presenter = presenter
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupTableView()
    }
    
    // MARK: - Helper Methods
    
    private func setupTableView() {
        view.addSubview(tableView)
        activateConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = favorites
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .refresh)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openOptionMenu))
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
                
            ]
        )
    }
    
    // MARK: - Action Methods
    
    @objc private func openOptionMenu() {
        presenter.showOptionMenu()
    }
}

// MARK: - UITableView Data Source and Delegate

// TODO: Need to replace placeholder data with real data.

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
        UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = "USD"
        cell.detailTextLabel?.text = "0.90"
        
        return cell
    }
    
}


