//
//  TestBinaryExpressionParsing.swift
//  nifty
//
//  Created by Mitchell Allison on 04/02/2015.
//  Copyright (c) 2015 mitchellallison. All rights reserved.
//

import XCTest

class TestBinaryExpressionParsing: XCTestCase {
    
    func testPrecendenceOne() {
        let program = "1 + 2 * 3"
        if let ast = program.tokenise()?.parse() {
            if let plusBinop = ast.children[0] as? SwiftBinaryExpression {
                XCTAssertEqual(plusBinop.op, "+", "Root binary expression was not +.")
                let expectedLHS : SwiftExpr = SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 1, line: 1))
                XCTAssertEqual(plusBinop.lhs, expectedLHS, "LHS of + did not equal 1.")
                if let multiplyBinop = plusBinop.rhs as? SwiftBinaryExpression {
                    XCTAssertEqual(multiplyBinop.op, "*", "Second level binary expression was not *.")
                    XCTAssertEqual(multiplyBinop.lhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 5, line: 1)), "LHS of * did not equal 2.")
                    XCTAssertEqual(multiplyBinop.rhs, SwiftSignedIntegerLiteral(val: 3, lineContext: LineContext(pos: 9, line: 1)), "RHS of * did not equal 3.")
                }
            } else {
                XCTFail("Root node not binary expression.")
            }
        } else {
            XCTFail("Issue parsing program..")
        }
    }
    
    func testPrecendenceTwo() {
        let program = "1 * 2 + 3"
        if let ast = program.tokenise()?.parse() {
            if let plusBinop = ast.children[0] as? SwiftBinaryExpression {
                XCTAssertEqual(plusBinop.op, "+", "Root binary expression was not +.")
                XCTAssertEqual(plusBinop.rhs, SwiftSignedIntegerLiteral(val: 3, lineContext: LineContext(pos: 9, line: 1)), "LHS of + did not equal 3.")
                if let multiplyBinop = plusBinop.lhs as? SwiftBinaryExpression {
                    XCTAssertEqual(multiplyBinop.op, "*", "Second level binary expression was not *.")
                    XCTAssertEqual(multiplyBinop.lhs, SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 1, line: 1)), "LHS of * did not equal 1.")
                    XCTAssertEqual(multiplyBinop.rhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 4, line: 1)), "RHS of * did not equal 2.")
                }
            } else {
                XCTFail("Root node not binary expression.")
            }
        } else {
            XCTFail("Issue parsing program..")
        }
    }
    
    func testPrecendenceThree() {
        let program = "1 + 2 / 3 * 4 - 5"
        // (1 + ((2 / 3) * 4)) - 5
        if let ast = program.tokenise()?.parse() {
            if let minusBinop = ast.children[0] as? SwiftBinaryExpression {
                XCTAssertEqual(minusBinop.op, "-", "Root binary expression was not -.")
                XCTAssertEqual(minusBinop.rhs, SwiftSignedIntegerLiteral(val: 5, lineContext: LineContext(pos: 17, line: 1)), "RHS of - did not equal 5.")
                if let plusBinop = minusBinop.lhs as? SwiftBinaryExpression {
                    XCTAssertEqual(plusBinop.op, "+", "Second level binary expression was not +.")
                    XCTAssertEqual(plusBinop.lhs, SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 1, line: 1)), "LHS of + did not equal 1.")
                    if let multiplyBinop = plusBinop.rhs as? SwiftBinaryExpression {
                        XCTAssertEqual(multiplyBinop.op, "*", "Third level binary expression was not *.")
                        XCTAssertEqual(multiplyBinop.rhs, SwiftSignedIntegerLiteral(val: 4, lineContext: LineContext(pos: 13, line: 1)), "LHS of * did not equal 1.")
                        if let divideBinop = multiplyBinop.lhs as? SwiftBinaryExpression {
                            XCTAssertEqual(divideBinop.op, "/", "Fourth level binary expression was not /.")
                            XCTAssertEqual(divideBinop.lhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 5, line: 1)), "LHS of / did not equal 2.")
                            XCTAssertEqual(divideBinop.rhs, SwiftSignedIntegerLiteral(val: 3, lineContext: LineContext(pos: 9, line: 1)), "RHS of / did not equal 3.")
                        } else {
                            XCTFail("Fourth level node not binary expression.")
                        }
                    } else {
                        XCTFail("Third level node not binary expression.")
                    }
                } else {
                    XCTFail("Second level node not binary expression.")
                }
            } else {
                XCTFail("Root node not binary expression.")
            }
        } else {
            XCTFail("Issue parsing program..")
        }
    }
    
    func testMultipleBrackets() {
        let program = "1 + 2"
        let programWithBrackets = "(((((1 + 2)))))"
        if let programBody = program.tokenise()?.parse()?.children.first as? SwiftBinaryExpression {
            if let programWithBracketsBody = program.tokenise()?.parse()?.children.first as? SwiftBinaryExpression {
                XCTAssertEqual(programBody, programWithBracketsBody, "Brackets not stripped from expression.")
            } else {
                XCTFail("Program body with brackets could not be parsed.")
            }
        } else {
            XCTFail("Program body without brackets could not be parsed.")
        }
    }
    
    func testPrecendenceHard() {
        let program = "(1+(2+x))*((x+1)+2)"
        if let ast = program.tokenise()?.parse() {
            if let plusBinop = ast.children[0] as? SwiftBinaryExpression {
                XCTAssertEqual(plusBinop.op, "*", "Root binary expression was not *.")
                if let leftBinop = plusBinop.lhs as? SwiftBinaryExpression {
                    XCTAssertEqual(leftBinop.op, "+", "Second level binary expression was not +.")
                    XCTAssertEqual(leftBinop.lhs, SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 2, line: 1)), "LHS of * did not equal 1.")
                    if let leftInnerBinop = leftBinop.rhs as? SwiftBinaryExpression {
                        XCTAssertEqual(leftInnerBinop.op, "+", "Second level binary expression was not +.")
                        XCTAssertEqual(leftInnerBinop.lhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 5, line: 1)), "LHS of + did not equal 2.")
                        XCTAssertEqual(leftInnerBinop.rhs, SwiftIdentifierString(name: "x", lineContext: LineContext(pos: 7, line: 1)), "RHS of + did not equal x.")
                    } else {
                        XCTFail("RHS of RHS binop not binary expression.")
                    }
                } else {
                    XCTFail("LHS not binary expression.")
                }
                if let rightBinop = plusBinop.rhs as? SwiftBinaryExpression {
                    XCTAssertEqual(rightBinop.op, "+", "Second level binary expression was not +.")
                    XCTAssertEqual(rightBinop.rhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 18, line: 1)), "LHS of * did not equal 2.")
                    if let rightInnerBinop = rightBinop.lhs as? SwiftBinaryExpression {
                        XCTAssertEqual(rightInnerBinop.op, "+", "Second level binary expression was not +.")
                        XCTAssertEqual(rightInnerBinop.lhs, SwiftIdentifierString(name: "x", lineContext: LineContext(pos: 13, line: 1)), "LHS of + did not equal x.")
                        XCTAssertEqual(rightInnerBinop.rhs, SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 15, line: 1)), "RHS of + did not equal 1.")
                    } else {
                        XCTFail("RHS of RHS binop not binary expression.")
                    }
                    
                } else {
                    XCTFail("RHS not binary expression.")
                }
            } else {
                XCTFail("Root node not binary expression.")
            }
        } else {
            XCTFail("Issue parsing program..")
        }
    }
    
    func testLeftAssociativity() {
        let program = "1 + 2 + 3"
        if let ast = program.tokenise()?.parse() {
            if let plusBinop = ast.children[0] as? SwiftBinaryExpression {
                XCTAssertEqual(plusBinop.op, "+", "Root binary expression was not +.")
                XCTAssertEqual(plusBinop.rhs, SwiftSignedIntegerLiteral(val: 3, lineContext: LineContext(pos: 9, line: 1)), "LHS of + did not equal 3.")
                if let multiplyBinop = plusBinop.lhs as? SwiftBinaryExpression {
                    XCTAssertEqual(multiplyBinop.op, "+", "Second level binary expression was not +.")
                    XCTAssertEqual(multiplyBinop.lhs, SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 1, line: 1)), "LHS of + did not equal 1.")
                    XCTAssertEqual(multiplyBinop.rhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 4, line: 1)), "RHS of + did not equal 2.")
                }
            } else {
                XCTFail("Root node not binary expression.")
            }
        } else {
            XCTFail("Issue parsing program..")
        }
    }
    
    func testBracketPrecedence() {
        let program = "1 + (2 + 3)"
        if let ast = program.tokenise()?.parse() {
            if let plusBinop = ast.children[0] as? SwiftBinaryExpression {
                XCTAssertEqual(plusBinop.op, "+", "Root binary expression was not +.")
                XCTAssertEqual(plusBinop.lhs, SwiftSignedIntegerLiteral(val: 1, lineContext: LineContext(pos: 1, line: 1)), "LHS of + did not equal 1.")
                if let multiplyBinop = plusBinop.rhs as? SwiftBinaryExpression {
                    XCTAssertEqual(multiplyBinop.op, "+", "Second level binary expression was not +.")
                    XCTAssertEqual(multiplyBinop.lhs, SwiftSignedIntegerLiteral(val: 2, lineContext: LineContext(pos: 4, line: 1)), "LHS of + did not equal 2.")
                    XCTAssertEqual(multiplyBinop.rhs, SwiftSignedIntegerLiteral(val: 3, lineContext: LineContext(pos: 9, line: 1)), "RHS of + did not equal 3.")
                }
            } else {
                XCTFail("Root node not binary expression.")
            }
        } else {
            XCTFail("Issue parsing program..")
        }
    }
    
    func testPrefixExpression() {
        let program = "++a"
        if let ast = program.tokenise()?.parse() {
            if let prefixExp = ast.children[0] as? SwiftPrefixExpression {
                XCTAssertEqual(prefixExp.op, "++", "Prefix operator incorrect.")
                XCTAssertEqual(prefixExp.expr, SwiftIdentifierString(name: "a", lineContext: nil), "Expression parsed incorrectly")
            } else {
                XCTFail("Prefix expression parsed incorrectly.")
            }
        }
    }
    
    func testPostfixExpression() {
        let program = "a++"
        if let ast = program.tokenise()?.parse() {
            if let postfixExp = ast.children[0] as? SwiftPostfixExpression {
                XCTAssertEqual(postfixExp.op, "++", "Prefix operator incorrect.")
                XCTAssertEqual(postfixExp.expr, SwiftIdentifierString(name: "a", lineContext: nil), "Expression parsed incorrectly")
            } else {
                XCTFail("Postfix expression parsed incorrectly.")
            }
        }
    }
    
    func testPostfixPrefixBinOpExpression() {
        let program = "a++ - ++b"
        if let ast = program.tokenise()?.parse() {
            if let binop = ast.children[0] as? SwiftBinaryExpression {
                if let lhs = binop.lhs as? SwiftPostfixExpression {
                    XCTAssertEqual(lhs.op, "++", "Prefix operator incorrect.")
                    XCTAssertEqual(lhs.expr, SwiftIdentifierString(name: "a", lineContext: nil), "Expression parsed incorrectly")
                } else {
                    XCTFail("Postfix expression parsed incorrectly.")
                }
                
                XCTAssertEqual(binop.op, "-", "Binary operator parsed incorrectly.")
                
                if let rhs = binop.rhs as? SwiftPrefixExpression {
                    XCTAssertEqual(rhs.op, "++", "Prefix operator incorrect.")
                    XCTAssertEqual(rhs.expr, SwiftIdentifierString(name: "b", lineContext: nil), "Expression parsed incorrectly")
                } else {
                    XCTFail("Prefix expression parsed incorrectly.")
                }
            } else {
                XCTFail("Postfix expression parsed incorrectly.")
            }
        }
    }
    
    func testPrefixPostfixBinOpExpression() {
        let program = "++a - b++"
        if let ast = program.tokenise()?.parse() {
            if let binop = ast.children[0] as? SwiftBinaryExpression {
                if let lhs = binop.lhs as? SwiftPrefixExpression {
                    XCTAssertEqual(lhs.op, "++", "Prefix operator incorrect.")
                    XCTAssertEqual(lhs.expr, SwiftIdentifierString(name: "a", lineContext: nil), "Expression parsed incorrectly")
                } else {
                    XCTFail("Postfix expression parsed incorrectly.")
                }
                
                XCTAssertEqual(binop.op, "-", "Binary operator parsed incorrectly.")
                
                if let rhs = binop.rhs as? SwiftPostfixExpression {
                    XCTAssertEqual(rhs.op, "++", "Prefix operator incorrect.")
                    XCTAssertEqual(rhs.expr, SwiftIdentifierString(name: "b", lineContext: nil), "Expression parsed incorrectly")
                } else {
                    XCTFail("Prefix expression parsed incorrectly.")
                }
            } else {
                XCTFail("Postfix expression parsed incorrectly.")
            }
        }
    }
    
    func testFunctionCall() {
        let program = "foo()"
        if let ast = program.tokenise()?.parse() {
            if let call = ast.children[0] as? SwiftCall {
                XCTAssertEqual(call.identifier.name, "foo", "Incorrect identifier parsed.")
                XCTAssert(call.children.isEmpty, "Function call argument list not empty.")
            } else {
                XCTFail("SwiftCall parsed incorrectly.")
            }
        } else {
            XCTFail("Function call parsed incorrectly.")
        }
    }
    
    func testFunctionCallBinOp() {
        let program = "foo() + bar()"
        if let ast = program.tokenise()?.parse() {
            if let binop = ast.children[0] as? SwiftBinaryExpression {
                if let lhs = binop.lhs as? SwiftCall {
                    XCTAssertEqual(lhs.identifier.name, "foo", "Incorrect identifier parsed.")
                    XCTAssert(lhs.children.isEmpty, "Function call argument list not empty.")
                } else {
                    XCTFail("LHS SwiftCall parsed incorrectly.")
                }
                
                XCTAssertEqual(binop.op, "+", "Binary operator parsed incorrectly.")
                
                if let rhs = binop.rhs as? SwiftCall {
                    XCTAssertEqual(rhs.identifier.name, "bar", "Incorrect identifier parsed.")
                    XCTAssert(rhs.children.isEmpty, "Function call argument list not empty.")
                } else {
                    XCTFail("RHS SwiftCall parsed incorrectly.")
                }
            }
            
                   } else {
            XCTFail("Function call parsed incorrectly.")
        }
    }

}