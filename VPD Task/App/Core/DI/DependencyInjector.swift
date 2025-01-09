//
//  ServiceContainer.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//

import Foundation


class DependencyContainer {
    static let shared = DependencyContainer()
    private var dependencies: [String: Any] = [:]
    
    
    func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencies[key] as? T else {
            fatalError("No dependency found for \(key)")
        }
        return dependency
    }
}


@propertyWrapper
struct Inject<T> {
    let wrappedValue: T
    
    init() {
        self.wrappedValue = DependencyContainer.shared.resolve()
    }
}


