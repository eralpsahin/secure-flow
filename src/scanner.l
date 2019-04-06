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

	// This will track current scanner location.
	// Action is called when length of the token is known.
	#define YY_USER_ACTION m_driver.increaseLocation(yyleng);
	
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

%option nodefault
%option noyywrap
%option c++
%option yyclass="Scanner"
%option prefix="EzAquarii_"

%%


[a-z]+ { 
  cout << "Scanner: identifier [" << yytext << "]" << endl;
  return EzAquarii::Parser::make_STRING(yytext, EzAquarii::location( /* put location data here if you want */ )); 
}
            
"(" {
  cout << "Scanner: '('" << endl;
  return EzAquarii::Parser::make_LEFTPAR(EzAquarii::location());
}
            
")" { 
  cout << "Scanner: ')'" << endl;
  return EzAquarii::Parser::make_RIGHTPAR(EzAquarii::location());
}
            
; {
  cout << "Scanner: ';'" << endl;
  return EzAquarii::Parser::make_SEMICOLON(EzAquarii::location());
}
            
, {
  cout << "Scanner: ','" << endl;
  return EzAquarii::Parser::make_COMMA(EzAquarii::location());
}
            
[\n\t ] {}

[1-9][0-9]* {
  cout << "Scanner: decimal number: " << yytext << endl;
  uint64_t number = strtoull(yytext, 0, 10);
  return EzAquarii::Parser::make_NUMBER(number, EzAquarii::location());
}

.  { 
  cout << "Scanner: unknown character [" << yytext << "]" << endl; 
}
            
<<EOF>>     { return yyterminate(); }


%%
