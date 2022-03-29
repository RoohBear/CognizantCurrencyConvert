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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = "Sorry, there was a problem loading your favorites list. Please make sure that you have added your favorite currency inside the options menu."
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        return errorLabel
    }()
    
    convenience init(presenter: FavoritesPresenterProtocol) {
        self.init()
        self.presenter = presenter
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        setupActivityIndicator()
        setupNavigationBar()
        setupTableView()
        setupAlertView()
        
        handleCurrencyRateListPublisher(options: presenter.getOptions(), refreshRatesOnly: false)
        
        presenter.favoriteListPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.handleCurrencyRateListPublisher(options: $0, refreshRatesOnly: false)
        }.store(in: &subscriptions)
    }
    
    
    // MARK: - Helper Methods
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.activateConstraints()
    }
    
    private func setupAlertView() {
        view.addSubview(errorLabel)
        errorLabel.activateConstraints()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.activateConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = favorites
        navigationItem.leftBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openOptionMenu))
    }
    
    @objc private func refreshButtonTapped() {
        handleCurrencyRateListPublisher(options: presenter.getOptions(), refreshRatesOnly: true)
    }
    
    private func handleCurrencyRateListPublisher(options: Options?, refreshRatesOnly: Bool) {
        guard let options = options, !options.favorites.isEmpty else {
            self.tableView.isHidden = true
            self.errorLabel.isHidden = false
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            return
        }
        
        if !refreshRatesOnly {
            self.favoriteList = options.favorites
            self.baseCurrency = options.baseCurrency
        }
        
        presenter.currencyRatesPublisher(options: options).receive(on: DispatchQueue.main).sink { [weak self] response in
            
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            
            self?.errorLabel.isHidden = true
            self?.tableView.isHidden = false
            
            self?.currencyRates = response
            self?.tableView.reloadData()
            
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
        
        if let currencyRate = currencyRates?.rates[currencyCode] as? Double {
            cell.detailTextLabel?.text = String(currencyRate)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let baseCurrency = baseCurrency {
            return "Based Currency: \(baseCurrency.currencyName) \(baseCurrency.currencyCode)"
        }
        return "Error: Could not display currency name."
    }
    
}


