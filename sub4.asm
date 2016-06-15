;;
;; file: sub4.asm
;; Subprogram example

default rel

%include "asm_io.inc"

segment .data
  prompt  db      ") Enter an integer number (0 to quit): ", 0

segment .bss


segment .text

global  get_int, print_sum

;;
;; subprogram get_int
;; Parameters (in order pushed on stack)
;;   number of input (at [rbp+0x18])
;;   address of word to store input into (at [rbp+0x10])
;; Notes:
;;   values of eax and ebx are destroyed
get_int:
  enter   0,0

  mov     rax, [rbp+0x18]
  call    print_int

  mov     rax, prompt
  call    print_string

  call    read_int
  mov     rbx, [rbp+0x10]
  mov     [rbx], eax         ; store input into memory

  leave
  ret                        ; jump back to caller

;; subprogram print_sum
;; prints out the sum
;; Parameter:
;;   sum to print out (at [ebp+0x18])
;; Note: destroys value of eax
;;
segment .data
  result  db      "The sum is ", 0

segment .text
print_sum:
  enter   0,0

  mov     rax, result
  call    print_string

  mov     rax, [rbp+0x18]       ; rax -> eax
  call    print_int
  call    print_nl

  leave
  ret
