%{
	#include <iostream>
	#include <cstdlib>
	#include "scanner.h"
	#include "interpreter.h"
	#include "parser.hpp"
	#include "location.hh"

	using namespace std;

	// Original yyterminate() macro returns int. Since we're using Bison 3 variants
	// as tokens, we must redefine it to change type from `int` to `Parser::semantic_type`
	#define yyterminate() EzAquarii::Parser::make_END(EzAquarii::location());

	/* 
	* This will track current scanner location.
	* Action is called when length of the token is known.
	* Gets called on token match before the action in flex.
	*/
	#define YY_USER_ACTION m_driver_.IncreaseLocation(yyleng);
	
	// !!!WARNING!!!
	// Location API is used, but the location is not initialized, 'cause I'm lazy. When making
	// a token with make_{something} method you can pass detailed token location. Current location
	// is accessible with m_driver.location() method. All puzzle elements are there - just
	// pass location value in every action code block below. I'm going to waste more time writing
	// this excuse than putting this boilerplate below...
	//
	// Location class can be found in location.hh and posistion.hh files. It's just a bit too much
	// boilerplate for this small example. Bummer.
%}

%option nodefault noyywrap c++ yyclass="Scanner" prefix="EzAquarii_"
%x C_COMMENT
%%

"letvar" { // LETVAR keyword for local variable declaration
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'letvar'" << endl;
#endif
  return EzAquarii::Parser::make_LETVAR(EzAquarii::location());
}

"in" { // IN keyword for local variable declarations
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'in'" << endl;
#endif

  return EzAquarii::Parser::make_IN(EzAquarii::location());
}

"if" { // IF keyword for conditionals
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'if'" << endl;
#endif

  return EzAquarii::Parser::make_IF(EzAquarii::location());
}

"then" { // THEN keyword for conditionals
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'then'" << endl;
#endif

  return EzAquarii::Parser::make_THEN(EzAquarii::location());
}

"else" { // ELSE keyword for conditionals
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'else'" << endl;
#endif

  return EzAquarii::Parser::make_ELSE(EzAquarii::location());
}

"while" { // WHILE keyword for loops
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'while'" << endl;
#endif

  return EzAquarii::Parser::make_WHILE(EzAquarii::location());
}

"do" { // DO keyword for loops
#ifdef SCANNER_OUTPUT
  cout << "Scanner: 'do'" << endl;
#endif

  return EzAquarii::Parser::make_DO(EzAquarii::location());
}
            
";" { // SEMICOLON used in c;c'
#ifdef SCANNER_OUTPUT
  cout << "Scanner: ';'" << endl;
#endif

  return EzAquarii::Parser::make_SEMICOLON(EzAquarii::location());
}

":=" { // Assignment symbol  used in e := e'
#ifdef SCANNER_OUTPUT
  cout << "Scanner: ':='" << endl;
#endif

  return EzAquarii::Parser::make_ASSIGNMENT(EzAquarii::location());
}

"=" { // Equality symbol used in e = e'
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '='" << endl;
#endif

  return EzAquarii::Parser::make_EQUAL(EzAquarii::location());
}

"+" { // Addition symbol used in e + e'
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '+'" << endl;
#endif

  return EzAquarii::Parser::make_PLUS(EzAquarii::location());
}

"-" { // Subtraction symbol used in e - e'
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '-'" << endl;
#endif

  return EzAquarii::Parser::make_MINUS(EzAquarii::location());
}

"<" { // Less than symbol used in e < e'
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '<'" << endl;
#endif

  return EzAquarii::Parser::make_LESS(EzAquarii::location());
}

"{" { // Braces used in block_command
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '{'" << endl;
#endif

  return EzAquarii::Parser::make_LBRACES(EzAquarii::location());
}

"}" { // Braces used in block_command
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '}'" << endl;
#endif

  return EzAquarii::Parser::make_RBRACES(EzAquarii::location());
}

"[" { // Bracket used for security level definition
#ifdef SCANNER_OUTPUT
  cout << "Scanner: '['" << endl;
#endif

  return EzAquarii::Parser::make_LBRACKET(EzAquarii::location());
}

"]" { // Bracket used for security level definition
#ifdef SCANNER_OUTPUT
  cout << "Scanner: ']'" << endl;
#endif

  return EzAquarii::Parser::make_RBRACKET(EzAquarii::location());
}

[HL] { // LEVEL used in variable declaration
#ifdef SCANNER_OUTPUT
  cout << "Scanner: [" << yytext << "]" << endl;
#endif

  return EzAquarii::Parser::make_LEVEL(yytext, EzAquarii::location( /* put location data here if you want */ )); 
}

[_a-zA-Z][_a-zA-Z0-9]* { // IDENTIFIER used in expressions
#ifdef SCANNER_OUTPUT
  cout << "Scanner: [" << yytext << "]" << endl;
#endif

  return EzAquarii::Parser::make_IDENTIFIER(yytext, EzAquarii::location( /* put location data here if you want */ )); 
}

-?[0-9]* { // NUMBER integer literal
#ifdef SCANNER_OUTPUT
  cout << "Scanner: " << yytext << endl;
#endif

  int number = strtoull(yytext, 0, 10);
  return EzAquarii::Parser::make_NUMBER(number, EzAquarii::location());
}

<INITIAL>{
"/*"              BEGIN(C_COMMENT);
}
<C_COMMENT>{
"*/"      BEGIN(INITIAL);
[^*\n]+   // eat comment in chunks
"*"       // eat the lone star
\n        yylineno++;
}

[\n\t ] {}

. { 
  cout << "Scanner: unknown character [" << yytext << "]" << endl; 
}
            
<<EOF>>     { return yyterminate(); }


%%
