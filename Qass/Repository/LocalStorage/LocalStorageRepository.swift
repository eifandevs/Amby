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
}
