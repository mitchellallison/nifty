//
//  TestFunctionDeclarationParsing.swift
//  nifty
//
//  Created by Mitchell Allison on 11/02/2015.
//  Copyright (c) 2015 mitchellallison. All rights reserved.
//

import Cocoa
import XCTest

class TestFunctionDeclarationParsing: XCTestCase {
    func testNoArgumentFunctionExplicitVoidReturnType() {
        let program = "func foo() -> Void { }"
        if let ast = program.tokenise()?.parse(), let functionDeclaration = ast.children[0] as? SwiftFunctionDeclaration, let returnType = functionDeclaration.prototype.type {
            XCTAssertEqual(functionDeclaration.prototype.identifier, "foo", "Function identifier parsed incorrectly.")
            XCTAssertEqual(returnType, SwiftTupleType(types: [], lineContext: nil), "Return type mismatch.")
            XCTAssert(functionDeclaration.prototype.parameters.isEmpty, "Parameter list parsed incorrectly.")
        } else {
            XCTFail("Issue parsing function.")
        }
    }
    
    func testNoArgumentFunctionImplicitReturnType() {
        let program = "func foo() { }"
        if let ast = program.tokenise()?.parse(), let functionDeclaration = ast.children[0] as? SwiftFunctionDeclaration, let returnType = functionDeclaration.prototype.type {
            XCTAssertEqual(functionDeclaration.prototype.identifier, "foo", "Function identifier parsed incorrectly.")
            XCTAssertEqual(returnType, SwiftTypeIdentifier(identifier: "Void", lineContext: nil), "Return type mismatch.")
            XCTAssert(functionDeclaration.prototype.parameters.isEmpty, "Parameter list parsed incorrectly.")
        } else {
            XCTFail("Issue parsing function.")
        }
    }
    
    func testOneArgumentWithNoTypeFunction() {
        let program = "func foo(bar) { }"
        if let ast = program.tokenise()?.parse(), let functionDeclaration = ast.children[0] as? SwiftFunctionDeclaration, let returnType = functionDeclaration.prototype.type {
            XCTAssertEqual(functionDeclaration.prototype.identifier, "foo", "Function identifier parsed incorrectly.")
            XCTAssertEqual(returnType, SwiftTypeIdentifier(identifier: "Void", lineContext: nil), "Return type mismatch.")
            XCTAssertEqual(functionDeclaration.prototype.parameters[0], SwiftDeclaration(id: "bar", lineContext: nil), "Argument list parsed incorrectly.")
            XCTAssertEqual(functionDeclaration.prototype.parameters.count, 1, "Incorrect number of parameters.")
        } else {
            XCTFail("Issue parsing function.")
        }
    }
    
    func testOneArgumentWithTypeFunction() {
        let program = "func foo(bar: Int) { }"
        if let ast = program.tokenise()?.parse(), let functionDeclaration = ast.children[0] as? SwiftFunctionDeclaration, let returnType = functionDeclaration.prototype.type {
            XCTAssertEqual(functionDeclaration.prototype.identifier, "foo", "Function identifier parsed incorrectly.")
            XCTAssertEqual(returnType, SwiftTypeIdentifier(identifier: "Void", lineContext: nil), "Return type mismatch.")
            let declaration = SwiftDeclaration(id: "bar", type: SwiftTypeIdentifier(identifier: "Int", lineContext: nil), lineContext: nil)
            XCTAssertEqual(functionDeclaration.prototype.parameters[0], declaration, "Argument list parsed incorrectly.")
            XCTAssertEqual(functionDeclaration.prototype.parameters.count, 1, "Incorrect number of parameters.")
        } else {
            XCTFail("Issue parsing function.")
        }
    }
    
    func testTwoArgumentWithNoTypeFunction() {
        let program = "func foo(bar, baz) { }"
        if let ast = program.tokenise()?.parse(), let functionDeclaration = ast.children[0] as? SwiftFunctionDeclaration, let returnType = functionDeclaration.prototype.type {
            XCTAssertEqual(functionDeclaration.prototype.identifier, "foo", "Function identifier parsed incorrectly.")
            XCTAssertEqual(returnType, SwiftTypeIdentifier(identifier: "Void", lineContext: nil), "Return type mismatch.")
            XCTAssertEqual(functionDeclaration.prototype.parameters[0], SwiftDeclaration(id: "bar", lineContext: nil), "Argument list parsed incorrectly.")
            XCTAssertEqual(functionDeclaration.prototype.parameters[1], SwiftDeclaration(id: "baz", lineContext: nil), "Argument list parsed incorrectly.")
            XCTAssertEqual(functionDeclaration.prototype.parameters.count, 2, "Incorrect number of parameters.")
        } else {
            XCTFail("Issue parsing function.")
        }
    }
    
    func testTwoArgumentWithTypeFunction() {
        let program = "func foo(bar: Int, baz: Bool) { }"
        if let ast = program.tokenise()?.parse(), let functionDeclaration = ast.children[0] as? SwiftFunctionDeclaration, let returnType = functionDeclaration.prototype.type {
            XCTAssertEqual(functionDeclaration.prototype.identifier, "foo", "Function identifier parsed incorrectly.")
            XCTAssertEqual(returnType, SwiftTypeIdentifier(identifier: "Void", lineContext: nil), "Return type mismatch.")
            let param1 = SwiftDeclaration(id: "bar", type: SwiftTypeIdentifier(identifier: "Int", lineContext: nil), lineContext: nil)
            let param2 = SwiftDeclaration(id: "baz", type: SwiftTypeIdentifier(identifier: "Bool", lineContext: nil), lineContext: nil)
            XCTAssertEqual(functionDeclaration.prototype.parameters[0], param1, "Argument list parsed incorrectly.")
            XCTAssertEqual(functionDeclaration.prototype.parameters[1], param2, "Argument list parsed incorrectly.")
            XCTAssertEqual(functionDeclaration.prototype.parameters.count, 2, "Incorrect number of parameters.")
        } else {
            XCTFail("Issue parsing function.")
        }
    }
}
