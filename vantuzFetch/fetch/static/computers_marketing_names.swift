//
//  computers_marketing_names.swift
//  vantuzFetch
//
//  Created by showydima on 13.08.2026.
//

final class MarketingNamesFromModel: Sendable {
    private let codenames: [String: String] = [
            "J274AP": "Mac mini (2020)",
            "J293AP": "MacBook Pro (13-inch, 2020)",
            "J313AP": "MacBook Air (2020)",
            "J456AP": "iMac (24-inch, 2021)",
            "J457AP": "iMac (24-inch, 2021)",
            "J316sAP": "MacBook Pro (16-inch, 2021)",
            "J316cAP": "MacBook Pro (16-inch, 2021)",
            "J314sAP": "MacBook Pro (14-inch, 2021)",
            "J314cAP": "MacBook Pro (14-inch, 2021)",
            "J375cAP": "Mac Studio (2022)",
            "J375dAP": "Mac Studio (2022)",
            "J493AP": "MacBook Pro (13-inch, 2022)",
            "J413AP": "MacBook Air (2022)",
            "J473AP": "Mac mini (2023)",
            "J474sAP": "Mac mini (2023)",
            "J414sAP": "MacBook Pro (14-inch, 2023)",
            "J416sAP": "MacBook Pro (16-inch, 2023)",
            "J414cAP": "MacBook Pro (14-inch, 2023)",
            "J416cAP": "MacBook Pro (16-inch, 2023)",
            "J415AP": "MacBook Air (15-inch, 2023)",
            "J475cAP": "Mac Studio (2023)",
            "J475dAP": "Mac Studio (2023)",
            "J180dAP": "Mac Pro (2023)",
            "J433AP": "iMac (24-inch, 2023)",
            "J434AP": "iMac (24-inch, 2023)",
            "J504AP": "MacBook Pro (14-inch, 2023)",
            "J514sAP": "MacBook Pro (14-inch, 2023)",
            "J516sAP": "MacBook Pro (16-inch, 2023)",
            "J514cAP": "MacBook Pro (14-inch, 2023)",
            "J516cAP": "MacBook Pro (16-inch, 2023)",
            "J514mAP": "MacBook Pro (14-inch, 2023)",
            "J516mAP": "MacBook Pro (16-inch, 2023)",
            "J613AP": "MacBook Air (13-inch, 2024)",
            "J615AP": "MacBook Air (15-inch, 2024)",
            "J575dAP": "Mac Studio (2025)",
            "J623AP": "iMac (24-inch, 2024)",
            "J624AP": "iMac (24-inch, 2024)",
            "J773gAP": "Mac mini (2024)",
            "J773sAP": "Mac mini (2024)",
            "J604AP": "MacBook Pro (14-inch, 2024)",
            "J614sAP": "MacBook Pro (14-inch, 2024)",
            "J616sAP": "MacBook Pro (16-inch, 2024)",
            "J614cAP": "MacBook Pro (14-inch, 2024)",
            "J616cAP": "MacBook Pro (16-inch, 2024)",
            "J713AP": "MacBook Air (13-inch, 2025)",
            "J715AP": "MacBook Air (15-inch, 2025)",
            "J575cAP": "Mac Studio (2025)"
        ]
    private let normalizedCodenames: [String: String]

    private init() {
        normalizedCodenames = Dictionary(
            uniqueKeysWithValues: codenames.map { key, value in
                (Self.normalize(key), value)
            }
        )
    }

    static let shared = MarketingNamesFromModel()

    private static func normalize(_ raw: String) -> String {
        var result = raw.uppercased()
        if result.hasSuffix("AP") {
            result.removeLast(2)
        }
        return result
    }

    func getName(_ HW_MODEL: String) -> String? {
        normalizedCodenames[Self.normalize(HW_MODEL)]
    }
}
