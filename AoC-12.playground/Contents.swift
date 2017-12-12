//: Playground - noun: a place where people can play

import Cocoa

extension Set {
    func inserting(_ other: Element) -> Set<Element> {
        var copy = self
        copy.insert(other)
        return copy
    }
}

struct Program {
    let id: Int
    let pipes: [Int]
    
    init?(_ string: String) {
        let trimmed = string.replacingOccurrences(of: " ", with: "")
        let components = trimmed.components(separatedBy: "<->")
        
        guard components.count == 2 else { return nil }
        guard let id = Int(components[0]) else { return nil }
        
        self.id = id
        self.pipes = components[1].split(separator: ",").flatMap { Int($0) }
    }
}

typealias Village = [Int: Program]

func findMinID(`in` village: Village, `for` program: Program, except exceptions: Set<Int> = Set<Int>()) -> Int {
    let exceptions = exceptions.inserting(program.id)
    var minID = Int.max
    for pipe in program.pipes {
        minID = min(minID, pipe)
        
        guard
            pipe != program.id,
            !exceptions.contains(pipe),
            let otherProgram = village[pipe]
        else {
            continue
        }

        let otherMinID = findMinID(in: village, for: otherProgram, except: exceptions)
        minID = min(minID, otherMinID)
    }
    
    return minID
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)
let programs = file.split(separator: "\n").map { Program(String($0))! }
let village = Dictionary(uniqueKeysWithValues: programs.enumerated().map({ ($0, $1) }))

let filtered = programs.filter { findMinID(in: village, for: $0) == 0 }
assert(filtered.count == 283)

let minIDs = Set(programs.map { findMinID(in: village, for: $0) })
assert(minIDs.count == 195)

