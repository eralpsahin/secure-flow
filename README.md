# Secure flow analysis type system

This is an implementation of the type system in "A sound type system for secure flow analysis”. Language Based Security (CSE597-07 Special Topics) Final Project.

- [x] Build lexer/parser for the IMP language
- [x] Implement the type system
- [x] Implement composition of commands
- [ ] Evaluate the code


# Installation
- Need Bison 3.0.1 on CSE Labs to compile the source code.
- Download from http://ftp.gnu.org/gnu/bison/bison-3.0.1.tar.gz
- `tar -zxvf bison-3.0.1.tar.gz`
- in bison-3.0.1 directory `./configure prefix="$HOME"` Prefix is added so that we don't install bison to `usr/local/bin` and don't need sudo.
- `make`
- `make install`
- This should install bison to `~/bin/bison`. `BISON_PATH` variable in Makefile is configured to that for testing on LAB machines. Change it to `bison` if testing on a machine with bison 3.0.1 installed to default path.


# Compile Project
- At project root `make` should compile the code with couple of unused variable warnings.
- The project binary path is `build/main`.
- Do `make test` to test all 4 test cases I included. Log about tests cases will be created in `output` directory.
- `build/main < test.txt  > output.txt` to test your own test cases.


# Statements
Language accepts four statements

- Letvar declares a local variable living only in the block scope
```
letvar x [H] := 20 in {
  ...
}
```
- While statement
```
while 10 < 20 do {
  ...
}
```
- If then else statement

```
if x < 20 then {
  ...
} else {
  ...
}
```
- Assigment statement
```
x := 20
```

# Expressions
- Plus, minus, less than, and equal operators are defined on identifiers and numbers.

# Miscellaneous
- Comments can be added with C style `/* */`.
- Sequence of commands are seperated with `;`. Last command of a block command does not have `;` after it.

```
letvar x [L] := 20 in {
  x := 10;
  if x < 15 then {
    ...
  } else {
    ...
  };
  x := 20
}
```