TITLE Project 6 - String Primitives and Macros   (Proj6_jalaleds.asm)

; Author: Salim Jalaleddine
; Last Modified: 11/30/2022
; OSU email address: jalaleds@oregonstate.edu
; Course number/section:   CS271 Section 402
; Project Number: 6                Due Date: 12/4/22
; Description: Program asks user to enter 10 integers that are taken in
; string form. Each integer is validated to see if they fit in 32-bit registers, or
; if negative. Integers are converted to decimal and truncated average, sum, and
; list of numbers are displayed

;  Implementation notes:
;	This program is implemented using procedures.

INCLUDE Irvine32.inc


; -- mGetString --
; Gets string input from user, is a macro
; preconditions: buffer, prompt, len_str, max_len exist
; postconditions: EAX, ECX, EDX, changed
; Receives:
; buffer = empty array that is passed in which will hold input
; prompt = prompt to user
; len_str = count of bytes input by user
; max_len = maximum length user can input
; returns: buffer is filled with user input
mGetString MACRO buffer, prompt, len_str, max_len
PUSHAD

mov     EDX, prompt   ; display prompt message to user
call    WriteString

mov     EDX, buffer   ; move buffer to EDX register, and size of maximum length of input string to ECX register
mov     ECX, max_len

call    ReadString    ; call ReadString to get user input and put result in buffer variable
mov     len_str, EAX    ; move length of input string to len_str variable

POPAD
ENDM



; -- mDisplayString --
; Displays string to user interface
; preconditions: string exists
; postconditions: EDX changed
; Receives:
; string = string made up of bytes
; returns: message to user
mDisplayString MACRO string
PUSHAD

mov     EDX, string
call    WriteString

POPAD
ENDM



ASCIIARRAYSIZE = 30
NUMSARRAYSIZE = 10



.data
intro1      BYTE      "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ",13,10,0
intro2      BYTE      "Written by: Salim Jalaleddine ",13,10,0
prompt1     BYTE      13,10,"Please provide 10 signed decimal integers.",13,10
            BYTE      "Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the "
            BYTE      "integers, their sum, and their average value.",13,10,0
prompt2     BYTE      "Please enter a signed number: ",0
error       BYTE      "ERROR: You did not enter a signed number or your number was too big.",13,10,0
intro3      BYTE      13,10,"You entered the following numbers: ",13,10,0
sumIntro    BYTE      "The sum of these numbers is: ",0
aveIntro    BYTE      "The truncated average is: ",0
buffer      BYTE      ASCIIARRAYSIZE DUP (?)
total_num   SDWORD    ?
len_str     BYTE      1 DUP (?)
list_nums   SDWORD    NUMSARRAYSIZE  DUP (?)
is_negative DWORD     0
max_len     DWORD     ASCIIARRAYSIZE
list_ptr    DWORD     0
spacing     BYTE      ", ",0
sum         SDWORD     0
temp_str    BYTE      1 DUP(?)

.code
main PROC
  mDisplayString  OFFSET intro1   ; Display introductions as well as prompt for signed integers
  mDisplayString  OFFSET intro2
  mDisplayString  OFFSET prompt1
  call            Crlf

  mov             ECX, NUMSARRAYSIZE

  _getNumber:                     ; Loop in main procedure that calls procedure ReadVal to get number from user
  PUSH            ECX
  PUSH            list_ptr
  PUSH            OFFSET prompt2
  PUSH            OFFSET error
  PUSH            OFFSET buffer
  PUSH            total_num
  PUSH            OFFSET list_nums
  PUSH            OFFSET len_str
  PUSH            OFFSET is_negative
  PUSH            max_len
  call            ReadVal
  POP             ECX
  add             list_ptr, 4   ; increment pointer pointing to list
  LOOP            _getNumber

  mDisplayString  OFFSET intro3  ; message before displaying numbers

  mov             ESI, OFFSET list_nums  ; point ESI to address of list_nums and clear EAX registser
  mov             EAX, 0

  mov             ECX, 10   ; initialize loop counter

  _displayNumbers:     ; Loop in main procedure that calls procedure WriteVal to display numbers to user
  PUSH             ECX

  cld                  ; set clear direction flag and then load SDWORD into EAX
  LODSD
  PUSH             OFFSET is_negative
  PUSH             EAX       ; push SDWORD to stack
  PUSH             OFFSET temp_str
  call             WriteVal

  POP              ECX  ; return preserved loop counter

  cmp              ECX, 1  ; check if last iteration, if so go to end loop so extra comma isn't added
  je               _skipSpacing

  mDisplayString   OFFSET spacing    ; add comma

  _skipSpacing:
  LOOP            _displayNumbers

  call            Crlf


  mov             ESI, OFFSET list_nums  ; find sum
  mov             ECX, 10
  _addNums:
  mov             EAX, 0
  cld
  LODSD
  add             sum, EAX
  LOOP            _addNums

  mDisplayString   OFFSET sumIntro  ; display sum message

  mov              EAX, sum        ; display sum using WriteVal
  PUSH             OFFSET is_negative    
  PUSH             EAX      
  PUSH             OFFSET temp_str
  call             WriteVal

  call Crlf

  mDisplayString   OFFSET aveIntro  ; display average message

  mov              EAX, sum    ; find average
  CDQ
  mov              EBX, 10
  idiv             EBX

  PUSH             OFFSET is_negative   ; display average using WriteVal
  PUSH             EAX      
  PUSH             OFFSET temp_str
  call             WriteVal

  call Crlf

  Invoke ExitProcess,0	; exit to operating system
main ENDP



; -- ReadVal --
; Reads values from user as string, then converts to SDWORD type and stores into list_nums
; preconditions: prompt2, error, buffer, total_num, list_nums, len_str, is_negative, max_len are on stack
; postconditions: EAX, ECX, EDI, EBX, EBP, ESI, EDX changed
; Receives:
; prompt_2 = prompt to user to put in number
; error = error message
; buffer = empty array
; total_num = SDWORD accumulator
; list_nums: array that holds SDWORDS
; len_str: count of input length by user
; is_negative: variable to keep track of negation
; max_len: maximum bytes user can put
; returns: list_nums is filled with converted SDWORD
ReadVal PROC
  PUSH            EBP     ; set base pointer
  mov             EBP, ESP

  PUSHAD    ; preserve registers

  mov             EBX, [EBP + 40]
  mov             EDI, [EBP + 20]            ; move address of list of sdwords to EDI register, then find place in list
  add             EDI, EBX
  jmp             _prompt

  _popECX:
  POP            ECX

  _error:                       ; display error message to user
  cmp            EBX, 2147483648  ; account for -214783648 edge case
  JE             _checkEdgeCase

  jmp            _finishError

  _checkEdgeCase:
  mov            EAX, [EBP + 12]   ; check if negative flag is set, if it is not then finish with error, otherwise jump to makeNegative
  cmp            EAX, 1
  je             _makeNegative        

  _finishError:
  mDisplayString [EBP + 32]

  _prompt:
  mGetString     [EBP + 28], [EBP + 36], [EBP + 16], [EBP + 8]    ; get user input and pass in variables from stack
  
  mov            EAX, [EBP + 16]         ; move length of input string to ECX to initialize loop counter
  mov            ECX, EAX            

  mov            ESI, [EBP + 28]  
  mov            EBX, [EBP + 24]

  PUSH           ECX                ; preserve loop counter and clear EAX register
  mov            EAX, 0

  cld                ; clear direction flag and load data into EAX register
  LODSB

  PUSH           EBX               ; reset negative flag
  mov            EBX, 0
  mov            [EBP + 12], EBX
  POP            EBX       

  cmp            EAX, 43   ; check if positive  sign
  je             _positive

  cmp            EAX, 45   ; check if negative sign
  je             _negative

  cmp            EAX, 48   ; check if leading zero
  je             _checkZero

  jmp            _validateSize   ; otherwise jump to validate size

  _positive:
  jmp            _checkZero

  _negative:                ; if negative, set negative variable, decrement loop counter, and enter loop
  PUSH           EBX
  mov            EBX, 1
  mov            [EBP + 12], EBX
  POP            EBX

  _checkZero:             ; iterate over leading zeros
  mov            EAX, 0

  cld
  LODSB      
  POP            ECX
  dec            ECX

  PUSH           ECX
  cmp            EAX, 48    ; if zero then keep iterating to check for zeros
  je             _checkZero       

  cmp             ECX, 0  ; catch edge case if 0 is only number
  je              _zero

  _validateSize:           ; if number without leading zeros and sign is larger than 10, then is invalid
  cmp            ECX, 10
  jg             _popECX

  jmp            _validNumber

  _nextNumber:
  PUSH           ECX                ; preserve loop counter and clear EAX register
  mov            EAX, 0

  cld                ; clear direction flag and load data into EAX register
  LODSB

  _validNumber:
  cmp            EAX, 48    ; throw error if ascii is below 48
  JL             _popECX

  cmp            EAX, 57    ; throw error if ascii is above 57
  JG             _popECX

  sub            EAX, 48     ; convert in ascii from character to dec, then multiply accumulator by 10, then add converted ascii to accumulator
  imul           EBX, 10
  JO             _popECX        ; invalid if overflow flag is set, which means accumulated number too large/small

  add            EBX, EAX
  JO             _popECX        ; invalid if overflow flag is set, which means accumulated number too large/small

  POP            ECX
  LOOP           _nextNumber

  mov            EAX, [EBP + 12]   ; check if negative flag is set, if it is not then jump to finish
  cmp            EAX, 0
  je             _finish

  _makeNegative:
  mov            EAX, EBX     ; if negative flag set, negate current number
  neg            EAX
  mov            EBX, EAX     
  jmp            _finish

  _zero:
  POP            ECX
  mov            EBX, 0

  _finish:
  mov            [EDI], EBX    ; move accumulator result to proper place in list_nums using Register Indirect Addressing

  POPAD

  POP            EBP     ; pop base pointer
  RET            36    
ReadVal ENDP




; -- WriteVal --
; Converts from SDWORD to ascii format, displays to user
; preconditions: is_negative, EAX with SDWORD filled in, temp_str exist
; postconditions: EAX, EDX, EBP, ESP, ESI, ECX, EBX, EDI changed
; Receives:
; is_negative = variable to keep track of negation
; EAX (SDWORD) = EAX Register filled with corresponding SDWORD to be converted to aasci 
; temp_str = empty string that will be filled with ascii
; returns: ascii character to user interface
WriteVal PROC

  PUSH           EBP     ; set base pointer
  mov            EBP, ESP

  PUSHAD       ; preserve registers

  mov            EBX, 0
  mov            [EBP + 16], EBX  ; clear negative flag from previous iterations

  mov            ECX, 0 ; initialize counter
  mov            EAX, [EBP + 12]

  cmp            EAX, 0    ; check if inputted SDWORD is negative, if so set flag to 1
  jl             _setNegativeFlag

  jmp            _aasciConversion

  _setNegativeFlag:         ; set negative flag by making is_negative equal to 1, then make SDWORD positive by using neg
  mov            EDX, 1
  mov            [EBP + 16], EDX
  neg            EAX

  _aasciConversion:
  inc            ECX

  CDQ
  mov            EBX, 10   ; divide by 10
  idiv           EBX

  PUSH           EDX  ; push remainder to stack

  cmp             EAX, 0   ; check whether last number if quotient is 0
  je              _lastNum

  jmp            _aasciConversion

  _lastNum:
  mov            EDI, [EBP + 8]   ; move tmp_str to EDI for preparation to fill string

  mov            EBX, ECX   ; preserve loop for clearing of string at the end

  mov            EAX, [EBP + 16] ; check if negative flag is set from before, if so add negative sign to beginning of string
  cmp            EAX, 0
  je             _reverse

  mov            EAX, 0
  mov            EAX, 45    ; display negative sign, and increment EBX counter for clear at end
  STOSB
  inc            EBX

  _reverse:
  mov            EAX, 0
  POP            EAX    ; pop from stack and mov to EAX, then add 48 to convert to string form, then load into string
  add            EAX, 48
  STOSB
  
  LOOP           _reverse

  mDisplayString [EBP + 8]

  mov            ECX, EBX ; initialize loop counter for clearing

  _clearString:          ; clear string for next SDWORD in outer loop in main procedure
  mov            EAX, 0
  STD
  STOSB

  LOOP           _clearString

  POPAD

  POP            EBP     ; pop base pointer
  RET            12

WriteVal ENDP

END main