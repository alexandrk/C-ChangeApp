//
//  Datastore.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

struct TaskItem {
  var label: String
  var substitute: String?
  var taskCount: Int
  var substituteCount: Int
  var goal: Int
  var color: UIColor
  
  init(_ label: String, substitute: String?, color: UIColor?, goal: Int) {
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
    
    self.goal = goal
  }
}

struct TaskItems {
  static var colors = Constants.colors
  static var items: [TaskItem] = []
//                                  [TaskItem("Smoking", substitute: nil, color: nil, goal: 5),
//                                  TaskItem("Water", substitute: nil, color: nil, goal: -1),
//                                  TaskItem("Exercise", substitute: nil, color: nil, goal: -1)]
}
