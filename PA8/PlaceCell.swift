//
//  PlaceCell.swift
//  PA8
//  Sam Toll
//  CPSC 315
//  December 10th, 2020
//
//  Created by Sam Toll on 12/6/20.
//

import Foundation
import UIKit

// placecell class to represent a certain cell on our table view assigned a specific nearby place
class PlaceCell: UITableViewCell {
    
    // labels on the cell
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // override awakefromnib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // override setselected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // update cell with place given
    func update(with place: Place) {
        placeLabel.text = "\(place.name) (\(place.rating)⭐️)"
        addressLabel.text = place.vicinity
    }
}
