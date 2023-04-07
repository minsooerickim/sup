# Detailed Requirements
programming lanaguage: SUP-L
program extension: .sup
name of compiler: SUP-LC

<!-- have code examples -->
- Integer scalar variables
  - `int x@ int y@ int z@`
    - the above declares 3 integer variables x, y, and z. the `@` symbol marks the end of a line.
- One-dimensional arrays of integers (indexing, assigning)
  - `[]`
    - the square brackets refer to an array
  - here is an example of declaring an integer array of size 5.
    - `int array_name[5]@`
  - SUP-L is a **Zero-based** array indexing.
    - this is how you would access the 3rd element in the array, `array_name`
      - `array_name[2]@`
- Assignment statements (raidah)
  - `=`
- Arithmetic operators (e.g., “+”, “-”, “*”, “/”)
  - `+, -, *, /`
    - `int x = 5@`
    - `int y = 5@`
    - `x + y` would equal 10
    - `x - y` would equal 0
    - `x / y` would equal 1
    - `x * y` would equal 25
- Relational operators (e.g., “<”, “==”, “>”, “!=”)
  - `<, ==, >, !=`
    - `int x = 6@`
    - `int y = 5@`
    - `x < y` would equal false
    - `x == y` would equal false
    - `x > y` would equal true
    - `x != y` would equal true
- While loop (including "break" and "continue" loop control statements)
  - `chillin` (while)
  - `stop` (break)
  - `continue` (continue) come back to it later?
  - for ex. I can do the following
      - ```
        int i = 0@
        chillin(i < 10)#
          sup(i == 4)#
            i++@
            continue@
            #
          sup(i==5)#
            stop@
            #
        #
        ```
      - the above code snippet will enter the while loop (chillin) if i < 10. If i == 4, then i will be incremented and continued (continue). Next, if i == 5, then we break from the loop (stop).
- If-then-else statements
  - SUP-L uses the keywords `sup`, `vibin`, `wbu` in place of `if`, `then`, `else` respectively.
  - `sup`
    - signifies the start of the if statement
  - `vibin`
    - signifies the start of what to do if the `sup` condition is true
  - `wbu`
    - signifies the start of what to do if the `sup` condition is false 
  - for ex. I can do the following
      - ```
        sup(flag) #
          vibin #
            supout <- "flag is true!"@
          #
          wbu #
            supout <- "flag is false!"@
          #
        #
        ```
      - the above code snippet will print out "flag is true" if the flag variable is true and "flag is false" if the flag is false
- Read and write statements (cin, cout equivalent in C/C++) (raidah)
  - `supin ->` (cin)
  - `supout <-` (cout)
- Comments (raidah)
  - `;)` (single line)
  - `:) (:` (multi line)
- Functions (that can take multiple scalar arguments and return a single scalar result) (raidah)
  - function_name(parameters) return_type #code#

## additional notes
- `@` marks the end of a line (it is equivalent to `;` in c++)
- SUP-L is **case sensitive**. All reserved words are expressed in lower case.
- strings are surrounded by `" "`

# Symbols & Tokens
<!-- where do we find the token names?? do we include @? -->
| Symbol in Language | Token Name |
|--------------------|------------|
|int                 |INTEGER     |
|[]                  |ARRAY       |
|@                   |SEMICOLON   |
|-                   |SUB         |
|+                   |ADD         |
|*                   |MULT        |
|/                   |DIV         |
|%                   |MOD         |
|==                  |EQ          |
|!=                  |NEQ         |
|<                   |LT          |
|>                   |GT          |
|<=                  |LTE         |
|>=                  |GTE         |
|==                  |EQ          |
|sup                 |IF          |
|vibin               |THEN        |
|wbu                 |ELSE        |
|chillin             |WHILE       |
|continue            |CONTINUE    |
|stop                |BREAK       |
