//
//  TaskCell.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell {
  
  let nameLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Add"
    return view
  }()
  
  let goalLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textAlignment = .center
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
    
    addSubview(nameLabel)
    addSubview(goalLabel)
    
    NSLayoutConstraint.activate([
      
      // Name Label
      nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
      nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      nameLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -16),
      nameLabel.heightAnchor.constraint(equalToConstant: 20),
      
      // Goal Label
      goalLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      goalLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
      goalLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -16),
      goalLabel.heightAnchor.constraint(equalToConstant: 20)
      
      ])
  }
  
}
