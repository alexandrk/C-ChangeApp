//
//  AddTaskViewController.swift
//  C-Change
//
//  Created by Alexander on 2/17/18.
//  Copyright © 2018 Dictality. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController, HSBColorPickerDelegate, UITextFieldDelegate {

  weak private var appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
  private let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
  private weak var colorPickerHeightConstraint: NSLayoutConstraint?
  
  var taskItem: Task?
  var taskItemIndex: Int?
  
  // MARK: Views Definitions
  let colorPicker: HSBColorPicker = {
    let view = HSBColorPicker()
    view.elementSize = 1
    view.alpha = 0
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  // Labels
  let nameLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Name"
    return view
  }()
  
  let substituteLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Substitute"
    return view
  }()
  
  let colorLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Color"
    return view
  }()
  
  let goalLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Goal"
    return view
  }()
  
  let countLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = "Count"
    return view
  }()
  
  let messageLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = ""
    view.textAlignment = .center
    return view
  }()
  
  // Fields
  let nameField: UITextField = {
    let view = UITextField()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let substituteField: UITextField = {
    let view = UITextField()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let selectedColor: UIButton = {
    let view = UIButton()
    view.setTitle("SELECT COLOR", for: .normal)
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let goalField: UITextField = {
    let view = UITextField()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    view.translatesAutoresizingMaskIntoConstraints = false
    view.keyboardType = .numberPad
    view.text = "0"
    return view
  }()
  
  let countField: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setTitle("Change Count", for: .normal)
    return view
  }()
  
  let saveButton: UIButton = {
    let view = UIButton()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    view.backgroundColor = .black
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setTitle("Save", for: .normal)
    view.setTitleColor(.white, for: .normal)
    view.setTitleColor(.gray, for: .highlighted)
    view.addTarget(self, action: #selector(saveButtonTouched), for: .touchUpInside)
    return view
  }()
  
  // MARK: Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    // Necessary for HSBColorPickerTouched HSBColorPicker delegate method
    colorPicker.delegate = self
    
    // Necessary for textFieldShouldReturn delegate method
    nameField.delegate = self
    substituteField.delegate = self
    goalField.delegate = self
    
    // Gesture recognizer for a popup of the color picker
    let touchInsideSelectedColorView = UILongPressGestureRecognizer(target: self, action: #selector(showColorPicker))
    touchInsideSelectedColorView.minimumPressDuration = 0
    selectedColor.addGestureRecognizer(touchInsideSelectedColorView)
    
    countField.addTarget(self, action: #selector(changeCount), for: .touchUpInside)
    
    setupViews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationItem.title = "Change"
    
    // If here to edit existing item
    if let taskItem = taskItem {
      nameField.text = taskItem.name
      selectedColor.backgroundColor = taskItem.color
      selectedColor.setTitle("", for: .normal)
      goalField.text = taskItem.goal.description
    }
  }
  
  @objc private func changeCount() {
    let vc = CountTableViewController()
    vc.fetchedTask = taskItem
    navigationController?.pushViewController(vc, animated: true)
  }
  
  // MARK: HSBColorPickerDelegate Methods
  func HSBColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
    selectedColor.backgroundColor = color
    let title = (selectedColor.backgroundColor != nil) ? "" : "SELECT COLOR"
    selectedColor.setTitle(title, for: .normal)
    
    if state.rawValue == 3 {
      self.colorPicker.alpha = 0
      self.colorPickerHeightConstraint?.constant = 0
      UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
        self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
  
  // Required for height animation (HSBColorPicker needs height for drawing the colors rect)
  // This delegate method is called, when HSBColorPicker.draw method is finished
  func HSBColorPickerFinishedDrawing(sender: HSBColorPicker, rect: CGRect) {
    self.colorPickerHeightConstraint?.constant = 0
  }
  
  // MARK: Text Fields Delegate Methods
  // Handles resignation of first responder when touched outside of textfields
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  // Handles return key as resignFirstResponder for textfields
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return true
  }
  
  // MARK: Button Handler
  @objc private func saveButtonTouched() {
    
    guard let name = nameField.text, name.count > 0 else {
      messageLabel.text = "Name is Required"
      return
    }
    
    let goal = ((goalField.text != nil) && Int16(goalField.text!) != nil) ? Int16(goalField.text!)! : 0
    
    let task: Task!
    if self.taskItem != nil {
      task = self.taskItem
    } else {
      task = Task(entity: Task.entity(), insertInto: context)
      task.created_at = Date()
    }
    
    task.name = name
    task.color = selectedColor.backgroundColor ?? UIColor.white
    task.goal = goal
    task.updated_at = Date()
    appDelegate?.saveContext()
    navigationController?.popToRootViewController(animated: true)
  }
  
  // MARK: Helper Methods
  // Animates display of color picker
  @objc private func showColorPicker() {
    self.colorPicker.alpha = 1
    self.colorPickerHeightConstraint?.constant = 200
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  // Setup view elements constraints
  private func setupViews() {
    
    view.addSubview(nameLabel)
    view.addSubview(nameField)
    
    view.addSubview(substituteLabel)
    view.addSubview(substituteField)
    
    view.addSubview(colorLabel)
    view.addSubview(selectedColor)
    view.addSubview(colorPicker)
    
    view.addSubview(goalLabel)
    view.addSubview(goalField)
    
    view.addSubview(countLabel)
    view.addSubview(countField)
    
    view.addSubview(messageLabel)
    view.addSubview(saveButton)
    
    NSLayoutConstraint.activate([
      
      //Name
      nameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15),
      nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
      nameLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 3.5/10),
      nameLabel.heightAnchor.constraint(equalToConstant: 50),
      
      nameField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15),
      nameField.topAnchor.constraint(equalTo: nameLabel.topAnchor),
      nameField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 6/10),
      nameField.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
//      //Substitute
//      substituteLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
//      substituteLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
//      substituteLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
//      substituteLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
//
//      substituteField.rightAnchor.constraint(equalTo: nameField.rightAnchor),
//      substituteField.topAnchor.constraint(equalTo: substituteLabel.topAnchor),
//      substituteField.widthAnchor.constraint(equalTo: nameField.widthAnchor),
//      substituteField.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      //Color
      colorLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
      colorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
      colorLabel.widthAnchor.constraint(equalTo: nameField.widthAnchor),
      colorLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      selectedColor.rightAnchor.constraint(equalTo: nameField.rightAnchor),
      selectedColor.topAnchor.constraint(equalTo: colorLabel.topAnchor),
      selectedColor.widthAnchor.constraint(equalTo: nameField.widthAnchor),
      selectedColor.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      //Color Picker
      colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      colorPicker.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 15),
      colorPicker.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -40),
      
      //Goal
      goalLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
      goalLabel.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 15),
      goalLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
      goalLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      goalField.rightAnchor.constraint(equalTo: nameField.rightAnchor),
      goalField.topAnchor.constraint(equalTo: goalLabel.topAnchor),
      goalField.widthAnchor.constraint(equalTo: nameField.widthAnchor),
      goalField.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      //Count
      countLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
      countLabel.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 15),
      countLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
      countLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      countField.rightAnchor.constraint(equalTo: nameField.rightAnchor),
      countField.topAnchor.constraint(equalTo: countLabel.topAnchor),
      countField.widthAnchor.constraint(equalTo: nameField.widthAnchor),
      countField.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      //Message Label
      messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      messageLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -8),
      messageLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16),
      messageLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor),
      
      //Save Button
      saveButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
      saveButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1/2),
      saveButton.heightAnchor.constraint(equalTo: nameLabel.heightAnchor)
    ])
    colorPickerHeightConstraint = colorPicker.heightAnchor.constraint(equalToConstant: 200)
    colorPickerHeightConstraint!.isActive = true
  }
}
