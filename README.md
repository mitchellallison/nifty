Nifty - A Swift front-end for LLVM written (mostly) in Swift.
=====

When Swift was announced at WWDC earlier this
year, it generated a lot of excitement.
Described as "the first industrial-quality
systems programming language that is as
expressive and enjoyable as a scripting
language."[1], Swift was not only a
paradigm shift, encouraging exploration of
topics like functional programming, but
also a huge surprise to the Apple community.
Whilst the language features of Swift have been
thoroughly praised, perhaps the unsung hero in
this story is the Swift compiler itself,
enabling features from type inference to the
REPL (Read-Evaluate-Print-Loop).

In this series of [blog posts][blog], we'll be taking a basic look at compiler
architecture and developing our very own Swift compiler, Nifty, written (mostly) in
Swift.

## Isn't that hard? ##

Yes. For that reason, we're only going to touch on a small fraction of the
features that the real Swift compiler provides. The aim of this blog series is
to learn about compiler architecture as well as to explore using Swift language
features, not to replace Apple's Swift compiler.

It should also be mentioned that this set of tutorials may not (and is unlikely
to) teach compiler engineering best practices.

## What is our goal? ##

Our goal is to take the simple, iterative fibonacci program below as our input
and be able to generate a target representation of it. We will then learn how to
run this representation in a REPL.

```
func fibonacci(num: Int) -> Int {
    var iter = num
    var x = 0
    var y = 1
    while (iter > 0) {
        let tmpX = x
        x = y
        y = tmpX + y
        iter--
    }
    return x
}
```

## What do I need to know? ##

I'll assume that you've read "The Swift Programming Language"[2] and
that you're familiar with concepts from Objective-C. Later in the blog posts,
it will be useful to have a basic understanding of C++ (in the form of
Objective-C++), although not strictly necessary.

## So what is a compiler? ##

A compiler is a program which transforms source code written in a programming
language (in our case Swift, which we can call the source language) into a
another programming language (the target language, which for the purposes of
Nifty will be LLVM).

A compiler is comprised of a number of transformations, firstly over the source
code and later over more complicated data structures. Let's look briefly at
these transformations.

### Lexical analysis ###

The first stage aims to transform an input program into a set of tokens (sometimes
referred to as tokenisation). At this stage we are able to pick up basic
lexical errors, like invalid identifiers or characters. The tokens that are
produced are often annotated with information about the line and
position at which the token was encountered in the program for debugging purposes.

### Syntax analysis or Parsing ###

Now that we have a set of tokens and line and position context that are valid,
we begin to look at the structure of the program: the program's syntax. It is
here that we resolve ambiguity or warn about poorly structured programs. If
you've ever had a compiler complain about missing semicolons, syntax analysis
is to blame (or perhaps the blame is on you).

As syntax analysis is performed over the set of tokens, an Abstract Syntax Tree
(AST) is constructed. The AST is used to describe the program's structure
unambiguously.

### Semantic analysis ###

Syntax analysis checks that the structure of the program is valid, whereas the
next stage, semantic analysis, ensures that the meaning of the program is
correct: the program's semantics.

Semantic analysis is an open-ended task; different languages use varying levels
of semantic analysis. In the context of Swift, semantic analysis is where we
perform type checking and inference (the thing that saves you specifying those pesky type
annotations when declaring variables).

Semantic analysis is typically performed over the AST, annotating it with useful
information for later stages.

### Optimisation ###

Once we are more certain that we have a program that is both syntactically and
semantically valid, we can begin to perform some optimisations. The field of
compiler optimisations is vast, but to give you an idea, below is an example of
a simple 'peephole' optimisation.

```
// Before optimisation
let x = 12 + 200 * 4 
let y = 9 * 0

// After optimisation
let x = 812
let y = 0
```

In the example above, we perform 'constant folding' to prevent unnecessary
arithmetic operations when executing the program.

Many optimisations are generic and can be performed across programs, regardless
of the source language. As a result, some compilers (Nifty included) opt to
create an 'Intermediate Representation', a source agnostic data structure which
common optimisations and code generation techniques can be applied against.
LLVM defines an IR (the aptly named LLVM IR) to do just that. LLVM was
originally developed by Chris Lattner, coincidentally also listed as one of the
original authors of Swift.

### Code generation ###

At this stage, we take our AST (or our IR if we transformed the AST
appropriately) and 'walk the tree' to generate our target language. This often
involves architecture specific logic, but general tasks range from instruction
selection (picking the best instruction for a given task) to register
allocation (managing efficient use of small pieces of CPU memory).

With Nifty, our aim is to generate LLVM IR, and so we won't cover these typical
code generation techniques. We will however investigate how to build a REPL
(Read-Eval-Print-Loop) to evaluate our program using JIT (Just-In-Time)
code generation and a brief look at 'llc', an LLVM cross-compiler, to explore
transforming Swift to assembly.

## Acknowledgements ##

Nifty is inspired by [Kaleidoscope][kaleidoscope], a great tutorial
from the LLVM team on "Implementing a language with LLVM".

[1]:  https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/
[2]:   https://itunes.apple.com/gb/book/swift-programming-language/id881256329?mt=11
[kaleidoscope]: http://llvm.org/docs/tutorial/LangImpl1.html
[blog]: http://www.mitchellallison.com/blog/

