#include <iostream>
#include "interpreter.h"
#include "parser.hpp"
#include "scanner.h"

using namespace EzAquarii;
using namespace std;

int main() {
  Interpreter i;
  int res = i.Parse();
  return res;
}
