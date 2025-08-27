//
//  AllTasksViewController.swift
//  Mirror
//
//  Created by Yuqing Wang on 8/26/25.
//

import UIKit


@objcMembers
//@objc(AllTasksViewController)
class AllTasksViewController: UITableViewController {
    
    // MARK: - Sample Data
    let tasks = [
        "English",
        "French",
        "Quantum Mechanics",
        "Electromagnetism"
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected task: \(tasks[indexPath.row])")
    }
}
