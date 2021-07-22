//
//  UsersViewController.swift
//  jAlHamlanApp
//
//  Created by Aljawhara Saleh on 08/12/1442 AH.
//

import UIKit
import sqlite3

class UsersViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var usersTableView: UITableView!
    var UsersArray = [Datum]()
    var db: OpaquePointer?
    
    
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usersTableView.delegate = self
        self.usersTableView.dataSource = self
        
        readUsers(url: "https://gorest.co.in/public-api/users")
        
    }
    
    func createDB() {
        
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("UsersDB.sqlite")
        
        // open database
        
        
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return
        }
        
    }
    
    func createTableDB() {
        
        
        let createTableQuuery =  "create table if not exists USERTable (id integer primary key autoincrement ,uid INTEGER, name TEXT , email TEXT , gender TEXT , status TEXT);"
        if sqlite3_exec(db, createTableQuuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
            return
        }
        print("table has been created...")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            
            let alert = UIAlertController(title: "An issue with the network.!", message: "Please try again", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Dismiss logic here")
                
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func storeDB(uid: Int, name: String, email: String, gender: String, status: String) {
        
        var stmt: OpaquePointer?
        
        let query = "insert into USERTable (uid, name, email, gender, status) values (?, ?, ?, ?, ?)"
        
        
        if sqlite3_prepare_v2(db,query , -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(uid)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user id: \(errmsg)")
        }
        if sqlite3_bind_text(stmt, 2, name, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user name: \(errmsg)")
        }
        if sqlite3_bind_text(stmt, 3, email, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user email: \(errmsg)")
        }
        if sqlite3_bind_text(stmt, 4, gender, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user gender: \(errmsg)")
        }
        if sqlite3_bind_text(stmt, 5, status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user status: \(errmsg)")
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting user: \(errmsg)")
        }
        
        if sqlite3_reset(stmt) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error resetting prepared statement: \(errmsg)")
        }
        
        if sqlite3_finalize(stmt) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        stmt = nil
        
    }
    
    func readUsers(url : String){
        
        guard let url = URL(string: url) else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async{
                if  error != nil {
                    print("Error: \(String(describing: error))")
                }
                else if let data = data {
                    do{
                        let decoder = JSONDecoder()
                        do {
                            let response = try decoder.decode(User.self, from: data)
                            if  response.code == 200{
                                
                                self.createDB()
                                self.createTableDB()
                                
                                for user in response.data {
                                    self.UsersArray.append(user)
                                    
                                    
                                    self.storeDB(uid: user.id, name: user.name, email: user.email, gender: user.gender, status: user.status)
                                    
                                }
                                self.retrieveData()
                            }
                            
                        } catch let error  {
                            print("Parsing Failed \(error.localizedDescription)")
                        }}}
                self.usersTableView.reloadData()
            }
        }.resume()
        
    }
    
    func retrieveData() {
        
        var stmt2: OpaquePointer?
        
        if sqlite3_prepare_v2(self.db, "select id, uid, name, email, gender, status from USERTable", -1, &stmt2, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(stmt2) == SQLITE_ROW {
            let id = sqlite3_column_int64(stmt2, 0)
            print("id = \(id); ", terminator: "")
            
            if let cString = sqlite3_column_text(stmt2, 1) {
                let uid = String(cString: cString)
                print("uid = \(uid)")
            } else {
                print("uid not found")
            }
            //------------------------------------------------
            if let cString = sqlite3_column_text(stmt2, 2) {
                let name = String(cString: cString)
                print("name = \(name)")
            } else {
                print("name not found")
            }
            if let cString = sqlite3_column_text(stmt2, 3) {
                let email = String(cString: cString)
                print("email = \(email)")
            } else {
                print("email not found")
            }
            if let cString = sqlite3_column_text(stmt2, 4) {
                let gender = String(cString: cString)
                print("gender = \(gender)")
            } else {
                print("gender not found")
            }
            if let cString = sqlite3_column_text(stmt2, 5) {
                let status = String(cString: cString)
                print("status = \(status)")
            } else {
                print("status not found")
            }
            print("---------------------------------")
        }
        
        if sqlite3_finalize(stmt2) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        stmt2 = nil
        
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        db = nil
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersTableViewCell") as! UsersTableViewCell
        
        cell.name.text = UsersArray[indexPath.row].name
        cell.email.text = UsersArray[indexPath.row].email
        cell.status.text = UsersArray[indexPath.row].status
        cell.gender.text = UsersArray[indexPath.row].gender
        
        cell.email.textColor = .black
        
        if self.UsersArray[indexPath.row].status.prefix(1) == "a" || self.UsersArray[indexPath.row].status.prefix(1) == "A"{
            
            cell.cellView.backgroundColor = UIColor(patternImage: UIImage(named: "blueCard")!)
            cell.status.textColor = .blue
        }else{
            cell.cellView.backgroundColor = UIColor(patternImage: UIImage(named: "redCard")!)
            cell.status.textColor = .darkGray
        }
        
        if self.UsersArray[indexPath.row].gender.prefix(1) == "f" || self.UsersArray[indexPath.row].gender.prefix(1) == "F"{
            cell.cellImage.backgroundColor = UIColor(patternImage: UIImage(named: "femaleIcon")!)
            cell.cellImage.contentMode = .scaleAspectFit
        }else{
            cell.cellImage.backgroundColor = UIColor(patternImage: UIImage(named: "maleIcon")!)
            cell.cellImage.contentMode = .scaleAspectFit
        }
        
        cell.name.isEnabled = false
        cell.email.isEnabled = false
        cell.status.isEnabled = false
        cell.gender.isEnabled = false
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}
// MARK: - User
struct User: Codable {
    let code: Int
    let meta: Meta
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int
    let name, email, gender, status: String
}


// MARK: - Meta
struct Meta: Codable {
    let pagination: Pagination
}

// MARK: - Pagination
struct Pagination: Codable {
    let total, pages, page, limit: Int
}
