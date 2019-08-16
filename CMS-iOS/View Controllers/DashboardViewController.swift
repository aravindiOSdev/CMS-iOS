//
//  DashboardViewController.swift
//  CMS-iOS
//
//  Created by Hridik Punukollu on 11/08/19.
//  Copyright © 2019 Hridik Punukollu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD
import SideMenuSwift

class DashboardViewController : SideMenuController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let constant = Constants.Global.self
    var courseList = [Course]()
    var userDetails = User()
    var selectedCourseId : Int = 0
    var selectedCourseName : String = ""
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.isHidden = true
        tableView.reloadData()
        SideMenuController.preferences.basic.statusBarBehavior = .slide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if courseList.isEmpty {
            getRegisteredCourses {
                SVProgressHUD.dismiss()
            }
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        welcomeLabel.text = "Welcome, \(userDetails.name)"
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if navigationController?.topViewController != self {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CourseDetailsViewController
        destinationVC.courseid = selectedCourseId
        destinationVC.courseName = selectedCourseName
    }
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem) {
        
        self.sideMenuController?.revealMenu() 
        
    }
    
    func getRegisteredCourses(completion: @escaping() -> Void) {
        let params = ["wstoken" : constant.secret, "userid" : 4626] as [String : Any]
        let FINAL_URL : String = constant.BASE_URL + constant.GET_COURSES
        SVProgressHUD.show()
        Alamofire.request(FINAL_URL, method: .get, parameters: params, headers: constant.headers).responseJSON { (courseData) in
            if courseData.result.isSuccess {
                let courses = JSON(courseData.value)
//                print(courses)
                for i in 0 ..< courses.count{
                    let currentCourse = Course()
                    currentCourse.courseid = courses[i]["id"].int!
                    currentCourse.displayname = courses[i]["displayname"].string!
//                    print(courses[i]["displayname"])
                    self.courseList.append(currentCourse)
                }
            }
            self.tableView.reloadData()
            completion()
        }
    }
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchBar.isHidden = false        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "reuseCell")
        cell.textLabel?.text = courseList[indexPath.row].displayname
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedCourseId = courseList[indexPath.row].courseid
        self.selectedCourseName = courseList[indexPath.row].displayname
        performSegue(withIdentifier: "goToCourseContent", sender: self)
    }
    
}
