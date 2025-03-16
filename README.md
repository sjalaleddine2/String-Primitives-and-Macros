# String Primitives and Macros

## Overview

This project, implemented in x86 Assembly using the Microsoft Macro Assembler (MASM), prompts the user to input 10 signed integers. It converts these inputs from their string representations to signed double-word integers (SDWORD), validates them, calculates their sum and average, and then displays the results.

## Features

- **User Input Handling**: Accepts 10 numeric inputs from the user, supporting both positive and negative integers within the range of -2,147,483,648 to 2,147,483,647.
- **String to Integer Conversion**: Converts input strings into their numeric (SDWORD) representations, ensuring validation of user input.
- **Integer to String Conversion**: Converts numeric values back to string format for display purposes.
- **Arithmetic Operations**: Calculates and displays the sum and truncated average of the entered numbers.

## Macros and Procedures

- **Macros**:
  - `mGetString`: Displays a prompt and reads user input into a specified memory location.
  - `mDisplayString`: Prints a string stored in a specified memory location.

- **Procedures**:
  - `ReadVal`: Invokes `mGetString` to obtain user input as a string of digits, converts this string to its numeric SDWORD representation, and validates the input to ensure it is a valid number without letters or symbols.
  - `WriteVal`: Converts a numeric SDWORD value back into a string of ASCII digits for display.

## Requirements

- Do not use `ReadInt`, `ReadDec`, `WriteInt`, or `WriteDec` functions.
- Conversion routines must utilize `LODSB` and/or `STOSB` instructions where appropriate.
- Procedure parameters must be passed on the stack.
- Strings should be passed by reference.
- Registers used within procedures must be saved and restored appropriately.
- Avoid referencing data segment variables by name outside of the main program; use register indirect access for array elements and base + offset addressing for parameters on the runtime stack.
- Averages can be floored (i.e., truncated towards zero).

## Example Output

```
Please enter a signed integer: -12345
Please enter a signed integer: 67890
...
The numbers you entered are:
-12345
67890
...
The sum is: 55545
The average is: 5554
Goodbye!
```

## How to Run

1. **Assemble the Program**: Use MASM to assemble the `.asm` file.
2. **Link the Object File**: Link the assembled object file to create an executable.
3. **Execute**: Run the executable in a command-line environment.


