//
//  IntroViewController.swift
//  C-Change
//
//  Created by Alexander on 2/16/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

  let addItem: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    view.setBackgroundImage(#imageLiteral(resourceName: "Add_Icon"), for: .normal)
    view.setBackgroundImage(#imageLiteral(resourceName: "Add_Icon_Selected"), for: .highlighted)
    return view
  }()
  
  let topLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "DON'T BE SHY"
    view.textAlignment = .center
    view.font = UIFont(name: "Heiti SC", size: 25)
    return view
  }()
  
  let bottomLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "ADD YOUR FIRST HABIT"
    view.textAlignment = .center
    view.font = UIFont(name: "Heiti SC", size: 25)
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    addLayoutConstraints()
  }

  private func addLayoutConstraints() {
    
    view.addSubview(topLabel)
    view.addSubview(addItem)
    view.addSubview(bottomLabel)
    
    NSLayoutConstraint.activate([
      // Top Label
      topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      topLabel.bottomAnchor.constraint(equalTo: addItem.topAnchor, constant: -20),
      topLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
      topLabel.heightAnchor.constraint(equalToConstant: 50),
      
      // Add Item Icon
      addItem.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addItem.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      addItem.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -150),
      addItem.heightAnchor.constraint(equalTo: view.widthAnchor, constant: -150),
      
      // Bottom Label
      bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      bottomLabel.topAnchor.constraint(equalTo: addItem.bottomAnchor, constant: 20),
      bottomLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
      bottomLabel.heightAnchor.constraint(equalToConstant: 50)
      
    ])
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
