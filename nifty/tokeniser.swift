//
//  tokeniser.swift
//  nifty
//
//  Created by Mitchell Allison on 29/10/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import Foundation

//MARK: Program tokenisation

/// Position information within a program
public class LineContext : NSObject, Equatable {
    public typealias LinePosition = Int
    public typealias LineNumber = Int
    
    public var pos: LinePosition
    public var line: LineNumber
    
    init(pos: LinePosition, line: LineNumber) {
        self.pos = pos
        self.line = line;
    }
}

public func ==(lhs: LineContext, rhs: LineContext) -> Bool {
    return lhs.pos == rhs.pos && lhs.line == rhs.line
}

// A lexical representation of a source program. Composed of an array of SwiftToken enums, and
// a corresponding array of LineContext objects, referring to the position at which the enums
// were encountered in the source.
class SwiftLexicalRepresentation: Printable {
    var tokens: [SwiftToken]
    var context: [LineContext]
    
    init(tokens: [SwiftToken], context: [LineContext]) {
        self.tokens = tokens
        self.context = context
    }
    
    var description: String {
        let tokenDescriptions = tokens.map({$0.description + " "})
        let description = tokenDescriptions.reduce("", combine: { (description, token) -> String in
            description + token
        })
        return description
    }
}

// Representation of Swift's lexical syntax
enum SwiftToken: Printable, Equatable {
    case Invalid(String)
    case IntegerLiteral(Int)
    case DoubleLiteral(Double)
    
    case Identifier(String)
    
    case PrefixOperator(String), InfixOperator(String), PostfixOperator(String)
    
    case VariableDeclaration, ConstantDeclaration
    
    case LeftBracket, LeftBrace, RightBracket, RightBrace
    
    case Colon
    
    case Comma
    
    case While, If, Return, Function
    
    case True, False
    
    case Returns
    
    case NewLine, SemiColon
    
    var description: String {
        switch self {
        case .Invalid(let string):
            return "Invalid token: \(string)"
        case .IntegerLiteral(let val):
            return val.description
        case .DoubleLiteral(let double):
            return double.description
        case .Identifier(let string):
            return string
        case .SemiColon:
            return ";"
        case .NewLine:
            return "\n"
        case .PrefixOperator(let string):
            return string
        case .InfixOperator(let string):
            return string
        case .PostfixOperator(let string):
            return string
        case .VariableDeclaration:
            return "var"
        case .ConstantDeclaration:
            return "let"
        case .Function:
            return "func"
        case .LeftBracket:
            return "("
        case .LeftBrace:
            return "{"
        case .RightBracket:
            return ")"
        case .RightBrace:
            return "}"
        case .Colon:
            return ":"
        case .Comma:
            return ","
        case .While:
            return "while"
        case .If:
            return "if"
        case .Return:
            return "return"
        case .Returns:
            return "->"
        case .True:
            return "true"
        case .False:
            return "false"
        }
    }
    
    /**
    Tokenises a program, returning a SwiftLexicalRepresentation object for the given source.
    
    :param: input The source program.
    
    :returns: A lexical representation of the program.
    */
    static func tokenise(var input: String) -> (SwiftLexicalRepresentation, [SCError]?) {
        
        var errors = [SCError]()
        
        let identifierRegex = "([a-z_][a-z0-9]*)"
        
        var linepos = 1, line = 1
        
        // An array of SwiftToken enum values, representing our source program
        var tokens = [SwiftToken]()
        // An array of LineContext values, corresponding to position and line information for the 
        // SwiftToken at the corresponding index.
        var context = [LineContext]()
        
        while (!input.isEmpty) {
            // Temporarily store the old line and position
            let cachedLinePos = linepos
            let cachedLine = line
            
            input
                // Matches a binary literal e.g 0b101
                .match(/"^0b([01]+)"/"i") {
                    let num = strtol($0[1], nil, 2)
                    tokens.append(SwiftToken.IntegerLiteral(num))
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches an octal literal e.g 0c106
                .match(/"^0c([0-7]+)"/"i") {
                    let num = strtol($0[1], nil, 8)
                    tokens.append(SwiftToken.IntegerLiteral(num))
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches a hexadecimal literal e.g 0xdeadbeef
                .match(/"^0x([0-9A-F]+)"/"i") {
                    let num = strtol($0[1], nil, 16)
                    tokens.append(SwiftToken.IntegerLiteral(num))
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
        
                // Matches a Double literal e.g 1.1
                .match(/"^[0-9]*\\.[0-9]+"/"i") {
                    let num = $0[0] as NSString
                    tokens.append(SwiftToken.DoubleLiteral(num.doubleValue))
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches an Int literal e.g 1
                .match(/"^[0-9]+"/"i") {
                    let num = strtol($0[0], nil, 10)
                    tokens.append(SwiftToken.IntegerLiteral(num))
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                
                // Declarations
                
                // Matches the var keyword
                .match(/"^var(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.VariableDeclaration)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches the let keyword
                .match(/"^let(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.ConstantDeclaration)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Keywords
                
                // Matches the func keyword
                .match(/"^func(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.Function)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches the if keyword
                .match(/"^if(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.If)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?

                // Matches the while keyword
                .match(/"^while(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.While)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches the return keyword
                .match(/"^return(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.Return)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches the true keyword
                .match(/"^true(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.True)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?

                // Matches the false keyword
                .match(/"^false(?!\(identifierRegex))") {
                    tokens.append(SwiftToken.False)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Identifiers
                
                // Matches the identifiers, with optional prefix and postfix operators (++/--)
                .match(/"^([\\+\\-]{2,})?\(identifierRegex)([\\+\\-]{2,})?"/"i") {
                    var newLinePos = cachedLinePos
                    if !$0[1].isEmpty {
                        tokens.append(SwiftToken.PrefixOperator($0[1]))
                        context.append(LineContext(pos: newLinePos, line: cachedLine))
                        newLinePos += count($0[1])
                    }
                    tokens.append(SwiftToken.Identifier($0[2]))
                    context.append(LineContext(pos: newLinePos, line: cachedLine))
                    newLinePos += count($0[2])
                    if !$0[3].isEmpty {
                        // tokenise postfix operator
                        tokens.append(SwiftToken.PostfixOperator($0[3]))
                        context.append(LineContext(pos: newLinePos, line: cachedLine))
                    }
                    linepos += count($0[0])
                }?
                
                // Operators & punctuation
                
                // Matches the arrow symbol
                .match(/"^->") {
                    tokens.append(SwiftToken.Returns)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                
                // Matches the infix operators (+,-,*,/)
                .match(/"^[\\+\\-/*<>=](=)?") {
                    tokens.append(SwiftToken.InfixOperator($0[0]))
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Parentheses & Tuples
                
                // Matches a left bracket
                .match(/"^\\(") {
                    tokens.append(SwiftToken.LeftBracket)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches a left brace
                .match(/"^\\{") {
                    tokens.append(SwiftToken.LeftBrace)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches a right bracket
                .match(/"^\\)") {
                    tokens.append(SwiftToken.RightBracket)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches a right brace
                .match(/"^\\}") {
                    tokens.append(SwiftToken.RightBrace)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches a comma
                .match(/"^,") {
                    tokens.append(SwiftToken.Comma)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Type declaration
                
                // Matches a colon
                .match(/"^:") {
                    tokens.append(SwiftToken.Colon)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                
                // Whitespace
                
                // Matches new lines
                .match(/"^(\\n)+") {
                    tokens.append(SwiftToken.NewLine)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos = 0
                    line += $0.count - 1
                }?
                
                // Matches semicolons
                .match(/"^(;)+") {
                    tokens.append(SwiftToken.SemiColon)
                    context.append(LineContext(pos: cachedLinePos, line: cachedLine))
                    linepos += count($0[0])
                }?
                
                // Matches any other whitespace
                .match(/"^\\s") {
                    linepos += count($0[0])
                }?
                
                // Error
                
                // Matches anything else. At this point, an error must have occured
                .match(/"^.*") {
                    tokens.append(SwiftToken.Invalid($0[0]))
                    context.append(LineContext(pos: linepos, line: line))
                    errors.append(SCError(message: "Invalid syntax \($0[0]) encountered.", lineContext: LineContext(pos: linepos, line: line)))
                    linepos += count($0[0])
                }
            
            // Get position of the first character in our input string.
            var index = input.startIndex
            // Calculate the position of the first character we have not yet encountered
            let newIndex = advance(index, linepos - cachedLinePos)
            // Replace old string with substring starting from newIndex
            input = input.substringFromIndex(newIndex)
        }
        let rep = SwiftLexicalRepresentation(tokens: tokens, context: context)
        if (errors.isEmpty) {
            return (rep, nil)
        } else {
            return (rep, errors)
        }
        
    }
}

// Equatable conformance for SwiftToken
func ==(lhs: SwiftToken, rhs: SwiftToken) -> Bool {
    switch (lhs, rhs) {
    case (let .IntegerLiteral(x), let .IntegerLiteral(y)):
        return x == y
    case (let .Invalid(x), let .Invalid(y)):
        return x == y
    case (let .Identifier(x), let .Identifier(y)):
        return x == y
    case (let .DoubleLiteral(x), let .DoubleLiteral(y)):
        return x == y
    case (let .PrefixOperator(x), let .PrefixOperator(y)):
        return x == y
    case (let .InfixOperator(x), let .InfixOperator(y)):
        return x == y
    case (let .PostfixOperator(x), let .PostfixOperator(y)):
        return x == y
    default:
        return false
    }
}

//MARK: String extensions

// Extensions for String, including range and match.
extension String {
    /**
    Generates an NSRange.
    
    :returns: An NSRange relating to the length of the string.
    */
    func range() -> NSRange {
        return NSMakeRange(0, count(self))
    }
    
    /**
    Matches the string against a regular expression. If the expression matches, the closure is
    executed, with the matches parameter populated with the substrings matched for the groups
    of the regular expression.
    
    :param: regex The NSRegularExpression used to match against the string.
    :param: closure A closure taking an array of substrings corresponding to group matches and with a Void return type.
    
    :returns: The string (self) if a match did not occur, nil otherwise.
    */
    func match(regex: NSRegularExpression, closure: (matches: [String]) -> ()) -> String? {
        // Check for first match in string.
        if let match = regex.firstMatchInString(self, options: nil, range: self.range()) {
            var groups: [String] = []
            for index in 0..<match.numberOfRanges {
                // Match found, gather substrings for groups.
                let rangeAtIndex: NSRange = match.rangeAtIndex(index)
                let myString = self as NSString
                var group: String!
                if rangeAtIndex.location != NSNotFound {
                    // Group matched.
                    group = myString.substringWithRange(rangeAtIndex)
                } else {
                    // Optional group did not match.
                    group = ""
                }
                groups.append(group)
            }
            // Execute the closure with the substrings matched with the regular expression groups.
            closure(matches: groups)
            return nil
        } else {
            return self
        }
    }
}



//MARK: Regular expression helpers

prefix operator  / {}

/**
Constructs an NSRegularExpression from a string.

:param: regex The pattern to construct the NSRegularExpression with.

:returns: An NSRegularExpression constructed from the string.
*/
prefix func /(regex: String) -> NSRegularExpression {
    return NSRegularExpression(pattern: regex, options: nil, error: nil)!
}

/**
Constructs an NSRegularExpression from an NSRegularExpression and a set of letter used to define options.

:param: lhs The NSRegularExpression to modify.
:param: rhs The options {i,x,p,s,m,w,d} to add to the NSRegularExpression as defined by the ICU standards.

:returns: An NSRegularExpression constructed from the previous NSRegularExpression and added options.
*/
func /(lhs: NSRegularExpression, rhs: String) -> NSRegularExpression {
    let pattern = lhs.pattern
    var optionsMask: UInt = 0
    
    rhs.match(/"i") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.CaseInsensitive.rawValue
    }
    rhs.match(/"x") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.AllowCommentsAndWhitespace.rawValue
    }
    rhs.match(/"q") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.IgnoreMetacharacters.rawValue
    }
    rhs.match(/"s") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.DotMatchesLineSeparators.rawValue
    }
    rhs.match(/"m") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.AnchorsMatchLines.rawValue
    }
    rhs.match(/"w") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.UseUnicodeWordBoundaries.rawValue
    }
    rhs.match(/"d") { (groups: [String]) -> () in
        optionsMask |= NSRegularExpressionOptions.UseUnixLineSeparators.rawValue
    }
    return NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(optionsMask), error: nil)!;
}

func ~=(string: String, regex: NSRegularExpression) -> Bool {
    return regex.firstMatchInString(string, options: nil, range:string.range()) != nil
}
