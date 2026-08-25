//
//  logotypes.swift
//  vantuzFetch
//
//  Created by showydima on 23.08.2026.
//



final class Logotypes: Sendable {
    
    private static let AppleLogo = [
        "                 ,xNMM.",
        "               .OMMMMo",
        "               lMM",
        "     .;loddo:.  .olloddol;.",
        "   cKMMMMMMMMMMNWMMMMMMMMMM0:",
        " .KMMMMMMMMMMMMMMMMMMMMMMMWd.", // color 2
        "XMMMMMMMMMMMMMMMMMMMMMMMX.",
        "MMMMMMMMMMMMMMMMMMMMMMMM:", // color 3
        ":MMMMMMMMMMMMMMMMMMMMMMMM:",
        "MMMMMMMMMMMMMMMMMMMMMMMMX.", // color 4
        " kMMMMMMMMMMMMMMMMMMMMMMMMWd.",
        " 'XMMMMMMMMMMMMMMMMMMMMMMMMMMk", // color 5
        "  'XMMMMMMMMMMMMMMMMMMMMMMMMK.",
        "    kMMMMMMMMMMMMMMMMMMMMMMd", // color 6
        "     ;KMMMMMMMWXXWMMMMMMMk.",
        "       \"cooc*\"    \"*coo'\"",
    ] // art from neofetch
    
    private let logotypes: [String: [String]] = [
        "Apple": AppleLogo,
    ]
    private init() {}
    static let shared = Logotypes()
    func getLogotype(_ version: String) -> [String]? {
        logotypes[version]
    }
}
