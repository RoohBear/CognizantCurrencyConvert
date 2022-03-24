//
//  FavoritesViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    
    private let favorites = "Favorites"
    private var cellIdentifier: String { "cellIdentifier" }
    private var presenter: FavoritesPresenterProtocol!
    private var subscriptions = Set<AnyCancellable>()
    private var favoriteList: [Currency] = []
    private var baseCurrency: Currency?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        
        presenter.favoriteListPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.handleFavoriteListPublisher(options: $0)
        }.store(in: &subscriptions)
    }
    
    
    // MARK: - Helper Methods
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.activateConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = favorites
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .refresh)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openOptionMenu))
    }
    
    private func handleFavoriteListPublisher(options: Options) {
        
        guard !options.favorites.isEmpty else {
            return
        }
        
        favoriteList = options.favorites
        baseCurrency = options.baseCurrency
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    // MARK: - Action Methods
    
    @objc private func openOptionMenu() {
        presenter.showOptionMenu()
    }
}

// MARK: - UITableView Data Source

// TODO: Need to replace placeholder data with real data.

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
        UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if indexPath.row == 0 {
            if let baseCurrency = baseCurrency {
                cell.textLabel?.text = "Based Currency: \(baseCurrency.currencyName) \(baseCurrency.currencyCode)"
            }
        } else {
            cell.textLabel?.text = favoriteList[indexPath.row - 1].currencyCode
            cell.detailTextLabel?.text = "0.90"
        }
        
        return cell
    }
    
}


