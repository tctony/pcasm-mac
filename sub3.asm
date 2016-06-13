;;
;; file: sub3.asm
;; Subprogram example program
;;
;; To create executable:
;; Using djgpp:
;; nasm -f coff sub3.asm
;; gcc -o sub1 sub3.o driver.c asm_io.o
;;
;; Using Borland C/C++
;; nasm -f obj sub3.asm
;; bcc32 sub3.obj driver.c asm_io.obj

default rel

%include "asm_io.inc"

segment .data
  sum     dd   0

segment .bss
  input   resd 1

;;
;; psuedo-code algorithm
;; i = 1;
;; sum = 0;
;; while( get_int(i, &input), input != 0 ) {
;;   sum += input;
;;   i++;
;; }
;; print_sum(num);

segment .text
global  _asm_main
_asm_main:
  enter   0,0               ; setup routine

  mov     edx, 1            ; edx is 'i' in pseudo-code
while_loop:
  mov     rax, input
  push    rax               ; push address on input on stack
  push    rdx               ; edx -> rdx
  call    get_int
  mov     rdx, [rsp]
  add     rsp, 0x10             ; remove i and &input from stack

  mov     eax, [input]
  cmp     eax, 0
  je      end_while

  add     [sum], eax        ; sum += input

  inc     edx
  jmp     while_loop

end_while:
  sub     rsp, 0x08         ; align to 0x10, 0x08 = 0x10 - 0x08
  mov     eax, dword [sum]
  push    rax                   ; push value of sum onto stack, eax -> rax
  call    print_sum
  add     rsp, 0x10

  leave
  ret

;;
;; subprogram get_int
;; Parameters (in order pushed on stack)
;;   number of input (at [rbp + 0x10])
;;   address of word to store input into (at [rbp + 0x18])
;; Notes:
;;   values of eax and ebx are destroyed
segment .data
  prompt  db      ") Enter an integer number (0 to quit): ", 0

segment .text
get_int:
  enter   0, 0

  mov     rax, [rbp + 0x10]
  call    print_int

  mov     rax, prompt
  call    print_string

  call    read_int
  mov     rbx, [rbp + 0x18]
  mov     [rbx], eax         ; store input into memory

  leave
  ret                        ; jump back to caller

;; subprogram print_sum
;; prints out the sum
;; Parameter:
;;   sum to print out (at [rbp+0x10])
;; Note: destroys value of eax
;;
segment .data
  result  db      "The sum is ", 0

segment .text
print_sum:
  enter   0, 0

  mov     rax, result
  call    print_string

  mov     rax, [rbp + 0x10]     ; rax -> eax
  call    print_int
  call    print_nl

  leave
  ret
