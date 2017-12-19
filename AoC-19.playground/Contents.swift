//: Playground - noun: a place where people can play

import Cocoa

extension String {
    subscript (i: Int) -> Character {
        get {
            return self[index(self.startIndex, offsetBy: i)]
        }
    }
}

enum Direction {
    case left
    case right
    case up
    case down
    
    static var all: [Direction] {
        return [.left, .right, .up, .down]
    }
}

struct IndexPath {
    var row: Int
    var column: Int
    
    mutating func move(`in` direction: Direction) {
        switch direction {
        case .left:
            self.column -= 1
        case .right:
            self.column += 1
        case .up:
            self.row -= 1
        case .down:
            self.row += 1
        }
    }
    
    func moved(`in` direction: Direction) -> IndexPath {
        var copy = self
        copy.move(in: direction)
        return copy
    }
}

enum LinePart: Character {
    case vertical = "|"
    case horizontal = "-"
    case crossing = "+"
}

extension Character {
    static let whitespace: Character = " "
}

struct Grid {
    private let lines: [String]
    
    init(string: String) {
        self.lines = string.components(separatedBy: .newlines)
    }
    
    var entryPoint: IndexPath? {
        guard let line = self.lines.first else { return nil }
        guard let column = line.index(of: LinePart.vertical.rawValue) else { return nil }
        
        return IndexPath(row: 0, column: column.encodedOffset)
    }
    
    func char(at indexPath: IndexPath) -> Character? {
        guard indexPath.row >= 0 && indexPath.column >= 0 else { return nil }
        guard self.lines.count-1 >= indexPath.row else { return nil }
        let line = self.lines[indexPath.row]
        guard line.count-1 >= indexPath.column else { return nil }
        
        return line[indexPath.column]
    }
    
    func followPath() -> (String, Int)? {
        guard let entryPoint = self.entryPoint else { return nil }
        
        var collectedChars = ""
        var position = entryPoint
        var direction = Direction.down
        var isAtEnd = false
        var steps = 0
        
        while !isAtEnd {
            position.move(in: direction)
            guard let char = self.char(at: position) else {
                isAtEnd = true
                break
            }
            
            if let linePart = LinePart(rawValue: char) {
                if linePart == .crossing {
                    if let new = Direction.all.first(where: {
                        self.canMove(in: $0, currentDirection: direction, currentPosition: position)
                    }) {
                        direction = new
                    }
                }
            } else if char != .whitespace {
                collectedChars.append(char)
            } else {
                isAtEnd = true
            }
            steps += 1
        }
        
        return (collectedChars, steps)
    }
    
    private func canMove(`in` direction: Direction, currentDirection: Direction, currentPosition: IndexPath) -> Bool {
        if direction == .left && currentDirection == .right {
            return false
        }
        if direction == .right && currentDirection == .left {
            return false
        }
        if direction == .up && currentDirection == .down {
            return false
        }
        if direction == .down && currentDirection == .up {
            return false
        }
        
        guard let char = self.char(at: currentPosition.moved(in: direction)) else { return false }
        
        if let linePart = LinePart(rawValue: char) {
            switch (direction, linePart) {
            case (.left, .horizontal):
                return true
            case (.right, .horizontal):
                return true
            case (.up, .vertical):
                return true
            case (.down, .vertical):
                return true
            default:
                return false
            }
        } else if char != .whitespace {
            return true
        } else {
            return false
        }
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)

let grid = Grid(string: file)
let (letters, steps) = grid.followPath()!
assert(letters == "ITSZCJNMUO")
assert(steps == 17420)
