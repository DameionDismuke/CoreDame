//
//  ViewController.swift
//  CoreDameData
//
//  Created by Dameion Dismuke on 1/2/23.
//
// Create an application that utilizes an online API, decodes it, and saves the data into Core Data, and
// the app fetches the data from core data instead to see if the data has already been pulled.

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //PersistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Buttons for Cryptocurrency
    @IBOutlet weak var btcPrice: UILabel!
    @IBOutlet weak var ethPrice: UILabel!
    
    //Buttons for country currency
    @IBOutlet weak var usdPrice: UILabel!
    @IBOutlet weak var audPrice: UILabel!
    @IBOutlet weak var jpyPrice: UILabel!
    
    //Updated Pricing
    @IBOutlet weak var lastUpdatedPrice: UILabel!
    
    //TABLEVIEW
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //array of investmentGoals
    private var models = [InvestmentGoal]()
    
    
    //API url
    let urlString = "https://api.coingecko.com/api/v3/exchange_rates"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CoreDame Crypto List"
        
        view.addSubview(tableView)
        
        getAllInvestments()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        //plus button to add investments
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        //fetching the data
        fetchData()
        
        _ = Timer(timeInterval: 10, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
        
        
    }
    
    //The function for the + add symbol
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New Investment", message: "Enter new Investment/Crypto", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler:nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self?.createInvestment(name: text, unit: text, value: 0.0, type: text)
        }))
        
        present(alert, animated: true)
    }
    
    
    
    //This the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    //THIS IS THE CELL
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    //something to delete
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let investment = models[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { //_ in
            
        let alert = UIAlertController(title: "New Investment", message: "Enter your Investment/Crypto", preferredStyle: .alert)
            
        alert.addTextField(configurationHandler:nil)
        alert.textFields?.first?.text = investment.name
        alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first,
                      let newName = field.text, !newName.isEmpty,
                      let newUnit = field.text, !newUnit.isEmpty,
                      let newValue = field.0.0, !newValue.isEmpty,
                      let newType = field.text, !newType.isEmpty
                else {
                    return
                }
                
            self?.updateInvestment(investment: investment, newName: newName, newUnit: newUnit, newValue: newValue, newType: newType)
            }))
            
            self.present(alert, animated: true)
            
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            self?.deleteInvestment(investment: investment)
        }))
        
        present(sheet, animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //CORE DATA
    
    @objc func refreshData() -> Void
    {
        fetchData()
    }
    
    func fetchData() {
        
        let url = URL(string: urlString)
        let defaultSession = URLSession(configuration: .default)
        let dataTask = defaultSession.dataTask(with: url!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if(error != nil){
                print(error!)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(Rates.self, from: data!)
                self.setPrices(currency: json.rates)
                
                
            }
            catch{
                print(error)
                return
            }
            
        }
        dataTask.resume()
    }
    
    
    func formatPrice(_ price : Price) -> String {
        return String(format: "%@ %.4f", price.unit, price.value)
    }
    
    func setPrices(currency : Currency){
        
        
        DispatchQueue.main.async {
            self.btcPrice.text = self.formatPrice(currency.btc)
            self.ethPrice.text = self.formatPrice(currency.eth)
            self.usdPrice.text = self.formatPrice(currency.usd)
            self.audPrice.text = self.formatPrice(currency.aud)
            self.jpyPrice.text = self.formatPrice(currency.jpy)
            
            self.lastUpdatedPrice.text = self.formatDate(date: Date())
        }
    }
    
    func formatDate(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM y HH:mm:ss"
        return formatter.string(from: date)
        
    }
    
    func getAllInvestments(){
        
        do {
            models = try context.fetch(InvestmentGoal.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            //error
        }
        
    }
    
    
    
    //This is for adding things onto the list
    func createInvestment(name: String, unit: String, value: Float, type: String){
        
        let newInvestment = InvestmentGoal(context: context)
        
        newInvestment.name = name
        newInvestment.unit = unit
        newInvestment.value = value
        newInvestment.type = type
        
        
        do {
            try context.save()
        }
        catch {
            
        }
        
    }
    
    
    //This is for deleting things on the list
    func deleteInvestment(investment: InvestmentGoal){
        
        context.delete(investment)
        
        
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    
    //This is for updating the list
    func updateInvestment(investment: InvestmentGoal, newName: String, newUnit: String, newValue: Float, newType: String){
        
        investment.name = newName
        investment.unit = newUnit
        investment.value = newValue
        investment.type = newType
        
        do {
            try context.save()
            getAllInvestments()
        }
        catch {
            
        }
        
    }
        
        


}

