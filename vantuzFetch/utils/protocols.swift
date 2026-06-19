//
//  protocols.swift
//  vantuzFetch
//
//  Created by showydima on 29.05.2026.
//

struct FetchResult: Sendable {
    let keyId: String  // id of label (using to custom label output w/ config)
    let value: String  // value of this label
}

protocol FetchableModule: Sendable {
    var id: String { get }
    func run() -> [FetchResult]
}

