//: Playground - noun: a place where people can play

import Cocoa

extension String {
    func leftPad(with char: Character, length: Int) -> String {
        guard self.count < length else { return self }
        let diff = length - self.count
        
        return String(Array(repeating: char, count: diff)) + self
    }
    
    var hexBinaryRep: String {
        let hex = self.map { UInt8(String($0), radix: 16)! }
        return hex.reduce("", { $0 + String($1, radix: 2).leftPad(with: "0", length: 4) })
    }
}

func knotHash(_ input: String, rounds: Int = 64) -> String {
    let ascii = input.flatMap { $0.unicodeScalars.map({ Int($0.value) }) }
    let inputLengths = ascii + [17, 31, 73, 47, 23]
    
    var list = (0..<256).map { $0 }
    
    var position = 0
    var skipSize = 0
    
    for _ in 0..<rounds {
        for rangeLength in inputLengths {
            guard rangeLength <= list.count else { fatalError("Invalid Length \(rangeLength)") }
            
            // wrap position if needed
            if position > list.count-1 {
                position = position.remainderReportingOverflow(dividingBy: list.count).0
            }
            
            if rangeLength > 1 {
                var ranges = [ClosedRange<Int>]()
                // determine range(s) to reverse
                let endIndex = position + rangeLength - 1
                if endIndex > list.count-1 {
                    var i = position
                    for _ in position...endIndex {
                        if i >= list.count-1 {
                            ranges.append((position...i))
                            i = 0
                        } else {
                            i += 1
                        }
                    }
                    ranges.append((0...i-1))
                } else {
                    ranges.append((position...endIndex))
                }
                
                // get numbers in ranges; flatten and reverse them
                let slice: [Int] = ranges.flatMap({ list[$0] }).reversed()
                // replace numbers in list with numbers in slice
                var sliceIndex = 0
                for range in ranges {
                    for listIndex in CountableRange(range) {
                        list[listIndex] = slice[sliceIndex]
                        sliceIndex += 1
                    }
                }
            }
            
            // move to next position and update skip size
            position += rangeLength + skipSize
            skipSize += 1
        }
    }
    
    let blocks = (0..<16).map { list[(16*$0..<16*$0+16)] }
    let hashes = blocks.map { $0.reduce(0, ^) }
    let hex = hashes
        .map({ String(format: "%02X", $0).trimmingCharacters(in: .whitespaces) })
        .reduce("", +)
        .lowercased()

    return hex
}

extension Array {
    func appending(_ other: [Element]) -> [Element] {
        var copy = self
        copy.append(contentsOf: other)
        
        return copy
    }
}

class Square: CustomDebugStringConvertible {
    let value: Character
    let indexPath: IndexPath
    
    init(value: Character, indexPath: IndexPath) {
        self.value = value
        self.indexPath = indexPath
    }
    
    var debugDescription: String {
        return "\(self.value) at (\(self.indexPath.row), \(self.indexPath.column))"
    }
}

struct IndexPath {
    let row: Int
    let column: Int
}

class Grid {
    private var rows: [[Square]] = []
    
    func insert(_ square: Square) {
        let indexPath = square.indexPath
        if indexPath.row > self.rows.count-1 {
            self.rows.append([square])
        } else {
            self.rows[indexPath.row].insert(square, at: indexPath.column)
        }
    }
    
    func square(at indexPath: IndexPath) -> Square? {
        guard indexPath.row >= 0 && indexPath.column >= 0 else { return nil }
        guard indexPath.row <= self.rows.count-1 else { return nil }
        let row = self.rows[indexPath.row]
        guard indexPath.column <= row.count-1 else { return nil }
        
        return row[indexPath.column]
    }
    
    var groups: [[Square]] {
        var groups = [[Square]]()
        for row in self.rows {
            for square in row {
                guard square.value == "1" else { continue }
                // make sure square isn't in a group already
                guard !groups.contains(where: { $0.contains(where: { $0 === square }) }) else { continue }
                let group = self.findGroup(of: square, excluding: [square])
                groups.append(group)
            }
        }
        
        return groups
    }
    
    private func findGroup(of square: Square, excluding: [Square]) -> [Square] {
        let adjacentIndexPaths = self.adjacentIndexPaths(for: square.indexPath)
        var adjacentSquares = [Square]()
        for indexPath in adjacentIndexPaths {
            guard let otherSquare = self.square(at: indexPath) else { continue }
            guard otherSquare.value == "1" else { continue }
            guard !excluding.contains(where: { $0 === otherSquare }) else { continue }
            adjacentSquares.append(otherSquare)
        }
        
        var newExcludes = excluding.appending(adjacentSquares)
        var group = [square]
        for otherSquare in adjacentSquares {
            let otherGroup = self.findGroup(of: otherSquare, excluding: newExcludes)
            newExcludes.append(contentsOf: otherGroup)
            group.append(contentsOf: otherGroup)
        }
        
        return group
    }
    
    private func adjacentIndexPaths(`for` root: IndexPath) -> [IndexPath] {
        return [
            IndexPath(row: root.row-1, column: root.column), // top
            IndexPath(row: root.row+1, column: root.column), // bottom
            IndexPath(row: root.row, column: root.column-1), // left
            IndexPath(row: root.row, column: root.column+1), // right
        ]
    }
    
}

let rows = (0..<128).map { "ugkiagan-\($0)" }
let hashedRows = rows.map { knotHash($0) }
let binaryRows = hashedRows.map { $0.hexBinaryRep }
//let usedSquareCount = binaryRows.reduce(0, { $0 + ($1.filter({ $0 == "1" }) as [Character]).count })
//assert(usedSquareCount == 8292)

let grid = Grid()
for (rowIdx, row) in binaryRows.enumerated() {
    for (column, char) in row.enumerated() {
        grid.insert(Square(value: char, indexPath: IndexPath(row: rowIdx, column: column)))
    }
}

assert(grid.groups.count == 1069)
