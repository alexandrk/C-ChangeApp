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
    view.textAlignment = .center
    view.font = Constants.fontLarge
    view.adjustsFontSizeToFitWidth = true
    view.numberOfLines = 0
    return view
  }()
  
  let goalLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textAlignment = .center
    view.font = Constants.fontMedium
    return view
  }()
  
  let deleteLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textAlignment = .center
    view.text = "DELETE"
    view.font = Constants.fontMediumBold
    view.textColor = Constants.CollectionView.deleteLabeldColor
    view.transform = CGAffineTransform(rotationAngle: -1.5708)
    return view
  }()
  
  let editLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textAlignment = .center
    view.text = "EDIT"
    view.font = Constants.fontMediumBold
    view.textColor = Constants.CollectionView.editLabelColor
    view.transform = CGAffineTransform(rotationAngle: 1.5708)
    return view
  }()
  
  var panGesture: UIPanGestureRecognizer!
  
  // Required to be reset on layout change to properly display rotated label
  var deleteLabelLeftAnchorConstraint: NSLayoutConstraint!
  var editLabelRightAnchorConstraint: NSLayoutConstraint!
  
  var activeSlideAreaMultiplier: CGFloat = 0.5
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.layer.cornerRadius = Constants.CollectionView.cellCornerRadius
    contentView.layer.masksToBounds = true
    self.layer.masksToBounds = true
    self.backgroundColor = Constants.CollectionView.actionBackgroundColor
    
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
      let activeSlideArea = contentView.frame.width * activeSlideAreaMultiplier
      
      if p.x < activeSlideArea && p.x > -activeSlideArea {
        // if the change is less that activeSlideArea, animate contentView
        self.contentView.frame = CGRect(x: p.x, y: 0, width: width, height: height)
      } else if p.x < -(activeSlideArea) {
        // [EDIT] if gesture x is negative and smaller than activeSlideArea, stop animation
        self.contentView.frame = CGRect(x: -activeSlideArea, y: 0, width: width, height: height)
      } else {
        // [DELETE]if gesture x is positive and greater than activeSlideArea, stop animation
        self.contentView.frame = CGRect(x: activeSlideArea, y: 0, width: width, height: height)
      }
    }
    
  }
  
  @objc func onPan(_ pan: UIPanGestureRecognizer) {
    let p: CGPoint = panGesture.translation(in: self)
    
    if pan.state == UIGestureRecognizerState.began {
      
      // Set proper constraints for rotated labels [DELETE | EDIT], based on row/column layout type
      if self.frame.width == self.frame.height {
        deleteLabelLeftAnchorConstraint.constant = 0
        editLabelRightAnchorConstraint.constant = 0
        activeSlideAreaMultiplier = 0.5
      } else {
        deleteLabelLeftAnchorConstraint.constant = -65
        editLabelRightAnchorConstraint.constant = 65
        activeSlideAreaMultiplier = 0.33
      }
      
    } else if pan.state == UIGestureRecognizerState.changed {
      self.setNeedsLayout()
      
    } else if pan.numberOfTouches == 0 && abs(p.x) > contentView.frame.width * activeSlideAreaMultiplier {
      
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
    return false
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
      nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
      nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16),
      nameLabel.heightAnchor.constraint(equalToConstant: 30),
      
      // Goal Label
      goalLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      goalLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
      goalLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16),
      goalLabel.heightAnchor.constraint(equalToConstant: 25),
      
      // Delete Label
      deleteLabel.topAnchor.constraint(equalTo: topAnchor),
      deleteLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
      deleteLabel.heightAnchor.constraint(equalTo: heightAnchor),
      
      // Edit Label
      editLabel.topAnchor.constraint(equalTo: topAnchor),
      editLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
      editLabel.heightAnchor.constraint(equalTo: heightAnchor)
      
      ])
    deleteLabelLeftAnchorConstraint = deleteLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: -65)
    editLabelRightAnchorConstraint = editLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 65)
    deleteLabelLeftAnchorConstraint.isActive = true
    editLabelRightAnchorConstraint.isActive = true
  }
  
}
