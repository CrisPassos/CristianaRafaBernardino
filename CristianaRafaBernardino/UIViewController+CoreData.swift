	//
//  UIViewController+CoreData.swift
//  CristianaRafaBernardino
//
//  Created by Rafael Bernardino on 15/04/17.
//
//

import UIKit
import CoreData
    
    extension UIViewController {
        var appDelegate: AppDelegate {
            return UIApplication.shared.delegate as! AppDelegate
        }
        
        var context: NSManagedObjectContext {
            return appDelegate.persistentContainer.viewContext
        }
    }

