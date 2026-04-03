

class OsCodenames {
    private let codenames: [Int: String] = [
        26: "Tahoe",
        15: "Sequoia",
        14: "Sonoma",
        13: "Ventura",
        12: "Monterey",
        11: "Big Sur"
    ]
    private init() {}
    static let shared = OsCodenames()
    func getCodeName(_ version: Int) -> String? {
        codenames[version]
    }
}
