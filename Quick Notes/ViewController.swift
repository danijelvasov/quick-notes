//
//  ViewController.swift
//  Quick Notes
//
//  Created by OSX on 8/30/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    var realm : Realm!
    var objectsArray : Results<Item> {
        get {
            return realm.objects(Item.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        tableView.delegate = self
        tableView.dataSource = self
        reload()
    }

    @IBAction func addBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add new items to list:", message: "What do you want to do?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            let textField = (alert.textFields?.first)! as UITextField
           
            let itemToAdd = Item()
            itemToAdd.note = textField.text!
                try! self.realm.write {
                    self.realm.add(itemToAdd)
                    self.tableView.insertRows(at: [IndexPath(row: self.objectsArray.count-1, section: 0)], with: .automatic)
                }
        }
        alert.addAction(add)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? Cell  else { return UITableViewCell()}
        
        let item = objectsArray[indexPath.row]
        cell.cellLabel.text = item.note
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (row, indexPath) in
            let itemToRemove = self.objectsArray[indexPath.row]
            try! self.realm.write {
                self.realm.delete(itemToRemove)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (row, indexPath) in
            let editingAlert = UIAlertController(title: "Edit selected item", message: "What do you want to do?", preferredStyle: .alert)
            editingAlert.addTextField(configurationHandler: nil)
            let textField = (editingAlert.textFields?.first)! as UITextField
            let itemToEdit = self.objectsArray[indexPath.row]
            textField.text = itemToEdit.note
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            let update = UIAlertAction(title: "Update", style: .default, handler: { (action) in
                try! self.realm.write {
                   itemToEdit.setValue(textField.text, forKey: "note")
                }
                self.reload()
            })
            editingAlert.addAction(update)
            editingAlert.addAction(cancel)
        self.present(editingAlert, animated: true, completion: nil)
            
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        editAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return [deleteAction,editAction]
    }
    
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let itemToRemove = objectsArray[indexPath.row]
//            try! self.realm.write {
//                self.realm.delete(itemToRemove)
//            }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
    
    func reload() {
        tableView.reloadData()
    }
    
}

class Item: Object {
    @objc dynamic var note : String = ""
}


class Cell : UITableViewCell{
    @IBOutlet weak var cellLabel: UILabel!
    
}





