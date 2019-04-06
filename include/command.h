#ifndef COMMAND_H
#define COMMAND_H

#include <stdint.h>
#include <string>
#include <vector>

namespace EzAquarii {

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

  std::string str() const;
  std::string name() const;

 private:
  std::string m_name;
  std::vector<uint64_t> m_args;
};

}  // namespace EzAquarii

#endif  // COMMAND_H
