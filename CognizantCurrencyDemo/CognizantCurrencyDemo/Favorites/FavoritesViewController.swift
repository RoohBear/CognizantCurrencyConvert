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
    private lazy var subscriptions = Set<AnyCancellable>()
    private var favoriteList: [Currency] = []
    private var currencyRates: CurrencyRates?
    
    private var baseCurrency: Currency?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.isHidden = true
        return tableView
    }()
    
    
    convenience init(presenter: FavoritesPresenterProtocol) {
        self.init()
        self.presenter = presenter
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        
        handleFavoriteListPublisher(options: presenter.getOptions())
        
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
            self.tableView.isHidden = true
            return
        }
        
        presenter.currencyRatesPublisher(options: options).receive(on: DispatchQueue.main).sink { [weak self] response in
            
            self?.favoriteList = options.favorites
            self?.baseCurrency = options.baseCurrency
            self?.tableView.reloadData()
            self?.tableView.isHidden = false
            self?.currencyRates = response
            
        }.store(in: &subscriptions)
    }
    
    // MARK: - Action Methods
    
    @objc private func openOptionMenu() {
        presenter.showOptionMenu()
    }
}

// MARK: - UITableView Data Source

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
        UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        let currencyCode = favoriteList[indexPath.row].currencyCode
        
        cell.textLabel?.text = currencyCode
        
        if let currencyRate = currencyRates?.rates[currencyCode] {
            cell.detailTextLabel?.text = String(currencyRate)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let baseCurrency = baseCurrency {
            return "Based Currency: \(baseCurrency.currencyName) \(baseCurrency.currencyCode)"
        }
        return ""
    }
    
}


