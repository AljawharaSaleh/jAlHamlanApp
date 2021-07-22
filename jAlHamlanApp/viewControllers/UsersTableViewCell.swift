//
//  UsersCellTableViewCell.swift
//  jAlHamlanApp
//
//  Created by Aljawhara Saleh on 08/12/1442 AH.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
