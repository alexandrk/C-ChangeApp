//
//  MainViewController.swift
//  C-Change
//
//  Created by Alexander on 2/15/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UICollectionViewController {

  private var tasksFetchedRC: NSFetchedResultsController<Task>!
  weak private var appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
  private let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
  
  // MARK: - Views
  private var columnLayout = false
  let layoutTypeButton: UIBarButtonItem = {
    var barButton = UIBarButtonItem()
    barButton.image = #imageLiteral(resourceName: "Column_Layout")
    barButton.title = "Columns"
    barButton.action = #selector(changeColumnLayout)
    
    return barButton
  }()
  
  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.register(TaskCell.self, forCellWithReuseIdentifier: "taskCell")
    navigationItem.title = "Change"
    collectionView?.backgroundColor = UIColor.white
    
    // Navigation Bar Buttons
    layoutTypeButton.target = self
    navigationItem.setRightBarButtonItems([
      UIBarButtonItem(barButtonSystemItem: .add,
                      target: self,
                      action: #selector(addItemTouched)),
      layoutTypeButton], animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchData()
    
    let numberOfObjects = tasksFetchedRC.fetchedObjects?.count
    
    // Load Intro View, if no objects found in CoreData
    if numberOfObjects == 0 {
      navigationController?.pushViewController(IntroViewController(), animated: false)
    } else {
      navigationController?.navigationBar.isHidden = false
      collectionView?.reloadData()  //Update data, when returning to VC from other VCs
    }
  }
  
  // MARK: - Event Handlers
  @objc private func addItemTouched() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    navigationController?.pushViewController(AddTaskViewController(), animated: true)
  }
  
  @objc private func changeColumnLayout() {
    columnLayout = !columnLayout
    
    if columnLayout {
      layoutTypeButton.image = #imageLiteral(resourceName: "Row_Layout")
      layoutTypeButton.title = "Rows"
    } else {
      layoutTypeButton.image = #imageLiteral(resourceName: "Column_Layout")
      layoutTypeButton.title = "Columns"
    }
    collectionView?.collectionViewLayout.invalidateLayout()
    
    UIView.animate(
      withDuration: 0.4,
      delay: 0.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: UIViewAnimationOptions(),
      animations: {
        self.collectionView?.layoutIfNeeded()
    },
      completion: nil
    )
  }
  
  // MARK: - CollectionView Methods
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tasksFetchedRC.fetchedObjects?.count ?? 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCell", for: indexPath)
    cell.layer.cornerRadius = Constants.CollectionView.cellCornerRadius
    
    guard let taskCell = cell as? TaskCell else {
      print("Couldn't cast cell to TaskCell")
      return cell
    }
    
    if tasksFetchedRC.fetchedObjects == nil {
      print("ERROR: cellForItemAt, no fetched objects found.")
      return cell
    }
    
    let task = tasksFetchedRC.object(at: indexPath)
    let doneTimes = task.done?.count ?? 0
    
    taskCell.contentView.backgroundColor = task.color
    
    // Determine font color based on the background color [white/black]
    var textColor = UIColor.black
    if let taskComponents = task.color?.cgColor.components {
      let red = taskComponents[0] * 255
      let green = taskComponents[1] * 255
      let blue = taskComponents[2] * 255
      let brightness = (red * 299 + green * 587 + blue * 114) / 1000
      textColor = (brightness < 123) ? .white : .black
    }
    textColor = textColor.withAlphaComponent(0.9)
    taskCell.nameLabel.textColor = textColor
    taskCell.goalLabel.textColor = textColor
    taskCell.lastDoneLabel.textColor = textColor
    
    taskCell.nameLabel.text = task.name!.uppercased()
    
    if task.goal > 0 {
      taskCell.goalLabel.text = "\(doneTimes) / \(task.goal)"
    } else {
      taskCell.goalLabel.text = "\(doneTimes)"
    }
    
    if doneTimes > 0 {
      
      let timestampDescending = NSSortDescriptor(keyPath: \TaskDone.timestamp, ascending: false)
      let mostRecentDone = task.done?.sortedArray(using: [timestampDescending]).first as? TaskDone
      
      if let timeInterval = mostRecentDone?.timestamp?.timeIntervalSinceNow {
        let intInterval = Int(timeInterval) * -1
        var sinceLastDone = ""
        let days = intInterval / 86400
        let hours = intInterval % 86400 / 3600
        let minutes = intInterval % 86400 % 3600 / 60
        let seconds = intInterval % 86400 % 3600 % 60
        
        if days > 0 { sinceLastDone += "\(days) d" }
        if hours > 0 { sinceLastDone += " \(hours)h" }
        if minutes > 0 { sinceLastDone += " \(minutes)m" }
        if seconds > 0 { sinceLastDone += " \(seconds)s" }
        
        sinceLastDone = (sinceLastDone.isEmpty) ? "just now" : sinceLastDone + " ago"
        taskCell.lastDoneLabel.text = sinceLastDone
      }
      
    } else {
      taskCell.lastDoneLabel.text = ""
    }
    
    return taskCell
  }
  
  // Increment number of items done on click
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let done = TaskDone(entity: TaskDone.entity(), insertInto: context)
    done.task = tasksFetchedRC.object(at: indexPath)
    done.timestamp = Date()
    appDelegate?.saveContext()
    
    UIView.performWithoutAnimation {
      self.collectionView?.reloadItems(at: [indexPath])
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    switch action.description {
    case "delete":
      promptForDelete(collectionView, indexPath)
    case "edit":
      editItem(collectionView, indexPath)
    default:
      print("This should never execute, please check cell action types")
    }
    
  }

 override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let itemInTransition = TaskItems.items.remove(at: sourceIndexPath.row)
    TaskItems.items.insert(itemInTransition, at: destinationIndexPath.row)
  }
  
  // MARK: - Helper Functions
  private func promptForDelete(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
    
    let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete item '\(tasksFetchedRC.object(at: indexPath).name?.uppercased() ?? "N/A")'?", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
      self.context.delete(self.tasksFetchedRC.object(at: indexPath))
      self.appDelegate?.saveContext()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
      self.dismiss(animated: true, completion: nil)
      UIView.animate(withDuration: 0.2, animations: {
        collectionView.cellForItem(at: indexPath)?.setNeedsLayout()
        collectionView.cellForItem(at: indexPath)?.layoutIfNeeded()
      })
    }))
    
    present(alert, animated: true, completion: nil)
  }
  
  private func editItem(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
    let vc = AddTaskViewController()
    vc.taskItem = tasksFetchedRC.object(at: indexPath)
    vc.taskItemIndex = indexPath.row
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func fetchData() {
    let request = Task.fetchRequest() as NSFetchRequest<Task>
    
//    let sort = NSSortDescriptor(keyPath: \Friend.name, ascending: true)
//    if !query.isEmpty {
//      request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
//    }
    let sort = NSSortDescriptor(key: #keyPath(Task.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
//    let color = NSSortDescriptor(key: #keyPath(Friend.eyeColor), ascending:true)
    
    request.sortDescriptors = [sort]
    do {
      tasksFetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      tasksFetchedRC.delegate = self
      try tasksFetchedRC.performFetch()
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
  
}

// MARK: - CollectionView FlawLayout Delegate extension
extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return Constants.CollectionView.squareCellSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return Constants.CollectionView.sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    var itemSize: CGSize!
    let horizontalInset = Constants.CollectionView.sectionInsets.left + Constants.CollectionView.sectionInsets.right
    
    if columnLayout {
      let halfWidth = collectionView.bounds.width / 2
      itemSize = CGSize(width: halfWidth - horizontalInset / 2 - Constants.CollectionView.squareCellSpacing / 2,
                        height: halfWidth - horizontalInset / 2 - Constants.CollectionView.squareCellSpacing / 2)
    } else {
      itemSize = CGSize(width: collectionView.bounds.width - horizontalInset, height: 100)
    }
    
    return itemSize
  }
  
}

//// MARK: - NSFetchedResultsControllerDelegate
extension MainViewController: NSFetchedResultsControllerDelegate {

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    let index = indexPath ?? (newIndexPath ?? nil)
    guard let cellIndex = index else {
      return
    }

    switch type {
      case .insert: collectionView?.insertItems(at: [cellIndex])
      case .delete: collectionView?.deleteItems(at: [cellIndex])
      default: break
    }
  }

}

