CC       := g++
CC_FLAGS := -g -Wall -Wextra -g

BUILD	  := build
INCLUDE	:= include
SRC     := src

EXECUTABLE := $(BUILD)/main
DSYM       := $(BUILD)/main.dSYM
RM         := rm -rf

CLEAN_LIST := $(INCLUDE)/scanner.cpp\
					 $(INCLUDE)/parser.cpp $(INCLUDE)/parser.hpp\
					 $(INCLUDE)/location.hh\
					 $(INCLUDE)/position.hh $(INCLUDE)/stack.hh\
					 .vscode/ipch

FILE_LIST := $(SRC)/main.cpp $(SRC)/interpreter.cpp\
					$(SRC)/command.cpp

.PHONY: default
default: $(EXECUTABLE) interclean

$(EXECUTABLE): scanner parser $(SRC)/*
	$(CC) $(CC_FLAGS) -I$(INCLUDE) \
	$(INCLUDE)/scanner.cpp $(INCLUDE)/parser.cpp \
	$(FILE_LIST) \
	-o $(EXECUTABLE)

.PHONY: run
run: $(EXECUTABLE) interclean
	$(EXECUTABLE)

.PHONY: scanner
scanner: $(SRC)/scanner.l
	flex -o include/scanner.cpp $(SRC)/scanner.l


.PHONY: parser
parser: $(SRC)/parser.y
	bison -o include/parser.cpp $(SRC)/parser.y

.PHONY: interclean
interclean:
	$(RM) $(DSYM) $(CLEAN_LIST)

.PHONY: clean
clean:
	$(RM) $(EXECUTABLE) $(DSYM) $(CLEAN_LIST)
