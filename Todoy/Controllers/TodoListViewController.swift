//
//  ViewController.swift
//  Todoy
//
//  Created by Eric on 8/27/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems:Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadTodoData()
        }
    }
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    When you see me typing out the code for NSAttributedStringKey just be aware that Apple has recently changed it to NSAttributedString.Key
//
//    So be sure to use the latest syntax!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodoData()
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = selectedCategory?.backgroundColor {
            navigationController?.navigationBar.barTintColor = UIColor(hexString: color)
            navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)]
            
            self.searchBar.barTintColor = UIColor(hexString: color)
            
        }
        title = selectedCategory?.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(.darkGray, returnFlat: true)]
    }
    
    //MARK: - Save/Load Data
    func loadTodoData() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error saving Categories: \(error)")
            }
        }
    }
    
    //MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            let color = UIColor.init(hexString: selectedCategory?.backgroundColor ?? "FFF")
//            cell.backgroundColor = color?.darken(byPercentage: 0.05 * CGFloat(indexPath.row))
            cell.backgroundColor = color?.darken(byPercentage: CGFloat(Float(indexPath.row) / Float(todoItems!.count + 8)))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.tintColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No items added"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done", error)
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todo", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newTodo = Item()
                        newTodo.title = textField.text!
                        newTodo.dateCreated = Date()
                        currCategory.items.append(newTodo)
                    }
                } catch {
                    print("Error saving item to category \(error)")
                }
                
            }
            self.tableView.reloadData()
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
        (alert.actions[1] as UIAlertAction).isEnabled = (tf.text!.count > 2)
    }
}

//MARK: - SearchBar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0) {
            loadTodoData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
            self.tableView.reloadData()
        }
    }
}
