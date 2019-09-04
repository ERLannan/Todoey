//
//  CategoryViewController.swift
//  Todoy
//
//  Created by Eric on 8/29/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context )
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategories()
            textField.resignFirstResponder()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            
            alertTextField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
            
            textField = alertTextField
            textField.becomeFirstResponder()
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
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print("Error fetching Categories: \(error)")
        }
    }
    
    func saveCategories() {
        do{
            try context.save()
            self.tableView.reloadData()
        } catch {
            print("Error saving Categories: \(error)")
        }
    }
    
    //MARK: - TableView Datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    //MARK: - Data Manipulation
}
