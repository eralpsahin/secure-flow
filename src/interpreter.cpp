#include "interpreter.h"
#include "command.h"

#include <sstream>

using namespace EzAquarii;

Interpreter::Interpreter()
    : m_scanner_(*this), m_parser_(m_scanner_, *this), m_location_(0) {}

int Interpreter::Parse() {
  m_location_ = 0;
  return m_parser_.parse();
}

void Interpreter::Clear() {
  m_location_ = 0;
  m_commands_.clear();
}

std::string Interpreter::ToString() const {
  std::stringstream s;
  s << "Interpreter: " << m_commands_.size()
    << " commands received from command line." << endl;
  for (size_t i = 0; i < m_commands_.size(); i++) {
    s << " * " << m_commands_[i].ToString() << endl;
  }
  return s.str();
}

void Interpreter::AddCommand(const Command &cmd) { m_commands_.push_back(cmd); }

void Interpreter::IncreaseLocation(unsigned int loc) {
  m_location_ += loc;
  cout << "increaseLocation(): " << loc << ", total = " << m_location_ << endl;
}

unsigned int Interpreter::GetLocation() const { return m_location_; }
