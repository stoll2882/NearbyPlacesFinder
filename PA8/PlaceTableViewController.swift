//
//  PlaceTableViewController.swift
//  PA8
//  Sam Toll
//  CPSC 315
//  December 10th, 2020
//
//  Created by Sam Toll on 12/6/20.
//

import Foundation
import UIKit
import CoreLocation
import MBProgressHUD

// Places Table View Controller: Delegate for tableview, corelocationmanager, and searchbar
class PlaceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // table view and search bar outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // define our core location manager as well as create variable to store users current location at all times
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    // places array to store all the nearby places availbale to view to the user at all times
    var places = [Place]()
    
    // load the view...
    override func viewDidLoad() {
        super.viewDidLoad()
        // set all delegates to self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        // if location services are enabled on device... set up for this project
        if (CLLocationManager.locationServicesEnabled()) {
            setupLocationServices()
        }
        
        // make it so keybaord is dismissed upon tap of view
        let tap = UITapGestureRecognizer(target: tableView, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
        // reload data
        tableView.reloadData()
    }
    
    // function to setup location services..
    func setupLocationServices() {
        // set the delegate to self
        locationManager.delegate = self
        // request when in use of location
        locationManager.requestWhenInUseAuthorization()
        // set desired accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // start updating users location
        locationManager.startUpdatingLocation()
        // request users current location
        locationManager.requestLocation()
    }
    
    // function that runs whenever users location updates and changes their current location stored in the global variable
    // prints out current coordinates for debugging purposes (the first time I tried this I was apparently in the middle of the pacific ocean)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[locations.count - 1]
        print("latitude: \(currentLocation.coordinate.latitude)")
        print("longitude: \(currentLocation.coordinate.longitude)")
    }
    
    // function to execute if location manager fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
        // 0: no location
        // 1: authorization error
    }
    
    // function to execute upon press of search bar button item
    @IBAction func searchButtonPressed(_ sender: Any) {
        // if there is text in the search bar... preform a search
        if searchBar.text != "", let text = searchBar.text {
            searchPlace(place: text)
        }
    }
    
    // function to execute upon press of search button on users keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // if there is text in the search bar... preform a search
        if searchBar.text != "", let text = searchBar.text {
            searchPlace(place: text)
        }
    }
    
    // function to execute when the text changes in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // show the cancel button incase user wants to escape
        searchBar.showsCancelButton = true
        // if there is text still... perform a new search to keep results updates
        if searchBar.text != "", let text = searchBar.text {
            searchPlace(place: text)
        } else if searchBar.text == "" { // if there is no text... the field has been cleared so clear array and reload data, dismiss keyboard and remove cancel button
            places.removeAll()
            places = []
            tableView.reloadData()
            searchBar.showsCancelButton = false
        }
    }
    
    // function tbat performs a search
    func searchPlace(place: String) {
        // get current user coordinates stores in global location variable
        let latitude = currentLocation.coordinate.latitude;
        let longitude = currentLocation.coordinate.longitude;
        
        let keyword: String = place
        
        // show progress hud
        MBProgressHUD.showAdded(to: self.view, animated: true)
        // fetch nearby places array from places api and set variable of current nearby palces to array returned
        PlacesAPI.fetchNearbyPlaces(latitude: latitude, longitude: longitude, keyword: keyword) { (nearbyPlacesOptional) in
            if let nearbyPlaces = nearbyPlacesOptional {
                self.places = nearbyPlaces
                // print them for debugging purposes
                print("NEARBY PLACES ARRAY: \(self.places)")
            }
            // reload the data and hide the progress hud
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // function that returns number of rows in the table (the number of nearby places)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    // function that updates the table view with PlaceCells full of all the current nearby places available to the user
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let place = places[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
        
        cell.update(with: place)
        
        return cell
    }
    
    // function to execute upon refresh request
    @IBAction func refreshButtonPressed(_ sender: Any) {
        // force an update of the location by requesting it
        locationManager.requestLocation()
        // if there is text in the search bar... perform a new search with the new location
        if searchBar.text != "", let text = searchBar.text {
            searchPlace(place: text)
        }
    }
    
    // function to execute upon run of segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            // segue to go to detail view / controller
            if identifier == "DetailSegue" {
                // if the destination is the detail view...
                if let placeDetailVC = segue.destination as? PlaceDetailViewController {
                    // the place is the row selected - set place optional within detail controller to place selected
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let place = places[indexPath.row]
                        placeDetailVC.placeOptional = place
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            // segue to go add a trip view
            }
        }
    }
}

