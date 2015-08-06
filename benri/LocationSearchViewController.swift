//
//  LocationSearchController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/13/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation

class LocationSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelSearch(sender: AnyObject) {
        self.selectedLocationName = ""
        self.performSegueWithIdentifier("backFromLocationToTag", sender: self)
    }
    
    private var predictData:[GMSAutocompletePrediction] = []
    private var hotSpotData:[String] = ["Current Location", "Roppongi", "Shibuya", "Ginza"]
    private var hotSpotLocation:[CLLocation] = [LocationService.sharedInstance.getCurrentLocation(),
        CLLocation(latitude: 35.664122, longitude: 139.729426),
        CLLocation(latitude: 35.664035, longitude: 139.698212),
        CLLocation(latitude: 35.672089, longitude: 139.770592)]
    
    private var searchActive = false
    
    var placesClient: GMSPlacesClient?
    var selectedLocationName = ""
    var selectedCoordinates = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        
        placesClient = GMSPlacesClient()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        let tokyo = CLLocationCoordinate2DMake(35.6833, 139.6833)
        let northEast = CLLocationCoordinate2DMake(tokyo.latitude + 1, tokyo.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(tokyo.latitude - 1, tokyo.longitude - 1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        
        if count(searchText) > 2 {
            searchActive = true
            placesClient?.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                if error != nil {
                    println("Autocomplete error \(error) for query '\(searchText)'")
                    return
                }
                
                println("Populating results for query '\(searchText)'")
                self.predictData = [GMSAutocompletePrediction]()
                if let results:[GMSAutocompletePrediction] = results as? [GMSAutocompletePrediction]{
                    for result in results {
                        self.predictData.append(result)
                    }
                }
                self.tableView.reloadData()
            })
        } else {
            searchActive
                = false
            self.predictData = [GMSAutocompletePrediction]()
            self.tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return predictData.count;
        } else {
            return hotSpotData.count;
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell") as! SearchCell
        
        if searchActive {
            var regularFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
            var boldFont = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
    
            var bolded:NSMutableAttributedString = predictData[indexPath.row].attributedFullText as! NSMutableAttributedString
            bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: NSAttributedStringEnumerationOptions.allZeros, usingBlock: { (value, range, stop) -> Void in
                var font = (value == nil) ? regularFont : boldFont
                bolded.addAttribute(NSFontAttributeName, value: font, range: range)
            })
            cell.placeID = predictData[indexPath.row].placeID
            self.setGeoCode(predictData[indexPath.row].placeID, cell: cell)
            cell.searchText?.attributedText = bolded
        } else {
            cell.searchText?.text = hotSpotData[indexPath.row]
            cell.coordinates = hotSpotLocation[indexPath.row]
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 27.0))
        
        if searchActive {
            var label = UILabel(frame: CGRectMake(0, 5, tableView.frame.size.width, 22.0))
            label.text = "powered by Google"
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: label.font.fontName, size: 14.0)
            label.alpha = 0.8
            label.textColor = UIColor(red: 247.0/255.0, green: 97.0/255.0, blue: 65.0/255.0, alpha: 1.0)
            footerView.addSubview(label)

        }
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: SearchCell = self.tableView.cellForRowAtIndexPath(indexPath) as! SearchCell
        
      //  let searchViewController = segue.destinationViewController as! searchViewController
       // searchViewController.message = "Hello from the 1st View Controller"
        
        /*println("select")
        println(indexPath)
        selectedLocationName = cell.searchText?.text as String!
        selectedCoordinates = cell.coordinates
        self.performSegueWithIdentifier("selectLocationFromSearchSegueUnwind", sender: self)*/
        
    }
    
    private func setGeoCode(placeID:String, cell:SearchCell) -> Void {
        placesClient?.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                println("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                cell.coordinates = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                
            } else {
                println("No place details for \(placeID)")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "didSelectLocation" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let cell: SearchCell = self.tableView.cellForRowAtIndexPath(indexPath) as! SearchCell
                let tagViewController = segue.destinationViewController as! TagsViewController
                tagViewController.locationSearchText = cell.searchText?.text as String!
                tagViewController.locationSearch = cell.coordinates
            }
        }
    }
}