CC       := g++
CC_FLAGS := -Wall -Wextra -g
BISON_PATH := bison

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
	${BISON_PATH} -o include/parser.cpp $(SRC)/parser.y

.PHONY: interclean
interclean:
	$(RM) $(DSYM) $(CLEAN_LIST) output

.PHONY: test
test: $(EXECUTABLE) interclean
	mkdir output
	$(EXECUTABLE) < testif.code > output/if.out
	$(EXECUTABLE) < testwhile.code > output/while.out
	$(EXECUTABLE) < testletvar.code > output/letvar.out


.PHONY: clean
clean:
	$(RM) $(EXECUTABLE) $(DSYM) $(CLEAN_LIST) output
