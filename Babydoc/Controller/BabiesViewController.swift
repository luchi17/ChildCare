//
//  BabysViewController.swift
//  Babydoc
//
//  Created by Luchi Parejo alcazar on 29/04/2019.
//  Copyright © 2019 Luchi Parejo alcazar. All rights reserved.
//

import UIKit
import RealmSwift
import PMAlertController
import SwipeCellKit
import RLBAlertsPickers


class BabiesViewController : UITableViewController, notifyChangeInName{
    func loadNewName() {
        loadBabies()
    }
    
    let realm = try! Realm()
    var registeredBabies : Results<Baby>?
    let font = UIFont(name: "Avenir-Heavy", size: 17)
    let fontLight = UIFont(name: "Avenir-Medium", size: 17)
    let greenColor = UIColor.init(hexString: "32828A")
    let grayColor = UIColor.init(hexString: "555555")
    let grayLightColor = UIColor.init(hexString: "7F8484")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadBabies()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
    }
    
    
    @IBAction func addBabyPressed(_ sender: UIBarButtonItem) {
        
        var textFieldStore = UITextField()

        let alert = UIAlertController(style: .alert, title: "Add New Child" )
        let config: TextField.Config = { textField in
            
            
            textField.becomeFirstResponder()
            textField.textColor = .flatBlackDark
            textField.font = self.fontLight
            textField.leftViewPadding = 6
            textField.borderStyle = .roundedRect
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.placeholder = "new baby name..."
            textFieldStore = textField
        }
        alert.setTitle(font: font!, color: self.grayLightColor!)
        alert.addOneTextField(configuration: config)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
            
            let newBaby = Baby()
            newBaby.name = textFieldStore.text!
            self.save(baby : newBaby)
        })
        
        alert.addAction(okAction)
        alert.addAction(title: "Cancel" , style : .destructive)
        alert.show()
    }
    
    
    
    
    
    //MARK: - Table View Data Source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //this is called nil coalescing operator
        return registeredBabies?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "babiesCell", for: indexPath)
        cell.textLabel?.text = registeredBabies?[indexPath.row].name
        cell.textLabel?.textColor = UIColor.init(hexString: "7F8484")
        cell.textLabel?.font = fontLight
        return cell
    }
    
    
    //MARK: - Table View Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToBabyInfo", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //this is done before segue occurs
//        //each category has its own items so depending on which one you select,
//        //a table of items is going to appear or another
        let destinationVC = segue.destination as! BabyInfoViewController
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.selectedBaby  = registeredBabies?[indexpath.row]
            destinationVC.delegate = self
            destinationVC.navigationItem.title = destinationVC.selectedBaby?.name
      
        }
    
    }
    
    //MARK: Data Manipulation
    func save(baby : Baby){
        
        
        do{
            try realm.write {
                //categories.append cannot be done because is of type Results and does not have a list
                realm.add(baby) //PERSIST DATA
            }
        }
        catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadBabies(){
        
        registeredBabies = realm.objects(Baby.self)
        
        tableView.reloadData()
        
    }
    
}
