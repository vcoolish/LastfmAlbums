import UIKit

func deleteFile(file: URL) -> Bool {
    let fileManager = FileManager.default
    
    do {
        try fileManager.removeItem(at: file)
        return true
    } catch _ as NSError {
        return false
    }
}

func getFile(name: String, folder: String? = nil) -> URL? {
    var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    if let folder = folder {
        documentsUrl = documentsUrl.appendingPathComponent(folder)
    }
    
    do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
        
        if let index = directoryContents.firstIndex(where: {$0.lastPathComponent == name }) {
            return directoryContents[index]
        }
        return nil
        
    } catch _ as NSError {
        return nil
    }
}

func saveImage(image: UIImage, path: String, folder: String?) -> URL? {
    var documentsDirectoryURL = try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
        if let fold = folder {
            do {
                documentsDirectoryURL = documentsDirectoryURL?.appendingPathComponent(fold)
                try FileManager().createDirectory(atPath: documentsDirectoryURL!.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        let fileURL = documentsDirectoryURL?.appendingPathComponent(path)
        
        let maxFileSize = 600*1024
        var imageData = image.jpegData(compressionQuality: 1.0)
        
        if imageData == nil {
            return nil
        }
        
        while (imageData!.count > maxFileSize)
        {
            imageData = image.jpegData(compressionQuality: 0.1)
        }
        
        do {
            if let fileURL = fileURL {
                try! imageData?.write(to: fileURL, options: [.atomic])
            }
            return fileURL?.absoluteURL
        } catch {
            return nil
        }
    
}
