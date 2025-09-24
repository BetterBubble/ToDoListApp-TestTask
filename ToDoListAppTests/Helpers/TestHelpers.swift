//
//  TestHelpers.swift
//  ToDoListAppTests
//

import Foundation

// MARK: - Result Extension

extension Result {
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
}