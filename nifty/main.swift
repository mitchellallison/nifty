//
//  main.swift
//  nifty
//
//  Created by Mitchell Allison on 29/10/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import Foundation

extension String {
    func tokenise() -> SwiftLexicalRepresentation? {
        let (rep, errors) = SwiftToken.tokenise(self)
        if (errors == nil) {
            return rep
        } else {
            return nil
        }
    }
}

extension SwiftLexicalRepresentation {
    func parse() -> SwiftAST? {
        let parser = SwiftParser(tokens: tokens, lineContext: context)
        let ast = parser.generateAST()
        return ast
    }
}

if let ast = "let x: Int = 1".tokenise()?.parse() {
    println(ast)
}