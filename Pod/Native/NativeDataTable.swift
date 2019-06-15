//
//  DataTable.swift
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 02/09/2018.
//

import Foundation

extension String: Error {}

public struct NativeDataTable<T: Collection> {
    public let values: T

    public init?(fromMatch match: String, transform: ([[String]]) throws -> T) {
        guard let data = match.data(using: .utf8),
            let string = String(data: data, encoding: .utf8), string.contains("|,|") else {
                return nil
        }

        var lines = string.components(separatedBy: "|,|")
        let first = lines.removeFirst() + "|"
        let last = "|" + lines.removeLast()
        let middle = lines.map { "|\($0)|" }
        let table = ([first] + middle + [last]).map {
            Array($0
                .components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .dropFirst().dropLast()
            )
        }

        do {
            self.values = try transform(table)
        } catch {
            print(error)
            return nil
        }
    }
}

extension StepDefiner {
    func step<T: Collection>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<T>)->(), transform: @escaping ([[String]]) throws -> T) {
        self.test.addStep(expression, options: [], file: file, line: line) { (matches: StepMatches<String>) in
            guard let match = matches.allMatches.first else {
                XCTFail("Expected single match not found in \"\(expression)\"")
                return
            }

            guard let dataTable = NativeDataTable<T>(fromMatch: match, transform: transform) else {
                XCTFail("Could not convert \"\(match)\" to \(T.self)")
                return
            }

            f1(dataTable)
        }
    }
}

extension StepDefiner {

    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     | 1 |
     | 2 |
     | 3 |
     ```
     
     Values passed to the step:
     ```
     [1, 2, 3]
     ```
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[T]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [T] in
            let columns = Set(values.map({ $0.count }))
            guard columns.count == 1 && columns.first == 1 else {
                throw "Table should contain single column"
            }
            return try values.map {
                guard let value = T(fromMatch: $0[0]) else {
                    throw "Failed to convert \($0[0]) to \(T.self)"
                }
                return value
            }
        }
    }

    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     | 1 | 4 |
     | 2 | 5 |
     | 3 | 6 |
     ```

     Values passed to the step:
     ```
     [[1, 4], [2, 5], [3, 6]]
     ```
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[[T]]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [[T]] in
            return try values.map { row in
                try row.map { (cell) -> T in
                    guard let value = T(fromMatch: cell) else {
                        throw "Failed to convert \(cell) to \(T.self)"
                    }
                    return value
                }
            }
        }
    }

    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     | firstName   | lastName | birthDate  |
     | Annie M. G. | Schmidt  | 1911-03-20 |
     | Roald       | Dahl     | 1916-09-13 |
     | Astrid      | Lindgren | 1907-11-14 |
     ```

     Values passed to the step:
     ```
     [
         [ "firstName": "Annie M.G", "lastName": "Schmidt",  "birthDate": "1911-03-20" ],
         [ "firstName": "Roald",     "lastName": "Dahl",     "birthDate": "1916-09-13" ],
         [ "firstName": "Astrid",    "lastName": "Lindgren", "birthDate": "1907-11-14" ]
     ]
     ```
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[[String: T]]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [[String: T]] in
            var values = values
            let titles = values.removeFirst()
            return try values.reduce(into: [[String: T]]()) { values, row in
                let value = try row.enumerated().reduce(into: [String: T]()) { (values, cell) in
                    let title = titles[cell.offset]
                    guard let value = T(fromMatch: cell.element) else {
                        throw "Failed to convert \(cell.element) to \(T.self)"
                    }
                    values[title] = value
                }
                values.append(value)
            }
        }
    }

    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     | KMSY | Louis Armstrong New Orleans International Airport |
     | KSFO | San Francisco International Airport               |
     | KSEA | Seattle–Tacoma International Airport              |
     | KJFK | John F. Kennedy International Airport             |
     ```

     Values passed to the step:
     ```
     [
         "KMSY": "Louis Armstrong New Orleans International Airport",
         "KSFO": "San Francisco International Airport",
         "KSEA": "Seattle–Tacoma International Airport",
         "KJFK": "John F. Kennedy International Airport"
     ]
     ```
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[String: T]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [String: T] in
            let columns = Set(values.map({ $0.count }))
            guard columns.count == 1 && columns.first == 2 else {
                throw "Table should contain two columns"
            }
            return try values.reduce(into: [String: T]()) { (values, row) in
                guard let value = T(fromMatch: row[1]) else {
                    throw "Failed to convert \(row[1]) to \(T.self)"
                }
                values[row[0]] = value
            }
        }
    }

    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     | KMSY | 29.993333 |  -90.258056 |
     | KSFO | 37.618889 | -122.375000 |
     | KSEA | 47.448889 | -122.309444 |
     | KJFK | 40.639722 |  -73.778889 |
     ```

     Values passed to the step:
     ```
     [
         "KMSY": [29.993333, -90.258056],
         "KSFO": [37.618889, -122.375000],
         "KSEA": [47.448889, -122.309444],
         "KJFK": [40.639722, -73.778889]
     ]
     ```
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[String: [T]]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [String: [T]] in
            return try values.reduce(into: [String: [T]]()) { (values, row) in
                values[row[0]] = try row.dropFirst().map { cell in
                    guard let value = T(fromMatch: cell) else {
                        throw "Failed to convert \(cell) to \(T.self)"
                    }
                    return value
                }
            }
        }
    }

    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     |      |       lat |         lon |
     | KMSY | 29.993333 |  -90.258056 |
     | KSFO | 37.618889 | -122.375000 |
     | KSEA | 47.448889 | -122.309444 |
     | KJFK | 40.639722 |  -73.778889 |
     ```

     Values passed to the step:
     ```
     [
         "KMSY": [ "lat": 29.993333, "lon": -90.258056 ],
         "KSFO": [ "lat": 37.618889, "lon": -122.375000 ],
         "KSEA": [ "lat": 47.448889, "lon": -122.309444 ],
         "KJFK": [ "lat": 40.639722, "lon": -73.778889 ]
     ]
     ```
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[String: [String: T]]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [String: [String: T]] in
            var values = values
            let titles = Array(values.removeFirst().dropFirst())
            return try values.reduce(into: [String: [String: T]]()) { (values, row) in
                values[row[0]] = try Array(row.dropFirst()).enumerated().reduce(into: [String: T](), { (values, cell) in
                    let title = titles[cell.offset]
                    guard let value = T(fromMatch: cell.element) else {
                        throw "Failed to convert \(cell.element) to \(T.self)"
                    }
                    values[title] = value
                })
            }
        }
    }

    // TODO: implement custom decoder that will decode string cell values to expected types instead of failing
    /**
     Step that parses data table
     
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     | name  | age | height |
     | Alice | 20  | 170    |
     | Bob   | 21  | 171    |
     ```
     
     Values passed to the step:
     ```
     [
         Person(name: "Alice", age: "20", height: 170),
         Person(name: "Bob", age: "21", height: 171)
     ]
     ```
    */
    open func step<T: CodableMatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[T]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [T] in
            var values = values
            let titles = values.removeFirst()
            return try values.reduce(into: [T]()) { values, row in
                let value = row.enumerated().reduce(into: [String: Any]()) { (values, cell) in
                    let title = titles[cell.offset]
                    values[title] = cell.element.cellValue
                }
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                let decoded = try JSONDecoder().decode(T.self, from: data)
                values.append(decoded)
            }
        }
    }

    // TODO: implement custom decoder that will decode string cell values to expected types instead of failing
    /**
     Define the step that accepts a data table as a single parameter.
     
     Input from the feature file:
     ```
     |   | name  | age | height |
     | 1 | Alice | 20  | 170    |
     | 2 | Bob   | 21  | 171    |
     ```

     Values passed to the step:
     ```
     [
         1: Person(name: "Alice", age: 20, height: 170),
         2: Person(name: "Bob", age: 21, height: 171)
     ]
     ```
    */
    open func step<T: CodableMatchedStringRepresentable, U: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f1: @escaping (NativeDataTable<[U: T]>)->()) {
        self.step(expression, file: file, line: line, f1: f1) { (values: [[String]]) throws -> [U: T] in
            var values = values
            let titles = Array(values.removeFirst().dropFirst())
            return try values.reduce(into: [U: T]()) { (values, row) in
                guard let key = U(fromMatch: row[0]) else {
                    throw "Failed to convert \(row[0]) to \(U.self)"
                }
                let value = Array(row.dropFirst()).enumerated().reduce(into: [String: Any](), { (values, cell) in
                    let title = titles[cell.offset]
                    values[title] = cell.element.cellValue
                })
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                let decoded = try JSONDecoder().decode(T.self, from: data)
                values[key] = decoded
            }
        }
    }

}

private extension String {
    var cellValue: Any {
        if (hasPrefix("\"") && hasSuffix("\"")) || (hasPrefix("'") && hasSuffix("'")) {
            return String(self.dropFirst().dropLast())
        } else if let float = Double(fromMatch: self) {
            return float
        } else if let bool = Bool(fromMatch: self) {
            return bool
        } else {
            return self
        }
    }

}

