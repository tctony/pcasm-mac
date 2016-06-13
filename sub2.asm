;;
;; file: sub2.asm
;; Subprogram example program
;;
;; To create executable:
;; Using djgpp:
;; nasm -f coff sub2.asm
;; gcc -o sub1 sub2.o driver.c asm_io.o
;;
;; Using Borland C/C++
;; nasm -f obj sub2.asm
;; bcc32 sub2.obj driver.c asm_io.obj

%include "asm_io.inc"

default rel

segment .data
  prompt1 db    "Enter a number: ", 0       ; don't forget nul terminator
  prompt2 db    "Enter another number: ", 0
  outmsg1 db    "You entered ", 0
  outmsg2 db    " and ", 0
  outmsg3 db    ", the sum of these is ", 0

segment .bss
;;
;; These labels refer to double words used to store the inputs
;;
  input1  resd 1
  input2  resd 1



segment .text
global  _asm_main
_asm_main:
  enter   0, 0               ; setup routine

  mov     rax, prompt1      ; print out prompt
  call    print_string

  mov     rdi, input1       ; store address of input1 into ebx
  call    get_int           ; read integer

  mov     rax, prompt2      ; print out prompt
  call    print_string

  mov     rdi, input2
  call    get_int

  mov     eax, [input1]     ; eax = dword at input1
  add     eax, [input2]     ; eax += dword at input2
  mov     ebx, eax          ; ebx = eax
;;
;; next print out result message as series of steps
;;

  mov     rax, outmsg1
  call    print_string      ; print out first message
  mov     eax, [input1]
  call    print_int         ; print out input1
  mov     rax, outmsg2
  call    print_string      ; print out second message
  mov     eax, [input2]
  call    print_int         ; print out input2
  mov     rax, outmsg3
  call    print_string      ; print out third message
  mov     eax, ebx
  call    print_int         ; print out sum (ebx)
  call    print_nl          ; print new-line

  mov     eax, 0            ; return back to C
  leave
  ret
;;
;; subprogram get_int
;; Parameters:
;;   rdi - address of word to store integer into
;; Notes:
;;   value of eax is destroyed
get_int:
  enter   0, 0
  call    read_int
  mov     [rdi], eax         ; store input into memory
  leave
  ret                        ; jump back to caller
