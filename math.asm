;;
;; file: math.asm
;; This program demonstrates how the integer multiplication and division
;; instructions work.
;;
;; To create executable:
;; nasm -f coff math.asm
;; gcc -o math math.o driver.c asm_io.o

default rel

%include "asm_io.inc"

segment .data
;;
;; Output strings
;;
  prompt          db    "Enter a number: ", 0
  square_msg      db    "Square of input is ", 0
  cube_msg        db    "Cube of input is ", 0
  cube25_msg      db    "Cube of input times 25 is ", 0
  quot_msg        db    "Quotient of cube/100 is ", 0
  rem_msg         db    "Remainder of cube/100 is ", 0
  neg_msg         db    "The negation of the remainder is ", 0

segment .bss
  input   resd 1


segment .text
global  _asm_main
_asm_main:
  enter   0, 0               ; setup routine

  mov     rax, prompt
  call    print_string

  call    read_int
  mov     [input], eax

  imul    eax               ; edx:eax = eax * eax
  mov     ebx, eax          ; save answer in ebx
  mov     rax, square_msg
  call    print_string
  mov     eax, ebx
  call    print_int
  call    print_nl

  imul    ebx, [input]      ; ebx *= [input]
  mov     rax, cube_msg
  call    print_string
  mov     eax, ebx
  call    print_int
  call    print_nl

  mov     rax, cube25_msg
  call    print_string
  imul    ecx, ebx, 25      ; ecx = ebx*25
  mov     eax, ecx
  call    print_int
  call    print_nl

  mov     rax, quot_msg
  call    print_string
  mov     eax, ebx
  cdq                       ; initialize edx by sign extension
  mov     ecx, 100          ; can't divide by immediate value
  idiv    ecx               ; edx:eax / ecx
  mov     ecx, eax          ; save quotient into ecx
  mov     ebx, edx          ; save remainer into ebx
  mov     eax, ecx
  call    print_int
  call    print_nl

  mov     rax, rem_msg
  call    print_string
  mov     eax, ebx
  call    print_int
  call    print_nl

  mov     rax, neg_msg
  call    print_string
  neg     ebx               ; negate the remainder
  mov     eax, ebx
  call    print_int
  call    print_nl

  mov     eax, 0            ; return back to C
  leave
  ret
