//: Playground - noun: a place where people can play

import Cocoa

extension Array {
    var flipped: [Element] {
        guard self.count > 1 else { return self }
        var copy = self
        copy.swapAt(0, self.count-1)
        
        return copy
    }
}

struct IndexPath {
    let row: Int
    let column: Int
}

struct Pattern {
    private let base: Square
    
    init?(_ string: String) {
        self.base = Square(rows: string.components(separatedBy: "/"))
    }
    
    func matches(_ square: Square) -> Bool {
        guard square.size == self.base.size else { return false }
        
        let rotations = (square.size%2 == 0) ? 4 : 8
        let squareRows = square.rows
        var baseRows = base.rows.map { Array<Character>($0) }
        
        // with a little help from https://www.reddit.com/r/adventofcode/comments/7l8nze/2017_day_21_am_i_missing_something/drlgxqt/
        for _ in 0..<rotations {
            let rotatedRows = baseRows.map({ String($0) })
            if rotatedRows == squareRows || rotatedRows.flipped == squareRows {
                return true
            }
            
            let copy = baseRows
            for row in 0..<square.size {
                baseRows[row] = copy.map({ $0[row] }).reversed()
            }
        }
        
        return false
    }
}

struct Rule {
    let pattern: Pattern
    let replacement: Square
    
    init?(_ string: Substring) {
        let components = string.components(separatedBy: " => ")
        guard
            components.count == 2,
            let pattern = Pattern(components[0])
        else {
            return nil
        }
        self.pattern = pattern
        self.replacement = Square(rows: components[1].components(separatedBy: "/"))
    }
}

struct Square: CustomDebugStringConvertible {
    var rows: [String]
    
    var size: Int {
        return self.rows.count
    }
    
    var onPixelCount: Int {
        return self.rows.reduce(0, { $0 + ($1.filter({ $0 == "#" }) as [Character]).count })
    }
    
    var debugDescription: String {
        return self.rows.joined(separator: "\n")
    }
}

struct Grid: CustomDebugStringConvertible {
    var rows: [[Square]]
    
    init(rows: [[Square]]) {
        self.rows = rows
    }
    
    init(string: String) {
        let lines = string.split(separator: "\n")
        let squareSize = (lines.count%2 == 0) ? 2 : 3
        let size = lines.count/squareSize
        
        var rows = [[Square]]()
        for rowIdx in 0..<size {
            var row = [Square]()
            for column in 0..<size {
                var square = Square(rows: [])
                let lineIdx = rowIdx*squareSize
                for line in lineIdx..<lineIdx+squareSize {
                    let currentLine = lines[line]
                    let position = currentLine.index(currentLine.startIndex, offsetBy: column*squareSize)
                    let range = position..<currentLine.index(position, offsetBy: squareSize)
                    square.rows.append(String(currentLine[range]))
                }
                row.append(square)
            }
            rows.append(row)
        }
        
        self.rows = rows
    }
    
    var size: Int {
        return self.rows.count
    }
    
    var stringRepresentation: String {
        guard self.rows.count > 0 else { return "" }

        var string = ""
        let squareSize = self.rows[0][0].size
        let numberOfLines = self.size*squareSize

        for line in 0..<numberOfLines {
            let row = line/squareSize
            let squareRow = line%squareSize
            for column in 0..<self.size {
                string += self.rows[row][column].rows[squareRow]
            }
            string += "\n"
        }

        return string
    }
    
    var debugDescription: String {
        return self.rows.reduce("", { $0 + $1.debugDescription + "\n" })
    }
    
    var onPixelCount: Int {
        return self.rows.reduce(0, { $0 + $1.reduce(0, { $0 + $1.onPixelCount }) })
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)
let rules = file.split(separator: "\n").map { Rule($0)! }

let initialSquare = Square(rows: [".#.", "..#", "###"])
var grid = Grid(rows: [[initialSquare]])

for _ in 0..<5 {
    let dividedGrid = Grid(string: grid.stringRepresentation)
    var newRows = dividedGrid.rows
    for (rowIdx, row) in newRows.enumerated() {
        for (columnIdx, square) in row.enumerated() {
            guard let rule = rules.first(where: { $0.pattern.matches(square) }) else {
                fatalError("No rule for \(square)")
            }
            newRows[rowIdx][columnIdx] = rule.replacement
        }
    }
    grid = Grid(rows: newRows)
}

assert(grid.onPixelCount == 171)
//assert(grid.onPixelCount == 2498142) for 18 rotations
