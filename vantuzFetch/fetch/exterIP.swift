//
//  external-ip.swift
//  vantuzFetch
//
//  Created by showydima on 14.09.2026.
//

import Foundation


private final class ResultBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: String?

    var value: String? {
        get { lock.lock(); defer { lock.unlock() }; return _value }
        set { lock.lock(); defer { lock.unlock() }; _value = newValue }
    }
}

struct ExternalIPModule: FetchableModule {
    let id: String = "external-ip"

    func run() -> [FetchResult] {
        let url = URL(string: "https://api.ipify.org")!
        let semaphore = DispatchSemaphore(value: 0)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 0.75
        let session = URLSession(configuration: config)

        let box = ResultBox()

        let task = session.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }

            guard
                error == nil,
                let http = response as? HTTPURLResponse,
                http.statusCode == 200,
                let data = data,
                let text = String(data: data, encoding: .utf8)
            else { return }

            box.value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        task.resume()

        _ = semaphore.wait(timeout: .now() + 2)

        guard let ip = box.value else { return [] }
        return [FetchResult(keyId: self.id, value: ip)]
    }
}
