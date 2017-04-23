//
//  ProductRegisterViewController.swift
//  CristianaRafaBernardino
//
//  Created by Rafael Bernardino on 15/04/17.
//
//

import UIKit
import CoreData

class ProductRegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var tfNomeProduto: UITextField!
    @IBOutlet weak var ivImagemProduto: UIImageView!
    @IBOutlet weak var tfEstado: UITextField!
    @IBOutlet weak var tfValor: UITextField!
    @IBOutlet weak var flagCartao: UISwitch!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    var product: Product!
    var dataSource: [State] = []
    var selectedState: State!
    var smallImage: UIImage!
    var toolbar = UIToolbar()
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if product != nil {
            tfNomeProduto.text = product.descricao
            //ivImagemProduto.image = product.imagem as? UIImage
            
            
            if let image = product.imagem as? UIImage{
                ivImagemProduto.image = image
            }
            
            selectedState = product.state
            tfEstado.text = product.state?.estado
            tfValor.text = String(product.valor)
            flagCartao.setOn(product.flagCartao, animated: true)
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        addToolBar()
        tfEstado.inputView = pickerView
        loadState()
    }
    
    func loadState() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "estado", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        toolBar.items = [btCancel,space,btDone]
        tfEstado.inputAccessoryView = toolBar
    }
    
    func cancel() {
        tfNomeProduto.resignFirstResponder()
        tfEstado.resignFirstResponder()
        tfValor.resignFirstResponder()
    }
    
    func done() {
        if dataSource.count > 0 {
            tfEstado.text = dataSource[pickerView.selectedRow(inComponent: 0)].estado
            selectedState = dataSource[pickerView.selectedRow(inComponent: 0)] as State
        }
        cancel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addUpdateProduto(_ sender: UIButton) {
        if product == nil {
            product = Product(context: context)
        }
        
        if tfNomeProduto.text == "" {
            showAlert(field: "Nome do produto")
            return
        } else {
            product.descricao = tfNomeProduto.text
        }
        
        if tfValor.text == "" {
            showAlert(field: "Valor")
            return
        } else {
            product.valor = Double(tfValor.text!)!
        }
        
        product.flagCartao = flagCartao.isOn
                
        if smallImage == nil {
            if product.imagem == nil {
                showAlert(field: "Imagem")
                return
            }
        } else {
            ivImagemProduto.image = smallImage
            product.imagem = smallImage
        }
        
        
        if selectedState == nil {
            showAlert(field: "Estado")
            return
        } else {
            product.state = selectedState
        }
        
        do {
            try context.save()
            navigationController!.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(field: String) {
        let message = "Campo \(field) deve ser preenchido"
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count;
    }    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedState = dataSource[row]
        tfEstado.text = dataSource[row].estado
        return dataSource[row].estado
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar imagem", message: "Escolha o local da imagem ?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action:UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        
        //Como reduzir uma imagem
        let smallSize = CGSize(width: 300, height: 280)
        
        UIGraphicsBeginImageContext(smallSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        ivImagemProduto.image = smallImage
        
        if product != nil {
            product.imagem = smallImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}


