;;
;; file: sub5.asm
;; Subprogram to C interfacing example

default rel

%include "asm_io.inc"

;; subroutine calc_sum
;; finds the sum of the integers 1 through n
;; Parameters:
;;   n    - what to sum up to (at rdi)
;;   sump - pointer to int to store sum into (at rsi)
;; pseudo C code:
;; void calc_sum( int n, int * sump )
;; {
;;   int i, sum = 0;
;;   for( i=1; i <= n; i++ )
;;     sum += i;
;;   *sump = sum;
;; }
;;
;; To assemble:
;; DJGPP:   nasm -f coff sub5.asm
;; Borland: nasm -f obj  sub5.asm

segment .text
global  _calc_sum
;;
;; local variable:
;;   sum at [rbp-0x08]
_calc_sum:
  enter   0, 0
  push    rdi
  push    rsi
  push    0                     ; sub = 0
  push    rbx                   ; save rbx IMPORTANT!

  dump_stack 1, 1, 3        ; print out stack from ebp-8 to ebp+16

  mov     ecx, 1            ; ecx is i in pseudocode
for_loop:
  cmp     ecx, [rbp - 0x08]      ; cmp i and n
  jnle    end_for           ; if not i <= n, quit

  add     [rbp - 0x18], ecx      ; sum += i, add 32 bit int to 64 bit int
  inc     ecx
  jmp     for_loop

end_for:
  mov     rbx, [rbp - 0x10]     ; ebx = sump
  mov     rax, [rbp - 0x18]      ; eax = sum
  mov     [rbx], eax             ; rax -> eax

  pop     rbx               ; restore rbx
  sub     rsp, 0x18
  leave
  ret
