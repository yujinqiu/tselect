//
//  main.swift
//  select
//
//  Created by knight on 9/28/20.
//

import Foundation
import AppKit
import ArgumentParser

struct Directory {
    static func CurrentWorkingDirectory()-> String {
        return  FileManager.default.currentDirectoryPath
    }
}

struct Path {
    static let seperator = "/"
    static let home = "~"
    static let relativePrefix = "./"
    let fm = FileManager.default
    var path: String
    var cwd: String
    
    init(path: String) {
        self.path = path
        self.cwd = Directory.CurrentWorkingDirectory()
    }
    
    
    var isAbsolute: Bool {
        return path.hasPrefix(Path.seperator) || path.hasPrefix(Path.home)
    }
    
    var isRelative: Bool {
        return !isAbsolute
    }
    
    var absPath: String {
        if isAbsolute {
            return path
        }
        let path =  "\(self.cwd)/\(self.path)"
        return path
    }
    
    var exists: Bool {
        return fm.fileExists(atPath: self.absPath)
    }
}

struct Target: ParsableCommand {
    @Argument(help: "files that will be selected in Finder.")
    var files: [String]
}

let target = Target.parseOrExit()
var urls:[URL] = []

for file in target.files {
    let path = Path(path: file)
    if path.exists {
        let url = NSURL(fileURLWithPath: path.absPath)
        // standardizing path: transform ../.. to the right path
        guard let standardizedPath = url.standardizingPath else {
            continue
        }
        urls.append(standardizedPath)
    }
}

if urls.count > 0 {
    NSWorkspace.shared.activateFileViewerSelecting(urls)
}

