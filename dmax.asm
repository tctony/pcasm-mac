;;
;; file: dmax.asm

global _dmax


segment .text
;; function dmax
;; returns the larger of its two double arguments
;; C prototype
;; double dmax( double d1, double d2 )
;; Parameters:
;;   d1   - first double
;;   d2   - second double
;; Return value:
;;   larger of d1 and d2 (in ST0)

;; next, some helpful symbols are defined

%define d1   [ebp+8]
%define d2   [ebp+16]

_dmax:
  enter   0, 0

  comisd  xmm0, xmm1                 ; ST0 = d2
  jnb     d1_bigger
  movq    xmm0, xmm1

d1_bigger:                          ; if d2 is bigger, nothing to do

exit:
  leave
  ret
