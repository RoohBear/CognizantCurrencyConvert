//
//  ViewController.swift
//  CognizantCurrencyDemo
//
//  Created by Greg Wishart on 2022-03-21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableFrom:UITableView!
    @IBOutlet weak var tableTo:UITableView!
    @IBOutlet weak var textfieldConvertFrom:UITextField!
    @IBOutlet weak var labelResult:UILabel!
    @IBOutlet weak var labelSourceCurrency:UILabel!
    
    // A very temporary currency table. Replace this with what the model class downloads
    let currencyTable = ["USD", "CAD", "AUS", "GBP", "COP", "YEN"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // @TODO: download the conversion tables here.
        // model.downloadConversionTables()

        // select the first rows in the tables, enter a default value to convert from,
        // and do the conversion
        tableFrom.selectRow(at: IndexPath(item:0, section:0), animated:false, scrollPosition:.top)
        tableTo.selectRow(at: IndexPath(item:0, section:0), animated:false, scrollPosition:.top)
        textfieldConvertFrom.text = "0.0"
        textfieldConvertFrom.addTarget(self, action:#selector(textfieldChanged), for:.editingChanged)
        self.doConversion()
    }

    /// Called when user changes text in textfieldConvertFrom
    @objc func textfieldChanged()
    {
        self.doConversion()
    }

    /// Called on viewDidLoad(), when the user changes the conversion source or destination,
    /// and when the user enters something in the textfield.
    ///
    /// Does the conversion using the selected currencies in the table and stores the result
    /// in labelResult.
    func doConversion()
    {
        let convertFrom = tableFrom.indexPathForSelectedRow
        let convertTo = tableTo.indexPathForSelectedRow

        // do math here 🤷‍♂️, store result in labelResult
        
        labelSourceCurrency.text = currencyTable[convertFrom!.row]
        labelResult.text = "0.0 \(currencyTable[convertTo!.row])"
    }
    
    /// MARK: - UITableView datasource and delegate stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyTable.count
    }

    // called when user selects a currency from either table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.doConversion()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if let cellReused = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = cellReused
        }
        cell.textLabel?.text = currencyTable[indexPath.row]
        
        return cell
    }
}
