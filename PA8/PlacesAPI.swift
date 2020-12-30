//
//  PlacesAPI.swift
//  PA8
//  Sam Toll
//  CPSC 315
//  December 10th, 2020
//
//  Created by Sam Toll on 12/7/20.
//

import Foundation
import UIKit
import CoreLocation
import GooglePlaces

// global PlacesAPI struct
struct PlacesAPI {
    
    // projectAPIKey and baseURL for detail requests
    static let apiKey = APIKey.APIKey;
    static let baseURL = "https://maps.googleapis.com/maps/api/place/details/json?"
    
    // function to get proper details url based on what field was wanted and the id of the place we are getting it from
    static func placeDetailsURL(id: String, field: String) -> URL {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(id)&fields=\(field)&key=\(apiKey)")
        // return url unwrapped
        return url!
    }
    
    // function to fetch the nearby places array and thread to the table view controller
    static func fetchNearbyPlaces(latitude: CLLocationDegrees, longitude: CLLocationDegrees, keyword: String, completion: @escaping ([Place]?) -> Void) {
        // nearby places request url based on users current location and their search
        let nearbyPlacesURL = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=5000&keyword=\(keyword)&key=\(apiKey)")!
        
        // set the task of retrieving the data from the url
        let task = URLSession.shared.dataTask(with: nearbyPlacesURL) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                // parsing the Data response into JSON
                // if teh nearbyPlaces array returned is proper and exits... thread it through
                if let nearbyPlaces = nearbyPlaces(fromData: data) {
                    print("we got [Place] with \(nearbyPlaces.count)")
                    DispatchQueue.main.async {
                        completion(nearbyPlaces)
                    }
                }
                // parsing the JSON into [Place] array
                // otherwise... there was an error :(
            } else {
                if let error = errorOptional {
                    print("error getting the nearby places data: \(error)")
                }
            }
        }
        // start the task running
        task.resume()
    }
    
    // function to get the nearbyPlaces array
    static func nearbyPlaces(fromData data: Data) -> [Place]? {
        // do catch block to avoid unncessary errors
        do {
            // set the json object... and get the array of json place objects
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let nearbyPlacesArray = jsonDictionary["results"] as? [[String: Any]] else {
                print("error parsing JSON")
                return nil
            }
            // print statenent alerting we have gotten the array for debugging purposes
            print("we got the array!")
            var nearbyPlaces = [Place]()
            for nearbyPlaceObject in nearbyPlacesArray {
                // loop through array and use nearbvyPlace method to get formatted nearby place with all neccessary information
                if let nearbyPlace = nearbyPlace(fromJSON: nearbyPlaceObject) {
                    // if it exists.. add it to the array
                    nearbyPlaces.append(nearbyPlace)
                }
            }
            if !nearbyPlaces.isEmpty {
                print("array is not empty!")
                return nearbyPlaces
            }
        } catch {
            print("Error converting Data to JSON \(error)")
        }
        
        return nil
    }
    
    // function to get a single nearby place from a json object
    static func nearbyPlace(fromJSON json: [String: Any]) -> Place? {
        // get simple fields neccessary out of json objects and create a place object (and return it) formatted with correct fields
        guard let id = json["place_id"] as? String, let name = json["name"] as? String, let rating = json["rating"] as? Double, let vicinity = json["vicinity"] as? String else {
            print("error parsing json Details")
            return nil
        }
        // create newPlace object and return it
        let newPlace = Place(ID: id, name: name, vicinity: vicinity, rating: rating)
        return newPlace
    }
    
    // function to use a detail request to get the phone number of a place based on its ID
    static func getPhoneNumber(id: String, completion: @escaping (String?) -> Void) {
        // url with proper parameters
        let url: URL = placeDetailsURL(id: id, field: "formatted_phone_number")
        // mew task with new url...
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                // parsing the Data response into JSON
                do {
                    // get the JSON object and begin parsing for formatted phone number going throuhg a couple levels
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["result"] as? [String: Any], let phoneNumber = result["formatted_phone_number"] as? String else {
                        print("error parsing phone JSON")
                        return
                    }
                    // if we got the phone number - return it (with threading)!
                    print("Phone number: \(phoneNumber)")
                    DispatchQueue.main.async {
                        completion(phoneNumber)
                    }
                // otherwise... there was an error
                } catch {
                    print("Error converting Data to JSON \(error)")
                }
            } else {
                if let error = errorOptional {
                    print("error getting the nearby places data: \(error)")
                }
            }
        }
        // start task
        task.resume()
    }
    
    // function to use a detail request to get the first review text of a place based on its ID
    static func getReview(id: String, completion: @escaping (String?) -> Void) {
        // url with proper parameters
        let url: URL = placeDetailsURL(id: id, field: "reviews")
        // new task with new url...
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                // parsing the Data response into JSON
                do {
                    // get the JSON object and begin parsing for the first reviews text going throuhg a couple levels
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["result"] as? [String: Any], let reviewsArray = result["reviews"] as? [[String: Any]] else {
                        print("error parsing review JSON")
                        return
                    }
                    let firstReview = Array(reviewsArray)[0]
                    guard let reviewText = firstReview["text"] as? String else {
                        print("error parsing first review JSON")
                        return
                    }
                    // if we got the first reviews text... return it with threading
                    print("First Review text: \(reviewText)")
                    DispatchQueue.main.async {
                        completion(reviewText)
                    }
                } catch {
                    print("Error converting Data to JSON \(error)")
                }
            } else {
                if let error = errorOptional {
                    print("error getting the nearby places data: \(error)")
                }
            }
        }
        // start the task
        task.resume()
    }
    
    // function to use a detail request to get the open status of a place based on its ID
    static func getOpenStatus(id: String, completion: @escaping (String?) -> Void) {
        // url with proper parameters
        let url: URL = placeDetailsURL(id: id, field: "opening_hours")
        // new task with new url...
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                // parsing the Data response into JSON
                do {
                    // get the JSON object and begin parsing for the open status going through a couple levels
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["result"] as? [String: Any], let openingHoursArray = result["opening_hours"] as? [String: Any], let openStatus = openingHoursArray["open_now"] as? Bool else {
                        print("error parsing review JSON")
                        return
                    }
                    // if we got the open status and it is true... return open
                    if openStatus == true {
                        print("Open")
                        DispatchQueue.main.async {
                            completion("Open")
                        }
                    // if open status is false... return closed
                    } else {
                        print("Closed")
                        DispatchQueue.main.async {
                            completion("Closed")
                        }
                    }
                } catch {
                    print("Error converting Data to JSON \(error)")
                }
            } else {
                if let error = errorOptional {
                    print("error getting the nearby places data: \(error)")
                }
            }
        }
        // start task
        task.resume()
    }
    
    // function to use a photo request to get the first photo availabel of the places based on its ID
    static func getImage(id: String, completion: @escaping (UIImage?) -> Void) {
        // url with proper paramters for a photo request
        let url: URL = placeDetailsURL(id: id, field: "photos")
        // new task with new url...
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                // parsing the Data response into JSON
                do {
                    // get the JSON object and parse to get the array of photo JSON objects
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["result"] as? [String: Any], let photosArray = result["photos"] as? [[String: Any]] else {
                        print("error parsing photo JSON")
                        return
                    }
                    // get the first review by typecasting to an array and getting index 0 element
                    let firstReview = Array(photosArray)[0]
                    // parse first review again to get the photo reference
                    guard let photoReference = firstReview["photo_reference"] as? String else {
                        print("error parsing first photo JSON")
                        return
                    }
                    // if we got the photo reference... use photo method to get the photo itself in UIImage? form
                    photo(photoReference: photoReference) { (imageOptional) in
                        // if image is real... return with threading
                        if let image = imageOptional {
                            DispatchQueue.main.async {
                                completion(image)
                            }
                        // if not real... return nil for no image
                        } else {
                            print("error getting image from photo function")
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                    }
                    // photo reference tag for debugging purposes
                    print("Photo reference text: \(photoReference)")

                } catch {
                    print("Error converting Data to JSON \(error)")
                }
            } else {
                if let error = errorOptional {
                    print("error getting the nearby places data: \(error)")
                }
            }
        }
        // start task
        task.resume()
    }
    
    // photo function to return a UIImage from a photo reference
    static func photo(photoReference: String, completion: @escaping (UIImage?) -> Void) {
        // special photo request url with photoreference provided...
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)")!
        // new task with new url...
        let task = URLSession.shared.dataTask(with: url) { (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let image = UIImage(data: data) {
                // get the image from the data by constructing a uiimage fron the data
                DispatchQueue.main.async {
                    // if working... thread back the image
                    completion(image)
                }
            // if not correct... return nil for an error retrieving the photo
            } else {
                print("error getting image from data")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        // start the task
        task.resume()
    }
}
