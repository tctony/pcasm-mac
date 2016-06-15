;;
;; file: sub6.asm
;; Subprogram to C interfacing example

;; subroutine calc_sum
;; finds the sum of the integers 1 through n
;; Parameters:
;;   n    - what to sum up to (at [ebp + 8])
;; Return value:
;;   value of sum
;; pseudo C code:
;; int calc_sum( int n )
;; {
;;   int i, sum = 0;
;;   for( i=1; i <= n; i++ )
;;     sum += i;
;;   return sum;
;; }
;;
;; To assemble:
;; DJGPP:   nasm -f coff sub6.asm
;; Borland: nasm -f obj  sub6.asm

default rel

segment .text
global  _calc_sum
;;
;; local variable:
;;   sum at eax
_calc_sum:
  enter   0, 0

  mov     eax, 0   ; sum = 0
  mov     ecx, 1            ; ecx is i in pseudocode
for_loop:
  cmp     ecx, edi              ; cmp i and n
  jnle    end_for           ; if not i <= n, quit

  add     eax, ecx      ; sum += i
  inc     ecx
  jmp     for_loop

end_for:

  leave
  ret
