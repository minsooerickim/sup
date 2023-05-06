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
    - `int arrayName[5]@`
  - SUP-L is a **Zero-based** array indexing.
    - this is how you would access the 3rd element in the array, `arrayName`
      - `arrayName[2]@`
- Assignment statements
  - `=`
    - `x = y` the left variable gets assigned the value of the right variable
    - `int y = 3@ x = 2*y@` x would equal 6
- Arithmetic operators (e.g., “+”, “-”, “*”, “/”)
  - `+, -, *, /`
    - `int x = 5@`
    - `int y = 5@`
    - `x + y` would equal 10
    - `x - y` would equal 0
    - `x / y` would equal 1
    - `x * y` would equal 25
- Relational operators (e.g., “<”, “==”, “>”, “!=”, "<=", ">=")
  - `<, ==, >, !=, <=, >=`
    - `int x = 6@`
    - `int y = 5@`
    - `x < y` would equal false
    - `x == y` would equal false
    - `x > y` would equal true
    - `x >= y` would equal true
    - `x <= y` would equal false
    - `x != y` would equal true
- While loop (including "break" and "continue" loop control statements)
  - `chillin` (while)
  - `stop` (break)
  - `yessir` (continue)
  - for ex. I can do the following
      - ```
        int i = 0@
        chillin(i < 10)#
          sup(i == 4)#
            i++@
            yessir@
            #
          sup(i==5)#
            stop@
            #
        #
        ```
      - the above code snippet will enter the while loop (chillin) if i < 10. If i == 4, then i will be incremented and continued (yessir). Next, if i == 5, then we break from the loop (stop).
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
- Read and Write statements (cin, cout equivalent in C/C++ with the shift operators)
  - `supin ->` (std::cin >>)
    - accepts input from standard input device (inputs from user)
  - `supout <-` (std::cout <<)
    - displays or prints to the screen
  - Example:
      - ```
        int num@
        supout <- "Enter Your Favorite Number: "@
        supin -> num@
        supout <- "The Favorite Number is: " <- num@
        ```
      - the above code snippet asks the user to input an integer then it prints out the user's choice.
      If user enters 13, the program prints "The Favorite Number is: 13"
- New Lines
  - `next` (equivalent to endl in C++) and `\s` (equivalent to \n in C/C++)
    - marks beginning of a new line, used usually in write statements
  - Example: 
    - ```
      supout <- "Hello World!" <- next@
      supout <- "Hello World!\s"@
      ```
- Comments
  - `;)` (single line)
    - Used to indicate a single comment line
  - `:) (:` (multi line)
    - Used to indicate a block of comment, multiples lines
  - Example:
      - ```
        ;) sort the vector here

        :) Time complexity explanation ... 
           ... ... ...
           etc etc (:
        ```
- Functions (that can take multiple scalar arguments and return a single scalar result)
  - function_name(type parameter1, type parameter2, ...) return_type #code#
    - represents the Function Prototype for SUP-L
- Example:
    - ```
      supfib(int supnum) int #
        sup( supnum <= 1)#
          return supnum@
        #
        return supfib(supnum - 1) + supfib(supnum - 2)@
      #
      main() int #
        int supnum = 6@
        supout <- supfib(supnum) <- next@
        return 0@
      #
      ```
    - The above code snippet represents the fibonacci function written in SUP-L and is called in the main.
    Given a number, supnum, we can pass it into the supfib() function to get the supnum-th fibonacci number. In this case the program prints out 8. The recursive function takes in an integer variable and returns an integer as well. There is a base case that is taken care of using a sup(if) statement. Result is printed out in main using supout <- (cout).    

## additional notes
- `@` marks the end of a line (it is equivalent to `;` in c++)
- `#` opening and closing brackets for functions, loops, conditional statements etc(equivalent to { })
- SUP-L is **case sensitive**. All reserved words are expressed in lower case.
- strings are surrounded by `" "`
- Valid Identifiers
  - variable or functions names must start with an alphabet(uppercase, lowercase). They cannot start with a number or any special characters. The names can contain numbers but no special characters.
- Our language IS case sensitive
  - for ex. Supin would be considered a read statement.
- Whitespaces are ignored in sup.

# Symbols & Tokens
<!-- where do we find the token names?? do we include @? -->
| Symbol in Language | Token Name |
|--------------------|------------|
|int                 |INTEGER     |
|[]                  |ARRAY       |
|[                   |L_BRACKET   |
|]                   |R_BRACKET   |
|(                   |L_PARENT    |
|)                   |R_PARENT    |
|"                   |QUOTE       |
|@                   |SEMICOLON   |
|#                   |BRACKET     |
|,                   |COMMA       |
|-                   |SUB         |
|+                   |ADD         |
|*                   |MULT        |
|/                   |DIV         |
|%                   |MOD         |
|=                   |ASSIGNMENT  |
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
|yessir              |CONTINUE    |
|stop                |BREAK       |
|supin ->            |READ        |
|supout <-           |WRITE       |
|next                |NEWLINE     |
|\s                  |NEWLINE     |
|return              |RETURN      |
