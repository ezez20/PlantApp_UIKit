//
//  PlantDataModel.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/21/22.
//

import Foundation
import FirebaseFirestoreSwift

struct PlantDataModel: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    
    var dateAdded: Date
    var imageData: String
    var lastWateredDate: Date
    var notificationRequestID: UUID
    var order: Int
    var plant: String
    var plantImageString: String
    var wateredBool: Bool
    var waterHabit: Int
    
    enum CodingKeys: String, CodingKey {
        case dateAdded
        case imageData
        case notificationRequestID
        case order
        case plant
        case plantImageString
        case wateredBool
        case waterHabit
    }
}
