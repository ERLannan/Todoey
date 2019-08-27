//
//  ViewController.swift
//  Todoy
//
//  Created by Eric on 8/27/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = ["Feed Dog", "Walk Dog", "Do some work", "Boxing Workout"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    //MARK - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todo",
                                      message: "",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if(textField.text!.count > 3) {
                self.itemArray.append(textField.text!)
                self.tableView.reloadData()
            } else {
                textField.placeholder = "Must be more longer than 3 characters"
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            
            alertTextField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            
            textField = alertTextField
            
            
        }
        
        action.isEnabled = false
        
        alert.addAction(cancelAction)
        alert.addAction(action)
        
        present(alert,
                animated: true,
                completion: nil)
    }
    
     @objc func textChanged(sender:UITextField) {
        let tf = sender
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.next! }
        let alert = resp as! UIAlertController
        (alert.actions[1] as UIAlertAction).isEnabled = (tf.text!.count > 3)
    }
}

