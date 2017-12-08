//: Playground - noun: a place where people can play

import Cocoa

let spreadsheet = try! String(contentsOfFile: "/Users/florianschliep/Desktop/spreadsheet.txt")

let lines = spreadsheet.split(separator: "\n")

let numCharSet = CharacterSet(charactersIn: "1234567890")
let rows = lines.map { line -> [Int] in
    let line = String(line)
    let nsLine = line as NSString
    let scanner = Scanner(string: line)
    var column = [Int]()

    while scanner.isAtEnd == false {
        var numString: NSString?
        scanner.scanCharacters(from: numCharSet, into: &numString)
        guard let string = numString else { continue }
        column.append(Int(string as String)!)
    }

    return column
}

let checksums = rows.reduce(into: [Int]()) { sums, row in
    var divider = 0
    var divisor = 0
    for (idx, x) in row.enumerated().dropLast() {
        for yIdx in idx+1..<row.count {
            let y = row[yIdx]
            let tempDivider = max(x, y)
            let tempDivisor = min(x, y)
            if tempDivider.remainderReportingOverflow(dividingBy: tempDivisor).partialValue == 0 {
                divider = tempDivider
                divisor = tempDivisor
            }
        }
    }
    
    if divider != 0 && divisor != 0 {
        print("\(divider)/\(divisor)")
        sums.append(divider/divisor)
    }
}

let sum = checksums.reduce(0, +) // 74322 too high


