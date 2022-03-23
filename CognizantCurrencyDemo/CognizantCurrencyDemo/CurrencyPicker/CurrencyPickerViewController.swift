//
//  CurrencyPickerViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit
import Combine

class CurrencyPickerViewController: UIViewController {

    private var presenter: CurrencyPickerPresenterProtocol!
    private lazy var subscriptions = Set<AnyCancellable>()
    private var cellIdentifier: String { "cellIdentifier" }
    private var currencyList: [Currency] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
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
        errorLabel.text = "Sorry, there was a problem loading the currency list"
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        return errorLabel
    }()

    convenience init(presenter: CurrencyPickerPresenterProtocol) {
        self.init()
        self.presenter = presenter
        presenter.currencyListPublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.handleCurrencyListPublisher(currencies: $0)
        }.store(in: &subscriptions)
    }

    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        presenter.handleViewDidLoad()
        navigationItem.title = presenter.title
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        activityIndicator.startAnimating()
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                errorLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
            ]
        )
    }

    private func handleCurrencyListPublisher(currencies: [Currency]?) {
        activityIndicator.isHidden = true

        guard let currencies = currencies, !currencies.isEmpty else {
            errorLabel.isHidden = false
            return
        }

        currencyList = currencies
        tableView.reloadData()
        tableView.isHidden = false
    }
}

extension CurrencyPickerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.handleSelectedCurrency(currencyList[indexPath.row])
        tableView.reloadData()
    }
}

extension CurrencyPickerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencyList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            return UITableViewCell()
        }

        let currency = currencyList[indexPath.row]
        cell.textLabel?.text = currency.currencyCode + ": " + currency.currencyName
        cell.accessoryType = presenter.isSelectedCurrency(currency) ? .checkmark : .none
        return cell
    }
}

