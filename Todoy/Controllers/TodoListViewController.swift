//
//  ViewController.swift
//  Todoy
//
//  Created by Eric on 8/27/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [TodoItem]()
    var selectedCategory : Category? {
        didSet{
            loadTodoData()
        }
    }
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodoData()
    }
    
    
    //MARK: - Save/Load Data
    func loadTodoData(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionPredicate = predicate {
         request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print("Error fetching data from context")
        }
    }
    
    func saveTodoData() {
        do {
            try context.save()
            self.tableView.reloadData()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    //MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//            context.delete(itemArray[indexPath.row])
//            itemArray.remove(at: indexPath.row)

        saveTodoData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todo", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                let newTodo = TodoItem(context: self.context )
                newTodo.title = textField.text!
                newTodo.done = false
                newTodo.parentCategory = self.selectedCategory
                self.itemArray.append(newTodo)
                self.saveTodoData()
            textField.resignFirstResponder()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            
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
}

//MARK: - SearchBar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        searchBar.resignFirstResponder()
        loadTodoData(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0) {
            loadTodoData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()                
            }
        } else {
            let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadTodoData(with: request)
        }
    }
}
