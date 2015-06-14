//
//  SearchCell.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/14/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation

class SearchCell: UITableViewCell {

    @IBOutlet weak var searchText: UILabel!
    
    var placeID:String = ""
    var coordinates = CLLocation()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.searchText.text = ""
    }
    
}