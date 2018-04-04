//
//  CountTableViewController.swift
//  C-Change
//
//  Created by Alexander on 4/3/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit
import CoreData

class CountTableViewController: UITableViewController {

  var fetchedTask: Task!
  private var taskDoneArray: [TaskDone]?
  weak private var appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
  private let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
  
    override func viewDidLoad() {
      super.viewDidLoad()

      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
      
      let sortOrder = NSSortDescriptor(key: #keyPath(TaskDone.timestamp), ascending: false)
      taskDoneArray = fetchedTask.done?.sortedArray(using: [sortOrder]) as? [TaskDone]
    }
  
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return taskDoneArray?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)

      guard let taskDone = taskDoneArray?[indexPath.row],
      let timestamp = taskDone.timestamp else {
        print("ERROR: cellForRowAt: item at indexPath: \(indexPath) doesn't exist")
        return cell
      }
      
      let formattedDate = DateFormatter()
      formattedDate.dateFormat = "MMM dd, yyyy HH:mm:ss"
      cell.textLabel?.text = formattedDate.string(from: timestamp)

      return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
          
          // Delete the row from the data source
          context.delete(taskDoneArray![indexPath.row])
          appDelegate?.saveContext()
          
          taskDoneArray?.remove(at: indexPath.row)
          
          tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
