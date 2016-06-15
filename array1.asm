;;
;; file: array1.asm
;; This program demonstrates arrays in assembly
;;
;; To create executable:
;; nasm -f coff array1.asm
;; gcc -o array1 array1.o array1c.c
;;

%define ARRAY_SIZE 100
%define NEW_LINE 10

segment .data
  FirstMsg        db   "First 10 elements of array", 0
  Prompt          db   "Enter index of element to display: ", 0
  SecondMsg       db   "Element %d is %d", NEW_LINE, 0
  ThirdMsg        db   "Elements 20 through 29 of array", 0
  InputFormat     db   "%d", 0

segment .bss
  array           resd ARRAY_SIZE

segment .text
extern  _puts, _printf, _scanf, _dump_line
global  _asm_main
_asm_main:
  enter   0x10, 0             ; local dword variable at EBP - 4

;; initialize array to 100, 99, 98, 97, ...

  mov     ecx, ARRAY_SIZE
  mov     rbx, array
init_loop:
  mov     [rbx], ecx
  add     rbx, 4
  loop    init_loop
  mov     rbx, array

  mov     rdi, FirstMsg
  call    _puts

  mov     rdi, array
  mov     rsi, 10
  call    print_array           ; print first 10 elements of array

;; prompt user for element index
Prompt_loop:
  sub     rsp, 0x10
  mov     rdi, Prompt
  call    _printf

  mov     rdi, InputFormat
  mov     rsi, rsp
  call    _scanf
  cmp     rax, 1               ; eax = return value of scanf
  je      InputOK

  call    _dump_line  ; dump rest of line and start over
  add     rsp, 0x10
  jmp     Prompt_loop          ; if input invalid

InputOK:
  mov     rdi, SecondMsg      ; print out value of element
  mov     esi, [rsp]
  mov     rdx, [rbx+4*rsi]
  call    _printf

  add     rsp, 0x10

  mov     rdi, ThirdMsg         ; print out elements 20-29
  call    _puts

  lea     rdi, [rbx+4*20]
  mov     rsi, 10
  call    print_array

  mov     eax, 0            ; return back to C
  leave
  ret

;;
;; routine print_array
;; C-callable routine that prints out elements of a double word array as
;; signed integers.
;; C prototype:
;; void print_array( const int * a, int n);
;; Parameters:
;;   a - pointer to array to print out (at ebp+8 on stack)
;;   n - number of integers to print out (at ebp+12 on stack)

segment .data
  OutputFormat    db   "%-5d %5d", NEW_LINE, 0

segment .text
global  print_array
print_array:
  enter   0, 0
  push    rdi
  push    rsi

  mov     ecx, esi                  ; ecx = n
  xor     esi, esi                  ; ebx = 0
print_loop:
  push    rcx                       ; printf might change ecx!
  push    rsi
  mov     rax, [rbp-0x08]       ; address of first element
  mov     rdx, [rax+4*rsi]
  mov     rsi, [rsp]
  mov     rdi, OutputFormat
  call    _printf

  pop     rsi
  inc     esi
  pop     rcx
  loop    print_loop

  leave
  ret
