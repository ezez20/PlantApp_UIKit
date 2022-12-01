//
//  PlantDataModel.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/21/22.
//

import Foundation

struct PlantDataModel: Codable {
    let dateAdded: Date
    var id: UUID
    let imageData: String
    let lastWateredDate: Date
    var notificationRequestID: UUID
    let order: Int
    let plant: String
    let plantImageString: String
    let wateredBool: Bool
    let waterHabit: Int
    
}
