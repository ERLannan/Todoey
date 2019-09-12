//
//  CategoryViewController.swift
//  Todoy
//
//  Created by Eric on 8/29/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var categoryArray:Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(.darkGray, returnFlat: true)]
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.backgroundColor = RandomFlatColorWithShade(.dark).hexValue()//UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
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
        (alert.actions[1] as UIAlertAction).isEnabled = (tf.text!.count > 2)
    
    }
    
    func load() {
        categoryArray = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    
    func save(category: Category) {
        do{
            try realm.write {
                realm.add(category)
            }
            self.tableView.reloadData()
        } catch {
            print("Error saving Categories: \(error)")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categoryArray?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error saving Categories: \(error)")
            }
        }
    }
    //MARK: - TableView Datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.backgroundColor = UIColor(hexString: category.backgroundColor )
            cell.textLabel?.text = category.name
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation
}
