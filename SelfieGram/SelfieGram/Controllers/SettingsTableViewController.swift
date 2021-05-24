//
//  SettingsTableViewController.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 16/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit
import UserNotifications

enum SettingsKey: String {
    case saveLocation
}

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    private let notificationId = "SelfiegramReminder"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        updateReminderSwitch()
        
    }

    @IBAction func reminderSwitchToggle(_ sender: UISwitch) {
        let current = UNUserNotificationCenter.current()
        
        switch reminderSwitch.isOn {
        case true:
            // Define what kind of notification we send
            let notificationOptions: UNAuthorizationOptions = [.alert]
            
            // The switch was turn on
            // Ask permission to send notification
            current.requestAuthorization(options: notificationOptions) { (granted, error) in
                if granted {
                    // If it's granted permission. Queue the notification.
                    self.addNotificationRequest()
                }
                // Call updateReminderSwitch
                // because we may just learn that
                // we don't have permission
                self.updateReminderSwitch()
            }
        case false:
            // The switch was turn off
            // Remove any pending notification
            current.removeAllPendingNotificationRequests()
        }
    }
    
    @IBAction func locationSwitchToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
    }
    
    fileprivate func addNotificationRequest() {
        // Get the notification center
        let current = UNUserNotificationCenter.current()
        
        // Remove all existing notification
        current.removeAllPendingNotificationRequests()
        
        // Prepare the notification content
        let content = UNMutableNotificationContent()
        content.title = "Take a selfie!"
        
        // Create date components to represent 10AM
        var components = DateComponents()
        components.setValue(10, for: Calendar.Component.hour)
        
        // Trigger that goes off at this time, every day
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create Request
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        // Add it to the Notification Center
        current.add(request) { error in
            self.updateReminderSwitch()
        }
    }
    
    fileprivate func updateReminderSwitch() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized:
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
                    // Set to active if the list requests contain one
                    // that's got the correct id
                    let active = requests.filter({ $0.identifier == self.notificationId }).count > 0
                    
                    // If it's switch is enable
                    // we found our pending notification
                    self.updateReminderUI(enabled: true, active: active)
                })
            case .denied:
                // If the user has denied permission
                // the switch is off and disable
                self.updateReminderUI(enabled: false, active: false)
            case .notDetermined:
                // If the user hasn't been ask yet
                // the switch is enable, but default to off
                self.updateReminderUI(enabled: true, active: false)
            case .provisional:
                print("Failed to send notification")
            case .ephemeral:
                break
            }
        })
    }
    
    fileprivate func updateReminderUI(enabled: Bool, active: Bool) {
        OperationQueue.main.addOperation {
            self.reminderSwitch.isEnabled = enabled
            self.reminderSwitch.isOn = active
        }
    }
}
