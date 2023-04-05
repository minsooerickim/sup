# Detailed Requirements
programming lanaguage: SUP-L
program extension: .sup
name of compiler: SUP-LC

<!-- have code examples -->
- Integer scalar variables
  - `int x@ int y@ int z@`
    - the above delcares 3 integer variables x, y, and z. the `@` symbol marks the end of a line.
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
- Arithmetic operators (e.g., “+”, “-”, “*”, “/”) (siraaj)
  - `+, -, *, /`
- Relational operators (e.g., “<”, “==”, “>”, “!=”) (siraaj)
  - `<, ==, >, !=`
- While loop (including "break" and "continue" loop control statements) (siraaj)
  - `chilin` (while)
  - `stop` (break)
  - `continue` (continue) come back to it later?
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
        sup(flag)
        vibin #
          supout <- "flag is true!"
        #
        wbu #
          supout <- "flag is false!"
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
- `@` marks the end of a liine (it is equivalent to `;` in c++)
- SUP-L is **case sensitive**. All reserved words are expressed in lower case.
- strings are surrounded by `" "`

# Symbols & Tokens
<!-- where do we find the token names?? do we include @? -->
| Symbol in Language | Token Name |
|--------------------|------------|
|int                 |INTEGER     |
|[]                  |ARRAY       |
|sup                 |IF          |
|vibin               |THEN        |
|wbu                 |ELSE        |
