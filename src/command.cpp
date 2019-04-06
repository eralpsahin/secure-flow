#include "command.h"

#include <iostream>
#include <sstream>

using namespace EzAquarii;
using std::cout;
using std::endl;

Command::Command(const std::string &name, const std::vector<uint64_t> arguments)
    : m_name(name), m_args(arguments) {}

Command::Command(const std::string &name) : m_name(name), m_args() {}

Command::Command() : m_name(), m_args() {}

Command::~Command() {}

std::string Command::str() const {
  std::stringstream ts;
  ts << "name = [" << m_name << "], ";
  ts << "arguments = [";

  for (size_t i = 0; i < m_args.size(); i++) {
    ts << m_args[i];
    if (i < m_args.size() - 1) {
      ts << ", ";
    }
  }

  ts << "]";
  return ts.str();
}

std::string Command::name() const { return m_name; }