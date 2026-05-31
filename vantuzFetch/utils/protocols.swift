//
//  protocols.swift
//  vantuzFetch
//
//  Created by showydima on 29.05.2026.
//

struct FetchResult {
    let keyId: String  // id of label (using to custom label output w/ config)
    let value: String  // value of this label
}

protocol FetchableModule {
    var id: String { get }
    var isFetched: Bool { get }
    var results: [FetchResult] { get }
    mutating func run() 
}

