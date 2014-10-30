//
//  TestLexicalAnalysis.swift
//  nifty
//
//  Created by Mitchell Allison on 29/10/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import XCTest

class TestLexicalAnalysis: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBinaryLiteralSuccessful() {
        let result = SwiftToken.tokenise("0b10101").tokens[0]
        let expected = SwiftToken.IntegerLiteral(21)
        XCTAssertEqual(result, expected, "Binary value parsed incorrectly. Expected: " + expected.description + " but got: " + result.description)
    }
    
    func testOctalLiteralSuccessful() {
        let result = SwiftToken.tokenise("0c01234567").tokens[0]
        let expected = SwiftToken.IntegerLiteral(342391)
        XCTAssertEqual(result, expected, "Octal value parsed incorrectly. Expected: " + expected.description + " but got: " + result.description)
    }
    
    func testDecimalSuccessful() {
        let result = SwiftToken.tokenise("123").tokens[0]
        let expected = SwiftToken.IntegerLiteral(123)
        XCTAssertEqual(result, expected, "Decimal value parsed incorrectly. Expected: " + expected.description + " but got: " + result.description)
    }
    
    func testHexadecimalLiteralSuccessful() {
        let result = SwiftToken.tokenise("0x1234ABCDEF").tokens[0]
        let expected = SwiftToken.IntegerLiteral(78193085935)
        XCTAssertEqual(result, expected, "Hexadecimal value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testDoubleLiteralSuccessful() {
        let result = SwiftToken.tokenise("0.2").tokens[0]
        let expected = SwiftToken.DoubleLiteral(0.2)
        XCTAssertEqual(result, expected, "Double value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testDoubleLiteralNoIntegerSuccessful() {
        let result = SwiftToken.tokenise(".2").tokens[0]
        let expected = SwiftToken.DoubleLiteral(0.2)
        XCTAssertEqual(result, expected, "Double value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testDoubleLiteralNoFractionalFails() {
        let result = SwiftToken.tokenise("1.").tokens[1]
        let expected = SwiftToken.Invalid(".")
        XCTAssertEqual(result, expected, "Incorrect Double value parsed incorrectly. Expected: " + expected.description + "but got: " + result.description)
    }
    
    func testUnexpectedKeywordVar() {
        let result = SwiftToken.tokenise("variable").tokens[0]
        let expected = SwiftToken.Identifier("variable")
        XCTAssertEqual(result, expected, "'variable' incorrectly parsed as 'var' 'iable'.")
    }
    
    func testUnexpectedKeywordLet() {
        let result = SwiftToken.tokenise("letter").tokens[0]
        let expected = SwiftToken.Identifier("letter")
        XCTAssertEqual(result, expected, "'letter' incorrectly parsed as 'let' 'ter'.")
    }
    
    func testUnexpectedKeywordReturn() {
        let result = SwiftToken.tokenise("returnable").tokens[0]
        let expected = SwiftToken.Identifier("returnable")
        XCTAssertEqual(result, expected, "'returnable' incorrectly parsed as 'ret' 'urnable'.")
    }
    
       func testUnexpectedKeywordFunc() {
        let result = SwiftToken.tokenise("funcyTown").tokens[0]
        let expected = SwiftToken.Identifier("funcyTown")
        XCTAssertEqual(result, expected, "'funcyTown' incorrectly parsed as 'func' 'yTown'.")
    }
    
    func testUnexpectedKeywordWhile() {
        let result = SwiftToken.tokenise("whiled").tokens[0]
        let expected = SwiftToken.Identifier("whiled")
        XCTAssertEqual(result, expected, "'whiled' incorrectly parsed as 'while' 'd'.")
    }
    
    func testUnexpectedKeywordTrue() {
        let result = SwiftToken.tokenise("trueness").tokens[0]
        let expected = SwiftToken.Identifier("trueness")
        XCTAssertEqual(result, expected, "'whiled' incorrectly parsed as 'true' 'ness'.")
    }
    
    func testUnexpectedKeywordFalse() {
        let result = SwiftToken.tokenise("falsetto").tokens[0]
        let expected = SwiftToken.Identifier("falsetto")
        XCTAssertEqual(result, expected, "'whiled' incorrectly parsed as 'false' 'tto'.")
    }
    
    func testPrefixOperator() {
        let tokens = SwiftToken.tokenise("++twelve").tokens
        let expectedOperator = SwiftToken.PrefixOperator("++")
        let expectedIdentifier = SwiftToken.Identifier("twelve")
        XCTAssertEqual(tokens[0], expectedOperator, "Expected operator '\(expectedOperator)', got '\(tokens[0])'")
        XCTAssertEqual(tokens[1], expectedIdentifier, "Expected identifier '\(expectedIdentifier)', got '\(tokens[1])'")
    }
    
    func testInfixOperator() {
        let tokens = SwiftToken.tokenise("twelve + thirteen").tokens
        let expectedOperator = SwiftToken.InfixOperator("+")
        let expectedLHS = SwiftToken.Identifier("twelve")
        let expectedRHS = SwiftToken.Identifier("thirteen")
        XCTAssertEqual(tokens[0], expectedLHS, "Expected identifier '\(expectedLHS)', got '\(tokens[0])'")
        XCTAssertEqual(tokens[1], expectedOperator, "Expected operator '\(expectedOperator)', got '\(tokens[1])'")
        XCTAssertEqual(tokens[2], expectedRHS, "Expected identifier '\(expectedRHS)', got '\(tokens[0])'")
    }

    func testPostfixOperator() {
        let tokens = SwiftToken.tokenise("twelve++").tokens
        let expectedOperator = SwiftToken.PostfixOperator("++")
        let expectedIdentifier = SwiftToken.Identifier("twelve")
        XCTAssertEqual(tokens[0], expectedIdentifier, "Expected identifier '\(expectedIdentifier)', got '\(tokens[0])'")
        XCTAssertEqual(tokens[1], expectedOperator, "Expected operator '\(expectedOperator)', got '\(tokens[1])'")
    }

    
}
