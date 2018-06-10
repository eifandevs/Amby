//
//  LocalStorageRepository.swift
//  Qass
//
//  Created by tenma on 2018/06/10.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class LocalStorageRepository<Target: LocalStorageTargetType> {
    
    /// get file list
    public func getList(_ target: Target) -> [String]? {
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: target.base)
            return list
        } catch let error as NSError {
            log.error("failed to getList. base: \(target.base) error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// get file data
    public func getData(_ target: Target) -> Data? {
        do {
            let data = try Data(contentsOf: target.url)
            return data
        } catch let error as NSError {
            log.warning("failed to getData. url: \(target.url) error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// get image data
    public func getImage(_ target: Target) -> UIImage? {
        return UIImage(contentsOfFile: target.absolutePath)
    }
    
    /// write
    public func write(_ target: Target, data: Data) {
        do {
            try data.write(to: target.url)
            log.debug("store data. url: \(target.url)")
        } catch let error as NSError {
            log.error("failed to store: \(error.localizedDescription)")
        }
    }
    
    /// create folder
    public func create(_ target: Target) {
        Util.createFolder(path: target.absolutePath)
    }
    
    /// delete
    public func delete(_ target: Target) {
        Util.deleteFolder(path: target.absolutePath)
    }
}
