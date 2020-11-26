//
//  ViewController.swift
//  MyMealsCoreData
//
//  Created by Николаев Никита on 31.10.2020.
//  Copyright © 2020 Николаев Никита. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var context: NSManagedObjectContext!
    var user: User!
    var userName: String! = "" {
        didSet {
            nameLabel.text = userName
            updateMealTimes()
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let locale = Locale(identifier: "ru_Ru")
        formatter.locale = locale
        return formatter
    }()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func changeUser(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Введите имя пользователя", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            self.userName = ac.textFields?.first?.text
        }
        ac.addAction(ok)
        present(ac, animated: true)

    }
    
    @IBAction func addMealTime(_ sender: UIBarButtonItem) {
        let meal = Meal(context: context)
        meal.date = Date()
        
        let meals = user.meals?.mutableCopy() as? NSMutableOrderedSet
        meals?.add(meal)
        user.meals = meals
        
        do {
            try context.save()
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func updateMealTimes() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", userName)
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                user = User(context: context)
                user.name = userName
                try context.save()
            } else {
                user = results.first
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        updateMealTimes()
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.meals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        guard let meal = user.meals?[indexPath.row] as? Meal,
            let mealDate = meal.date else { return cell }
        cell.textLabel?.text = dateFormatter.string(from: mealDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let meal = user.meals?[indexPath.row] as? Meal, editingStyle == .delete else { return }
        context.delete(meal)
        
        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
}
