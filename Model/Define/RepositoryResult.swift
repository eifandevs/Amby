//
//  RepositoryRepositoryResult.swift
//  Model
//
//  Created by tenma on 2018/11/26.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

enum RepositoryResult<Value> {
    case success(Value)
    case failure(Error)

    /// Returns `true` if the RepositoryResult is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the RepositoryResult is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the RepositoryResult is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the associated error value if the RepositoryResult is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}

// MARK: - CustomStringConvertible

extension RepositoryResult: CustomStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the RepositoryResult was a
    /// success or failure.
    public var description: String {
        switch self {
        case .success:
            return "SUCCESS"
        case .failure:
            return "FAILURE"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension RepositoryResult: CustomDebugStringConvertible {
    /// The debug textual representation used when written to an output stream, which includes whether the RepositoryResult was a
    /// success or failure in addition to the value or error.
    public var debugDescription: String {
        switch self {
        case let .success(value):
            return "SUCCESS: \(value)"
        case let .failure(error):
            return "FAILURE: \(error)"
        }
    }
}

// MARK: - Functional APIs

extension RepositoryResult {
    public init(value: () throws -> Value) {
        do {
            self = try .success(value())
        } catch {
            self = .failure(error)
        }
    }

    public func unwrap() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }

    public func map<T>(_ transform: (Value) -> T) -> RepositoryResult<T> {
        switch self {
        case let .success(value):
            return .success(transform(value))
        case let .failure(error):
            return .failure(error)
        }
    }

    public func flatMap<T>(_ transform: (Value) throws -> T) -> RepositoryResult<T> {
        switch self {
        case let .success(value):
            do {
                return try .success(transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    public func mapError<T: Error>(_ transform: (Error) -> T) -> RepositoryResult {
        switch self {
        case let .failure(error):
            return .failure(transform(error))
        case .success:
            return self
        }
    }

    public func flatMapError<T: Error>(_ transform: (Error) throws -> T) -> RepositoryResult {
        switch self {
        case let .failure(error):
            do {
                return try .failure(transform(error))
            } catch {
                return .failure(error)
            }
        case .success:
            return self
        }
    }

    @discardableResult
    public func withValue(_ closure: (Value) -> Void) -> RepositoryResult {
        if case let .success(value) = self { closure(value) }

        return self
    }

    @discardableResult
    public func withError(_ closure: (Error) -> Void) -> RepositoryResult {
        if case let .failure(error) = self { closure(error) }

        return self
    }

    @discardableResult
    public func ifSuccess(_ closure: () -> Void) -> RepositoryResult {
        if isSuccess { closure() }

        return self
    }

    @discardableResult
    public func ifFailure(_ closure: () -> Void) -> RepositoryResult {
        if isFailure { closure() }

        return self
    }
}
