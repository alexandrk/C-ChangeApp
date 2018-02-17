//
//  TaskCell.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell {
  
  let label: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Add"
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addLayoutConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addLayoutConstraints() {
    
    addSubview(label)
    
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
      label.widthAnchor.constraint(equalTo: widthAnchor, constant: -16),
      label.heightAnchor.constraint(equalToConstant: 50)
      ])
  }
  
}
