%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0"
%language "c++" // Use C++ Lang
%defines
%define parser_class_name { Parser }

%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define api.namespace { EzAquarii }
%code requires
{
    #include <iostream>
    #include <string>
    #include <vector>
    #include <stdint.h>
    #include "command.h"

    using namespace std;

    namespace EzAquarii {
        class Scanner;
        class Interpreter;
    }
}

// Bison calls yylex() function that must be provided by us to suck tokens
// from the scanner. This block will be placed at the beginning of IMPLEMENTATION file (cpp).
// We define this function here (function! not method).
// This function is called only inside Bison, so we make it static to limit symbol visibility for the linker
// to avoid potential linking conflicts.
%code top
{
    #include <iostream>
    #include "scanner.h"
    #include "parser.hpp"
    #include "interpreter.h"
    #include "location.hh"
    
    // yylex() arguments are defined in parser.y
    static EzAquarii::Parser::symbol_type yylex(EzAquarii::Scanner &scanner, EzAquarii::Interpreter &driver) {
        return scanner.get_next_token();
    }
    
    // you can accomplish the same thing by inlining the code using preprocessor
    // x and y are same as in above static function
    // #define yylex(x, y) scanner.get_next_token()
    using namespace EzAquarii;
    std::vector<EzAquarii::Type> locals;
    Type find(std::vector<Type> &locals, std::string identifier) {
        for (size_t i = locals.size() - 1; i >= 0; i--) {
            if (locals[i].getIdentifier() == identifier)
            return locals[i];
        }
        std::cout << identifier << " is not declared \n";
        exit(0); 
    }  
    
}

%lex-param { EzAquarii::Scanner &scanner }
%lex-param { EzAquarii::Interpreter &driver }
%parse-param { EzAquarii::Scanner &scanner }
%parse-param { EzAquarii::Interpreter &driver }
%locations // Location Tracking
%define parse.trace
%define parse.error verbose

// Name clashes in generated files (Potentially unused)
%define api.token.prefix {TOKEN_}

%token SEMICOLON "semicolon";
%token IF "if";
%token THEN "then";
%token ELSE "else";
%token WHILE "while";
%token DO "do";
%token LETVAR "letvar";
%token IN "in";
%token LBRACES "{";
%token RBRACES "}";
%token LBRACKET "[";
%token RBRACKET "]";
%token PLUS "+";
%token MINUS "-";
%token LESS "<";
%token EQUAL "=";
%token ASSIGNMENT ":=";
%token <std::string> IDENTIFIER  "identifier";
%token <std::string> LEVEL  "level";
%token <uint64_t> NUMBER "number";

%token LEFTPAR "leftpar";
%token RIGHTPAR "rightpar";
%token COMMA "comma";
%token END 0 "end of file" // End of File error message (Potentially unused)

%type< Type > command block_command;
%type< Type > expression;
%start program

%%

program :   {
                cout << "*** RUN ***" << endl;
                cout << endl << "prompt> ";
                
                driver.Clear();
            }
        | program command SEMICOLON
            {
                //const Command &cmd = $command;
                cout << "Command parsed, updating AST" << endl;
                //driver.AddCommand(cmd);
                cout << endl << "prompt> ";
            }
        | program block_command SEMICOLON
            {
                //const Command &cmd = $block_command;
                cout << "Block command parsed, updating AST" << endl;
                //driver.AddCommand(cmd);
                cout << endl << "prompt> ";
            }
        | program expression SEMICOLON
            {
                //cout << "Expression parsed: " << $expression << endl;
                cout << endl << "prompt> ";
            }
;
block_command : LBRACES command RBRACES
            {
                $block_command = $command;
            }
            
;

/*
 TODO: add locations
 TODO: add semantic logic
*/
expression[outer] : IDENTIFIER
        {
            $outer = find(locals,$IDENTIFIER);
        }
    | NUMBER
        {
            $outer = Type("","L"); // literals are low level
        }
    | expression[inner] PLUS IDENTIFIER
        {
           Type id = find(locals,$IDENTIFIER);
           $outer = Type::Coercion($inner,id);
        }
    | expression[inner] PLUS NUMBER
        {
            $outer = Type::Coercion($inner,Type("","L"));
        }
    | expression[inner] MINUS IDENTIFIER
        {
            Type id = find(locals,$IDENTIFIER);
            $outer = Type::Coercion($inner,id);
        }
    | expression[inner] MINUS NUMBER
        {
            $outer = Type::Coercion($inner,Type("","L"));
        }
    | expression[inner] LESS IDENTIFIER
        {
            Type id = find(locals,$IDENTIFIER);
            $outer = Type::Coercion($inner,id);
        }
    | expression[inner] LESS NUMBER
        {
            $outer = Type::Coercion($inner,Type("","L"));
        }
    | expression[inner] EQUAL IDENTIFIER
        {
            Type id = find(locals,$IDENTIFIER);
            $outer = Type::Coercion($inner,id);
        }
    | expression[inner] EQUAL NUMBER
        {
            $outer = Type::Coercion($inner,Type("","L"));
        }
;

/*
 TODO: add if and let statements
 TODO: Remove template function commands
 TODO: Add logic
*/
command : WHILE expression DO block_command
        {
            if ($expression.getType() > $block_command.getType()) {
                cout << "Implicit unallowed flow" << endl;
                exit(0);
            }
            cout << "Parsed while loop" << endl;
        }
    | IF expression THEN block_command[then] ELSE block_command[else] // TODO: Refactor else requirement
        {
            if ($expression.getType() > $then.getType() || $expression.getType() > $else.getType()) {
                cout << "Implicit unallowed flow" << endl;
                exit(0);
            }
            $command = $expression;
            cout << "Parsed if statement" << endl;
        }
    | LETVAR IDENTIFIER LBRACKET LEVEL RBRACKET { locals.push_back(Type($IDENTIFIER, $LEVEL)); } ASSIGNMENT expression IN block_command
        {
            
            locals.pop_back(); // Remove the declared variable
        }
    | IDENTIFIER ASSIGNMENT expression[rhs]
        {
            Type id = find(locals,$IDENTIFIER);
            if (id.getType() < $rhs.getType()) { // low identifier high expression
                cout << "Explicit unallowed flow" << endl;
                exit(0);
            }
            $command = id;
            cout << "Parsed assignment expression" << endl;
            
        }
;
%%

// Bison expects us to provide implementation - otherwise linker complains
void EzAquarii::Parser::error(const location &loc , const std::string &message) {
        
        // Location should be initialized inside scanner action, but is not in this example.
        // Let's grab location directly from driver class.
	// cout << "Error: " << message << endl << "Location: " << loc << endl;
	
        cout << "Error: " << message << endl << "Error location: " << driver.GetLocation() << endl;
}
