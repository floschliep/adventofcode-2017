//: Playground - noun: a place where people can play

import Cocoa

struct Point {
    var x: Int
    var y: Int
}

extension Point: Equatable { }

func ==(lhs: Point, rhs: Point) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

func manhattan(a: Point, b: Point) -> Int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

func location(of number: Int) -> Point {
    var requiredMovements = 1
    
    var currentMovementX = 0
    var currentMovementY = 0
    var currentStep = 1
    
    var currentLocation = Point(x: 0, y: 0)
    
    for _ in 1..<number {
        if currentMovementX < requiredMovements {
            currentMovementX += 1
            currentLocation.x += currentStep
            continue
        }
        
        if currentMovementY < requiredMovements {
            currentMovementY += 1
            currentLocation.y += currentStep
        }
        
        if currentMovementY == requiredMovements {
            requiredMovements += 1
            currentStep *= -1
            currentMovementX = 0
            currentMovementY = 0
        }
    }
    
    return currentLocation
}

func number(at dest: Point) -> Int {
    var number = 1
    var currentLocation = Point(x: 0, y: 0)
    
    while currentLocation != dest {
        number += 1
        currentLocation = location(of: number)
    }
    
    return number
}

func neighbors(of locationNumber: Int) -> [Int] {
    let centerLocation = location(of: locationNumber)
    var neighbors = [Int]()
    
    // right
    let rightNeighbor = number(at: Point(x: centerLocation.x+1, y: centerLocation.y))
    if rightNeighbor < locationNumber {
        neighbors.append(rightNeighbor)
    }
    
    // top right
    let topRightNeighbor = number(at: Point(x: centerLocation.x+1, y: centerLocation.y+1))
    if topRightNeighbor < locationNumber {
        neighbors.append(topRightNeighbor)
    }
    
    // top
    let topNeighbor = number(at: Point(x: centerLocation.x, y: centerLocation.y+1))
    if topNeighbor < locationNumber {
        neighbors.append(topNeighbor)
    }
    
    // top left
    let topLeftNeighbor = number(at: Point(x: centerLocation.x-1, y: centerLocation.y+1))
    if topLeftNeighbor < locationNumber {
        neighbors.append(topLeftNeighbor)
    }
    
    // left
    let leftNeighbor = number(at: Point(x: centerLocation.x-1, y: centerLocation.y))
    if leftNeighbor < locationNumber {
        neighbors.append(leftNeighbor)
    }
    
    // bottom left
    let bottomLeftNeighbor = number(at: Point(x: centerLocation.x-1, y: centerLocation.y-1))
    if bottomLeftNeighbor < locationNumber {
        neighbors.append(bottomLeftNeighbor)
    }
    
    // bottom
    let bottomNeighbor = number(at: Point(x: centerLocation.x, y: centerLocation.y-1))
    if bottomNeighbor < locationNumber {
        neighbors.append(bottomNeighbor)
    }
    
    // bottom right
    let bottomRightNeighbor = number(at: Point(x: centerLocation.x+1, y: centerLocation.y-1))
    if bottomRightNeighbor < locationNumber {
        neighbors.append(bottomRightNeighbor)
    }

    return neighbors
}

func value(at locationNumber: Int) -> Int {
    let neighborsNumbers = neighbors(of: locationNumber)
    
    var locationValue = 0
    for n in neighborsNumbers {
        locationValue += value(at: n)
    }
    
    switch locationNumber {
    case 0:
        locationValue = 1
    case 1:
        locationValue = 1
    default:
        break
    }
    
    return locationValue
}

var x = 1
while true {
    print("testing \(x)")
    let val = value(at: x)
    if val > 368078 {
        print(val)
        break
    }
    
    x += 1
}

//print(valueStored(in: 1))
//print(valueStored(in: 2))
//print(valueStored(in: 3))
//print(valueStored(in: 4))
//print(valueStored(in: 5))


