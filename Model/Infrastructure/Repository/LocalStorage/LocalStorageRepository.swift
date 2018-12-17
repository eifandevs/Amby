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
    public func getList(_ target: Target) -> RepositoryResult<[String]> {
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: target.absolutePath)
            return .success(list)
        } catch let error as NSError {
            log.error("failed to getList. base: \(target.base) error: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    /// get file data
    public func getData(_ target: Target) -> RepositoryResult<Data> {
        do {
            let data = try Data(contentsOf: target.url)
            return .success(data)
        } catch let error as NSError {
            log.warning("failed to getData. url: \(target.url) error: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    /// get image data
    public func getImage(_ target: Target) -> RepositoryResult<UIImage> {
        if let image = UIImage(contentsOfFile: target.absolutePath) {
            return .success(image)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            return .failure(error)
        }
    }

    /// write
    public func write(_ target: Target, data: Data) -> RepositoryResult<()> {
        do {
            try data.write(to: target.url)
            log.debug("store data. url: \(target.url)")
            return .success(())
        } catch let error as NSError {
            log.error("failed to store: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    /// create folder
    public func create(_ target: Target) -> RepositoryResult<()> {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        return Util.createFolder(path: target.absolutePath) ? .success(()) : .failure(error)
    }

    /// delete
    public func delete(_ target: Target) -> RepositoryResult<()> {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        return Util.deleteFolder(path: target.absolutePath) ? .success(()) : .failure(error)
    }
}
