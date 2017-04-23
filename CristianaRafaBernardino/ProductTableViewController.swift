//
//  ProductTableViewController.swift
//  CristianaRafaBernardino
//
//  Created by Rafael Bernardino on 09/04/17.
//
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {
    
    var label = UILabel(frame: CGRect(x:0, y:0, width: 200, height: 25))
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadProduct()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProductRegisterViewController {
            if let index = tableView.indexPathForSelectedRow {
                vc.product = fetchedResultController.object(at: index)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.tintColor = .black
        label.alpha = 0.3
        label.backgroundColor = .white

        if let count = fetchedResultController.fetchedObjects?.count {
            if count < 1 {
                tableView.backgroundView = label
                tableView.rowHeight = 1
                return 0
            } else {
                tableView.backgroundView = nil
                tableView.estimatedRowHeight = 106
                tableView.rowHeight = UITableViewAutomaticDimension
                return count
            }
        } else {
            tableView.backgroundView = label
            return 0
        }
    }

    func loadProduct() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "descricao", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProduct", for: indexPath)
        let product = fetchedResultController.object(at: indexPath)
        
        cell.textLabel?.text = product.descricao
        cell.detailTextLabel?.text = String(product.valor)
        cell.imageView?.image = product.imagem as? UIImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            context.delete(product)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
}

extension ProductTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
