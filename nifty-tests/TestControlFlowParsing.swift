//
//  TestControlFlowParsing.swift
//  nifty
//
//  Created by Mitchell Allison on 04/02/2015.
//  Copyright (c) 2015 mitchellallison. All rights reserved.
//

import XCTest

class TestControlFlowParsing: XCTestCase {

    func testSimpleWhileLoop() {
        let program = "while(true) { 1 + 1 }"
        if let ast = program.tokenise()?.parse() {
            if let whileStmt = ast.children[0] as? SwiftWhileStatement {
                XCTAssertEqual(whileStmt.cond, SwiftBooleanLiteral(val: true, lineContext: nil), "Condition was not true.")
                if let binop = whileStmt.body.children.first as? SwiftBinaryExpression {
                    XCTAssertEqual(binop, SwiftBinaryExpression(op: "+", lhs: SwiftSignedIntegerLiteral(val: 1, lineContext: nil), rhs: SwiftSignedIntegerLiteral(val: 1, lineContext: nil)), "Binary expression was not 1+1.")
                } else {
                    XCTFail("Binary expression statement not found in AST.")
                }
            } else {
                XCTFail("While statement not found in AST.")
            }
        } else {
            XCTFail("While loop could not be parsed.")
        }
    }
    
    func testWhileLoopConditionExpression() {
        let program = "while(1 == (0 + 1)) { 1 + 1 }"
        if let ast = program.tokenise()?.parse() {
            if let whileStmt = ast.children[0] as? SwiftWhileStatement {
                if let binop = whileStmt.cond as? SwiftBinaryExpression {
                    XCTAssertEqual(binop.lhs, SwiftSignedIntegerLiteral(val:1, lineContext: nil), "LHS was not 0.")
                    XCTAssertEqual(binop.rhs, SwiftBinaryExpression(op: "+", lhs: SwiftSignedIntegerLiteral(val: 0, lineContext: nil), rhs: SwiftSignedIntegerLiteral(val: 1, lineContext: nil)), "RHS was not (0 + 1).")
                } else {
                    XCTFail("While condition could not be parsed.")
                }
            }
        } else {
            XCTFail("While loop could not be parsed.")
        }
    }
    
    func testSimpleIfLoop() {
        let program = "if(true) { 1 + 1 }"
        if let ast = program.tokenise()?.parse() {
            if let whileStmt = ast.children[0] as? SwiftIfStatement {
                XCTAssertEqual(whileStmt.cond, SwiftBooleanLiteral(val: true, lineContext: nil), "Condition was not true.")
                if let binop = whileStmt.body.children.first as? SwiftBinaryExpression {
                    XCTAssertEqual(binop, SwiftBinaryExpression(op: "+", lhs: SwiftSignedIntegerLiteral(val: 1, lineContext: nil), rhs: SwiftSignedIntegerLiteral(val: 1, lineContext: nil)), "Binary expression was not 1+1.")
                } else {
                    XCTFail("Binary expression statement not found in AST.")
                }
            } else {
                XCTFail("If statement not found in AST.")
            }
        } else {
            XCTFail("If statement could not be parsed.")
        }
    }
    
    func testIfConditionExpression() {
        let program = "if(1 == (0 + 1)) { 1 + 1 }"
        println(program.tokenise()!)
        if let ast = program.tokenise()?.parse() {
            if let whileStmt = ast.children[0] as? SwiftIfStatement {
                if let binop = whileStmt.cond as? SwiftBinaryExpression {
                    XCTAssertEqual(binop.lhs, SwiftSignedIntegerLiteral(val:1, lineContext: nil), "LHS was not 0.")
                    XCTAssertEqual(binop.rhs, SwiftBinaryExpression(op: "+", lhs: SwiftSignedIntegerLiteral(val: 0, lineContext: nil), rhs: SwiftSignedIntegerLiteral(val: 1, lineContext: nil)), "RHS was not (0 + 1).")
                } else {
                    XCTFail("If condition could not be parsed.")
                }
            }
        } else {
            XCTFail("If statement could not be parsed.")
        }
    }


}
