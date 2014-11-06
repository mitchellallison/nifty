//
//  TestLexicalAnalysis.swift
//  nifty
//
//  Created by Mitchell Allison on 29/10/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import XCTest

class TestLexicalAnalysis: XCTestCase {
    
    func testBinaryLiteralSuccessful() {
        let result = "0b10101".tokenise()!.tokens[0]
        let expected = SwiftToken.IntegerLiteral(21)
        XCTAssertEqual(result, expected, "Binary value parsed incorrectly. Expected: " + expected.description + " but got: " + result.description)
    }
    
    func testOctalLiteralSuccessful() {
        let result = "0c01234567".tokenise()!.tokens[0]
        let expected = SwiftToken.IntegerLiteral(342391)
        XCTAssertEqual(result, expected, "Octal value parsed incorrectly. Expected: " + expected.description + " but got: " + result.description)
    }
    
    func testDecimalSuccessful() {
        let result = "123".tokenise()!.tokens[0]
        let expected = SwiftToken.IntegerLiteral(123)
        XCTAssertEqual(result, expected, "Decimal value parsed incorrectly. Expected: " + expected.description + " but got: " + result.description)
    }
    
    func testHexadecimalLiteralSuccessful() {
        let result = "0x1234ABCDEF".tokenise()!.tokens[0]
        let expected = SwiftToken.IntegerLiteral(78193085935)
        XCTAssertEqual(result, expected, "Hexadecimal value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testDoubleLiteralSuccessful() {
        let result = "0.2".tokenise()!.tokens[0]
        let expected = SwiftToken.DoubleLiteral(0.2)
        XCTAssertEqual(result, expected, "Double value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testDoubleLiteralNoIntegerSuccessful() {
        let result = ".2".tokenise()!.tokens[0]
        let expected = SwiftToken.DoubleLiteral(0.2)
        XCTAssertEqual(result, expected, "Double value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testDoubleLiteralNoFractionalFails() {
        let (rep, errors) = SwiftToken.tokenise("1.")
        let result = rep.tokens[1]
        let expected = SwiftToken.Invalid(".")
        XCTAssertEqual(result, expected, "Incorrect Double value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }

    func testUnexpectedKeywordVar() {
        let result = "variable".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("variable")
        XCTAssertEqual(result, expected, "'variable' incorrectly parsed as 'var' 'iable'.")
    }
    
    func testUnexpectedKeywordLet() {
        let result = "letter".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("letter")
        XCTAssertEqual(result, expected, "'letter' incorrectly parsed as 'let' 'ter'.")
    }
    
    func testUnexpectedKeywordReturn() {
        let result = "returnable".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("returnable")
        XCTAssertEqual(result, expected, "'returnable' incorrectly parsed as 'ret' 'urnable'.")
    }
    
       func testUnexpectedKeywordFunc() {
        let result = "funcyTown".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("funcyTown")
        XCTAssertEqual(result, expected, "'funcyTown' incorrectly parsed as 'func' 'yTown'.")
    }
    
    func testUnexpectedKeywordWhile() {
        let result = "whiled".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("whiled")
        XCTAssertEqual(result, expected, "'whiled' incorrectly parsed as 'while' 'd'.")
    }
    
    func testUnexpectedKeywordTrue() {
        let result = "trueness".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("trueness")
        XCTAssertEqual(result, expected, "'whiled' incorrectly parsed as 'true' 'ness'.")
    }
    
    func testUnexpectedKeywordFalse() {
        let result = "falsetto".tokenise()!.tokens[0]
        let expected = SwiftToken.Identifier("falsetto")
        XCTAssertEqual(result, expected, "'whiled' incorrectly parsed as 'false' 'tto'.")
    }
    
    func testPrefixOperator() {
        let tokens = "++twelve".tokenise()!.tokens
        let expectedOperator = SwiftToken.PrefixOperator("++")
        let expectedIdentifier = SwiftToken.Identifier("twelve")
        XCTAssertEqual(tokens[0], expectedOperator, "Expected operator '\(expectedOperator)', got '\(tokens[0])'")
        XCTAssertEqual(tokens[1], expectedIdentifier, "Expected identifier '\(expectedIdentifier)', got '\(tokens[1])'")
    }
    
    func testInfixOperator() {
        let tokens = "twelve + thirteen".tokenise()!.tokens
        let expectedOperator = SwiftToken.InfixOperator("+")
        let expectedLHS = SwiftToken.Identifier("twelve")
        let expectedRHS = SwiftToken.Identifier("thirteen")
        XCTAssertEqual(tokens[0], expectedLHS, "Expected identifier '\(expectedLHS)', got '\(tokens[0])'")
        XCTAssertEqual(tokens[1], expectedOperator, "Expected operator '\(expectedOperator)', got '\(tokens[1])'")
        XCTAssertEqual(tokens[2], expectedRHS, "Expected identifier '\(expectedRHS)', got '\(tokens[0])'")
    }

    func testPostfixOperator() {
        let tokens = "twelve++".tokenise()!.tokens
        let expectedOperator = SwiftToken.PostfixOperator("++")
        let expectedIdentifier = SwiftToken.Identifier("twelve")
        XCTAssertEqual(tokens[0], expectedIdentifier, "Expected identifier '\(expectedIdentifier)', got '\(tokens[0])'")
        XCTAssertEqual(tokens[1], expectedOperator, "Expected operator '\(expectedOperator)', got '\(tokens[1])'")
    }

    
}
