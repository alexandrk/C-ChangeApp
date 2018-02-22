//
//  MainViewController.swift
//  C-Change
//
//  Created by Alexander on 2/15/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

class MainViewController: UICollectionViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    collectionView?.register(TaskCell.self, forCellWithReuseIdentifier: "taskCell")
    navigationItem.title = "Change"
    collectionView?.backgroundColor = UIColor.white
    
    // Navigation Bar Button
    navigationItem.setRightBarButton(
      UIBarButtonItem(barButtonSystemItem: .add,
                      target: self,
                      action: #selector(addItemTouched)), animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if TaskItems.items.count == 0 {
      navigationController?.pushViewController(IntroViewController(), animated: false)
    } else {
      navigationController?.navigationBar.isHidden = false
      collectionView?.reloadData()
    }
  }
  
  @objc private func addItemTouched() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    navigationController?.pushViewController(AddTaskViewController(), animated: true)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return TaskItems.items.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCell", for: indexPath)
    
    guard let taskCell = cell as? TaskCell else {
      print("Couldn't cast cell to TaskCell")
      return cell
    }
    
    let task = TaskItems.items[indexPath.row]
    
    taskCell.contentView.backgroundColor = task.color
    taskCell.nameLabel.text = task.label
    taskCell.nameLabel.textColor = task.fontColor
    taskCell.goalLabel.textColor = task.fontColor
    if task.goal > 0 {
      taskCell.goalLabel.text = "\(task.taskCount) / \(task.goal)"
    } else {
      taskCell.goalLabel.text = "\(task.taskCount)"
    }
    
    return taskCell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    TaskItems.items[indexPath.row].taskCount += 1
    UIView.performWithoutAnimation {
      self.collectionView?.reloadItems(at: [indexPath])
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete item \(TaskItems.items[indexPath.row].label)", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
      print("Action: \(action)")
      TaskItems.items.remove(at: indexPath.row)
      collectionView.deleteItems(at: [indexPath])
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

}
