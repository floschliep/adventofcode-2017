//: Playground - noun: a place where people can play

import Cocoa

extension Array {
    func removing(at index: Int) -> [Element] {
        var copy = self
        copy.remove(at: index)
        
        return copy
    }
}

struct Port: CustomDebugStringConvertible {
    let pins: Int
    var used: Bool

    var debugDescription: String {
        return self.pins.description
    }
}

struct Component: CustomDebugStringConvertible {
    private(set) var inPort: Port
    private(set) var outPort: Port
    
    init?(_ string: Substring) {
        let stringComponents = string.split(separator: "/") as [Substring]
        guard
            stringComponents.count == 2,
            let inPins = Int(String(stringComponents[0])),
            let outPins = Int(String(stringComponents[1]))
        else {
            return nil
        }
        self.inPort = Port(pins: inPins, used: false)
        self.outPort = Port(pins: outPins, used: false)
    }
    
    mutating func bridge(to pins: Int) -> Bool {
        if !self.inPort.used && self.inPort.pins == pins {
            self.inPort.used = true
            return true
        }
        if !self.outPort.used && self.outPort.pins == pins {
            self.outPort.used = true
            return true
        }
        
        return false
    }
    
    mutating func bridge(to component: inout Component) -> Bool {
        if !component.inPort.used && self.bridge(to: component.inPort.pins) {
            component.inPort.used = true
            return true
        }
        if !component.outPort.used && self.bridge(to: component.outPort.pins) {
            component.outPort.used = true
            return true
        }
        
        return false
    }
    
    var debugDescription: String {
        return "\(self.inPort)/\(self.outPort)"
    }
}

typealias Bridge = [Component]

func findBridges(withStart startComponent: Component, components: [Component]) -> [Bridge] {
    var paths = [Bridge]()
    let bridges = components.enumerated().flatMap { (offset, element) -> (Int, Component, Component)? in
        var copy = element
        var start = startComponent
        if copy.bridge(to: &start) {
            return (offset, start, copy)
        }
        
        return nil
    }
    if bridges.count == 0 {
        return [[startComponent]]
    } else {
        for (idx, start, component) in bridges {
            let subPaths = findBridges(withStart: component, components: components.removing(at: idx))
            for path in subPaths {
                paths.append([start] + path)
            }
        }
    }
    
    return paths
}

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)

let components = file.split(separator: "\n").map { Component($0)! }
let zeroPinComponents = components.enumerated().flatMap { (index, component) -> (Int, Component)? in
    var copy = component
    if copy.bridge(to: 0) {
        return (index, copy)
    }
    
    return nil
}

var bridges = [Bridge]()
for (index, start) in zeroPinComponents {
    bridges.append(contentsOf: findBridges(withStart: start, components: components.removing(at: index)))
}

// Part 1
//let strengths = bridges.map { $0.reduce(0, { $0 + $1.inPort.pins + $1.outPort.pins }) }
//assert(strengths.max() == 1859)

// Part 2
let maxLength = bridges.max(by: { $0.count < $1.count })!.count
let maxLengthBridges = bridges.filter { $0.count == maxLength }
let maxLengthStrengths = maxLengthBridges.map { $0.reduce(0, { $0 + $1.inPort.pins + $1.outPort.pins }) }
assert(maxLengthStrengths.max() == 1799)
