//
//  NotesViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 6/13/23.
//

import UIKit

class NotesViewController: UIViewController {
    
    let notesTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Notes"
        
        setupNotesTableView()
   
    }
    

}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupNotesTableView() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.register(NotesTableViewCell.self, forCellReuseIdentifier: K.notesTableViewCellID)
            
        view.addSubview(notesTableView)
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
        notesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        notesTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        notesTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        notesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        notesTableView.rowHeight = 150
        notesTableView.layer.cornerRadius = 10
        
    }
    
    // MARK: - UITableViewDelegate METHODS
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    
    
    // MARK: - UITableViewDataSource METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.notesTableViewCellID, for: indexPath) as! NotesTableViewCell
        
        return cell
    }
    
    
}
