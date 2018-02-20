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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    TaskItems.items = []
    if TaskItems.items.count == 0 {
      navigationController?.pushViewController(IntroViewController(), animated: false)
    } else {
      navigationController?.navigationBar.isHidden = false
      collectionView?.reloadData()
    }
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
    
    taskCell.label.text = task.label
    taskCell.backgroundColor = task.color
    
    return taskCell
  }

}
