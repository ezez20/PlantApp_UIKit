//
//  EditPlantViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/23/22.
//

import UIKit

class EditPlantViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    
    let plantTextFieldView = UIView()
    let plantTextField = UITextField()
    
    let wateringLabel = UILabel()
    
    let wateringSectionView = UIView()
    let waterHabitLabel = UILabel()
    let waterHabitButton = UIButton()
    
    let dividerView = UIView()
 
    let lastWateredLabel = UILabel()
    let datePicker = UIDatePicker()
    
    let updatePlantButton = UIButton()
    
    let inputImageButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Edit Plant"
        
        view.backgroundColor = .secondarySystemBackground
        // Do any additional setup after loading the view.
        
        // scrollView
        addView(viewIn: scrollView, addSubTo: view, top: view.topAnchor, topConst: 108, bottom: view.bottomAnchor, bottomConst: 0, left: view.leftAnchor, leftConst: 0, right: view.rightAnchor, rightConst: 0)
        
        scrollView.backgroundColor = .secondarySystemBackground
        
        // containerView
        addView(viewIn: containerView, addSubTo: view, top: scrollView.topAnchor, topConst: 0, bottom: scrollView.bottomAnchor, bottomConst: 500, left: scrollView.leftAnchor, leftConst: 0, right: scrollView.rightAnchor, rightConst: 0)
        
        // plantTextFieldView
        containerView.addSubview(plantTextFieldView)
        plantTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        plantTextFieldView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        plantTextFieldView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        plantTextFieldView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        plantTextFieldView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        plantTextFieldView.backgroundColor = .white
        
//        // plantTextField
        addView(viewIn: plantTextField, addSubTo: plantTextFieldView, top: plantTextFieldView.topAnchor, topConst: 5, bottom: plantTextFieldView.bottomAnchor, bottomConst: -5, left: plantTextFieldView.leftAnchor, leftConst: 5, right: plantTextFieldView.rightAnchor, rightConst: -5)
        
        plantTextField.backgroundColor = .white
        plantTextField.placeholder = "Type of plant"
      
        
        // wateringLabel
        containerView.addSubview(wateringLabel)
        wateringLabel.translatesAutoresizingMaskIntoConstraints = false
        wateringLabel.topAnchor.constraint(equalTo: plantTextFieldView.bottomAnchor, constant: 10).isActive = true
        wateringLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        wateringLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        
        wateringLabel.text = "WATERING"
        wateringLabel.textColor = .darkGray
        wateringLabel.font = UIFont.preferredFont(forTextStyle: .footnote
        )
      
        
        // wateringSectionView
        containerView.addSubview(wateringSectionView)
        wateringSectionView.translatesAutoresizingMaskIntoConstraints = false
        wateringSectionView.topAnchor.constraint(equalTo: wateringLabel.bottomAnchor, constant: 10).isActive = true
        wateringSectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        wateringSectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        wateringSectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        wateringSectionView.backgroundColor = .white
        
    
        
        // updatePlantButton
        containerView.addSubview(updatePlantButton)
        updatePlantButton.translatesAutoresizingMaskIntoConstraints = false
        updatePlantButton.topAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: 20).isActive = true
        updatePlantButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        updatePlantButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        updatePlantButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        updatePlantButton.addTarget(self, action: #selector(updatePlantButtonClicked(sender:)), for: .touchUpInside)
        updatePlantButton.setTitle("Update Plant", for: .normal)
        updatePlantButton.setTitleColor(.secondarySystemBackground, for: .normal)
        updatePlantButton.backgroundColor = .white
        
        // inputImageButton
        containerView.addSubview(inputImageButton)
        inputImageButton.translatesAutoresizingMaskIntoConstraints = false
        inputImageButton.topAnchor.constraint(equalTo: updatePlantButton.bottomAnchor, constant: 20).isActive = true
        inputImageButton.heightAnchor.constraint(equalToConstant: 350).isActive = true
        inputImageButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        inputImageButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        inputImageButton.backgroundColor = .white
        
        
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.isDirectionalLockEnabled = true
        
        // waterHabitButton
        wateringSectionView.addSubview(waterHabitButton)
        waterHabitButton.translatesAutoresizingMaskIntoConstraints = false
        waterHabitButton.topAnchor.constraint(equalTo: wateringSectionView.topAnchor, constant: 0).isActive = true
        waterHabitButton.bottomAnchor.constraint(equalTo: wateringSectionView.centerYAnchor, constant: 0).isActive = true
        waterHabitButton.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 0).isActive = true
        waterHabitButton.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: 0).isActive = true
        
        waterHabitButton.setTitle("Water every 2 days", for: .normal)
      
        waterHabitButton.setTitleColor(.placeholderText, for: .normal)
        waterHabitButton.contentHorizontalAlignment = .trailing
        waterHabitButton.backgroundColor = .white
        
        
        // waterHabit label
//        wateringSectionView.addSubview(wateringLabel)
//        wateringLabel.translatesAutoresizingMaskIntoConstraints = false
//        wateringLabel.topAnchor.constraint(equalTo: wateringSectionView.topAnchor, constant: 0).isActive = true
//        wateringLabel
        
        
        // dividerView
        dividerView.frame = CGRect(x: 10, y: wateringSectionView.frame.height/2, width: wateringSectionView.frame.width - 20, height: 1.0)
        dividerView.layer.borderWidth = 1.0
        dividerView.layer.borderColor = UIColor.placeholderText.cgColor
        wateringSectionView.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constraint(equalTo: wateringSectionView.topAnchor, constant: 49).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: -wateringSectionView.frame.height/2).isActive = true
        dividerView.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 5).isActive = true
        dividerView.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: -5).isActive = true
        
        // lastWateredLabel
        wateringSectionView.addSubview(lastWateredLabel)
        lastWateredLabel.translatesAutoresizingMaskIntoConstraints = false
        lastWateredLabel.topAnchor.constraint(equalTo: wateringSectionView.centerYAnchor, constant: 0).isActive = true
        lastWateredLabel.bottomAnchor.constraint(equalTo: wateringSectionView.bottomAnchor, constant: 0).isActive = true
        lastWateredLabel.leftAnchor.constraint(equalTo: wateringSectionView.leftAnchor, constant: 0).isActive = true
        lastWateredLabel.rightAnchor.constraint(equalTo: wateringSectionView.rightAnchor, constant: 0).isActive = true
        lastWateredLabel.backgroundColor = .white
        lastWateredLabel.text = "Last watered:"
        
        // datePicker
//        wateringSectionView.addSubview(datePicker)
//        datePicker.preferredDatePickerStyle = .compact
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        datePicker
    
    }
    
    
   
    
    func addView(viewIn: UIView, addSubTo: UIView, top: NSLayoutAnchor<NSLayoutYAxisAnchor>, topConst: Double, bottom: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomConst: Double, left: NSLayoutAnchor<NSLayoutXAxisAnchor>, leftConst: Double, right: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightConst: Double) {
        
        addSubTo.addSubview(viewIn)

        viewIn.translatesAutoresizingMaskIntoConstraints = false
        
        viewIn.topAnchor.constraint(equalTo: top, constant: topConst).isActive = true
        viewIn.bottomAnchor.constraint(equalTo: bottom, constant: bottomConst).isActive = true
        viewIn.leftAnchor.constraint(equalTo: left, constant: leftConst).isActive = true
        viewIn.rightAnchor.constraint(equalTo: right, constant: rightConst).isActive = true
    }

    
    @objc func updatePlantButtonClicked(sender: UIButton){
        print("Update Plant button clicked")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditPlantViewController: UITextViewDelegate {
    
}
