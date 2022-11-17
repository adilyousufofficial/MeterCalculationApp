//
//  DataManager.swift
//  MeterCalculationApp
//
//  Created by Adil Yousuf on 10/09/2022.
//

import Foundation
class DataManager {

    // MARK: - Properties
    static let shared = DataManager()
    
    var slabConfigure = [Slab]()
    var houseHoldModel = [HouseHoldModel]()
    
    func loadData() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "SaveHouseHolds") {
            houseHoldModel = try! PropertyListDecoder().decode([HouseHoldModel].self, from: data)
        }
    }
}

struct HouseHoldModel: Codable {
    var serviceNumber: String
    var previousReading: Double
    var readingHistory: [Double]
    var newCost: Double
}

struct Slab {
    let slab: Double
    let cost: Double
}
