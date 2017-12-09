//: Playground - noun: a place where people can play

import Cocoa

// - Model

class Tree<T: Equatable>: CustomDebugStringConvertible {
    let value: T
    let valueWeight: Int
    
    var children: [Tree<T>]
    var weight: Int {
        return self.children.reduce(self.valueWeight, { $0 + $1.weight })
    }
    
    init(value: T, valueWeight: Int, children: [Tree<T>]) {
        self.value = value
        self.valueWeight = valueWeight
        self.children = children
    }
    
    func findParent(of value: T) -> Tree<T>? {
        if self.children.contains(where: { $0.value == value }) {
            return self
        }
        
        return self.children.flatMap({ $0.findParent(of: value) }).first
    }
    
    func find(with value: T) -> Tree<T>? {
        if self.value == value {
            return self
        }
        
        return self.children.first(where: { $0.find(with: value) != nil })
    }
    
    var heaviestChild: Tree<T>? {
        let sortedChildren = self.children.sorted(by: { $0.weight > $1.weight })
        guard sortedChildren.count > 1 else { return nil }
        if sortedChildren[0].weight == sortedChildren[1].weight {
            return nil
        } else {
            return sortedChildren[0]
        }
    }
    
    var debugDescription: String {
        return "\(self.value) (\(self.weight)): \(self.children)"
    }
}

struct Program: CustomDebugStringConvertible {
    let name: String
    let weight: Int
    let parents: [String]
    
    init?(_ line: Substring) {
        let components = line.split(separator: " ", maxSplits: 2)
        guard components.count >= 2 else { return nil }
        
        self.name = String(components[0])
        self.weight = Int(components[1].trimmingCharacters(in: CharacterSet(charactersIn: "()")))!
        
        if components.count < 3 {
            self.parents = []
        } else {
            self.parents = components[2]
                .trimmingCharacters(in: CharacterSet(charactersIn: " ->"))
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        }
    }
    
    var debugDescription: String {
        return "\(self.name) (\(self.weight)) \(self.parents)"
    }
}

// - Input

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let file = try! String(contentsOfFile: filePath)
let programs = file.split(separator: "\n").map { Program($0)! }
var trees = [Tree<String>]()

for program in programs {
    // find parent for current program
    // if the program doesn't have a parent, skip
    guard let parent = programs.first(where: { $0.parents.contains(program.name) }) else {
        continue
    }
    
    let currentTree: Tree<String>
    if let existing = trees.enumerated().first(where: { $1.value == program.name }) {
        trees.remove(at: existing.offset)
        currentTree = existing.element
    } else {
        currentTree = Tree(value: program.name, valueWeight: program.weight, children: [])
    }
    
    if let top = trees.flatMap({ $0.find(with: parent.name) }).first {
        var parentTree = top
        // terrible
        while parentTree.value != parent.name {
            parentTree = parentTree.find(with: parent.name)!
        }
        parentTree.children.append(currentTree)
    } else {
        let parentTree = Tree(value: parent.name, valueWeight: parent.weight, children: [currentTree])
        trees.append(parentTree)
    }
}

assert(trees.count == 1)
let tree = trees[0]
assert(tree.value == "xegshds")

var heaviest = tree
while let child = heaviest.heaviestChild {
    heaviest = child
}

let parent = tree.findParent(of: heaviest.value)!
let other = parent.children.first(where: { $0.value != heaviest.value })!
let newHeaviestWeight = heaviest.valueWeight - (heaviest.weight - other.weight)

assert(newHeaviestWeight == 299)
