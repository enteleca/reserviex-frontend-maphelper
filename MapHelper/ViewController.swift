import UIKit
import MapKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate, MKMapViewDelegate {

    var mapView: MKMapView!
    var searchBar: UISearchBar!
    var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the search bar
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 50))
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        // Initialize the map view
        mapView = MKMapView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100))
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        view.addSubview(mapView)
        
        // Initialize the search button
        searchButton = UIButton(frame: CGRect(x: 20, y: view.frame.height - 70, width: view.frame.width - 40, height: 50))
        searchButton.setTitle("Find", for: .normal)
        searchButton.backgroundColor = .blue
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        view.addSubview(searchButton)
        
        // Add a gesture recognizer to the map view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // Handle long press gesture
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        print("Latitude: \(touchMapCoordinate.latitude), Longitude: \(touchMapCoordinate.longitude)")
    }
    var annotationToMapItem: [ObjectIdentifier: MKMapItem] = [:]

    // Handle search button tap
    @objc func searchButtonTapped() {
        guard let query = searchBar.text, !query.isEmpty else {
            print("Please enter a search query.")
            return
        }
        
        // Clear existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // In the searchButtonTapped method
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = item.placemark.title
                self.mapView.addAnnotation(annotation)
                
                // Save the map item for this annotation
                self.annotationToMapItem[ObjectIdentifier(annotation)] = item
            }

        }
    }
    
    // MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // In the mapView(_:didSelect:) method
        // In the mapView(_:didSelect:) method
        if let annotation = view.annotation {
            let key = ObjectIdentifier(annotation)
            if let mapItem = annotationToMapItem[key] {
                // Print out the details
                print("---- Details for Selected Place ----")
                
                // Basic Information
                print("Name: \(mapItem.name ?? "No name")")
                print("Latitude: \(mapItem.placemark.coordinate.latitude)")
                print("Longitude: \(mapItem.placemark.coordinate.longitude)")
                
                // Address Information
                let address = mapItem.placemark.addressDictionary
                print("Street: \(address?["Street"] ?? "No street")")
                print("SubLocality: \(address?["SubLocality"] ?? "No sub-locality")")
                print("City: \(address?["City"] ?? "No city")")
                print("SubAdministrativeArea: \(address?["SubAdministrativeArea"] ?? "No sub-administrative area")")
                print("State: \(address?["State"] ?? "No state")")
                print("ZIP: \(address?["ZIP"] ?? "No ZIP code")")
                print("Country: \(address?["Country"] ?? "No country")")
                print("CountryCode: \(address?["CountryCode"] ?? "No country code")")
                
                // Additional Information
                print("Timezone: \(mapItem.timeZone)")
                print("Phone: \(mapItem.phoneNumber ?? "No phone number")")
                print("URL: \(mapItem.url?.absoluteString ?? "No URL")")
                
                print("-------------------------------")
            }
        }


    }
}
