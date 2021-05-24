//
//  MasterViewController.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 05/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit
import CoreLocation

class SelfieListViewController: UITableViewController {

    var detailViewController: SelfieDetailViewController? = nil
    var selfies: [Selfie] = []
    var lastLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        
        do {
            selfies = try SelfieStore.shared.listSelfies().sorted(by: { $0.created > $1.created
            })
        } catch let error {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? SelfieDetailViewController
        }
    }
    
    @objc func createNewSelfie() {
        // Clear the location, so the next image doesn't end up an out of date location
        lastLocation = nil
        let shouldGetLocation = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        if shouldGetLocation {
            // Handle auth status
            switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted:
                // We either don't have permission, or the user is
                // not permitted to use location services at all.
                // Give up at this point.
                return
            case .notDetermined:
                // We don't know if we have permission or not. Ask for it.
                locationManager.requestWhenInUseAuthorization()
            default:
                // We have permission; nothing to do here
                break
            }
        }
        locationManager.delegate = self
        
        // Request a one-time location update
        locationManager.requestLocation()
        
        // Create new image picker
        let imagePicker = UIImagePickerController()
        
        // If a camera is available, use it. otherwise, use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        
        // If a front-facing camera is available, use it
        if UIImagePickerController.isCameraDeviceAvailable(.front) {
            imagePicker.cameraDevice = .front
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        // Notify when the user takes a photo
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func newSelfieTaken(image: UIImage) {
        // Create a new image
        let newSelfie = Selfie(title: "New Selfie")
        
        // Store the image
        newSelfie.image = image
        
        if let location = lastLocation {
            newSelfie.position = Selfie.Coordinate(location: location)
        }
        
        // Attempt to save photo
        do {
            try SelfieStore.shared.save(selfie: newSelfie)
        } catch let error {
            showError(message: "Can't save photo: \(error)")
            return
        }
        
        // Insert photo into view controller list
        selfies.insert(newSelfie, at: 0)
        
        // Update Table view
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selfie = selfies[indexPath.row]
                
                if let controller = (segue.destination as? UINavigationController)?.topViewController as? SelfieDetailViewController {
                    controller.selfie = selfie
                    controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let selfie = selfies[indexPath.row]
        cell.textLabel!.text = selfie.title
        
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date()) {
            cell.detailTextLabel?.text = "\(interval) ago"
        } else {
            cell.detailTextLabel?.text = nil
        }
        cell.imageView?.image = selfie.image
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selfieToRemove = selfies[indexPath.row]
            
            do {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                
                // Remove it in array
                selfies.remove(at: indexPath.row)
                
                // Remove from the tableView
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                let title = selfieToRemove.title
                showError(message: "Failed to delete \(title)")
            }
        }
    }
}

extension SelfieListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            let message = "Couldn't get a picture from the image picker"
            showError(message: message)
            return
        }
        newSelfieTaken(image: image)
        
        dismiss(animated: true, completion: nil)
    }
}

extension SelfieListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: error.localizedDescription)
    }
}
