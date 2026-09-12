//
//  protocols.swift
//  vantuzFetch
//
//  Created by showydima on 29.05.2026.
//

struct FetchResult: Sendable {
    // id of label (using to custom label output w/ config)
    // IMPORTANT: KEYID SHOULDNT CONTAIN '_'. Use '-' instead.
    let keyId: String
    
    let value: String  // value of this label
    var canBeSmartWrapped: Bool = false
}

protocol FetchableModule: Sendable {
    var id: String { get }
    func run() -> [FetchResult]
}

