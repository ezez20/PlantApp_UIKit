//
//  AccountFilloutViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 2/16/23.
//

import UIKit

class AccountFilloutViewController: UIViewController {

    let instructionTitle = UILabel()
    let label1 = UILabel()
    
    let textfieldView1 = UIView()
    let textfield1 = UITextField()
    
    let textfieldView2 = UIView()
    let textfield2 = UITextField()
    let revealTextfield2Button = UIButton()
    
    let textfieldView3 = UIView()
    let textfield3 = UITextField()
    let revealTextfield3Button = UIButton()
    
    let button1 = UIButton()
    
    let vcTitle: String?
    let label1Text: String?
    let instructionTitleText: String?
    let textfield1PlaceholderText: String?
    let textfield2PlaceholderText: String?
    let textfield3PlaceholderText: String?
    let button1TitleText: String?
    
    let loadingSpinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    var delegate: AccountFilloutVCButtonDelegate!

    init(vcTitle: String?, label1Text: String?, instructionTitleText: String?, textfield1PlaceholderText: String?, textfield2PlaceholderText: String?, textfield3PlaceholderText: String?, button1TitleText: String?) {
        self.vcTitle = vcTitle
        self.label1Text = label1Text
        self.instructionTitleText = instructionTitleText
        self.textfield1PlaceholderText = textfield1PlaceholderText
        self.textfield2PlaceholderText = textfield2PlaceholderText
        self.textfield3PlaceholderText = textfield3PlaceholderText
        self.button1TitleText = button1TitleText
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        view.backgroundColor = .secondarySystemBackground
        title = vcTitle
        
        view.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        label1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        label1.sizeToFit()
        label1.font = .boldSystemFont(ofSize: 15)
        label1.adjustsFontForContentSizeCategory = true
        label1.text = label1Text
        
        view.addSubview(instructionTitle)
        instructionTitle.translatesAutoresizingMaskIntoConstraints = false
        instructionTitle.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10).isActive = true
        instructionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instructionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        instructionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        instructionTitle.sizeToFit()
        instructionTitle.font = .systemFont(ofSize: 15)
        instructionTitle.numberOfLines = 2
        instructionTitle.text = instructionTitleText
        instructionTitle.tintColor = .lightText
        
        view.addSubview(textfieldView1)
        textfieldView1.translatesAutoresizingMaskIntoConstraints = false
        textfieldView1.topAnchor.constraint(equalTo: instructionTitle.bottomAnchor, constant: 10).isActive = true
        textfieldView1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textfieldView1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textfieldView1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textfieldView1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textfieldView1.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        textfieldView1.addSubview(textfield1)
        textfield1.translatesAutoresizingMaskIntoConstraints = false
        textfield1.topAnchor.constraint(equalTo: textfieldView1.topAnchor, constant: 5).isActive = true
        textfield1.leftAnchor.constraint(equalTo: textfieldView1.leftAnchor, constant: 20).isActive = true
        textfield1.rightAnchor.constraint(equalTo: textfieldView1.rightAnchor, constant: -20).isActive = true
        textfield1.bottomAnchor.constraint(equalTo: textfieldView1.bottomAnchor, constant: -5).isActive = true
        textfield1.backgroundColor = .white
        textfield1.placeholder = textfield1PlaceholderText
        textfield1.keyboardType = .emailAddress
        textfield1.autocapitalizationType = .none
        textfield1.delegate = self
        
        view.addSubview(textfieldView2)
        textfieldView2.translatesAutoresizingMaskIntoConstraints = false
        textfieldView2.topAnchor.constraint(equalTo: textfieldView1.bottomAnchor, constant: 10).isActive = true
        textfieldView2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textfieldView2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textfieldView2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textfieldView2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textfieldView2.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        textfieldView2.addSubview(revealTextfield2Button)
        revealTextfield2Button.translatesAutoresizingMaskIntoConstraints = false
        revealTextfield2Button.rightAnchor.constraint(equalTo: textfieldView2.rightAnchor).isActive = true
        revealTextfield2Button.centerYAnchor.constraint(equalTo: textfieldView2.centerYAnchor).isActive = true
        revealTextfield2Button.heightAnchor.constraint(equalTo: textfieldView2.heightAnchor).isActive = true
        revealTextfield2Button.widthAnchor.constraint(equalTo: textfieldView2.heightAnchor).isActive = true
        revealTextfield2Button.backgroundColor = .clear
        revealTextfield2Button.tintColor = .lightGray
        revealTextfield2Button.addTarget(self, action: #selector(revealTextfield2ButtonClicked(sender:)), for: .touchUpInside)
        
        textfieldView2.addSubview(textfield2)
        textfield2.translatesAutoresizingMaskIntoConstraints = false
        textfield2.topAnchor.constraint(equalTo: textfieldView2.topAnchor, constant: 5).isActive = true
        textfield2.leftAnchor.constraint(equalTo: textfieldView2.leftAnchor, constant: 20).isActive = true
        textfield2.rightAnchor.constraint(equalTo: revealTextfield2Button.leftAnchor).isActive = true
        textfield2.bottomAnchor.constraint(equalTo: textfieldView2.bottomAnchor, constant: -5).isActive = true
        textfield2.backgroundColor = .white
        textfield2.placeholder = textfield2PlaceholderText
        textfield2.keyboardType = .emailAddress
        textfield2.autocapitalizationType = .none
        textfield2.delegate = self
        textfield2.isSecureTextEntry = true
        
        view.addSubview(textfieldView3)
        textfieldView3.translatesAutoresizingMaskIntoConstraints = false
        textfieldView3.topAnchor.constraint(equalTo: textfieldView2.bottomAnchor, constant: 10).isActive = true
        textfieldView3.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textfieldView3.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textfieldView3.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textfieldView3.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textfieldView3.backgroundColor = .white
        
        
        textfieldView3.addSubview(revealTextfield3Button)
        revealTextfield3Button.translatesAutoresizingMaskIntoConstraints = false
        revealTextfield3Button.rightAnchor.constraint(equalTo: textfieldView3.rightAnchor).isActive = true
        revealTextfield3Button.centerYAnchor.constraint(equalTo: textfieldView3.centerYAnchor).isActive = true
        revealTextfield3Button.heightAnchor.constraint(equalTo: textfieldView3.heightAnchor).isActive = true
        revealTextfield3Button.widthAnchor.constraint(equalTo: textfieldView3.heightAnchor).isActive = true
        revealTextfield3Button.backgroundColor = .clear
        revealTextfield3Button.tintColor = .lightGray
        revealTextfield3Button.addTarget(self, action: #selector(revealTextfield3ButtonClicked(sender:)), for: .touchUpInside)
        
        textfieldView3.addSubview(textfield3)
        textfield3.translatesAutoresizingMaskIntoConstraints = false
        textfield3.topAnchor.constraint(equalTo: textfieldView3.topAnchor, constant: 5).isActive = true
        textfield3.leftAnchor.constraint(equalTo: textfieldView3.leftAnchor, constant: 20).isActive = true
        textfield3.rightAnchor.constraint(equalTo: revealTextfield3Button.leftAnchor).isActive = true
        textfield3.bottomAnchor.constraint(equalTo: textfieldView3.bottomAnchor, constant: -5).isActive = true
        textfield3.backgroundColor = .white
        textfield3.placeholder = textfield3PlaceholderText
        textfield3.keyboardType = .emailAddress
        textfield3.autocapitalizationType = .none
        textfield3.delegate = self
        textfield3.isSecureTextEntry = true
        
        view.addSubview(button1)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.topAnchor.constraint(equalTo: textfieldView3.bottomAnchor, constant: 20).isActive = true
        button1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button1.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button1.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button1.backgroundColor = .systemYellow
        button1.layer.cornerRadius = 15
        button1.setTitle(button1TitleText, for: .normal)
        button1.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
        button1.backgroundColor = UIColor(named: "customYellow1")
        button1.isEnabled = false
        
        view.addSubview(loadingSpinnerView)
        loadingSpinnerView.centerXAnchor.constraint(equalTo: button1.centerXAnchor).isActive = true
        loadingSpinnerView.centerYAnchor.constraint(equalTo: button1.centerYAnchor).isActive = true

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateInstructionLabel), name: NSNotification.Name(rawValue: "updateAccountFilloutViewController"), object: nil)
       
    }
    
    @objc func button1Pressed() {
        
        addLoadingSpinner()
        instructionTitle.text = "..."
        
        delegate?.buttonPressed(textfield1Text: textfield1.text, textfield2Text: textfield2.text, textfield3Text: textfield3.text)

    }
    
    @objc private func revealTextfield2ButtonClicked(sender: UIButton) {
        print("revealTextfield2ButtonClicked")
        
        textfield2.isSecureTextEntry.toggle()
        if textfield2.isSecureTextEntry == false {
            revealTextfield2Button.tintColor = .darkGray
        } else {
            revealTextfield2Button.tintColor = .lightGray
        }

    }
    
    @objc private func revealTextfield3ButtonClicked(sender: UIButton) {
        print("revealTextfield3ButtonClicked")
        
        textfield3.isSecureTextEntry.toggle()
        if textfield3.isSecureTextEntry == false {
            revealTextfield3Button.tintColor = .darkGray
        } else {
            revealTextfield3Button.tintColor = .lightGray
        }
        
    }

}

extension AccountFilloutViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateEntry()
    }
    
    func validateEntry() {
        
        if textfield1.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || textfield2.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || textfield3.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            button1.isEnabled = false
            button1.backgroundColor = UIColor(named: "customYellow1")
        } else {
            button1.isEnabled = true
            button1.backgroundColor = .systemYellow
        }
        
        if !textfield2.text!.isEmpty {
            revealTextfield2Button.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            revealTextfield2Button.setImage(UIImage(systemName: ""), for: .normal)
        }
        
        if !textfield3.text!.isEmpty {
            revealTextfield3Button.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            revealTextfield3Button.setImage(UIImage(systemName: ""), for: .normal)
        }
        
    }
    
    @objc func updateInstructionLabel(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let data = userInfo["message"] as? String {
                print("Data passed back: \(data)")
                instructionTitle.text = data
                textfield1.text = ""
                textfield2.text = ""
                textfield3.text = ""
                removeLoadingSpinner()
                view.endEditing(true)
            }
        }
     
    }
    
}

extension AccountFilloutViewController {
    
    func addLoadingSpinner() {
        DispatchQueue.main.async { [self] in
            button1.backgroundColor = UIColor(named: "customYellow1")
            button1.isEnabled = false
            loadingSpinnerView.startAnimating()
        }
    }
    
    func removeLoadingSpinner() {
        DispatchQueue.main.async { [self] in
            button1.isEnabled = true
            button1.backgroundColor = .systemYellow
            loadingSpinnerView.stopAnimating()
        }
    }
    
}


protocol AccountFilloutVCButtonDelegate {
    
    func buttonPressed(textfield1Text: String?, textfield2Text: String?, textfield3Text: String?)
    
}

