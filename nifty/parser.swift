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
            reduce(split($0.description) { $0 == "\n" }, "") {
                return $0 + "\n\t" + $1
            }
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
public class SwiftDeclaration: SwiftAST {
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

//MARK: SwiftExpr

// An abstract class representing a Swift expression in the AST.
public class SwiftExpr: SwiftAST {
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

// An identifier expression node in the AST.
public class SwiftIdentifierString: SwiftExpr {
    var id: String
    
    /**
    Initialises a SwiftIdentifierString node.
    
    :param: id The identifier string.
    :param: lineContext An optional LineContext relating to the node.
    
    :returns: An initialised SwiftIdentifierString.
    **/
    init(id: String, lineContext: LineContext?) {
        self.id = id
        super.init(assignable: true, lineContext: lineContext)
    }
}


//MARK: SwiftType

// An abstract class representing a type in the AST.
public class SwiftType: SwiftAST {}

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
}

//MARK: -
//MARK: Parser

// A class used to parse a [SwiftToken], accompanied by [LineContext].
public class SwiftParser {
    
    var tokens: [SwiftToken]
    var lineContext: [LineContext]
    lazy public private(set) var errors = [SCError]()
    
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
                if errors.count > 0 {
                    return nil
                }
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
        case .Identifier(_):
            if let lhs = parsePrimary() {
                return lhs
            } else {
                return nil
            }
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
    private func parseStorageDeclaration() -> SwiftDeclaration? {
        // Get identifier
        var type: SwiftType?
        let context = self.lineContext[0]
        if let declarationIdentifier = parseIdentifierDeclaration() {
            let declarationNode = SwiftDeclaration(id: declarationIdentifier, lineContext: context)
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
                case .Equal:
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
        return parsePrimary()
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
        case .IntegerLiteral(_):
            fallthrough
        case .DoubleLiteral(_):
            return parseNumberExpression()
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
        var identifier: String!
        switch tokens[0] {
        case .Identifier(let id):
            consumeToken()
            identifier = id
        default:
            errors.append(SCError(message: "Missing expected identifier.", lineContext: self.lineContext[0]))
            return nil
        }
        return SwiftIdentifierString(id: identifier, lineContext: context)
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
}