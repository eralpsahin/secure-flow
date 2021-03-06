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
            if (locals[i].GetIdentifier() == identifier)
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
%type< Type > more_commands;
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
;
block_command : LBRACES more_commands RBRACES
            {
                $block_command = $more_commands;
            }
            
;
more_commands[outer] : command
            {
                $outer = $command;
            }
        | command SEMICOLON more_commands[inner]
            {
                if ($command.GetType() == low || $inner.GetType() == low)
                    $outer = Type(low);
                else
                    $outer = Type(high);
            }        
;

expression[outer] : IDENTIFIER
        {
            $outer = find(locals,$IDENTIFIER);
        }
    | NUMBER
        {
            $outer = Type(low); // literals are low level
        }
    | expression[inner] PLUS IDENTIFIER
        {
           Type id = find(locals,$IDENTIFIER);
           $outer = Type::Coercion($inner,id);
        }
    | expression[inner] PLUS NUMBER
        {
            $outer = Type::Coercion($inner,Type(low));
        }
    | expression[inner] MINUS IDENTIFIER
        {
            Type id = find(locals,$IDENTIFIER);
            $outer = Type::Coercion($inner,id);
        }
    | expression[inner] MINUS NUMBER
        {
            $outer = Type::Coercion($inner,Type(low));
        }
    | expression[inner] LESS IDENTIFIER
        {
            Type id = find(locals,$IDENTIFIER);
            $outer = Type::Coercion($inner,id);
        }
    | expression[inner] LESS NUMBER
        {
            $outer = Type::Coercion($inner,Type(low));
        }
    | expression[inner] EQUAL IDENTIFIER
        {
            Type id = find(locals,$IDENTIFIER);
            $outer = Type::Coercion($inner,id);
        }
    | expression[inner] EQUAL NUMBER
        {
            $outer = Type::Coercion($inner,Type(low));
        }
;

command : WHILE expression DO block_command
        {
            if ($expression.GetType() > $block_command.GetType()) {
                cout << "Implicit unallowed flow" << endl;
                exit(0);
            }
            $command = $block_command;
            cout << "Parsed while loop" << endl;
        }
    | IF expression THEN block_command[then] ELSE block_command[else] // TODO: Refactor else requirement
        {
            if ($expression.GetType() > $then.GetType() || $expression.GetType() > $else.GetType()) {
                cout << "Implicit unallowed flow" << endl;
                exit(0);
            }
            if ($then.GetType() == low || $else.GetType() == low)
                $command = Type(low);
            else 
                $command = Type(high);

            cout << "Parsed if statement" << endl;
        }
    | LETVAR IDENTIFIER LBRACKET LEVEL RBRACKET { locals.push_back(Type($IDENTIFIER, $LEVEL)); } ASSIGNMENT expression IN block_command
        {
            locals.pop_back(); // Remove the declared variable
            /* Letvar SC is determined by the block only
            *  rather than the local variable declaration
            */
            $command = $block_command;
        }
    | IDENTIFIER ASSIGNMENT expression[rhs]
        {
            Type id = find(locals,$IDENTIFIER);
            if (id.GetType() < $rhs.GetType()) { // low identifier high expression
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
        cout << "Error: " << message << endl << "Error location: " << driver.GetLocation() << endl;
}
