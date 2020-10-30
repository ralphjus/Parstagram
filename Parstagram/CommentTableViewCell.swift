//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Justin Ralph on 10/29/20.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var commentPic: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
