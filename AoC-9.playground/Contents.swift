//: Playground - noun: a place where people can play

import Foundation

// - Extensions

extension Scanner {
    var index: String.Index {
        return self.string.index(with: self.scanLocation)
    }
    
    var currentChar: Character {
        return self.string[self.index]
    }
    
    func advanceLocation() {
        self.scanLocation += 1
    }
}

extension String {
    func index(with integer: Int) -> Index {
        return self.index(self.startIndex, offsetBy: integer)
    }
    
    subscript(idx: Int) -> Character {
        return self[self.index(with: idx)]
    }
}

// - Model

enum Element: Equatable, CustomDebugStringConvertible {
    case garbage(String)
    case group([Element])
    
    var debugDescription: String {
        switch self {
        case let .garbage(string):
            return "<\(string)>"
        case let .group(elements):
            let elementsDesc = elements.map({ $0.debugDescription }).joined(separator: ",")
            return "{\(elementsDesc)}"
        }
    }
    
    var score: Int {
        switch self {
        case .garbage(_):
            return 0
        case .group(_):
            return self.score(adding: 1)
        }
    }
    
    private func score(adding base: Int) -> Int {
        guard case let .group(elements) = self else {
            return 0
        }
        return elements.reduce(base) {
            $0 + $1.score(adding: base+1)
        }
    }
    
    var numberOfCharacters: Int {
        switch self {
        case let .garbage(string):
            return string.count
        case let .group(elements):
            return elements.reduce(0, { $0 + $1.numberOfCharacters })
        }
    }
}

func ==(lhs: Element, rhs: Element) -> Bool {
    switch lhs {
    case let .garbage(string):
        guard case let .garbage(other) = rhs else { return false }
        return (string == other)
    case let .group(group):
        guard case let .group(other) = rhs else { return false }
        return (group == other)
    }
}

enum Identifier: Character {
    case groupOpen = "{"
    case groupClose = "}"
    case garbageOpen = "<"
    case garbageClose = ">"
    case ignoreNext = "!"
    case comma = ","
    
    var isRelevantInGarbage: Bool {
        return (self == .garbageClose)
    }
}

enum ParserError: Error {
    case invalidCharacter(Character, String.Index)
    case unknown
}

// - Parser

func parse(_ input: String) throws -> Element {
    let scanner = Scanner(string: input)
    guard let element = try parseNextElement(scanner) else {
        throw ParserError.unknown
    }
    
    return element
}

func parseNextElement(_ scanner: Scanner) throws -> Element? {
    var currentElement: Element? = nil
    var lastIdentifier: Identifier? = nil
    
    while !scanner.isAtEnd {
        if let element = currentElement, case let .group(group) = element {
            if let nextElement = try parseNextElement(scanner) {
                currentElement = .group(group + [nextElement])
            } else {
                return currentElement
            }
        }
        
        guard !scanner.isAtEnd else { break } // we might have entered another loop
        
        let char = scanner.currentChar
        let identifier = Identifier(rawValue: char)
        
        if
            let element = currentElement,
            case let .garbage(string) = element,
            (
                identifier == nil ||
                identifier == .ignoreNext ||
                lastIdentifier == .ignoreNext ||
                identifier?.isRelevantInGarbage == false
            )
        {
            if lastIdentifier != .ignoreNext && identifier != .ignoreNext {
                currentElement = .garbage(string + String(char))
            }
            
            scanner.advanceLocation()
            
            if identifier == .ignoreNext && lastIdentifier == .ignoreNext {
                // if the id ignores the next BUT is itself being ignored,
                // ignore the current identifier and cotninue
                lastIdentifier = nil
                continue
            }
        } else if let id = identifier {
            switch id {
            case .groupOpen:
                currentElement = .group([])
                scanner.advanceLocation()
            case .garbageOpen:
                currentElement = .garbage("")
                scanner.advanceLocation()
            case .groupClose, .garbageClose:
                scanner.advanceLocation()
                return currentElement
            case .comma:
                scanner.advanceLocation()
            default:
                scanner.advanceLocation()
            }
        }
        
        lastIdentifier = identifier
    }
    
    return currentElement
}

// - Tests

func assertParseInput(input: String, result: Element) {
    do {
        let element = try parse(input)
        assert(element == result)
    } catch {
        assertionFailure("\(error)")
    }
}

func assertScore(input: String, result: Int) {
    do {
        let element = try parse(input)
        let score = element.score
        assert(score == result)
    } catch {
        assertionFailure("\(error)")
    }
}

func assertCharacterCount(input: String, result: Int) {
    do {
        let element = try parse(input)
        assert(element.numberOfCharacters == result)
    } catch {
        assertionFailure("\(error)")
    }
}

//assertParseInput(input: "{}", result: .group([]))
//assertParseInput(input: "{{{}}}", result: .group([.group([.group([])])]))
//assertParseInput(input: "{{},{}}", result: .group([.group([]), .group([])]))
//assertParseInput(input: "{{{},{},{{}}}}", result: .group([.group([.group([]), .group([]), .group([.group([])])])]))
//assertParseInput(input: "{<a>,<a>,<a>,<a>}", result: .group([.garbage("a"), .garbage("a"), .garbage("a"), .garbage("a")]))
//assertParseInput(input: "{{<a>},{<a>},{<a>},{<a>}}", result: .group([.group([.garbage("a")]), .group([.garbage("a")]), .group([.garbage("a")]), .group([.garbage("a")])]))
//assertParseInput(input: "{{<!>},{<!>},{<!>},{<a>}}", result: .group([.group([.garbage("},{<},{<},{<a")])]))
//assertParseInput(input: "{{<!!>},{<!!>},{<!!>},{<!!>}}", result: .group([.group([.garbage("")]), .group([.garbage("")]), .group([.garbage("")]), .group([.garbage("")])]))
//assertParseInput(input: "{{<a!>},{<a!>},{<a!>},{<ab>}}", result: .group([.group([.garbage("a},{<a},{<a},{<ab")])]))
//
//assertParseInput(input: "<>", result: .garbage(""))
//assertParseInput(input: "<random characters>", result: .garbage("random characters"))
//assertParseInput(input: "<<<<>", result: .garbage("<<<"))
//assertParseInput(input: "<{!>}>", result: .garbage("{}"))
//assertParseInput(input: "<!!>", result: .garbage(""))
//assertParseInput(input: "<!!!>>", result: .garbage(""))
//assertParseInput(input: "<{o\"i!a,<{i<a>", result: .garbage("{o\"i,<{i<a"))
//
//assertScore(input: "{}", result: 1)
//assertScore(input: "{{{}}}", result: 6)
//assertScore(input: "{{},{}}", result: 5)
//assertScore(input: "{{{},{},{{}}}}", result: 16)
//assertScore(input: "{<a>,<a>,<a>,<a>}", result: 1)
//assertScore(input: "{{<ab>},{<ab>},{<ab>},{<ab>}}", result: 9)
//assertScore(input: "{{<!!>},{<!!>},{<!!>},{<!!>}}", result: 9)
//assertScore(input: "{{<a!>},{<a!>},{<a!>},{<ab>}}", result: 3)

//assertCharacterCount(input: "<>", result: 0)
//assertCharacterCount(input: "<random characters>", result: 17)
//assertCharacterCount(input: "<<<<>", result: 3)
//assertCharacterCount(input: "<{!>}>", result: 2)
//assertCharacterCount(input: "<!!>", result: 0)
//assertCharacterCount(input: "<!!!>>", result: 0)
//assertCharacterCount(input: "<{o\"i!a,<{i<a>", result: 10)

// - Challenge

let filePath = Bundle.main.path(forResource: "input", ofType: "txt")!
let input = try! String(contentsOfFile: filePath)
let group = try! parse(input)

assert(group.score == 17390)
assert(group.numberOfCharacters == 7825)
