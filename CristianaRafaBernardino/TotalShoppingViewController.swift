//
//  TotalShoppingViewController.swift
//  CristianaRafaBernardino
//
//  Created by Rafael Bernardino on 21/04/17.
//
//

import UIKit
import CoreData

class TotalShoppingViewController: UIViewController {

    @IBOutlet weak var totalDolar: UILabel!
    @IBOutlet weak var totalReal: UILabel!
    
    var dataSource = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadProducts()
    }

    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
       
        do {
            try dataSource = context.fetch(fetchRequest)
            calcTotal()
        } catch {
            print("erro")
        }
    }
    
    func calcTotal() {
        var cotacaoDolar: Double = 0
        var percIof: Double = 0
        
        if let dolar = UserDefaults.standard.string(forKey: "cotacao_dolar") {
            cotacaoDolar = Double(dolar)!
        }
        
        if let iof = UserDefaults.standard.string(forKey: "iof") {
            percIof = Double(iof)!
        }
        
        var calcDolar: Double = 0
        var calcReal: Double = 0
        
        for itemProduct in dataSource {
            var productReal: Double = 0
            
            calcDolar += itemProduct.valor
            
            productReal = itemProduct.valor
            
            if itemProduct.flagCartao {
                productReal += (productReal * percIof / 100)
            }
            
            productReal = (productReal * cotacaoDolar)
            calcReal += productReal + (productReal * (itemProduct.state?.imposto)! / 100)
        }
        
        totalDolar.text = String(calcDolar)
        totalReal.text = String(calcReal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
