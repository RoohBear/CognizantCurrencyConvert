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
    private var currencyRateSubscription: AnyCancellable?
    private var favoriteListSubscription: AnyCancellable?
    
    private var favoriteList: [Currency] = []
    private var currencyRates: CurrencyRates?
    
    private var baseCurrency: Currency?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(handleTableRefresh),
            for: .valueChanged
        )
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
        if self.traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            errorLabel.textColor = .white
        } else {
            view.backgroundColor = .white
        }
        
        setupActivityIndicator()
        setupNavigationBar()
        setupTableView()
        setupAlertView()
        
        // gets the options in the OptionsRepository
        //
        handleCurrencyRateListPublisher(options: presenter.getOptions())
        
        // listens to the OptionsRepository
        favoriteListSubscription = presenter.favoriteListPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.handleCurrencyRateListPublisher(options: $0)
        }
    }
    
    // MARK: - Helper Methods
    
    @objc private func handleTableRefresh() {
        let options = presenter.getOptions()
        currencyRateSubscription = presenter.currencyRatesPublisher(
            options: options
        ).sink { [weak self] in
            self?.currencyRates = $0
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openOptionMenu))
    }
    
    private func handleCurrencyRateListPublisher(options: Options?) {
        guard let options = options, !options.favorites.isEmpty else {
            self.tableView.isHidden = true
            self.errorLabel.isHidden = false
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            return
        }
        
        self.favoriteList = options.favorites
        self.baseCurrency = options.baseCurrency
        
        // listens to the currency rate publisher that fetches the currency rate options
        currencyRateSubscription = presenter.currencyRatesPublisher(options: options).receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            
            self?.errorLabel.isHidden = true
            self?.tableView.isHidden = false
            
            self?.currencyRates = response  // response is a CurrencyRates object containing a dictionary of [String:Double] objects
            self?.tableView.reloadData()
        }
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
        } else {
            cell.detailTextLabel?.text = "Not available"
        }
        
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel()
        header.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        header.numberOfLines = 0
        header.textAlignment = .center
        if let baseCurrency = baseCurrency {
            let currencyDescription = "\(baseCurrency.currencyName) \(baseCurrency.currencyCode)"
            let components = [
                "Base Currency:".uppercased(),
                currencyDescription,
                "exchange rates current as of",
                presenter.rateTimeInfo
            ]
            let attributedText = NSMutableAttributedString(string: "")
            components.forEach {
                let text = ($0 == components.first ? "" : "\n") + $0
                let attributedString: NSAttributedString
                if $0 == currencyDescription {
                    attributedString = NSAttributedString(
                        string: text,
                        attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)]
                    )
                } else {
                    attributedString = NSAttributedString(string: text)
                }
                attributedText.append(attributedString)
            }
            header.attributedText = attributedText
        } else {
            header.text = "Error: Could not display currency name."
        }
        return header
    }
}
