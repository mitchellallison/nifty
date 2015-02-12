//
//  TestParser.swift
//  nifty
//
//  Created by Mitchell Allison on 06/11/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import XCTest

class TestDeclarationParsing: XCTestCase {

    func testLetDeclaration() {
        let program = "let x = 1"
        let ast = program.tokenise()!.parse()!
        if let declaration = ast.children[0] as? SwiftDeclaration {
            if let assignment = declaration.assignment as? SwiftSignedIntegerLiteral {
                XCTAssertEqual(assignment.val, 1, "Expected expression to be '1', was actually '\(assignment)'.'")
                XCTAssertEqual(declaration.identifier, "x", "Expected identifier to be 'x', was actually '\(declaration.identifier)'")
                XCTAssert(declaration.isConstant, "Expected declaration of '\(declaration.identifier)' to be constant, was actually variable.")
                XCTAssertNil(declaration.type, "Expected missing type prior to semantic analysis, type was actually \(declaration.type)")
            } else {
                XCTFail("Type of expression not Int.")
            }
        } else {
            XCTFail("First child of AST not of type SwiftDeclaration.")
        }
    }
    
    func testLetDeclarationWithType() {
        let program = "let x: Int = 1"
        let ast = program.tokenise()!.parse()!
        if let declaration = ast.children[0] as? SwiftDeclaration {
            if let assignment = declaration.assignment as? SwiftSignedIntegerLiteral {
                XCTAssertEqual(assignment.val, 1, "Expected expression to be '1', was actually '\(assignment)'.'")
                XCTAssertEqual(declaration.identifier, "x", "Expected identifier to be 'x', was actually '\(declaration.identifier)'")
                XCTAssert(declaration.isConstant, "Expected declaration of '\(declaration.identifier)' to be constant, was actually variable.")
                if let type = declaration.type as? SwiftTypeIdentifier {
                    XCTAssertEqual(type.identifier, "Int", "Expected type 'Int', type was actually \(type.identifier)")
                } else {
                    XCTFail("Wrong or missing type.")
                }
            } else {
                XCTFail("Type of expression not Int.")
            }
        } else {
            XCTFail("First child of AST not of type SwiftDeclaration.")
        }
    }

    
    func testVariableDeclaration() {
        let program = "var x = 1"
        let ast = program.tokenise()!.parse()!
        if let declaration = ast.children[0] as? SwiftDeclaration {
            if let assignment = declaration.assignment as? SwiftSignedIntegerLiteral {
                XCTAssertEqual(assignment.val, 1, "Expected expression to be '1', was actually '\(assignment)'.'")
                XCTAssertEqual(declaration.identifier, "x", "Expected identifier to be 'x', was actually '\(declaration.identifier)'")
                XCTAssert(!declaration.isConstant, "Expected declaration of '\(declaration.identifier)' to be variable, was actually constant.")
                XCTAssertNil(declaration.type, "Expected missing type prior to semantic analysis, type was actually \(declaration.type)")
            } else {
                XCTFail("Type of expression not Int.")
            }
        } else {
            XCTFail("First child of AST not of type SwiftDeclaration.")
        }
    }
    
    func testVariableDeclarationWithType() {
        let program = "var x: Int = 1"
        let ast = program.tokenise()!.parse()!
        if let declaration = ast.children[0] as? SwiftDeclaration {
            if let assignment = declaration.assignment as? SwiftSignedIntegerLiteral {
                XCTAssertEqual(assignment.val, 1, "Expected expression to be '1', was actually '\(assignment)'.'")
                XCTAssertEqual(declaration.identifier, "x", "Expected identifier to be 'x', was actually '\(declaration.identifier)'")
                XCTAssert(!declaration.isConstant, "Expected declaration of '\(declaration.identifier)' to be variable, was actually constant.")
                if let type = declaration.type as? SwiftTypeIdentifier {
                    XCTAssertEqual(type.identifier, "Int", "Expected type 'Int', type was actually \(type.identifier)")
                } else {
                    XCTFail("Wrong or missing type.")
                }
            } else {
                XCTFail("Type of expression not Int.")
            }
        } else {
            XCTFail("First child of AST not of type SwiftDeclaration.")
        }
    }


}
