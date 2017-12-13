//: Playground - noun: a place where people can play

import Cocoa

protocol Copying {
    func copy() -> Self
}

extension Dictionary where Value: Copying {
    func deepCopy() -> [Key: Value] {
        return self.mapValues { $0.copy() }
    }
}

final class Layer: Copying {
    let depth: Int
    let range: Int
    
    private(set) var scannerPosition: Int = 0
    private var currentScanDirection = 1
    
    init?(_ string: Substring) {
        let components = string.split(separator: ":")
        guard
            components.count == 2,
            let depth = Int(components[0]),
            let range = Int(components[1].trimmingCharacters(in: .whitespaces))
        else {
            return nil
        }
        
        self.depth = depth
        self.range = range
    }
    
    private init(depth: Int, range: Int, scannerPosition: Int, currentScanDirection: Int) {
        self.depth = depth
        self.range = range
        self.scannerPosition = scannerPosition
        self.currentScanDirection = currentScanDirection
    }
    
    func moveScannerForward() {
        switch self.scannerPosition {
        case self.range-1:
            self.currentScanDirection = -1
        case 0:
            self.currentScanDirection = 1
        default:
            break
        }
        self.scannerPosition += self.currentScanDirection
    }
    
    func copy() -> Layer {
        return Layer(depth: self.depth,
                     range: self.range,
                     scannerPosition: self.scannerPosition,
                     currentScanDirection: self.currentScanDirection)
    }
}

func severity(of firewall: [Int: Layer], layers: [Layer]) -> Int {
    var severity = 0
    for i in 0...layers.last!.depth {
        if let layer = firewall[i], layer.scannerPosition == 0 {
            severity += layer.depth*layer.range
        }
        
        for layer in layers {
            layer.moveScannerForward()
        }
    }
    
    return severity
}

func optimalDelay(`for` firewall: [Int: Layer], layers: [Layer]) -> Int {
    var delay = 0
    var wasCaught = false
    repeat {
        wasCaught = false
        let firewallCopy = firewall.deepCopy()
        for i in 0...layers.last!.depth {
            if let layer = firewallCopy[i], layer.scannerPosition == 0 {
                wasCaught = true
            }
            for (_, layer) in firewallCopy {
                layer.moveScannerForward()
            }
        }
        
        for layer in layers {
            layer.moveScannerForward()
        }

        print(delay)
        delay += 1
    } while wasCaught

    return (delay-1)
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)
let layers = file.split(separator: "\n").map { Layer($0)! }
let firewall = Dictionary(uniqueKeysWithValues: layers.map { ($0.depth, $0) })

assert(severity(of: firewall, layers: layers) == 2384)
//assert(optimalDelay(for: firewall, layers: layers) == 3921270)

