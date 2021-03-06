#ifndef COMMAND_H
#define COMMAND_H

#include <stdint.h>
#include <string>
#include <vector>

namespace EzAquarii {

enum SecurityLevel { low, high };
static const std::string enumNames[2] = {"low", "high"};

class Type {
 public:
  Type(std::string identifier, std::string type) : identifier_(identifier) {
    if (type == "H")
      level_ = high;
    else
      level_ = low;
  }
  
  Type(SecurityLevel level) :level_(level), identifier_("") {}

  static Type Coercion(const Type &lhs, const Type &rhs) {
    if (lhs.level_ == high || rhs.level_ == high)
      return Type("", "H");
    else
      return Type("", "L");
  }

  Type() {}

  SecurityLevel GetType() const { return level_; }
  std::string GetIdentifier() const { return identifier_; }

  std::string ToString() { return identifier_ + enumNames[level_]; }

 private:
  SecurityLevel level_;
  std::string identifier_;
};



/**
 * AST node. If you can call it AST at all...
 * It keeps function name and a list of arguments.
 */
class Command {
 public:
  Command(const std::string &name, const std::vector<uint64_t> arguments);
  Command(const std::string &name);
  Command();
  ~Command();

  std::string ToString() const;
  std::string GetName() const;

 private:
  std::string m_name_;
  std::vector<uint64_t> m_args_;
};

}  // namespace EzAquarii

#endif  // COMMAND_H
