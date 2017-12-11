//: Playground - noun: a place where people can play

import Cocoa

extension CGPoint {
    mutating func offset(by offset: CGSize) {
        self.x += offset.width
        self.y += offset.height
    }
}

enum Direction: Substring, CustomDebugStringConvertible {
    static var all: [Direction] {
        return [.north, .northWest, .northEast, .south, .southWest, .southEast]
    }
    
    case north = "n"
    case northWest = "nw"
    case northEast = "ne"
    
    case south = "s"
    case southWest = "sw"
    case southEast = "se"
    
    var offset: CGSize {
        switch self {
        case .north:
            return CGSize(width: 0, height: 1)
        case .northWest:
            return CGSize(width: -1, height: 1)
        case .northEast:
            return CGSize(width: 1, height: 0)
        case .south:
            return CGSize(width: 0, height: -1)
        case .southWest:
            return CGSize(width: -1, height: 0)
        case .southEast:
            return CGSize(width: 1, height: -1)
        }
    }
    
    static func forOffset(byX x: CGFloat, y: CGFloat) -> Direction {
        switch (x, y) {
        case (0, 1):
            return .north
        case (-1, 1):
            return .northWest
        case (1, 0):
            return .northEast
        case (0, -1):
            return .south
        case (-1, 0):
            return .southWest
        case (1, -1):
            return .southEast
        default:
            fatalError("Invalid Offset")
        }
    }
    
    var debugDescription: String {
        return String(self.rawValue)
    }
}

func parseDirections(_ string: String) -> [Direction] {
    return string.split(separator: ",").map { Direction(rawValue: $0)! }
}

func followDirections(_ directions: [Direction]) -> CGPoint {
    return directions.reduce(into: CGPoint.zero, { $0.offset(by: $1.offset) })
}

func shortestPath(from a: CGPoint, to b: CGPoint) -> [Direction] {
    var directions = [Direction]()
    var current = a
    
    while current != b {
        let direction: Direction
        
        if current.y != b.y {
            if current.y < b.y {
                 if current.x > b.x {
                    direction = Direction.forOffset(byX: -1, y: 1)
                } else {
                    direction = Direction.forOffset(byX: 0, y: 1)
                }
            } else {
                if current.x < b.x {
                    direction = Direction.forOffset(byX: 1, y: -1)
                } else {
                    direction = Direction.forOffset(byX: 0, y: -1)
                }
            }
        } else if current.x != b.x {
            if current.x < b.x {
                direction = Direction.forOffset(byX: 1, y: 0)
            } else {
                direction = Direction.forOffset(byX: -1, y: 0)
            }
        } else {
            fatalError()
        }
        
        directions.append(direction)
        current.offset(by: direction.offset)
    }
    
    return directions
}

func longestPath(from root: CGPoint, following directions: [Direction]) -> [Direction] {
    var location = root
    var longest = [Direction]()
    for offset in directions.map({ $0.offset }) {
        location.offset(by: offset)
        let path = shortestPath(from: root, to: location)
        if path.count > longest.count {
            longest = path
        }
    }
    
    return longest
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath).trimmingCharacters(in: .newlines)
let directions = parseDirections(file)

let destination = followDirections(directions)
let shortest = shortestPath(from: .zero, to: destination)
assert(shortest.count == 664)

let longest = longestPath(from: .zero, following: directions)
assert(longest.count == 1447)
