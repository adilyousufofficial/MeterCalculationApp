//
//  NewHouseHoldViewController.swift
//  MeterCalculationApp
//
//  Created by Adil Yousuf on 10/09/2022.
//

import UIKit
import Foundation

protocol RefreshHouseHoldDataOnUpdate {
    func isNewDataAdded(reloadTable:Bool)
}

class PreviousHistoryCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    //    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
//        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NewHouseHoldViewController: UIViewController {
    
//    var oldReading: Double = 510
//    var newReading: Double = 650
    
    var isServiceNumberExist = false
    var serviceNumberIndex = 0
    var index: Int?
    
    var delegate: RefreshHouseHoldDataOnUpdate!
    
    @IBOutlet weak var lblServiceNumber: UITextField!
    @IBOutlet weak var lblMeterReading: UITextField!
    
    @IBOutlet var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let nibName = UINib(nibName: "PreviousHistoryCell", bundle:nil)
        self.tableView?.register(nibName, forCellReuseIdentifier: "PreviousHistoryCell")

    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        
        if lblServiceNumber.text!.count < 4 {
            showAlert(message: "Customer number should be 10 digits")
            return
        }
        
        if !lblServiceNumber.text!.isAlphanumeric {
            showAlert(message: "Customer number should be alphanuic")
            return
        }
        
        index = searchElephantIndex(serviceNumber: lblServiceNumber.text!, houseHoldArr: DataManager.shared.houseHoldModel)
        var oldReading:Double = 0
        if index != nil {
            oldReading = DataManager.shared.houseHoldModel[index!].previousReading
            if oldReading > 0 {
                serviceNumberIndex = index!
                isServiceNumberExist = true
            }
        }
        if let newReading = Double(lblMeterReading.text!) {
            if newReading < 0 {
                showAlert(message: "Reading should in positive number")
                return
            }
            if oldReading > newReading {
                showAlert(message: "New Reading should be greater then \(oldReading)")
                return
            }
            saveData(newCost: calculateNewCost(reading: newReading-oldReading), previousReading: oldReading)
        } else {
            print("Not a valid number: \(lblMeterReading.text!)")
        }
    }
    
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchElephantIndex(serviceNumber: String, houseHoldArr: [HouseHoldModel]) -> Int? {
        return houseHoldArr.firstIndex { $0.serviceNumber == serviceNumber }
    }
    
    func calculateNewCost(reading:Double) -> Double {
        var result:Double = 0
        var remainingReading = reading
        for (_, value) in DataManager.shared.slabConfigure.enumerated() {
            let slab = value.slab
            let cost = value.cost
            if remainingReading > slab {
                result = result + (slab * cost)
                remainingReading = remainingReading - slab
            } else {
                result = result + (remainingReading * cost)
                remainingReading = 0
                break
            }
        }
        
        return result
    }
    
    func saveData(newCost:Double, previousReading:Double) {
        let alert = UIAlertController(title: "Updated Cost",
                                      message: "Previous Reading: \(previousReading) \n New Reading: \(String(describing: lblMeterReading.text!)) \n New Cost: $\(newCost)",
                                      preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
            [unowned self] action in
            print("save")
            if isServiceNumberExist {
                var houseHold = DataManager.shared.houseHoldModel[index!]
                houseHold.newCost = newCost
                houseHold.previousReading = Double(lblMeterReading.text!)!
                houseHold.readingHistory.append(Double(lblMeterReading.text!)!)
                DataManager.shared.houseHoldModel[serviceNumberIndex] = houseHold
            } else {
                let houseHold = HouseHoldModel(serviceNumber: lblServiceNumber.text!,
                                               previousReading: Double(lblMeterReading.text!)!,
                                               readingHistory: [Double(lblMeterReading.text!)!],
                                               newCost: newCost)
                DataManager.shared.houseHoldModel.append(houseHold)
            }
            
            if let data = try? PropertyListEncoder().encode(DataManager.shared.houseHoldModel) {
                UserDefaults.standard.set(data, forKey: "SaveHouseHolds")
            }
            
            delegate.isNewDataAdded(reloadTable: true)
            dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension NewHouseHoldViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let readingHistoryCount = DataManager.shared.houseHoldModel[index!].readingHistory.count
        return index != nil ? readingHistoryCount > 3 ? 4 : readingHistoryCount + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousHistoryCell", for: indexPath) as! PreviousHistoryCell
        cell.lblTitle?.text = "\(DataManager.shared.houseHoldModel[indexPath.row].readingHistory[indexPath.row])"
        return cell
    }
    
    
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^A-Z0-9]", options: .regularExpression) == nil && self != ""
    }
}
