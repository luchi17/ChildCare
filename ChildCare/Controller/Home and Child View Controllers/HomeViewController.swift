//
//  SecondViewController.swift
//  ChilCare
//
//  Created by Luchi Parejo alcazar on 05/04/2019.
//  Copyright © 2019 Luchi Parejo alcazar. All rights reserved.
//

import UIKit
import ScrollableDatepicker
import SwipeCellKit
import APESuperHUD
import PMAlertController
import RealmSwift
// MARK: - Home View Controller

class HomeViewController: UIViewController, resizeImageDelegate, changeNameBarHome{
    
    func changeName(name: String){
        
        
        self.navigationItem.title = name
        
        
    }
    
    
    
    func resizeImageIsCalled(image: UIImage, size: CGSize) -> UIImage {
        let image = resizeImage(image: image, targetSize: size)
        return image
    }

    @IBOutlet weak var sleep: ActionView!
    
    @IBOutlet weak var feed: ActionView!
    
    @IBOutlet weak var diaper: ActionView!
    
    @IBOutlet weak var medication: ActionView!
    
    @IBOutlet weak var grid: GridView!
    
    @IBOutlet weak var upcomingTasks: UILabel!
    
    @IBOutlet weak var todaysRecord: UILabel!
    
    @IBOutlet weak var dateToday: UIButton!
    
    @IBOutlet weak var taskTableView: UITableView!
    
    let font = UIFont(name: "Avenir-Heavy", size: 17)
    let fontLight = UIFont(name: "Avenir-Medium", size: 17)
    let grayColor = UIColor.init(hexString: "555555")
    let grayLightColor = UIColor.init(hexString: "7F8484")
    
    var defaultOptions = SwipeOptions()
    var realm = try! Realm()
    var currentChild = Child()
    var registeredChildren : Results<Child>?
    @IBOutlet weak var datePicker: ScrollableDatepicker!{
        didSet {
            var dates = [Date]()
            for day in -60...60 {
                dates.append(Date(timeIntervalSinceNow: Double(day * 86400)))
            }
            
            datePicker.dates = dates
            datePicker.selectedDate = Date()

            datePicker.delegate = self
            
            var configuration = Configuration()
            
            configuration.defaultDayStyle.dateTextFont = UIFont(name: "Avenir-Medium", size: 20)
            configuration.defaultDayStyle.dateTextColor = UIColor.init(hexString: "7F8484")
            configuration.defaultDayStyle.monthTextColor = UIColor.init(hexString: "7F8484")
            configuration.defaultDayStyle.weekDayTextColor = UIColor.init(hexString: "7F8484")
            configuration.defaultDayStyle.weekDayTextFont = UIFont(name: "Avenir-Medium", size: 8)
            
            configuration.weekendDayStyle.weekDayTextFont = UIFont(name: "Avenir-Heavy", size: 8)
            
            configuration.selectedDayStyle.selectorColor = UIColor.init(hexString: "64C5CF")
            configuration.selectedDayStyle.dateTextColor = UIColor.init(hexString: "64C5CF")
            configuration.selectedDayStyle.weekDayTextColor = UIColor.init(hexString: "64C5CF")
            configuration.selectedDayStyle.dateTextFont = UIFont(name: "Avenir-Heavy", size: 20)
            configuration.selectedDayStyle.backgroundColor = UIColor(white: 0.9, alpha: 0.25)
            
            configuration.daySizeCalculation = .numberOfVisibleItems(5)
            
            datePicker.configuration = configuration
        }
    }
    
    
    
    @objc func buttonClicked() {
        datePicker.selectedDate = Date()
        datePicker.scrollToSelectedDate(animated: true)
        showSelectedDate()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let destinationVC = segue.destination as! ChildrenViewController
        destinationVC.delegate = self
        destinationVC.delegateNameBarHome = self
        
    }
    
    func getCurrentChildApp() -> Child{
        
        if registeredChildren?.count != 0{
            for child in registeredChildren!{
                if child.current == true{
                    currentChild = child
                }
            }
        }
        
        
        
        return currentChild
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
            navigationController?.navigationBar.prefersLargeTitles = false
            tabBarItem.title = "Home"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        dateToday.setTitle("Today, "+formatter.string(from: datePicker.selectedDate!), for: .normal)
        dateToday.setTitleColor(UIColor.init(hexString: "64C5CF"), for: .normal)
        dateToday.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
        dateToday.backgroundColor = UIColor.white
        let spacing : CGFloat = 8.0
        dateToday.contentEdgeInsets = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        dateToday.layer.cornerRadius = 2
        dateToday.layer.masksToBounds = false
        dateToday.layer.shadowColor = UIColor.flatGray.cgColor
        dateToday.layer.shadowOpacity = 0.7
        dateToday.layer.shadowRadius = 1
        dateToday.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        
        dateToday.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        
        
        initialAppearance()
        
        DispatchQueue.main.async {
            self.showSelectedDate()
            self.datePicker.scrollToSelectedDate(animated: false)
            self.medication.selectedDay = self.datePicker.selectedDate!
            self.sleep.selectedDay = self.datePicker.selectedDate!

        }
        self.medication.setNeedsDisplay()
        self.medication.reloadInputViews()
        
        self.sleep.setNeedsDisplay()
        self.sleep.reloadInputViews()
        
        
        
        let button = UIButton(type: .custom)
        let image = UIImage(named : "add-color")
        button.setImage(image, for: .normal)
        button.frame.size = CGSize(width: 55, height: 55)
        button.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width-60, y: dateToday.frame.origin.y + dateToday.bounds.height/2 + 5   ), size: button.frame.size)
        
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.flatGray.cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 1.2, height: 1.2)
        
        self.view.addSubview(button)
        
        taskTableView.delegate = self
        taskTableView.dataSource = self 
        taskTableView.separatorStyle = .none
        
        taskTableView.register(UINib(nibName: "CustomCellHome", bundle: nil), forCellReuseIdentifier: "customCellHome")
        
        
        
    }
    func initialAppearance (){
        
        upcomingTasks.textColor = UIColor.init(hexString: "7F8484")!
        todaysRecord.textColor = UIColor.init(hexString: "7F8484")!
        sleep.layer.cornerRadius = 4
        sleep.layer.masksToBounds = true
        feed.layer.cornerRadius = 4
        feed.layer.masksToBounds = true
        diaper.layer.cornerRadius = 4
        diaper.layer.masksToBounds = true
        medication.layer.cornerRadius = 4
        medication.layer.masksToBounds = true
        
        feed.backgroundColor = feed.feedcolor.withAlphaComponent(CGFloat(0.2))
        diaper.backgroundColor = diaper.diapercolor.withAlphaComponent(CGFloat(0.2))
        medication.backgroundColor = medication.medicationcolor.withAlphaComponent(CGFloat(0.2))
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        taskTableView.rowHeight = UITableView.automaticDimension
        taskTableView.estimatedRowHeight = 180.0
        registeredChildren = realm.objects(Child.self)
        if registeredChildren!.count == 0{
            changeName(name: "Home")
        }
        else{
           
            changeName(name: getCurrentChildApp().name)
            medication.selectedDay = datePicker.selectedDate ?? Date()
            sleep.selectedDay = datePicker.selectedDate ?? Date()
            medication.loadAdministeredDoses(child: getCurrentChildApp())
            sleep.loadSleepRecords(child: getCurrentChildApp())
        }
        medication.setNeedsDisplay()
        medication.reloadInputViews()
        sleep.reloadInputViews()
        sleep.setNeedsDisplay()
        
        
    }
    
    //MARK: - Resize image method
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
}


//MARK: - ScrollableDatePicker method
extension HomeViewController: ScrollableDatepickerDelegate {
    
    func datepicker(_ datepicker: ScrollableDatepicker, didSelectDate date: Date) {
        
            self.showSelectedDate()
    
    }
    func showSelectedDate() {
        guard datePicker.selectedDate != nil else {
            return
        }
        self.medication.selectedDay = self.datePicker.selectedDate!
        self.sleep.selectedDay = self.datePicker.selectedDate!
        self.medication.setNeedsDisplay()
        self.medication.reloadInputViews()
        self.sleep.setNeedsDisplay()
        self.sleep.reloadInputViews()
        if self.registeredChildren?.count != 0 {
            self.medication.loadAdministeredDoses(child: self.getCurrentChildApp())
            self.sleep.loadSleepRecords(child: self.getCurrentChildApp())
        }

    }
    
    
}


//MARK: - SwipeTableViewCell delegate method
extension HomeViewController : SwipeTableViewCellDelegate{
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        defaultOptions.transitionStyle = .drag
        let normalColor = UIColor.flatGrayDark
        let font = UIFont(name: "Avenir-Heavy", size: 17)
        let remainderColor = UIColor.flatYellowDark
        let deleteColor = UIColor.red
        let cancelColor = UIColor.flatSkyBlue
        let width = 55.0
        let height = 55.0
        var textfieldName = UITextField()
        var textfieldQuantity = UITextField()
        var textfieldDate = UITextField()
        var textfieldNote = UITextField()
        let cell = tableView.cellForRow(at: indexPath) as! CustomCellHome
        
        if orientation == .right {
            
            
            let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                let alert = PMAlertController(title: "Remove Task", description: "Are you sure you want to remove the task permanently?",image : nil, style: .alert)
                let delete_action = PMAlertAction(title: "Delete", style: .default, action: { () in })
                let cancel_action = PMAlertAction(title: "Cancel", style: .cancel, action: { () in })
                
                delete_action.setTitleColor(deleteColor, for: .normal)
                cancel_action.setTitleColor(cancelColor, for: .normal)
                alert.alertTitle.font = font
                alert.addAction(delete_action)
                alert.addAction(cancel_action)
                alert.gravityDismissAnimation = true
                self.present(alert, animated: false, completion: nil)
            }
            deleteAction.backgroundColor = UIColor.init(hexString: "F8F9F9")?.withAlphaComponent(CGFloat(0.99))
            deleteAction.image = resizeImage(image: UIImage(named: "delete2")!, targetSize: CGSize(width: width, height: height))
            
            let more = SwipeAction(style: .default, title: nil){ action , indexPath in
                let alert = PMAlertController(title: nil, description: nil, image: nil, style : .alert)
                let edit_action = PMAlertAction(title: "Edit", style: .cancel, action:  { () in
                    
                    let editcontroller = PMAlertController(title: "Edit", description: "It is not required to fill in all the fields, fields that remain empty will preserve the previous data ", image : nil, style: .alert)
                    
                    editcontroller.addTextField({ (alertTextField) in
                        alertTextField!.placeholder = "new medication name..."
                        textfieldName = alertTextField!
                    })
                    
                    editcontroller.addTextField({ (alertTextField) in
                        alertTextField!.placeholder = "new quantity..."
                        textfieldQuantity = alertTextField!
                    })
                    editcontroller.addTextField( { (alertTextField) in
                        alertTextField!.placeholder = "new date..."
                        textfieldDate = alertTextField!
                    })
                    editcontroller.addTextField( { (alertTextField) in
                        alertTextField!.placeholder = "new note..."
                        textfieldNote = alertTextField!
                    })
                    let done_action = PMAlertAction(title: "Done", style: .default, action: { () in
                        
                        cell.nameField.text = textfieldName.text!.isEmpty ? cell.nameField.text : textfieldName.text
                        cell.quantityField.text = textfieldQuantity.text!.isEmpty ? cell.quantityField.text : textfieldQuantity.text
                        cell.dateField.text = textfieldDate.text!.isEmpty ? cell.dateField.text : textfieldDate.text
                        cell.noteField.text = textfieldNote.text!.isEmpty ? cell.noteField.text : textfieldNote.text
                        
                        
                    })
                    done_action.setTitleColor(cancelColor, for: .normal)
                    editcontroller.addAction(done_action)
                    editcontroller.alertTitle.textColor = normalColor
                    editcontroller.alertTitle.font = font
                    editcontroller.gravityDismissAnimation = true
                    editcontroller.dismissWithBackgroudTouch = true
                    self.present(editcontroller, animated: false, completion: nil)
                    
                })
                
                let addRemainder_action = PMAlertAction(title: "Add Remainder", style: .cancel, action: { () in })
                let cancel_action = PMAlertAction(title: "Cancel", style: .default, action: { () in })
                
                edit_action.setTitleColor(normalColor, for: .normal)
                addRemainder_action.setTitleColor(remainderColor, for: .normal)
                cancel_action.setTitleColor(cancelColor, for: .normal)
                alert.addAction(edit_action)
                alert.addAction(addRemainder_action)
                alert.addAction(cancel_action)
                alert.gravityDismissAnimation = true
                
                self.present(alert, animated: true, completion: nil)
            }
            more.backgroundColor = UIColor.init(hexString: "F8F9F9")?.withAlphaComponent(CGFloat(0.99))
            more.image = resizeImage(image: UIImage(named: "moreGray")!, targetSize: CGSize(width: width, height: height))
            more.hidesWhenSelected = true
            
            return [deleteAction,more]
        }
        else{
            
            var done = false
            let checked = SwipeAction(style: .default, title: nil) { action, indexPath in
                
                done = !done
                if done {
                    
                    let image = UIImage(named: "doubletick")!
                    let hudViewController = APESuperHUD(style: .icon(image: image, duration: 1), title: nil, message: "Task Finished!")
                    HUDAppearance.cancelableOnTouch = true
                    HUDAppearance.messageFont = self.fontLight!
                    HUDAppearance.messageTextColor = self.grayColor!
                    
                    self.present(hudViewController, animated: true)
                    
                }
                else{
                    
                    let image = UIImage(named: "sand")
                   
                    let hudViewController = APESuperHUD(style: .icon(image: image!, duration: 1), title: nil, message: "Remaining Task!")
                    HUDAppearance.cancelableOnTouch = true
                    HUDAppearance.messageFont = self.fontLight!
                    HUDAppearance.messageTextColor = self.grayColor!
                    
                    self.present(hudViewController, animated: true)
                    
                }
                
                
            }
            checked.backgroundColor = UIColor.init(hexString: "F8F9F9")?.withAlphaComponent(CGFloat(0.99))
            checked.image = resizeImage(image: UIImage(named: "doubletick")!, targetSize: CGSize(width: width, height: height))
            checked.hidesWhenSelected = true
            
            
            return [checked]
            
        }
    }
}

//MARK: - Table View Delegate and Datasource methods
extension HomeViewController :  UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRegisteredChildren", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCellHome") as! CustomCellHome
        
        cell.delegate = self as SwipeTableViewCellDelegate
        
        cell.backgroundColor = UIColor.init(hexString: "F8F9F9")?.withAlphaComponent(CGFloat(0.995))
        
        cell.actionName.text = "Medication"
        cell.actionName.textColor = medication.medicationcolor
        
        cell.nameTitle.text = "Name :"
        cell.nameTitle.textColor = UIColor.lightGray
        
        
        cell.nameField.text = "Apiretal"
        cell.nameField.textColor = UIColor.init(hexString: "7F8484")
        
        
        cell.dateTitle.text = "Date :"
        cell.dateTitle.textColor = UIColor.lightGray
        
        cell.dateField.text = "24/12/2012 12:00"
        cell.dateField.textColor = UIColor.init(hexString: "7F8484")
        
        cell.quantityTitle.text = "Quantity :"
        cell.quantityTitle.textColor = UIColor.lightGray
        
        cell.quantityField.text = "30 mg"
        cell.quantityField.textColor = UIColor.init(hexString: "7F8484")
 
        
        cell.noteTitle.text = "Note :"
        cell.noteTitle.textColor = UIColor.lightGray
        
        cell.noteField.text = "Remember to give it twice" //when db done check what happens if the note added is too big
        cell.noteField.textColor = UIColor.init(hexString: "7F8484")
        
        cell.actionImage.image = UIImage(named: "medication-1")
        
        return cell
    }
    
    
    
}



// MARK: - Action View class


class ActionView: UIView
    
{
    
    
    var sleepcolor :UIColor = UIColor.init(hexString: "2772db")!
    var feedcolor :UIColor = UIColor.init(hexString: "85ef47")!
    var diapercolor :UIColor = UIColor.init(hexString: "37D4C0")!
    var medicationcolor :UIColor = UIColor.init(hexString: "F54291")! 

    var doses : Results<MedicationDoseCalculated>?
    var sleeps : Results<Sleep>?
    var arrayAllDatesDoses = Array<Date>()
    var arrayDateTodayDoses = Array<Date>()
    var arrayAllDatesSleepsBegin = Array<Date>()
    var arrayAllDatesSleepsEnd = Array<Date>()
    var arrayDateTodaySleepsBegin = Array<Date>()
    var arrayDateTodaySleepsEnd = Array<Date>()
    
    var selectedDay : Date?{
        didSet{
            
        }
    }

    let napColor = UIColor.init(hexString: "66ACF8")
  
    
    func fillColor(start : CGFloat,with color:UIColor,width:CGFloat)
    {
        let topRect = CGRect(x : start, y:0, width : width, height: self.bounds.height)
        color.setFill()
        UIRectFill(topRect)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    func setDay(day : Date){
        selectedDay = day
    }
    
    override func draw(_ rect: CGRect)
    {
        let width = self.bounds.width
        let day : CGFloat = 24
 
        
        switch self.tag {
            
        case 0:
            
            for i in 0..<arrayDateTodaySleepsBegin.count{
                
                let sleep = sleeps?.filter("generalDateBegin == %@", arrayDateTodaySleepsBegin[i])
                
                var width1  = Float(0.0)
                var sleeptime  = true
                
                for s in sleep!{
                    
                    width1 = s.timeSleepFloat
                    sleeptime = s.nightSleep
                }
                
                let value = Float(arrayDateTodaySleepsBegin[i].minute * 100)/(60 * 100)
                let final = Float(arrayDateTodaySleepsBegin[i].hour) + value
                
                if sleeptime{
                    
                    self.fillColor(start : (CGFloat(final)*width)/day, with: sleepcolor, width: (CGFloat(width1)*width)/day)
                    
                }
                else{
                    
                    self.fillColor(start : (CGFloat(final)*width)/day, with: napColor!, width: (CGFloat(width1)*width)/day)
                    
                }
                
                
            }
            for date in  arrayDateTodaySleepsEnd{
                
                let value = Float(date.minute * 100)/(60 * 100)
                let final = Float(date.hour) + value
                
                self.fillColor(start : (CGFloat(0)*width)/day, with: sleepcolor, width: (CGFloat(final)*width)/day)
                
                
            }

            
        //MEDICATION
        case 3:

            for date in arrayDateTodayDoses{
                
                let value = round(Float(date.minute)/(60))
                let final = Float(date.hour) + value

               
                self.fillColor(start : (CGFloat(final)*width)/day, with: medicationcolor, width: 0.15*width/day)
            }
            
            
            
        default:
            break
        }
        
    }
    func loadAdministeredDoses(child : Child){

        doses = child.medicationDoses.filter(NSPredicate(value: true))
        
        arrayAllDatesDoses = []
        for dose in doses!{
            
            arrayAllDatesDoses.append(dose.generalDate)

        }
        arrayDateTodayDoses = []
        for date in arrayAllDatesDoses{

            if selectedDay == nil{
                selectedDay = Date()
            }
 
            if Calendar.current.isDate(date, inSameDayAs: selectedDay!){
                
                arrayDateTodayDoses.append(date)
            }

        }


    }
    func loadSleepRecords(child : Child){

        sleeps = child.sleeps.filter(NSPredicate(value: true))
        
        arrayAllDatesSleepsBegin = []
        arrayAllDatesSleepsEnd = []

        
        for sleep in sleeps!{
            
           
            arrayAllDatesSleepsBegin.append(sleep.generalDateBegin)
            arrayAllDatesSleepsEnd.append(sleep.generalDateEnd)

        }
        
        
        arrayDateTodaySleepsEnd = []
        arrayDateTodaySleepsBegin = []

        for date in arrayAllDatesSleepsBegin{

            
            if Calendar.current.isDate(date, inSameDayAs: selectedDay!){
                
                arrayDateTodaySleepsBegin.append(date)
            }
            
        }


        
        
        for i in 0..<arrayAllDatesSleepsEnd.count{

            if Calendar.current.isDate(arrayAllDatesSleepsEnd[i], inSameDayAs: selectedDay!) {
                
                var dateBegin = arrayAllDatesSleepsBegin[i]
                if dateBegin.day < arrayAllDatesSleepsEnd[i].day {
                     arrayDateTodaySleepsEnd.append(arrayAllDatesSleepsEnd[i])
                }
               
            }
            
        }

        
    }
    
    //MARK: Calc Date and String methods
    var _dateFormatter: DateFormatter?
    var dateFormatter: DateFormatter {
        if (_dateFormatter == nil) {
            _dateFormatter = DateFormatter()
            _dateFormatter!.locale = Locale(identifier: "en_US_POSIX")
            _dateFormatter!.dateFormat = "MM/dd/yyyy HH:mm"
        }
        return _dateFormatter!
    }
    
    func dateStringFromDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func dateFromString(dateString: String) -> Date? {
        return dateFormatter.date(from: dateString)
    }
    
    var _dateFormatter2: DateFormatter?
    var dateFormatter2: DateFormatter {
        if (_dateFormatter2 == nil) {
            _dateFormatter2 = DateFormatter()
            _dateFormatter2!.locale = Locale(identifier: "en_US_POSIX")
            _dateFormatter2!.dateFormat = "HH:mm"
        }
        return _dateFormatter2!
    }

    func dateStringFromDate2(date: Date) -> String {
        return dateFormatter2.string(from: date)
    }
    func dateFromString2(dateString : String)->Date{
        return dateFormatter2.date(from: dateString)!
    }
    
    
}

// MARK: - Grid View

class GridView: UIView
    
{
    private var path = UIBezierPath()
    
    fileprivate var gridWidthMultiple: CGFloat
    {
        return 4
    }
    fileprivate var gridHeightMultiple : CGFloat
    {
        return 20
    }
    
    fileprivate var gridWidth: CGFloat
    {
        return bounds.width/CGFloat(gridWidthMultiple)
    }
    
    fileprivate var gridHeight: CGFloat
    {
        return bounds.height/CGFloat(gridHeightMultiple)
    }
    
    fileprivate var gridCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    fileprivate func drawGrid()
    {
        path = UIBezierPath()
        path.lineWidth = 0.15
        
        for index in 0...Int(gridWidthMultiple) 
        {
            let start = CGPoint(x: CGFloat(index) * gridWidth, y: 0)
            let end = CGPoint(x: CGFloat(index) * gridWidth, y:bounds.height)
            path.move(to: start)
            path.addLine(to: end)
        }
        path.close()
        
    }
    
    override func draw(_ rect: CGRect)
    {
        drawGrid()
        UIColor.black.setStroke()
        path.stroke()
        
    }
    
    
}
// MARK: - RoundShadow View

class RoundShadowView: UIView{
    
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 2.0
    private var fillcolor : UIColor = UIColor.white
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillcolor.cgColor
            
            shadowLayer.shadowColor = UIColor.flatGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            shadowLayer.shadowOpacity = 0.7
            shadowLayer.shadowRadius = 2
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}


