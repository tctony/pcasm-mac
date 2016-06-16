;;
;; file: memory.asm
;; This program illustrates how to use the string instructions

global _asm_copy, _asm_find, _asm_strlen, _asm_strcpy

segment .text
;; function asm_copy
;; copies blocks of memory
;; C prototype
;; void asm_copy( void * dest, const void * src, unsigned sz);
;; parameters:
;;   dest - pointer to buffer to copy to
;;   src  - pointer to buffer to copy from
;;   sz   - number of bytes to copy

;; next, some helpful symbols are defined

_asm_copy:
  enter   0, 0

  mov     rcx, rdx          ; rcx = number of bytes to copy

  cld                     ; clear direction flag
  rep     movsb           ; execute movsb ECX times

  leave
  ret


;; function asm_find
;; searches memory for a given byte
;; void * asm_find( const void * src, char target, unsigned sz);
;; parameters:
;;   src    - pointer to buffer to search
;;   target - byte value to search for
;;   sz     - number of bytes in buffer
;; return value:
;;   if target is found, pointer to first occurrence of target in buffer
;;   is returned
;;   else
;;     NULL is returned
;; NOTE: target is a byte value, but is pushed on stack as a dword value.
;;       The byte value is stored in the lower 8-bits.
;;
%define src    [ebp+8]
%define target [ebp+12]
%define sz     [ebp+16]

_asm_find:
  enter   0, 0

  mov     rax, rsi              ; al has value to search for
  mov     rcx, rdx

  cld
  repne   scasb           ; scan until ECX == 0 or [ES:EDI] == AL

  je      found_it        ; if zero flag set, then found value
  mov     eax, 0          ; if not found, return NULL pointer
  jmp     quit

found_it:
  mov     rax, rdi
  dec     rax              ; if found return (DI - 1)

quit:
  leave
  ret


;; function asm_strlen
;; returns the size of a string
;; unsigned asm_strlen( const char * );
;; parameter:
;;   src - pointer to string
;; return value:
;;   number of chars in string (not counting, ending 0) (in EAX)

%define src [ebp + 8]
_asm_strlen:
  enter   0, 0

  mov     rcx, 0xffffffff ; use largest possible ECX
  xor     al, al           ; al = 0

  cld
  repnz   scasb           ; scan for terminating 0

;;
;; repnz will go one step too far, so length is FFFFFFFE - ECX,
;; not FFFFFFFF - ECX
;;
  mov     eax, 0xfffffffe
  sub     eax, ecx          ; length = 0FFFFFFFEh - ecx

  leave
  ret

;; function asm_strcpy
;; copies a string
;; void asm_strcpy( char * dest, const char * src);
;; parameters:
;;   dest - pointer to string to copy to
;;   src  - pointer to string to copy from
;;

_asm_strcpy:
  enter   0, 0

  cld
cpy_loop:
  lodsb                   ; load AL & inc si
  stosb                   ; store AL & inc di
  or      al, al          ; set condition flags
  jnz     cpy_loop        ; if not past terminating 0, continue

  leave
  ret
