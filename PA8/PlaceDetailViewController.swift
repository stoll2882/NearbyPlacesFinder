//
//  PlaceDetailViewController.swift
//  PA8
//  Sam Toll
//  CPSC 315
//  December 10th, 2020
//
//  Created by Sam Toll on 12/6/20.
//

import Foundation
import UIKit
import MBProgressHUD

// Placedetailviewcontroller class
class PlaceDetailViewController: UIViewController {
    
    // place optional used to get selected place values
    var placeOptional: Place? = nil
    
    // labels seen on detail view controller page
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    
    // override view did load and display the place selected
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPlace()
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // display place function to upload UI with current selected place information
    func displayPlace() {
        // unwrap optional...
        if let place = placeOptional {
            // show progress hud for loading purposes
            MBProgressHUD.showAdded(to: self.view, animated: true)
            // set name label to name
            self.nameLabel.text = place.name
            // make a detail request through PlacesAPI for open status...
            // if the open status exists... update the name label to include it
            PlacesAPI.getOpenStatus(id: place.ID) { (openStatusOptional) in
                if let openStatus = openStatusOptional {
                    self.nameLabel.text = "\(place.name) (\(openStatus))"
                }
            }
            // set address label to places vicinity
            addressLabel.text = place.vicinity
            // set rating label to place star rating
            rating.text = "\(place.rating)⭐️"
            // make a detail request through PlacesAPI for the selected place phone number
            PlacesAPI.getPhoneNumber(id: place.ID) { (phoneNumberOptional) in
                if let phoneNumber = phoneNumberOptional {
                    // if successful set phone label to the phone number
                    self.phoneLabel.text = phoneNumber
                } else {
                    self.phoneLabel.text = ""
                }
            }
            // make a detail request through PlacesAPI for the selected place most recent review
            PlacesAPI.getReview(id: place.ID) { (reviewOptional) in
                if let review = reviewOptional {
                    // if successful set review label to the reviews text
                    self.rating.text = review
                } else {
                    self.rating.text = "No Reviews to Showcase"
                }
            }
            // show progress hud
            MBProgressHUD.showAdded(to: self.view, animated: true)
            // make a photo request for the first image available
            PlacesAPI.getImage(id: place.ID) { (imageOptional) in
                if let image = imageOptional {
                    // if there is one and it exists - set the image view to that image
                    self.placeImage.image = image
                } else {
                    return
                }
                // hide the progress hud because we were successful!!!
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            MBProgressHUD.hide(for: self.view, animated: true)

        }
    }
}
