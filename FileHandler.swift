//
//  FileHandler.swift
//  NLPUtilities
//
//  Created by NextEducation on 28/03/22.
//

import Foundation

struct FileHandler{
    
    static let shared = FileHandler()
    
    private init(){}
    
    ///Writes string to text file
    @discardableResult
    func writeDataToTextFile(file:File, data:String) -> Bool {
        var isWritingSuccessful:Bool = false
        
        let fileURL = self.getURL(file: file)
        
        if let unwrappedFileURL = fileURL{
            do {
                try data.write(to: unwrappedFileURL, atomically: false, encoding: .utf8)
                isWritingSuccessful = true
            }
            catch {
                debugPrint(error)
            }
        }
        return isWritingSuccessful
    }
    
    ///Raeds string from text file
    func getDataFromTextFile(file:File) -> String?{
        let fileURL = self.getURL(file: file)
        var fetchedString:String?
        if let unwrappedFileURL = fileURL{
            do {
                fetchedString = try String(contentsOf: unwrappedFileURL, encoding: .utf8)
            }
            catch {
                debugPrint(error)
            }
        }
        return fetchedString
    }
    
    ///Writes to JSON file in document
    @discardableResult
    func writeDataToJSONFile(file:File, data:Any) -> Bool{
        
        guard let unwrappedBinaryData = self.convertToData(data: data)  else {return false}
        let isWritingSuccessfull = self.writeDataToJSONFile(file: file, data: unwrappedBinaryData)
        return isWritingSuccessfull
    }
    
    private func writeDataToJSONFile(file:File,data:Data) -> Bool{
        var isWritingSuccessful = false
           if let fileURL = self.getURL(file: file)  {
            do {
                try data.write(to: fileURL)
                isWritingSuccessful = true
            } catch {
                
            }
        }
        return isWritingSuccessful
    }
    
    func convertToData(data:Any) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: data, options: [])
        }
        catch{
            return nil
        }
    }
    
    func deleteFile(fileURL:URL) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                print("Could not delete file, probably read-only filesystem")
            }
        }
    }
    func getDataFromJSONFile(file:File) -> Any?{
        var fetchedData:Any?
        if let fileURL = self.getURL(file: file) {
            do {
                let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                fetchedData = jsonResult
            } catch {
                debugPrint(error)
            }
        }
        return fetchedData
    }
    
    //    func doesFileExist(fileName:String, fileType:FileType, fileLocation: FileLocationType, containerGroupIdentifier:ContainerIdentifier? = nil) -> Bool {
    //        guard let _ = self.getURL(fileName: fileName, fileType: FileType.JSON, fileLocation: fileLocation, containerGroupIdentifier: containerGroupIdentifier) else {return false}
    //        return true
    //    }
    
    private func getURL(file:File) -> URL?{
        let fileLocationType:FileLocationType = file.fileLocationType
        return fileLocationType.getURL(file: file)
    }
}

enum FileLocationType{
    case bundle
    case documentsDirectory
    case containerGroup
    
    
    func getURL(file:File) -> URL?{
        let fileName:String = file.fileName
        let containerGroupIdentifier:ContainerIdentifier? = file.containerGroupIdentifier
        let fileType:FileType = file.fileType
        
        var url:URL?
        switch self {
        case .bundle:
            guard let filePathURLString = Bundle.main.path(forResource: fileName, ofType: fileType.rawValue) else {return nil}
            url = URL(fileURLWithPath: filePathURLString)
        case .documentsDirectory:
            let fileNameWithExtension = FileType.text.appendFileExtention(fileName: fileName)
            url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileNameWithExtension)
            
        case .containerGroup:
            if let identifier = containerGroupIdentifier?.rawValue {
                url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)?.appendingPathComponent(fileType.appendFileExtention(fileName: fileName))
            }
        }
        return url
    }
}


enum FileType:String{
    case JSON = "json"
    case text = "text"
    
    func appendFileExtention(fileName:String) -> String{
        return fileName + "." + self.rawValue
    }
}


