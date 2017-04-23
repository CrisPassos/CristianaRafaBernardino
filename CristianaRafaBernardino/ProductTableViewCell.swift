//
//  ProductTableViewCell.swift
//  CristianaRafaBernardino
//
//  Created by Rafael Bernardino on 15/04/17.
//
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivProduto: UIImageView!
    @IBOutlet weak var lbDescricao: UILabel!
    @IBOutlet weak var lbValor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

