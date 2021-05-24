//
//  DetailViewController.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 05/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit
import MapKit

class SelfieDetailViewController: UIViewController {

    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLbl: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var expandMap: UITapGestureRecognizer!
    
    var selfie: Selfie? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // The date formatter used to format the time and date of the photo.
    // It's created in a closure like this so that when it's used, it's
    // already configured the way we need it.

    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let selfie = selfie else { return }
        
        guard
            let selfieNameField = selfieNameField,
            let dateCreatedLbl = dateCreatedLbl,
            let selfieImageView = selfieImageView else {
                return
        }
        
        selfieNameField.text = selfie.title
        dateCreatedLbl.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
    }
    @IBAction func expandMap(_ sender: UITapGestureRecognizer) {
        if let coordinate = selfie?.position?.location {
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate.coordinate), MKLaunchOptionsMapTypeKey: NSNumber(value: MKMapType.mutedStandard.rawValue)]
            
            let placemark = MKPlacemark(coordinate: coordinate.coordinate, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = selfie?.title
            item.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        self.selfieNameField.resignFirstResponder()
        
        guard let selfie = selfie else { return }
        guard let text = selfieNameField.text else { return }
        
        selfie.title = text
        
        try? SelfieStore.shared.save(selfie: selfie)
        
        if let position = selfie.position {
            mapView.setCenter(position.location.coordinate, animated: false)
            mapView.isHidden = false
        }
    }
}

