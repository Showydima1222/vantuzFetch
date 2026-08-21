//
//  environment.swift
//  vantuzFetch
//
//  Created by showydima on 14.06.2026.
//

import Foundation

let knownShells: [String] = ["fish", "zsh", "bash", "sh", "dash", "tcsh",]
let knownTerminals: [String] = ["terminal", "iterm2", "ghostty", "wezterm-gui", "alacritty", "kitty", "tmux"]
let elevationTools = ["sudo", "doas", "su"]

struct ProcessNode {
    let pid: pid_t
    let ppid: pid_t
    let name: String
}

func getProcessLineage() -> [ProcessNode] {
    var lineage: [ProcessNode] = []
    var currentPid = getpid()
    
    while currentPid > 1 {
        guard let info = getProcessInfo(pid: currentPid) else { break }
        lineage.append(ProcessNode(pid: currentPid, ppid: info.ppid, name: info.name))
        currentPid = info.ppid
    }
    
    return lineage
}

func getProcessInfo(pid: pid_t) -> (ppid: pid_t, name: String)? {
    var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
    var size = 0
    guard sysctl(&mib, u_int(mib.count), nil, &size, nil, 0) == 0 else { return nil }
    
    var proc = kinfo_proc()
    guard sysctl(&mib, u_int(mib.count), &proc, &size, nil, 0) == 0 else { return nil }
    
    let ppid = proc.kp_eproc.e_ppid
    let name = withUnsafePointer(to: proc.kp_proc.p_comm) { ptr -> String in
        return ptr.withMemoryRebound(to: CChar.self, capacity: Int(MAXCOMLEN)) { cStr in
            return String(cString: cStr)
        }
    }
    return (ppid, name)
}

struct Environment {
    let shell: String?
    let terminal: String?
    let elevationMethod: String?
    
    static let shared = Environment()
    
    private init() {
        let lineage = getProcessLineage()
        
        self.shell = lineage.first(where: { knownShells.contains($0.name.lowercased()) })?.name
        self.terminal = lineage.first(where: { knownTerminals.contains($0.name.lowercased()) })?.name
        
        if let tool = lineage.first(where: { elevationTools.contains($0.name) })?.name { self.elevationMethod = tool }
        else if geteuid() == 0 { self.elevationMethod = "root" }
        else { self.elevationMethod = nil }
    }
}

struct ShellModule: FetchableModule {
    let id: String = "shell"
    
    func run() -> [FetchResult] {
        guard let shell = Environment.shared.shell else { return [] }
        
        let displayValue: String
        if let method = Environment.shared.elevationMethod { displayValue = "\(shell) (via \(method))" }
        else { displayValue = shell }
        
        return [FetchResult(keyId: "shell", value: displayValue)]
    }
}

struct TerminalModule: FetchableModule {
    let id: String = "terminal"
    
    func run() -> [FetchResult] {
        guard let terminal = Environment.shared.terminal else {
            if let envTerm = ProcessInfo.processInfo.environment["TERM_PROGRAM"] {
                return [FetchResult(keyId: "terminal", value: envTerm)]
            }
            return []
        }
        return [FetchResult(keyId: "terminal", value: terminal)]
    }
}
