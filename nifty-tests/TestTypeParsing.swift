//
//  TestTypeParsing.swift
//  nifty
//
//  Created by Mitchell Allison on 12/04/2015.
//  Copyright (c) 2015 mitchellallison. All rights reserved.
//

import XCTest

class TestTypeParsing: XCTestCase {
    
    func testSingularTypeParse() {
        let type = "Int"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftTypeIdentifier {
            let expected = SwiftTypeIdentifier(identifier: type)
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testSingularBracketedTypeParse() {
        let type = "Int"
        let bracketedType = "(" + type + ")"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftTypeIdentifier {
            let expected = SwiftTypeIdentifier(identifier: type)
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testVoidTypeParse() {
        let type = "()"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftTupleType {
            let expected = SwiftTupleType(types: [], lineContext: LineContext(pos: 1, line: 1))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }

    func testTwoSingularElementTupleParse() {
        let type1 = "Int"
        let type2 = "String"
        let type = "(\(type1), \(type2))"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftTupleType {
            let expected = SwiftTupleType(types: [SwiftTypeIdentifier(identifier: type1), SwiftTypeIdentifier(identifier: type2)], lineContext:LineContext(pos: 1, line: 1))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }

    func testTwoElementTupleOneVoidParse() {
        let type1 = "()"
        let type2 = "String"
        let type = "(\(type1), \(type2))"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftTupleType {
            let expected = SwiftTupleType(types: [SwiftTupleType(types: [], lineContext: LineContext(pos: 1, line: 1)), SwiftTypeIdentifier(identifier: type2)], lineContext:LineContext(pos: 1, line: 1))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }

    func testFunctionParseWithoutBrackets() {
        let argumentType = "Int"
        let returnType = "String"
        let type = "\(argumentType) -> \(returnType)"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftFunctionType {
            let expected = SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: argumentType), returnType: SwiftTypeIdentifier(identifier: returnType))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testFunctionParseWithBrackets() {
        let argumentType = "Int"
        let returnType = "String"
        let type = "(\(argumentType) -> \(returnType))"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftFunctionType {
            let expected = SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: argumentType), returnType: SwiftTypeIdentifier(identifier: returnType))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testVoidFunctionParseNoArguments() {
        let argumentType = "()"
        let returnType = "()"
        let type = "\(argumentType) -> \(returnType)"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftFunctionType {
            let expected = SwiftFunctionType(parameterType: SwiftTupleType(types: [], lineContext:LineContext(pos: 1, line: 1)), returnType: SwiftTupleType(types: [], lineContext:LineContext(pos: 7, line: 1)))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testVoidFunctionParseSingularArgument() {
        let argumentType = "Int"
        let returnType = "()"
        let type = "\(argumentType) -> \(returnType)"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftFunctionType {
            let expected = SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: argumentType), returnType: SwiftTupleType(types: [], lineContext:LineContext(pos: 8, line: 1)))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testRightAssociatedFunctionParse() {
        let argumentType = "Int"
        let nestedArgumentType = "String"
        let returnType = "Double"
        let type = "\(argumentType) -> \(nestedArgumentType) -> \(returnType)"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftFunctionType {
            let expected = SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: argumentType), returnType: SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: nestedArgumentType), returnType: SwiftTypeIdentifier(identifier: returnType)))
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
    
    func testNestTupleInFunctionParse() {
        let type = "Int -> (String, Int -> Bool) -> Double"
        let rep = type.tokenise()!
        let (t, c) = (rep.tokens, rep.context)
        let p = SwiftParser(tokens: t, lineContext: c)
        if let result = p.parseType() as? SwiftFunctionType {
            print(result)
            let innerFunctionType = SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: "Int"), returnType: SwiftTypeIdentifier(identifier: "Bool"))
            let innerType = SwiftFunctionType(parameterType: SwiftTupleType(types: [SwiftTypeIdentifier(identifier: "String"), innerFunctionType], lineContext: LineContext(pos: 8, line: 1)), returnType: SwiftTypeIdentifier(identifier: "Double"))
            let expected = SwiftFunctionType(parameterType: SwiftTypeIdentifier(identifier: "Int"), returnType: innerType)
            XCTAssertEqual(expected, result, "Type parsed incorrectly. Expected \(expected) but got \(result)")
        } else {
            XCTFail("Couldn't parse type \(type).")
        }
    }
}
