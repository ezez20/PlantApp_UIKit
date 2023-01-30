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
//    let imageData: String?
    let lastWateredDate: Date
    let order: Int
    let plant: String
    let plantImageString: String
    let waterHabit: Int
    let wateredBool: Bool
    var notificationRequestID: String
    var notificationPending: Bool

}
