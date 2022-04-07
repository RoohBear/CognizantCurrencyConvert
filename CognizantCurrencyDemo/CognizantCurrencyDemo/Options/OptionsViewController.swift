//
//  OptionsViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit
import Combine

class OptionsViewController: UIViewController {

    private var presenter: AnyPresenter<OptionsAction, OptionsState>!
    private var cellIdentifier: String { "cellIdentifier" }
    private lazy var subscriptions = Set<AnyCancellable>()
    private var state: OptionsPresenter.State?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableCell.self, forCellReuseIdentifier: cellIdentifier)
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

    // init() is a Designated initializer and are the primary initializers for a class.
    //
    // Convenience initializers are secondary, supporting initializers for a class.
    // You can define a convenience initializer to call a designated initializer from the same class
    // as the convenience initializer with some of the designated initializer’s parameters set to
    // default values. You can also define a convenience initializer to create an instance of that
    // class for a specific use case or input value type.
    convenience init(presenter: AnyPresenter<OptionsAction, OptionsState>) {
        self.init()
        self.presenter = presenter
        presenter.statePublisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.handleStatePublisher($0)
        }.store(in: &subscriptions)
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
        view.backgroundColor = .systemBackground
        presenter.processAction(.viewReady)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        activityIndicator.startAnimating()
        activateConstraints()
    }

    @objc private func handleDone() {
        presenter.processAction(.doneButton)
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

    private func handleStatePublisher(_ state: OptionsPresenter.State?) {
        activityIndicator.isHidden = true

        guard let state = state else {
            errorLabel.isHidden = false
            return
        }

        let isFirstData = self.state == nil
        self.state = state
        if isFirstData {
            tableView.reloadData()
        } else {
            tableView.reloadSections(
                IndexSet(integersIn: (0..<Section.allCases.count)),
                with: .fade
            )
        }
        tableView.isHidden = false
    }

    private func makeSwitch(for currency: Currency) -> UISwitch {
        let switchControl = UISwitch()
        switchControl.addAction(
            UIAction { _ in
                self.presenter.processAction(
                    .favoriteUpdate(isFavorite: switchControl.isOn, currency: currency)
                )
            },
            for: .valueChanged
        )
        if let favorites = state?.options.favorites {
            switchControl.isOn = favorites.contains(currency)
        }
        return switchControl
    }

    private func renderBaseCurrencyCell(_ cell: UITableViewCell) {
        if let currency = state?.options.baseCurrency {
            cell.textLabel?.text = "Base Currency: " + currency.currencyCode
            cell.detailTextLabel?.text = currency.currencyName
            cell.accessibilityIdentifier = currency.currencyCode + ": " + currency.currencyName
        }
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
    }

    private func renderCurrencyListCell(
        _ cell: UITableViewCell,
        currency: Currency?
    ) {
        cell.selectionStyle = .none
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        if let currency = currency {
            cell.textLabel?.text = currency.currencyCode + ": " + currency.currencyName
            cell.accessoryView = makeSwitch(for: currency)
        } else {
            cell.textLabel?.text = "No favorites selected"
            cell.accessoryView = nil
        }
    }
}

extension OptionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .baseCurrency else {
            return
        }
        presenter.processAction(.baseCurrencyTap)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension OptionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) ?? .baseCurrency {
        case .baseCurrency:
            return 1
        case .favorites:
            let count = state?.options.favorites.count ?? 0
            return max(count, 1)
        case .allCurrencies:
            return state?.allCurrencies.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) ?? .baseCurrency {
        case .baseCurrency: return nil
        case .favorites: return "Favorites"
        case .allCurrencies: return "All Currencies"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? TableCell()

        switch Section(rawValue: indexPath.section) ?? .baseCurrency {
        case .baseCurrency:
            renderBaseCurrencyCell(cell)
        case .favorites:
            let favorites = state?.options.favorites ?? []
            var currency: Currency?
            if !favorites.isEmpty {
                currency = favorites[indexPath.row]
            }
            renderCurrencyListCell(cell, currency: currency)
        case .allCurrencies:
            renderCurrencyListCell(cell, currency: state?.allCurrencies[indexPath.row])
        }

        return cell
    }
}

extension OptionsViewController {

    enum Section: Int, CaseIterable {
        case baseCurrency, favorites, allCurrencies
    }

    class TableCell: UITableViewCell {

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
