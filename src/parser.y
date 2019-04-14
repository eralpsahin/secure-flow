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
%token PLUS "+";
%token MINUS "-";
%token LESS "<";
%token EQUAL "=";
%token ASSIGNMENT ":=";
%token <std::string> IDENTIFIER  "identifier";
%token <uint64_t> NUMBER "number";

%token LEFTPAR "leftpar";
%token RIGHTPAR "rightpar";
%token COMMA "comma";
%token END 0 "end of file" // End of File error message (Potentially unused)

%type< EzAquarii::Command > command block_command;
%type< std::vector<uint64_t> > arguments;

%start program

%%

program :   {
                cout << "*** RUN ***" << endl;
                cout << "Type function with list of parmeters. Parameter list can be empty" << endl
                     << "or contain positive integers only. Examples: " << endl
                     << " * function()" << endl
                     << " * function(1,2,3)" << endl
                     << "Terminate listing with ; to see parsed AST" << endl
                     << "Terminate parser with Ctrl-D" << endl;
                
                cout << endl << "prompt> ";
                
                driver.Clear();
            }
        | program command
            {
                const Command &cmd = $command;
                cout << "command parsed, updating AST" << endl;
                driver.AddCommand(cmd);
                cout << endl << "prompt> ";
            }
        | program block_command
            {
                const Command &cmd = $block_command;
                cout << "Block command parsed, updating AST" << endl;
                driver.AddCommand(cmd);
                cout << endl << "prompt> ";
            }
        | program SEMICOLON
            {
                cout << "*** STOP RUN ***" << endl;
                cout << driver.ToString() << endl;
            }
        | program expression
            {
                cout << "*** STOP RUN ***" << endl;
                cout << driver.ToString() << endl;
            }
        ;

block_command : LBRACES command RBRACES
            {
                $block_command = Command("Block"); // TODO: Reword command ID 
                cout << "Parsed block command" << endl;
            }
;

/*
 TODO: add locations
 TODO: add semantic logic
*/
expression : IDENTIFIER
        {

        }
    | NUMBER
        {
            cout << "Parsed number expression" << endl;
        }
    | expression PLUS IDENTIFIER
        {

        }
    | expression PLUS NUMBER
        {

        }
    | expression MINUS IDENTIFIER
        {

        }
    | expression MINUS NUMBER
        {

        }
    | expression LESS IDENTIFIER
        {

        }
    | expression LESS NUMBER
        {

        }
    | expression EQUAL IDENTIFIER
        {

        }
    | expression EQUAL NUMBER
        {

        }
;

command : IDENTIFIER LEFTPAR RIGHTPAR
        {
            string &id = $IDENTIFIER;
            cout << "ID: " << id << endl;
            $command = Command(id);
        }
    | IDENTIFIER LEFTPAR arguments RIGHTPAR
        {
            string &id = $IDENTIFIER;
            const std::vector<uint64_t> &args = $arguments;
            cout << "function: " << id << ", " << args.size() << endl;
            $command = Command(id, args);
        }
;

arguments[outer] : NUMBER
        {
            uint64_t number = $NUMBER;
            $outer = std::vector<uint64_t>();
            $outer.push_back(number);
            cout << "first argument: " << number << endl;
        }
    | arguments[inner] COMMA NUMBER
        {
            uint64_t number = $NUMBER;
            std::vector<uint64_t> &args = $inner;
            args.push_back(number);
            $outer = args;
            cout << "next argument: " << number << ", arg list size = " << args.size() << endl;
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
