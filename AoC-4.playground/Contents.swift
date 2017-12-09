//: Playground - noun: a place where people can play

import Cocoa

extension Substring {
    subscript (i: Int) -> Character {
        get {
            return self[index(self.startIndex, offsetBy: i)]
        }
        set {
            var copy = Array(String(self))
            copy[i] = newValue
            self = Substring(copy)
        }
    }
        
    func isAnagram(of string: Substring) -> Bool {
        return (self.sorted() == string.sorted())
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let fileString = try! String(contentsOfFile: filePath)
let lines = fileString.split(separator: "\n")
let validLines = lines.filter { line in
    let words = line.split(separator: " ")
    let validWords = words.enumerated().filter { idx, word in
        for i in idx+1..<words.count {
            if word.isAnagram(of: words[i]) {
                return false
            }
        }
        
        return true
    }

    return (validWords.count == words.count)
}

assert(validLines.count == 119)
