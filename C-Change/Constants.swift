//
//  Constants.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

struct Constants {
  static let colors: [UIColor] = [.purple, .red, .brown, .yellow, .magenta, .green, .orange, .cyan, .blue]
  static let fontLarge = UIFont(name: "AppleSDGothicNeo-Regular", size: 25)
  static let fontMedium = UIFont(name: "AppleSDGothicNeo-Regular", size: 20)
  static let fontSmall = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
  static let fontMediumBold = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
  
  struct CollectionView {
    static let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    static let squareCellSpacing: CGFloat = 10
    static let cellCornerRadius: CGFloat = 10
    static let deleteLabeldColor = UIColor(red: 0.99, green: 0.26, blue: 0.24, alpha: 1.0)
    static let editLabelColor = UIColor(red: 0.22, green: 0.79, blue: 0.29, alpha: 1.0)
    static let actionBackgroundColor = UIColor(red: 0.01, green: 0.13, blue: 0.24, alpha: 1.0)
  }
}
