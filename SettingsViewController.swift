//
//  SettingsViewController.swift
//  CristianaRafaBernardino
//
//  Created by Rafael Bernardino on 15/04/17.
//
//

import UIKit
import CoreData

enum CategoryAlertType {
    case add
    case edit
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var tfCotacao: UITextField!
    @IBOutlet weak var tfIof: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [State] = []
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tfIof.delegate = self
        tfCotacao.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        loadStates()
        loadSettings()
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "estado", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadSettings() {
        tfCotacao.text = UserDefaults.standard.string(forKey: "cotacao_dolar")
        tfIof.text = UserDefaults.standard.string(forKey: "iof")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func adicionarEstado(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
    
    func showAlert(type: CategoryAlertType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Estado"
            if let estado = state?.estado {
                textField.text = estado
            }
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            if let imposto = state?.imposto {
                textField.text = String(describing: imposto)
            }
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            state.estado = alert.textFields?.first?.text
            state.imposto = Double((alert.textFields?.last?.text)!)!
            
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let state = dataSource[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.accessoryType == .none {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            self.context.delete(state)
            do {
                try self.context.save()
                self.dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action:
            UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true)
            
            self.showAlert(type: .edit, state: state)
        }
        editAction.backgroundColor = .blue
        
        return [deleteAction, editAction]
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.count < 1 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 80))
            label.text = "Sua lista está vazia!"
            label.textAlignment = .center
            label.tintColor = .black
            label.alpha = 0.3
            tableView.backgroundView = label
            tableView.rowHeight = 1
            return 0
        } else {
            tableView.estimatedRowHeight = 106
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.backgroundView = nil
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellState", for: indexPath)
        
        let state = dataSource[indexPath.row]
        cell.textLabel?.text = state.estado
        cell.detailTextLabel?.text = String(state.imposto)
        
        return cell
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        UserDefaults.standard.set(tfCotacao.text, forKey: "cotacao_dolar")
        UserDefaults.standard.set(tfIof.text, forKey: "iof")
    }
}
