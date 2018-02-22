//
//  TaskCell.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell, UIGestureRecognizerDelegate {
  
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
  
  let deleteLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textAlignment = .center
    view.text = "DELETE"
    view.textColor = .black
    view.backgroundColor = .red
    return view
  }()
  
  let editLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textAlignment = .center
    view.text = "EDIT"
    view.textColor = .black
    view.backgroundColor = .green
    return view
  }()
  
  var panGesture: UIPanGestureRecognizer!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.layer.masksToBounds = true
    self.layer.masksToBounds = true
    
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
    panGesture.delegate = self
    self.addGestureRecognizer(panGesture)
    
    addLayoutConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if panGesture.state == UIGestureRecognizerState.changed {
      let p: CGPoint = panGesture.translation(in: self)
      let width = self.contentView.frame.width
      let height = self.contentView.frame.height
      let halfOfContentViewFrame = contentView.frame.width / 2
      
      if p.x < halfOfContentViewFrame && p.x > -halfOfContentViewFrame {
        // if the change is less that half the frame width, animate contentView
        self.contentView.frame = CGRect(x: p.x, y: 0, width: width, height: height)
      } else if p.x < -(contentView.frame.width / 2) {
        // if gesture x is negative and smaller than half the frame width, stop animation
        self.contentView.frame = CGRect(x: -(contentView.frame.width / 2), y: 0, width: width, height: height)
      } else {
        // if gesture x is positive and greater than half the frame width, stop animation
        self.contentView.frame = CGRect(x: contentView.frame.width / 2, y: 0, width: width, height: height)
      }
    }
    
  }
  
  @objc func onPan(_ pan: UIPanGestureRecognizer) {
    let p: CGPoint = panGesture.translation(in: self)
    
    if pan.state == UIGestureRecognizerState.changed {
      self.setNeedsLayout()
    } else if pan.numberOfTouches == 0 && abs(p.x) > contentView.frame.width / 2 {
      
      // if gesture completed and abs(gesture x) greater than have the contentView frame, prompt for action
      if let collectionView: UICollectionView = self.superview as? UICollectionView {
        let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
        let actionType = (p.x > 0) ? "delete" : "edit"
        collectionView.delegate?.collectionView!(collectionView,
                                                 performAction: Selector((actionType)),
                                                 forItemAt: indexPath, withSender: nil)
      }
    } else {
      UIView.animate(withDuration: 0.2, animations: {
        self.setNeedsLayout()
        self.layoutIfNeeded()
      })
    }
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return abs((panGesture.velocity(in: panGesture.view)).x) > abs((panGesture.velocity(in: panGesture.view)).y)
  }
  
  private func addLayoutConstraints() {
    
    contentView.addSubview(nameLabel)
    contentView.addSubview(goalLabel)
    insertSubview(deleteLabel, belowSubview: contentView)
    insertSubview(editLabel, belowSubview: contentView)
    
    NSLayoutConstraint.activate([
      
      // Name Label
      nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
      nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16),
      nameLabel.heightAnchor.constraint(equalToConstant: 20),
      
      // Goal Label
      goalLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      goalLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
      goalLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16),
      goalLabel.heightAnchor.constraint(equalToConstant: 20),
      
      // Delete Label
      deleteLabel.leftAnchor.constraint(equalTo: leftAnchor),
      deleteLabel.topAnchor.constraint(equalTo: topAnchor),
      deleteLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
      deleteLabel.heightAnchor.constraint(equalTo: heightAnchor),
      
      // Edit Label
      editLabel.rightAnchor.constraint(equalTo: rightAnchor),
      editLabel.topAnchor.constraint(equalTo: topAnchor),
      editLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
      editLabel.heightAnchor.constraint(equalTo: heightAnchor)
      
      ])
  }
  
}
