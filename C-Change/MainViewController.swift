//
//  MainViewController.swift
//  C-Change
//
//  Created by Alexander on 2/15/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

class MainViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

  var columnLayout = false
  let layoutTypeButton: UIBarButtonItem = {
    var barButton = UIBarButtonItem()
    barButton.image = #imageLiteral(resourceName: "Column_Layout")
    barButton.title = "Columns"
    barButton.action = #selector(changeColumnLayout)
    
    return barButton
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    if TaskItems.items.count == 0 {
      navigationController?.pushViewController(IntroViewController(), animated: false)
    } else {
      navigationController?.navigationBar.isHidden = false
      collectionViewLayout.invalidateLayout()
      collectionView?.layoutIfNeeded()
      collectionView?.reloadData()
    }
  }
  
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
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return TaskItems.items.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCell", for: indexPath)
    
    cell.layer.cornerRadius = Constants.CollectionView.cellCornerRadius
    
    guard let taskCell = cell as? TaskCell else {
      print("Couldn't cast cell to TaskCell")
      return cell
    }
    
    let task = TaskItems.items[indexPath.row]
    
    taskCell.contentView.backgroundColor = task.color
    taskCell.nameLabel.text = task.label.uppercased()
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
    
    switch action.description {
    case "delete":
      promptForDelete(collectionView, indexPath)
    case "edit":
      editItem(collectionView, indexPath)
    default:
      print("This should never execute, please check cell action types")
    }
    
  }

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
  
  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let itemInTransition = TaskItems.items.remove(at: sourceIndexPath.row)
    TaskItems.items.insert(itemInTransition, at: destinationIndexPath.row)
  }
  
  private func promptForDelete(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
    
    let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete item \(TaskItems.items[indexPath.row].label)", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
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
  
  private func editItem(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
    let vc = AddTaskViewController()
    vc.taskItem = TaskItems.items[indexPath.row]
    vc.taskItemIndex = indexPath.row
    navigationController?.pushViewController(vc, animated: true)
  }
  
}
