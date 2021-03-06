//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Justin Ralph on 10/22/20.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var authorPic: UIImageView!
    
    @IBOutlet weak var caption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
