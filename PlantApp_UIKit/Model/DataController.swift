//
//  DataController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 9/6/22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
   // NSPersistentContainer: CoreData type responsible for loading a model and giving us access to data inside.
    let container = NSPersistentContainer(name: "PlantApp")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
