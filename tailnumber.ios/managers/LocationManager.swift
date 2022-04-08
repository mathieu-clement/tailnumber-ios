
import UIKit
import MapKit
import CoreLocation
import Combine
import Logging

class LocationManager: NSObject, ObservableObject {
    lazy var geocoder = CLGeocoder()
    private let logger = Logger(label: "LocationManager")

    func openMapWithAddress (_ locationString: String) {
        geocoder.geocodeAddressString(locationString) { placemarks, error in
            if let error = error {
                self.logger.error("\(error)")
            }

            guard let placemark = placemarks?.first else {
                return
            }

            guard let lat = placemark.location?.coordinate.latitude else{return}

            guard let lon = placemark.location?.coordinate.longitude else{return}

            let coords = CLLocationCoordinate2DMake(lat, lon)

            let place = MKPlacemark(coordinate: coords)

            let mapItem = MKMapItem(placemark: place)
            mapItem.name = locationString
            mapItem.openInMaps(launchOptions: nil)
        }
    }
}