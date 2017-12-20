//: Playground - noun: a place where people can play

import Cocoa

struct VectorString {
    let name: String
    let x: Int
    let y: Int
    let z: Int
    
    init?(_ string: String) {
        let components = string.split(separator: "=")
        guard components.count == 2 else {
            return nil
        }
        
        self.name = String(components[0])
        
        let coordinateComponent = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        let coordinateStrings = coordinateComponent.split(separator: ",")
        guard
            coordinateStrings.count == 3,
            let x = Int(coordinateStrings[0]),
            let y = Int(coordinateStrings[1]),
            let z = Int(coordinateStrings[2])
        else {
            print("v \(coordinateComponent)")
            return nil
        }
        
        self.x = x
        self.y = y
        self.z = z
    }
}

struct Vector: Equatable, CustomDebugStringConvertible {
    var x: Int
    var y: Int
    var z: Int
    
    static var zero: Vector {
        return Vector(x: 0, y: 0, z: 0)
    }
    
    init(_ string: VectorString) {
        self.x = string.x
        self.y = string.y
        self.z = string.z
    }
    
    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func distance(to other: Vector) -> Int {
        let xDist = abs(self.x - other.x)
        let yDist = abs(self.y - other.y)
        let zDist = abs(self.z - other.z)
        return xDist + yDist + zDist
    }
    
    var debugDescription: String {
        return "(\(self.x), \(self.y), \(self.z))"
    }
}

func ==(lhs: Vector, rhs: Vector) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z)
}

struct Particle {
    var position: Vector
    var velocity: Vector
    let acceleration: Vector
    
    init?(_ string: Substring) {
        let components = string
            .components(separatedBy: ", ") // that's cheap, I know
            .map({ VectorString($0)! })
        guard
            components.count == 3,
            components[0].name == "p",
            components[1].name == "v",
            components[2].name == "a"
        else {
            print("par \(components)")
            return nil
        }
        
        self.position = Vector(components[0])
        self.velocity = Vector(components[1])
        self.acceleration = Vector(components[2])
    }
    
    mutating func tick() {
        self.velocity.x += self.acceleration.x
        self.velocity.y += self.acceleration.y
        self.velocity.z += self.acceleration.z
        
        self.position.x += self.velocity.x
        self.position.y += self.velocity.y
        self.position.z += self.velocity.z
    }
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)
var particles = file.split(separator: "\n").map { Particle($0)! }

// Part 1
var cumulativeDistances = Array(repeating: 0, count: particles.count)
let ticks = particles.count

for _ in 0..<ticks {
    for idx in 0..<particles.count {
        particles[idx].tick()
        cumulativeDistances[idx] += particles[idx].position.distance(to: .zero)
    }
}

let minDistance = cumulativeDistances.enumerated().min(by: { $0.1 < $1.1 })!
assert(minDistance.offset == 364)

// Part 2

//var detectedCollision = false
//var ticks = 0
//
//repeat {
//    for idx in 0..<particles.count {
//        particles[idx].tick()
//    }
//
//    var indexesToKeep = Set<Int>()
//    for (idx, particle) in particles.enumerated() {
//        let duplicates = particles.filter { $0.position == particle.position }
//        if duplicates.count == 1 { // 1 "duplicate" = this particle
//            indexesToKeep.insert(idx)
//        }
//    }
//
//    let newParticles = indexesToKeep.map { particles[$0] }
//    if newParticles.count != particles.count {
//        detectedCollision = true
//        particles = newParticles
//    } else {
//        detectedCollision = false
//    }
//
//    ticks += 1
//} while detectedCollision || ticks < particles.count
//
//assert(particles.count == 420)

