//
//  Datastore.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

struct TaskItem {
  let label: String
  let substitute: String?
  let taskCount: Int
  let substituteCount: Int
  let color: UIColor
  
  init(_ label: String, substitute: String?, color: UIColor?) {
    self.label = label
    self.substitute = substitute
    self.taskCount = 0
    self.substituteCount = 0
    
    if let color = color {
      self.color = color
    } else {
      /// Assign random color from range
      if TaskItems.colors.count <= 0 {
        TaskItems.colors = Constants.colors
      }
      let randomIndex = Int(arc4random_uniform(UInt32(TaskItems.colors.count)))
      self.color = TaskItems.colors.remove(at: randomIndex)
    }
  }
}

struct TaskItems {
  static var colors = Constants.colors
  static var items: [TaskItem] = [TaskItem("Smoking", substitute: nil, color: nil),
                           TaskItem("Water", substitute: nil, color: nil),
                           TaskItem("Exercise", substitute: nil, color: nil)]
}
