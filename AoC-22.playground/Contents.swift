//: Playground - noun: a place where people can play

import Cocoa

enum Node: Character {
    case clean = "."
    case infected = "#"
    case weakened = "W"
    case flagged = "F"
}

enum Direction {
    case up
    case down
    case left
    case right
    
    var turnedLeft: Direction {
        switch self {
        case .up:
            return .left
        case .down:
            return .right
        case .left:
            return .down
        case .right:
            return .up
        }
    }
    
    var turnedRight: Direction {
        switch self {
        case .up:
            return .right
        case .down:
            return .left
        case .left:
            return .up
        case .right:
            return .down
        }
    }
    
    var reversed: Direction {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}

struct Position {
    static var root: Position {
        return Position(row: 0, column: 0)
    }
    
    var row: Int
    var column: Int
    
    mutating func move(`in` direction: Direction) {
        switch direction {
        case .up:
            self.row -= 1
        case .down:
            self.row += 1
        case .left:
            self.column -= 1
        case .right:
            self.column += 1
        }
    }
}

/*
          -row
 
          ..#
 -column  #..  +column
          ...
 
          +row
 
 */

struct Grid {
    private var rows: [Int: [Int: Node]]
    
    init(contents: String) {
        let lines = contents.split(separator: "\n")
        let numberOfColumns = lines[0].count
        let numberOfRows = lines.count
        
        guard numberOfColumns == numberOfRows, numberOfColumns%2 != 0 else { preconditionFailure() }
        
        var column = -numberOfColumns/2
        var row = -numberOfRows/2
        var rows = [Int: [Int: Node]]()
        
        for line in lines {
            for char in line {
                guard let node = Node(rawValue: char) else { preconditionFailure() }
                
                var currentRow: [Int: Node]
                if let existing = rows[row] {
                    currentRow = existing
                } else {
                    currentRow = [Int: Node]()
                }
                
                currentRow[column] = node
                rows[row] = currentRow
                
                column += 1
            }
            column = -numberOfRows/2
            row += 1
        }
        
        self.rows = rows
    }
    
    subscript(position: Position) -> Node {
        get {
            return self.node(at: position)
        }
        set {
            self.set(node: newValue, at: position)
        }
    }
    
    func node(at position: Position) -> Node {
        guard let row = self.rows[position.row] else { return .clean }
        return row[position.column] ?? .clean
    }
    
    mutating func set(node: Node, at position: Position) {
        if var row = self.rows[position.row] {
            row[position.column] = node
            self.rows[position.row] = row
        } else {
            self.rows[position.row] = [position.column: node]
        }
    }
    
    var stringRep: String {
        var string = ""
        for row in self.rows.sorted(by: { $0.0 < $1.0 }) {
            for column in row.value.sorted(by: { $0.0 < $1.0 }) {
                string += "\(column.value.rawValue)"
            }
            string += "\n"
        }
        
        return string
    }
    
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)

var grid = Grid(contents: file)
var direction = Direction.up
var position = Position.root
let bursts = 10_000_000
var infectionsCount = 0

for _ in 0..<bursts {
    switch grid[position] {
    case .infected:
        direction = direction.turnedRight
        grid[position] = .flagged
    case .flagged:
        direction = direction.reversed
        grid[position] = .clean
    case .clean:
        direction = direction.turnedLeft
        grid[position] = .weakened
    case .weakened:
        grid[position] = .infected
        infectionsCount += 1
    }
    position.move(in: direction)
}

assert(infectionsCount == 2512022)
