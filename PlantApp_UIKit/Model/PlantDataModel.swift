//
//  PlantDataModel.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 11/21/22.
//

import Foundation


func PlantDataModel_FB(dateAdded: Any, plantUUID: Any, plantName: Any, waterHabit: Any, plantOrder: Any, lastWatered: Any, plantImageString: Any, wateredBool: Any, notificationPending: Any) -> [String: Any] {
    
    return ["dateAdded": dateAdded,
            "plantUUID": plantUUID,
            "plantName": plantName,
            "waterHabit": waterHabit,
            "plantOrder": plantOrder,
            "lastWatered": lastWatered,
            "plantImageString": plantImageString,
            "wateredBool": wateredBool,
            "notificationPending": notificationPending]
    
}
