//
//  parser.swift
//  nifty
//
//  Created by Mitchell Allison on 04/11/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import Foundation

//MARK: Equatable protocol conformance

public func ==(lhs: SwiftAST, rhs: SwiftAST) -> Bool {
    return false
}

public func ==(lhs: SwiftType, rhs: SwiftType) -> Bool {
    switch (lhs, rhs) {
    case let (l as SwiftTypeIdentifier, r as SwiftTypeIdentifier):
        return l.identifier == r.identifier
    default:
        return false
    }
}

public func ==(lhs: SwiftExpr, rhs: SwiftExpr) -> Bool {
    switch (lhs, rhs) {
    case let (l as SwiftSignedIntegerLiteral, r as SwiftSignedIntegerLiteral):
        return l.val == r.val
    case let (l as SwiftDoubleLiteral, r as SwiftDoubleLiteral):
        return l.val == r.val
    case let (l as SwiftIdentifierString, r as SwiftIdentifierString):
        return l.name == r.name
    case let (l as SwiftBinaryExpression, r as SwiftBinaryExpression):
        return l.op == r.op && l.lhs == r.lhs && l.rhs == r.rhs
    case let (l as SwiftBooleanLiteral, r as SwiftBooleanLiteral):
        return l.val == r.val
    default:
        return false
    }
}

public func ==(lhs: SwiftDeclaration, rhs: SwiftDeclaration) -> Bool {
    switch (lhs, rhs) {
    case let (l, r):
        return l.identifier == r.identifier && l.isConstant == r.isConstant && l.assignment == r.assignment && l.type == r.type
    default:
        return false
    }
}

//MARK: -
//MARK: Types


// Abstract class representing a node in a Swift Abstract Syntax Tree.
public class SwiftAST : Equatable, Printable {
    var children: [SwiftAST] = []
   
    /**
    Initialises a SwiftAST node. Designated initialiser for subclasses, should not be called otherwise.
    
    :param: lineContext An optional LineContext relating to the node.

    :returns: An initialised SwiftAST.
    **/
    init(lineContext: LineContext?) {
        self.lineContext = lineContext
    }
    
    private var explicitLineContext: LineContext?
    
    var lineContext: LineContext? {
        get {
            return explicitLineContext ?? children.first?.lineContext
        }
        set (explicitLineContext) {
            self.explicitLineContext = explicitLineContext
        }
    }
    
    // Returns a description of all child nodes, indented appropriately.
    private var childDescriptions: String {
        // For every child, replace all instances of "\n" in their descriptions with "\n\t" to indent appropriately
        let indentedDescriptions = self.children.map({
            return reduce(split($0.description, { $0 == "\n" }), "") { return $0 + "\n\t" + $1 }
        })
        // Then, concatenate all the descriptions
        return reduce(indentedDescriptions, "", +)
    }
    
    public var description: String {
        return "SwiftAST" + self.childDescriptions
    }
}

// A Swift program/closure body node in the AST.
public class SwiftBody: SwiftAST {
    override public var description: String {
        return "SwiftBody" + self.childDescriptions
    }
}

// A constant or variable declaration node in the AST.
public class SwiftDeclaration: SwiftAST, Equatable {
    var identifier: String
    var isConstant: Bool
    var type: SwiftType?
    var assignment: SwiftExpr? {
        didSet {
            self.children.append(assignment!)
        }
    }
    
    /**
    Initialises a SwiftDeclaration node.
    
    :param: id The identifier of the binding.
    :param: type The optional type of the binding.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftDeclaration.
    **/
    init(id: String, type: SwiftType?, lineContext: LineContext?) {
        identifier = id
        isConstant = true
        self.type = type
        super.init(lineContext: lineContext)
        if let type = type {
            self.children.append(type)
        }
    }
    
    /**
    Initialises a SwiftDeclaration node without a type.
    
    :param: id The identifier of the binding.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftDeclaration.
    **/
    convenience init(id: String, lineContext: LineContext?) {
        self.init(id: id, type: nil, lineContext: lineContext)
    }
    
    override public var description: String {
        return "SwiftDeclaration: - identifier:\(identifier), isConstant:\(isConstant)" + self.childDescriptions
    }
}

public class SwiftFunctionParameter: SwiftDeclaration {
    
}

// The prototype for a function, consisting of its parameters, their types and the return type.
public class SwiftFunctionPrototype: SwiftDeclaration {
    var parameters: [SwiftDeclaration]
    
    /**
    Initialises a SwiftFunctionPrototype.

    :param: id The identifier of the function prototype.
    :param: parameters An array of SwiftDeclaration nodes, corresponding to the parameters of a function.
    :param: returnType The return type of the function.
    :param: lineContext An optional LineContext relating to the node.

    :returns: An initialised SwiftFunctionPrototype.
    **/
    init(id: String, parameters: [SwiftDeclaration], returnType: SwiftType, lineContext: LineContext?) {
        self.parameters = parameters
        super.init(id: id, type: returnType, lineContext: lineContext)
    }
}

// The body of a function.
public class SwiftFunctionBody: SwiftBody {
    
    /**
    Initialises a SwiftFunctionPrototype.
    
    :param: _ A SwiftBody representing the body of a function.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftFunctionPrototype.
    **/
    init(_ body: SwiftBody, lineContext: LineContext?) {
        super.init(lineContext: lineContext)
        self.children = body.children
        self.lineContext = body.lineContext
    }
}

// The declaration of a function, consisting of its prototype and body.
public class SwiftFunctionDeclaration: SwiftAST {
    var prototype: SwiftFunctionPrototype
    var body: SwiftFunctionBody?
    
    /**
    Initialises a SwiftFunctionDeclaration.
    
    :param: id The identifier of the function.
    :param: parameters An array of SwiftDeclaration nodes, corresponding to the parameters of a function.
    :param: returnType The return type of the function.
    :param: body A SwiftBody representing the body of a function.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftFunctionPrototype.
    **/
    init(id: String, parameters: [SwiftDeclaration], returnType: SwiftType, body: SwiftFunctionBody?, lineContext: LineContext?) {
        self.prototype = SwiftFunctionPrototype(id: id, parameters: parameters, returnType: returnType, lineContext: lineContext)
        self.body = body
        super.init(lineContext: lineContext)
        self.children.append(self.prototype)
        if let body = self.body {
            self.children.append(body)
        }
    }
}

// A function call
public class SwiftCall: SwiftExpr {
    let identifier: SwiftIdentifierString
    
    /**
    Initialises a SwiftCall node.

    :param: id The function identifier.
    :param: arguments An array of SwiftExpr nodes, corresponding to the arguments of the function.
    **/
    init(identifier: SwiftIdentifierString, arguments: [SwiftExpr]) {
        self.identifier = identifier
        super.init(lineContext: nil)
        let args = arguments as [SwiftAST]
        self.children.extend(args)
    }
}


// An assignment to a constant or variable.
public class SwiftAssignment: SwiftAST {
    var storage: SwiftExpr
    var expression: SwiftExpr
    
    init(storage: SwiftExpr, expression: SwiftExpr) {
        self.storage = storage
        self.expression = expression
        super.init(lineContext: nil)
        self.children = [self.storage, self.expression]
    }
}

public class SwiftConditionalStatement: SwiftAST {
    let cond: SwiftExpr
    let body: SwiftBody
    
    init(condition: SwiftExpr, body: SwiftBody, lineContext: LineContext?) {
        self.cond = condition
        self.body = body
        super.init(lineContext: lineContext)
        self.lineContext = lineContext
    }
}

// A while statement.
public class SwiftWhileStatement: SwiftConditionalStatement {}

// An if statement.
public class SwiftIfStatement: SwiftConditionalStatement {}


//MARK: SwiftExpr

// An abstract class representing a Swift expression in the AST.
public class SwiftExpr: SwiftAST, Equatable {
    let isAssignable: Bool
    
    /**
    Initialises a SwiftExpr node. Designated initialiser for subclasses, should not be called otherwise.
    
    :param: assignable Boolean value representing if the expression can be assigned to (i.e, identifiers, tuples).
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftExpr.
    **/
    init(assignable: Bool = false, lineContext: LineContext?) {
        self.isAssignable = assignable
        super.init(lineContext: lineContext)
    }
}

// An 'Int' node in the AST.
public class SwiftSignedIntegerLiteral: SwiftExpr {
    let val: Int
    
    /**
    Initialises a SwiftSignedIntegerLiteral node.
    
    :param: val The value represented by the integer literal.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftSignedIntegerLiteral.
    **/
    init(val: Int, lineContext: LineContext?) {
        self.val = val
        super.init(lineContext: lineContext)
    }
    
    override public var description: String {
        return "SwiftSignedIntegerLiteral - val:\(val)"
    }
}

// A 'Double' node in the AST.
public class SwiftDoubleLiteral: SwiftExpr {
    let val: Double
    
    /**
    Initialises a SwiftDoubleLiteral node.
    
    :param: val The value represented by the double literal.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftSignedDoubleLiteral.
    **/
    init(val: Double, lineContext: LineContext?) {
        self.val = val
        super.init(lineContext: lineContext)
    }
    
    override public var description: String {
        return "SwiftSignedDoubleLiteral - val:\(val)"
    }
}

// A boolean literal node in the AST.
public class SwiftBooleanLiteral: SwiftExpr {
    let val: Bool
    
    init(val: Bool, lineContext: LineContext?) {
        self.val = val
        super.init(assignable: false, lineContext: lineContext)
    }
}


// An identifier expression node in the AST.
public class SwiftIdentifierString: SwiftExpr {
    var name: String
    
    /**
    Initialises a SwiftIdentifierString node.
    
    :param: id The identifier string.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftIdentifierString.
    **/
    init(name: String, lineContext: LineContext?) {
        self.name = name
        super.init(assignable: true, lineContext: lineContext)
    }
}

// A binary expression node in the AST.
public class SwiftBinaryExpression: SwiftExpr {
    let op: String
    let lhs: SwiftExpr
    let rhs: SwiftExpr
    
    /**
    Initialises a SwiftBinaryExpression node.

    :param: op The binary operator.
    :param: lhs The left hand side of the binary expression.
    :param: rhs The left hand side of the binary expression.
    
    :returns: An initialised SwiftBinaryExpression node
    **/
    init(op: String, lhs: SwiftExpr, rhs:SwiftExpr) {
        self.op = op
        self.lhs = lhs
        self.rhs = rhs
        super.init(assignable: false, lineContext: nil)
        
        switch lhs {
        case let l as SwiftBinaryExpression:
            self.children.extend(l.children)
        default:
            self.children.append(lhs)
        }
        
        switch rhs {
        case let r as SwiftBinaryExpression:
            self.children.extend(r.children)
        default:
            self.children.append(rhs)
        }
    }
}

public class SwiftPostfixExpression: SwiftExpr {
    let expr: SwiftExpr
    let op: String
    
    init(op: String, expr: SwiftExpr, lineContext: LineContext?) {
        self.op = op
        self.expr = expr
        super.init(assignable: false, lineContext: lineContext)
        self.lineContext = lineContext
    }
}

public class SwiftPrefixExpression: SwiftExpr {
    let expr: SwiftExpr
    let op: String
    
    init(op: String, expr: SwiftExpr, lineContext: LineContext?) {
        self.op = op
        self.expr = expr
        super.init(assignable: false, lineContext: lineContext)
        self.lineContext = lineContext
    }
}



//MARK: SwiftType

// An abstract class representing a type in the AST.
public class SwiftType: SwiftAST, Equatable {}

// A type identifier node in the AST.
public class SwiftTypeIdentifier: SwiftType {
    var identifier: String
    
    /**
    Initialises a SwiftTypeIdentifier node.
    
    :param: identifier The type identifier string.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftTypeIdentifier.
    **/
    init(identifier: String, lineContext: LineContext?) {
        self.identifier = identifier
        super.init(lineContext: lineContext)
    }
    
    override public var description: String {
        return self.identifier
    }
}

//MARK: -
//MARK: Parser

// A class used to parse a [SwiftToken], accompanied by [LineContext].
public class SwiftParser {
    
    var tokens: [SwiftToken]
    var lineContext: [LineContext]
    lazy public private(set) var errors = [SCError]()
    
    var binaryOperatorPrecedence: Dictionary<String, Int> = [
        "<<":   160,
        ">>":   160,
        
        "*":    150,
        "/":    150,
        "%":    150,
        "&*":   150,
        "&/":   150,
        "&%":   150,
        "&":    150,
        
        "+":    140,
        "-":    140,
        "&+":   140,
        "&-":   140,
        "|":    140,
        "^":    140,
        
        "..":   135,
        "...":  135,
        
        "is":   132,
        "as":   132,
        
        "<":    130,
        "<=":   130,
        ">":    130,
        ">=":   130,
        "==":   130,
        "!=":   130,
        "===":  130,
        "!==":  130,
        "~=":   130,
        
        "&&":   120,
        
        "||":   110,
        
        "?":    100,
        
        "=":    90,
        "*=":   90,
        "/=":   90,
        "%=":   90,
        "+=":   90,
        "-=":   90,
        "<<=":  90,
        ">>=":  90,
        "&=":   90,
        "^=":   90,
        "|=":   90,
        "&&=":  90,
        "||=":  90,
    ]

    /**
    Gets the operator precedence for a specified operator.

    :param: op An operator.

    :returns: The precedence of the operator. Nil if the operator does not exist.
    **/
    func getOperatorPrecedence(op: String) -> Int {
        if let precedence = binaryOperatorPrecedence[op] {
            return precedence
        } else {
            return -1
        }
    }
    
    /**
    Initialises a SwiftParser.
    
    :param: tokens An array of SwiftToken values to parse.
    :param: lineContext An array of LineContext values corresponding to the tokens.
    
    :returns: An initialised SwiftIdentifierString.
    **/
    init(tokens: [SwiftToken], lineContext: [LineContext] = []) {
        self.tokens = tokens
        self.lineContext = lineContext
    }
    
    /**
    Generates an AST from the tokens and lineContext provided.
    
    :returns: A SwiftBody if no errors occured, nil otherwise.
    **/
    func generateAST() -> SwiftBody? {
        return parseBody()
    }
    
    // Removes the first value from tokens and lineContext respectively.
    private func consumeToken() {
        tokens.removeAtIndex(0)
        lineContext.removeAtIndex(0)
    }
    
    /**
    Parses a program or closure body.
    
    :param: bracesRequired If true, will validate presence of braces, otherwise will not.
    
    :returns: A SwiftBody if no errors occured, nil otherwise.
    **/
    private func parseBody(bracesRequired: Bool = false) -> SwiftBody? {
        if bracesRequired {
            switch tokens[0] {
            case .LeftBrace:
                consumeToken()
            default:
                errors.append(SCError(message: "Missing expected brace.", lineContext: self.lineContext[0]))
                return nil
            }
        }
        
        var body = SwiftBody(lineContext: self.lineContext[0])
        while !tokens.isEmpty {
            // If braces are required, check for them and return if encountered
            if bracesRequired {
                switch tokens[0] {
                case .RightBrace:
                    consumeToken()
                    return body
                default:
                    break
                }
            }
            // Otherwise, parse statement as normal, adding the statement as a child of the body
            if let statement = parseStatement() {
                body.children.append(statement)
            } else if errors.count > 0 {
                return nil
            }
        }
        return body
    }
    
    /**
    Parses a statement
    
    :returns: A SwiftAST subclass if no errors occured, nil otherwise.
    **/
    private func parseStatement() -> SwiftAST? {
        switch tokens[0] {
        case .VariableDeclaration:
            fallthrough
        case .ConstantDeclaration:
            return parseDeclarationStatement()
        case .IntegerLiteral(_):
            fallthrough
        case .DoubleLiteral(_):
            fallthrough
        case .LeftBracket:
            fallthrough
        case .Identifier(_):
            if let lhs = parsePrimary() {
                if tokens.count == 0 {
                    return lhs
                }
                switch tokens[0] {
                case .InfixOperator("=") where lhs.isAssignable:
                    return parseAssignment(lhs)
                default:
                    return parseOperationRHS(precedence: 0, lhs: lhs)
                }
            } else {
                return nil
            }
        case .While:
            fallthrough
        case .If:
            return parseConditionalStatement()
        case .Function:
            return parseFunctionDeclaration()
        case .SemiColon:
            fallthrough
        case .NewLine:
            consumeToken()
            return nil
        default:
            errors.append(SCError(message: "Unexpected token \(tokens[0]) encountered.", lineContext: lineContext[0]))
            return nil
        }
    }
    
    /**
    Parses the right hand side of a binary expression.

    :param: precedence The current precedence to consider when parsing.
    :param: lhs The current left hand side of the expression being parsed.

    :returns: An optional SwiftExpr.
    **/
    func parseOperationRHS(#precedence: Int, var lhs: SwiftExpr) -> SwiftExpr? {
        // If there are no more tokens, return the lhs
        if tokens.count == 0 {
            return lhs
        }
        
        // Otherwise, switch on the first token
        switch tokens[0] {
        case .InfixOperator(let op):
            let tokenPrecedence = getOperatorPrecedence(op)
            // If the token we have encountered does not bind as tightly as the current precedence, return the current expression
            if tokenPrecedence < precedence {
                return lhs
            }
            
            // Get next operand
            consumeToken()
            
            // Error handling
            if let rhs = parsePrimary() {
                // No further tokens
                if tokens.count == 0 {
                    return SwiftBinaryExpression(op: op, lhs: lhs, rhs: rhs)
                }
                
                // Get next operator
                switch tokens[0] {
                case .InfixOperator(let nextOp):
                    let nextTokenPrecedence = getOperatorPrecedence(nextOp)
                    
                    // The next token has higher precedence, parse from the rhs onwards.
                    if tokenPrecedence < nextTokenPrecedence {
                        if let newRhs = parseOperationRHS(precedence: tokenPrecedence, lhs: rhs) {
                            return parseOperationRHS(precedence: precedence + 1, lhs: SwiftBinaryExpression(op: op, lhs: lhs, rhs: newRhs))
                        } else {
                            return nil
                        }
                    }
                    return parseOperationRHS(precedence: precedence + 1, lhs: SwiftBinaryExpression(op: op, lhs: lhs, rhs: rhs))
                    // Encountered a different token, return the intermediate result.
                default:
                    return SwiftBinaryExpression(op: op, lhs: lhs, rhs: rhs)
                }

            } else {
                return nil
            }
        // Collapse the postfix operator and continue parsing
        case .PostfixOperator(let op):
            let context = self.lineContext[0]
            consumeToken()
            let newLHS = SwiftPostfixExpression(op: op, expr: lhs, lineContext: context)
            return parseOperationRHS(precedence: precedence, lhs: newLHS)
        // Collapse the prefix operator and continue parsing
        case .PrefixOperator(let op):
            let context = self.lineContext[0]
            consumeToken()
            let newLHS = SwiftPrefixExpression(op: op, expr: lhs, lineContext: context)
            return parseOperationRHS(precedence: precedence, lhs: newLHS)
        // Encountered a different token, return the lhs.
        default:
            return lhs
        }
    }
    
    /**
    Parses an assignment.

    :param: store The variable or constant where the assignment should be stored.

    :return: An optional SwiftAssignment node.
    **/
    func parseAssignment(store: SwiftExpr) -> SwiftAssignment? {
        switch tokens[0] {
        case .InfixOperator("="):
            consumeToken()
            if let rhs = parseExpression() {
                return SwiftAssignment(storage: store, expression: rhs)
            } else {
                return nil
            }
        default:
            errors.append(SCError(message: "Missing expected '='.", lineContext: self.lineContext[0]))
            return nil
        }
    }

    /**
    Parses a while statement.

    :return: A SwiftWhileStatement if no errors occured, nil otherwise.
    **/
    func parseConditionalStatement() -> SwiftConditionalStatement? {
        let context = self.lineContext[0]
        var token: SwiftToken
        switch tokens[0] {
        case .If:
            fallthrough
        case .While:
            token = tokens[0]
            consumeToken()
        default:
            errors.append(SCError(message: "Missing expected 'while'.", lineContext: self.lineContext[0]))
            return nil
        }
        
        if let cond = parseExpression(), let body = parseBody(bracesRequired: true) {
            switch token {
            case .While:
                return SwiftWhileStatement(condition: cond, body: body, lineContext: context)
            case .If:
                return SwiftIfStatement(condition: cond, body: body, lineContext: context)
            default:
                return nil
            }
        }
        
        // In the presence of an error, return nil
        return nil
    }
    
    /**
    Parses a declaration.
    
    :returns: A SwiftAST subclass if no errors occured, nil otherwise.
    **/
    private func parseDeclarationStatement() -> SwiftAST? {
        var isConstant = true
        switch tokens[0] {
        case .ConstantDeclaration:
            consumeToken()
        case .VariableDeclaration:
            consumeToken()
            isConstant = false
        default:
            errors.append(SCError(message: "Missing expected 'let' or 'var'.", lineContext: self.lineContext[0]))
            return nil
        }
        if let declaration = parseStorageDeclaration() {
            declaration.isConstant = isConstant
            return declaration
        }
        return nil
    }
    
    /**
    Parses a pattern consisting of an assignment.
    
    :returns: A SwiftDeclaration if no errors occured, nil otherwise.
    **/
    private func parseStorageDeclaration(isFunctionParameter: Bool = false) -> SwiftDeclaration? {
        var type: SwiftType?
        let context = self.lineContext[0]
        if let declarationIdentifier = parseIdentifierDeclaration() {
            let declarationNode = isFunctionParameter ? SwiftFunctionParameter(id: declarationIdentifier, lineContext: context) : SwiftDeclaration(id: declarationIdentifier, lineContext: context)
            
            if tokens.count > 0 {
                switch tokens[0] {
                case .Colon:
                    consumeToken()
                    type = parseType()
                    if type == nil {
                        errors.append(SCError(message: "Could not parse type.", lineContext: self.lineContext[0]))
                        return nil
                    }
                    declarationNode.type = type
                default:
                    break
                }
            }
            
            if tokens.count > 0 {
                // Check for optional assignment
                switch tokens[0] {
                case .InfixOperator("="):
                    consumeToken()
                    if let assignment = parseExpression() {
                        declarationNode.assignment = assignment
                    } else {
                        return nil
                    }
                default:
                    break;
                }
            }
            return declarationNode
        } else {
            return nil
        }
    }
    
    /**
    Parses an identifier used in a declaration.
    
    :returns: A String if no errors occured, nil otherwise.
    **/
    private func parseIdentifierDeclaration() -> String? {
        switch tokens[0] {
        case .Identifier(let string):
            consumeToken()
            return string
        default:
            errors.append(SCError(message: "Missing expected identifier.", lineContext: self.lineContext[0]))
            return nil
        }
    }
    
    /**
    Parses a type.
    
    :returns: A SwiftTypeIdentifier if no errors occured, nil otherwise.
    **/
    private func parseType() -> SwiftTypeIdentifier? {
        switch tokens[0] {
        case .Identifier(let t):
            let context = self.lineContext[0]
            consumeToken()
            return SwiftTypeIdentifier(identifier: t, lineContext: context)
        default:
            return nil
        }
    }
    
    /**
    Parses a Swift expression.
    
    :returns: A SwiftExpr if no errors occured, nil otherwise.
    **/
    private func parseExpression() -> SwiftExpr? {
        if let primary = parsePrimary() {
            return parseOperationRHS(precedence: 0, lhs: primary)
        } else {
            return nil
        }
    }
    
    /**
    Parses the first part of a SwiftExpr.
    
    :returns: A SwiftExpr if no errors occured, nil otherwise.
    **/
    private func parsePrimary() -> SwiftExpr? {
        let context = self.lineContext[0]
        switch tokens[0] {
        case .Identifier(let string):
            return parseIdentifierExpression()
        case .PrefixOperator(let op):
            consumeToken()
            if let expr = parsePrimary() {
                return SwiftPrefixExpression(op: op, expr: expr, lineContext: context)
            } else {
                return nil
            }
        case .IntegerLiteral(_):
            fallthrough
        case .DoubleLiteral(_):
            return parseNumberExpression()
        case .True:
            consumeToken()
            return SwiftBooleanLiteral(val: true, lineContext: context)
        case .False:
            consumeToken()
            return SwiftBooleanLiteral(val: false, lineContext: context)
        case .LeftBracket:
            return parseParenthesesExpression()
        default:
            errors.append(SCError(message: "\(tokens[0]) is not a Swift expression.", lineContext: self.lineContext[0]))
            return nil
        }
    }
    
    /**
    Parses an identifier within an expression.
    
    :returns: A SwiftExpr if no errors occured, nil otherwise.
    **/
    private func parseIdentifierExpression() -> SwiftExpr? {
        // Get identifier
        let context = self.lineContext[0]
        var identifier: SwiftIdentifierString!
        switch tokens[0] {
        case .Identifier(let id):
            consumeToken()
            identifier = SwiftIdentifierString(name: id, lineContext: context)
        default:
            errors.append(SCError(message: "Missing expected identifier.", lineContext: self.lineContext[0]))
            return nil
        }
        
        // Check if it's a function call
        if tokens.count == 0 {
            return identifier
        }
        switch tokens[0] {
        case .LeftBracket:
            consumeToken()
            var args = [SwiftExpr]()
            while true {
                if tokens.count == 0 {
                    errors.append(SCError(message: "Missing expected ')' in function argument list.", lineContext: self.lineContext[0]))
                    return nil
                }
                switch tokens[0] {
                case .RightBracket:
                    consumeToken()
                    return SwiftCall(identifier: identifier, arguments: args)
                case .Comma:
                    consumeToken()
                default:
                    if let exp = parseExpression() {
                        args.append(exp)
                    } else {
                        return nil
                    }
                }
            }
        default:
            return identifier
        }
    }

    /**
    Parses a numerical literal.
    
    :returns: A SwiftExpr if no errors occured, nil otherwise.
    **/
    private func parseNumberExpression() -> SwiftExpr? {
        let context = self.lineContext[0]
        switch tokens[0] {
        case .IntegerLiteral(let int):
            consumeToken()
            return SwiftSignedIntegerLiteral(val: int, lineContext: context)
        case .DoubleLiteral(let double):
            consumeToken()
            return SwiftDoubleLiteral(val: double, lineContext: context)
        default:
            errors.append(SCError(message: "Missing expected Int or Double literal.", lineContext: self.lineContext[0]))
            return nil
        }
    }
    
    /**
    Parses an expression enclosed in parentheses.
    
    :returns: A SwiftExpr if no errors occured, nil otherwise.
    **/
    private func parseParenthesesExpression() -> SwiftExpr? {
        let context = self.lineContext[0]
        switch tokens[0] {
        case .LeftBracket:
            consumeToken()
        default:
            errors.append(SCError(message: "Missing expected '('.", lineContext: self.lineContext[0]))
            return nil
        }
        
        if let expr = parseExpression() {
            switch tokens[0] {
            case .RightBracket:
                consumeToken()
                return expr
            default:
                errors.append(SCError(message: "Missing expected ')'.", lineContext: self.lineContext[0]))
                return nil
            }
        } else {
            return nil
        }
    }
    
    /**
    Parses a function declaration.
    
    :returns: A SwiftFunctionDeclaration if no errors occured, nil otherwise
    **/
    func parseFunctionDeclaration() -> SwiftFunctionDeclaration? {
        let context = self.lineContext[0]
        switch tokens[0] {
        case .Function:
            consumeToken()
        default:
            errors.append(SCError(message: "Missing expected 'func'.", lineContext: self.lineContext[0]))
            return nil
        }
        
        let functionIdentifier: String
        switch tokens[0] {
        case .Identifier(let string):
            functionIdentifier = string
            consumeToken()
        default:
            errors.append(SCError(message: "Missing expected function identifier.", lineContext: self.lineContext[0]))
            return nil
        }
        
        let functionParameters: [SwiftFunctionParameter]
        
        if let params = parseFunctionParameters() {
            functionParameters = params
        } else {
            return nil
        }

        let returnType: SwiftType
        
        let returnTypeContext = self.lineContext[0]
        switch tokens[0] {
        case .Returns:
            consumeToken()
            if let type = parseType() {
                returnType = type
            } else {
                return nil
            }
        default:
            // If not specified, function type is Void
            returnType = SwiftTypeIdentifier(identifier: "Void", lineContext: context)
        }
        
        var body: SwiftFunctionBody?
        if (tokens.isEmpty) {
            errors.append(SCError(message: "Function body not specified.", lineContext: returnTypeContext))
            return nil
        }
        let bodyContext = self.lineContext[0]
        switch tokens[0] {
        case .LeftBrace:
            if let closure = parseBody(bracesRequired: true) {
                body = SwiftFunctionBody(closure, lineContext: bodyContext)
                fallthrough
            } else {
                return nil
            }
        default:
            return SwiftFunctionDeclaration(id: functionIdentifier, parameters: functionParameters, returnType: returnType, body: body, lineContext: context)
        }
    }
    
    func parseFunctionParameters() -> [SwiftFunctionParameter]? {
        switch tokens[0] {
        case .LeftBracket:
            consumeToken()
        default:
            errors.append(SCError(message: "Missing expected '('.", lineContext: self.lineContext[0]))
            return nil
        }
        
        func parseParams() -> [SwiftFunctionParameter]? {
            var functionParameters: [SwiftFunctionParameter] = [SwiftFunctionParameter]()
            while true {
                switch tokens[0] {
                case .RightBracket:
                    return functionParameters
                case .Comma:
                    consumeToken()
                default:
                    if let arg = parseStorageDeclaration(isFunctionParameter: true) as? SwiftFunctionParameter {
                        functionParameters.append(arg)
                    } else {
                        return nil
                    }
                }
            }
        }
        
        if let params = parseParams() {
            switch tokens[0] {
            case .RightBracket:
                consumeToken()
                return params
            default:
                errors.append(SCError(message: "Missing expected ')'.", lineContext: self.lineContext[0]))
                return nil
            }
        } else {
            return nil
        }
    }



}