#ifndef INTERPRETER_H
#define INTERPRETER_H

#include <vector>

#include "scanner.h"

#include "parser.hpp"

namespace EzAquarii {

// forward declare our simplistic AST node class so we
// can declare container for it without the header
class Command;

/**
 * This class is the interface for our scanner/lexer. The end user
 * is expected to use this. It drives scanner/lexer, keeps
 * parsed AST and generally is a good place to store additional
 * context data. Both parser and lexer have access to it via internal
 * references.
 *
 * I know that the AST is a bit too strong word for a simple
 * vector with nodes, but this is only an example. Get off me.
 */
class Interpreter {
 public:
  Interpreter();

  /**
   * Run parser. Results are stored inside.
   * \returns 0 on success, 1 on failure
   */
  int Parse();

  /**
   * Clear AST
   */
  void Clear();

  /**
   * Print AST
   */
  std::string ToString() const;

  /**
   * This is needed so that Scanner and Parser can call some
   * methods that we want to keep hidden from the end user.
   */
  friend class Parser;
  friend class Scanner;

 private:
  // Used internally by Parser to insert AST nodes.
  void AddCommand(const Command &cmd);

  // Used internally by Scanner YY_USER_ACTION to update location indicator
  void IncreaseLocation(unsigned int loc);

  // Used to get last Scanner location. Used in error messages.
  unsigned int GetLocation() const;

 private:
  Scanner m_scanner_;
  Parser m_parser_;
  std::vector<Command> m_commands_;  // Example AST
  unsigned int m_location_;          // Used by scanner
};

}  // namespace EzAquarii

#endif  // INTERPRETER_H
