//
//  MedicationDoseCalculated.swift
//  ChildCare
//
//  Created by Luchi Parejo alcazar on 18/05/2019.
//  Copyright © 2019 Luchi Parejo alcazar. All rights reserved.
//

import Foundation
import RealmSwift

class MedicationDoseCalculated : Object {
    
    @objc dynamic var weight : Float = 0
    @objc dynamic var date : DateCustom?
    @objc dynamic var generalDate = Date()
    @objc dynamic var dose : String = ""
    @objc dynamic var doseUnit : String = ""
    @objc dynamic var medicationType : MedicationType?

}

