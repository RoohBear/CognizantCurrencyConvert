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
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var fallbackLabel: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var rateUpdateActivity: UIActivityIndicatorView!
    
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
        
        activity.startAnimating()
        presenter.viewReady()
    }
}

// MARK: Private Methods
extension CurrencyConverterViewController {
    private func refreshTableViews() {
        activity.stopAnimating()
        contentStack.isHidden = false
        
        tableTo.reloadData()
        tableFrom.reloadData()
    }
    
    // ** called when the user updates text in the UITextField, or when the selection in the tables have changed
    private func exchangeRateCriteriaUpdated() {
        guard let amount = textfieldConvertFrom.text,
              !amount.trimmingCharacters(in: .whitespaces).isEmpty,
              let currencyIndex = tableFrom.indexPathForSelectedRow,
              let baseCurrencyIndex = tableTo.indexPathForSelectedRow
        else {
            return
        }
        
        labelResult.text = nil
        rateUpdateActivity.startAnimating()
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
    
    // called by ViewDidLoad. Subscribes to publishers to update the UI when we get results from the scoop service
    private func sinkToPublishers() {
        // this one updates the tables when we download the currencies
        presenter.listUpdatePublisher.sink {
            self.refreshTableViews()
        }.store(in: &cancellables)
        
        // this just sets presenter.currencyRatePublisher to update labelResult when presenter publishes a result
        // (an alternative way of setting self.labelResult)
        #if false
            presenter.currencyRatePublisher
                .assign(to: \.text, on: labelResult)
                .store(in: &cancellables)
        #endif
        
        // this sets the label to the result,
        // stops the activityindicator when presenter.currencyRatePublisher publishes a result
        presenter.currencyRatePublisher.sink {[weak self] rate in
            self?.rateUpdateActivity.stopAnimating()
            self?.labelResult.text = rate
        }.store(in: &cancellables)
    }
    
    private func setFromLabel(for index: Int) {
        labelSourceCurrency.text = presenter.currency(at: index)
    }
}

// MARK: TableView Data Source Methods
extension CurrencyConverterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberCurrencies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = presenter.currency(at: indexPath.row)
        return cell
    }
}

// MARK: TableVew Delegate methods
extension CurrencyConverterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableFrom {
            setFromLabel(for: indexPath.row)
        }
        exchangeRateCriteriaUpdated()
    }
}
