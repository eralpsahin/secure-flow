CC		:= g++
CC_FLAGS := -g -Wall -Wextra -g

BIN		:= bin
INCLUDE	:= include
SRC := src

EXECUTABLE	:= main
DSYM := main.dSYM
RM := rm -rf

CLEAN_LIST := $(INCLUDE)/scanner.cpp\
					$(INCLUDE)/parser.cpp $(INCLUDE)/parser.hpp\
					$(INCLUDE)/location.hh\
					$(INCLUDE)/position.hh $(INCLUDE)/stack.hh

FILE_LIST := $(SRC)/main.cpp $(SRC)/interpreter.cpp\
					$(SRC)/command.cpp

.PHONY : interclean clean scanner parser run

default: $(BIN)/$(EXECUTABLE) interclean

$(BIN)/$(EXECUTABLE): scanner parser $(SRC)/*
	$(CC) $(CC_FLAGS) -I$(INCLUDE) \
	$(INCLUDE)/scanner.cpp $(INCLUDE)/parser.cpp \
	$(FILE_LIST) \
	-o $(BIN)/$(EXECUTABLE)

run: $(BIN)/$(EXECUTABLE)
	$(BIN)/main

scanner: $(SRC)/scanner.l
	flex -o include/scanner.cpp $(SRC)/scanner.l

parser: $(SRC)/parser.y
	bison -o include/parser.cpp $(SRC)/parser.y

interclean:
	$(RM) $(BIN)/$(DSYM) $(CLEAN_LIST)

clean:
	$(RM) $(BIN)/$(EXECUTABLE) $(BIN)/$(DSYM) $(CLEAN_LIST)
