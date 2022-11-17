//
//  HouseHoldTableViewController.swift
//  MeterCalculationApp
//
//  Created by Adil Yousuf on 10/09/2022.
//

import UIKit

// Slab Table Configuration

class HouseHoldTableViewController: UITableViewController, RefreshHouseHoldDataOnUpdate {
    
    func isNewDataAdded(reloadTable: Bool) {
        if reloadTable {
            tableView.reloadData()
        }
    }
    
    var names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HouseHolds"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(navigateTo))
        
        
        DataManager.shared.slabConfigure.append(Slab(slab: 100, cost: 5))
        DataManager.shared.slabConfigure.append(Slab(slab: 400, cost: 8))
        DataManager.shared.slabConfigure.append(Slab(slab: 500, cost: 10))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataManager.shared.loadData()
    }
    
    @objc func navigateTo(_ sender: UIBarButtonItem) {
        if let destinationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewHouseHoldViewController") as? NewHouseHoldViewController{
            let nav = self.navigationController
            destinationVC.delegate = self
            //presenting
            nav?.present(destinationVC, animated: true, completion: { })
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.shared.houseHoldModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(DataManager.shared.houseHoldModel[indexPath.row].serviceNumber) - \(DataManager.shared.houseHoldModel[indexPath.row].previousReading)"
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
