//
//  SelfieStore.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 05/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit.UIImage

enum SelfieStoreError: Error {
    case cannotSaveImage(UIImage?)
}

final class SelfieStore {
    static let shared = SelfieStore()
    
    private var imageCache: [UUID: UIImage] = [:]
    
    var documentFolder: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }
    
    /// Gets an image by ID. Will be cached in memory for future lookups.
    /// - parameter id: the id of the selfie whose image you are after
    /// - returns: the image for that selfie or nil if it doesn't exist
    func getImage(id: UUID) -> UIImage? {
        
        // If this image already in the cache, return it
        if let image = imageCache[id] {
            return image
        }
        
        // Figure where the image should live
        let imageURL = documentFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        // Get the data from this file, exit if it fail
        guard let imageData = try? Data(contentsOf: imageURL) else { return nil }
        
        // Get the image from the data, exit if it fail
        guard let image = UIImage(data: imageData) else { return nil }
        
        // Store the loaded image in the cache next time
        imageCache[id] = image
        
        return image
    }
    
    /// Saves an image to disk.
    /// - parameter id: the id of the selfie you want this image /// associated with
    /// - parameter image: the image you want saved
    /// - Throws: `SelfieStoreObject` if it fails to save to disk
    func setImage(id: UUID, image: UIImage?) throws {
        
        // Figure out where the file would end up
        let fileName = "\(id.uuidString)-image.jpg"
        let destinationURL = self.documentFolder.appendingPathComponent(fileName)
        
        if let image = image {
            guard let data = image.jpegData(compressionQuality: 0.9) else { throw SelfieStoreError.cannotSaveImage(image) }
            
            // Attempt to write the data out
            try data.write(to: destinationURL)
        } else {
            // The image is nil, indicating that we want to remove the image
            // Attemp to perform a deletion
            try FileManager.default.removeItem(at: destinationURL)
            
            // Cache the image in memory. (If this image is nil
            // this has the effect of removing the entry from
            // the cache dictionary)
            imageCache[id] = image
        }
    }
    
    // Returns a list of Selfie objects loaded from disk.
    /// - returns: an array of all selfies previously saved
    /// - Throws: `SelfieStoreError` if it fails to load a selfie correctly from disk
    func listSelfies() throws -> [Selfie] {
        
        // Get the list of files in the document directory
        let contents = try FileManager.default.contentsOfDirectory(at: documentFolder, includingPropertiesForKeys: nil)
        
        // Get all files whose path extension is 'json',
        // load them as data, and decode them from JSON
        
        return try contents.filter { $0.pathExtension == "json" }.map { try Data(contentsOf: $0) }.map { try JSONDecoder().decode(Selfie.self, from: $0)}
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// This function simply takes the ID from the Selfie you pass in,
    /// and gives it to the other version of the delete function.
    /// - parameter selfie: the selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie
    /// from disk
    func delete(selfie: Selfie) throws {
        try delete(id: selfie.id)
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// - parameter id: the id property of the Selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie
    /// from disk
    func delete(id: UUID) throws {
        let selfieDataName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        
        let selfieDataURL = documentFolder.appendingPathComponent(selfieDataName)
        let imageURL = documentFolder.appendingPathComponent(imageFileName)
        
        // Remove the two file if they exist
        if FileManager.default.fileExists(atPath: selfieDataURL.path) {
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        // Wipe the image cache if it's there
        imageCache[id] = nil
    }
    
    /// Attempts to load a selfie from disk.
    /// - parameter id: the id property of the Selfie object you want loaded
    /// from disk
    /// - returns: the selfie with the matching id, or nil if it doesn't exist
    func load(id: UUID) -> Selfie? {
        
        let dataFileName = "\(id.uuidString).json"
        let dataURL = documentFolder.appendingPathComponent(dataFileName)
        
        // Attempt to load the data from this file,
        // and then convert the data into a photo, than return it
        // return nil if any step is fails
        if
            let data = try? Data(contentsOf: dataURL),
            let selfie = try? JSONDecoder().decode(Selfie.self, from: data) {
            return selfie
        } else {
            return nil
        }
    }
    
    /// Attempts to save a selfie to disk.
    /// - parameter selfie: the selfie to save to disk
    /// - Throws: `SelfieStoreError` if it fails to write the data
    func save(selfie: Selfie) throws {
        
        let selfieData = try JSONEncoder().encode(selfie)
        let fileName = "\(selfie.id.uuidString).json"
        let destinationURL = documentFolder.appendingPathComponent(fileName)
        
        try selfieData.write(to: destinationURL)
    }
}
