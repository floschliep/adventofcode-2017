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
        
//        for a in 0..<self.count {
//            var chars = Array(String(self))
//            for b in a..<self.count {
//                for c in a..<self.count {
//                    for d in a..<self.count {
//                        chars.swapAt(c, d)
//                    }
//                    if Substring(chars) == string {
//                        return true
//                    }
//                }
//            }
//        }
        
        return false
    }
}

let fileString = try! String(contentsOfFile: "/Users/florianschliep/Desktop/input.txt")
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
print(validLines.count)

