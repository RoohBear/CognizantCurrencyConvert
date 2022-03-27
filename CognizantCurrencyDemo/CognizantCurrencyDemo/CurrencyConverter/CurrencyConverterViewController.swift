//
//  CurrencyConverterViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Greg Wishart on 2022-03-21.
//

import UIKit
import Combine

class CurrencyConverterViewController: UIViewController {
    @IBOutlet weak var tableFrom:UITableView!
    @IBOutlet weak var tableTo:UITableView!
    @IBOutlet weak var textfieldConvertFrom:UITextField!
    @IBOutlet weak var labelResult:UILabel!
    @IBOutlet weak var labelSourceCurrency:UILabel!
    
    private var cancellables = Set<AnyCancellable>()
    private var presenter: CurrencyConverterPresenterProtocol!
    
    // MARK: Initialisers
    @available(*, unavailable, message: "Use CurrencyConverterViewController.instance(presenter) instead")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Static Methods
    static func instance(presenter: CurrencyConverterPresenterProtocol) -> CurrencyConverterViewController {
        let converterViewController = UIStoryboard(name: "Main",
                                                   bundle: nil)
            .instantiateViewController(withIdentifier: "converterController") as! CurrencyConverterViewController
        converterViewController.presenter = presenter
        return converterViewController
    }
    
    // MARK: Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextField()
        
        sinkToPublishers()
        presenter.viewReady()
    }
}

// MARK: Private Methods
extension CurrencyConverterViewController {
    private func refreshTableViews() {
        tableTo.reloadData()
        tableFrom.reloadData()
    }
    
    private func exchangeRateCriteriaUpdated() {
        guard let amount = textfieldConvertFrom.text,
              !amount.trimmingCharacters(in: .whitespaces).isEmpty,
              let currencyIndex = tableFrom.indexPathForSelectedRow,
              let baseCurrencyIndex = tableTo.indexPathForSelectedRow
        else {
            return
        }
        
        presenter.converterCriteriaUpdated(withBaseCurrencyIndex: baseCurrencyIndex.row,
                                           currencyIndex: currencyIndex.row,
                                           amount: amount)
    }
    
    private func setTextField() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.textfieldConvertFrom)
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .sink{ [weak self] _ in
                self?.exchangeRateCriteriaUpdated()
            }
            .store(in: &cancellables)
    }
    
    private func sinkToPublishers() {
        presenter.listUpdatePublisher.sink {
            self.refreshTableViews()
        }.store(in: &cancellables)
        
        presenter.currencyRatePublisher
            .assign(to: \.text, on: labelResult)
            .store(in: &cancellables)
    }
}

// MARK: TableView Data Source Methods
extension CurrencyConverterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberCurrencies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if let cellReused = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = cellReused
        }
        
        cell.textLabel?.text = presenter.currencyData(at: indexPath.row)
        return cell
    }
}

// MARK: TableVew Delegate methods
extension CurrencyConverterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exchangeRateCriteriaUpdated()
    }
}
