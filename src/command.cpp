#include "command.h"

#include <iostream>
#include <sstream>

using namespace EzAquarii;
using std::cout;
using std::endl;

Command::Command(const std::string &name, const std::vector<uint64_t> arguments)
    : m_name_(name), m_args_(arguments) {}

Command::Command(const std::string &name) : m_name_(name), m_args_() {}

Command::Command() : m_name_(), m_args_() {}

Command::~Command() {}

std::string Command::ToString() const {
  std::stringstream ts;
  ts << "name = [" << m_name_ << "], ";
  ts << "arguments = [";

  for (size_t i = 0; i < m_args_.size(); i++) {
    ts << m_args_[i];
    if (i < m_args_.size() - 1) {
      ts << ", ";
    }
  }

  ts << "]";
  return ts.str();
}

std::string Command::GetName() const { return m_name_; }