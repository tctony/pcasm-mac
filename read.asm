;;
;; file: read.asm
;; This subroutine reads an array of doubles from a file

segment .data
  format  db      "%lf", 0        ; format for fscanf()

segment .bss

segment .text
global  _read_doubles
extern  _fscanf

%define SIZEOF_DOUBLE   8
%define FP              qword [rbp - 0x08]
%define ARRAYP          qword [rbp - 0x10]
%define ARRAY_SIZE      qword [rbp - 0x18]
%define TEMP_DOUBLE     qword [rbp - 0x20]

;;
;; function read_doubles
;; C prototype:
;;   int read_doubles( FILE * fp, double * arrayp, int array_size );
;; This function reads doubles from a text file into an array, until
;; EOF or array is full.
;; Parameters:
;;   fp         - FILE pointer to read from (must be open for input)
;;   arrayp     - pointer to double array to read into
;;   array_size - number of elements in array
;; Return value:
;;   number of doubles stored into array (in EAX)

_read_doubles:
  enter   0x20, 0
  mov     FP, rdi
  mov     ARRAYP, rsi
  mov     ARRAY_SIZE, rdx
  mov     TEMP_DOUBLE, 0

  mov     rcx, ARRAY_SIZE
while_loop:
  push    rcx
  sub     rsp, 0x08

;;
;; call fscanf() to read a double into TEMP_DOUBLE
;; fscanf() might change edx so save it
;;
  mov     rdi, FP
  mov     rsi, format
  lea     rax, [rbp - 0x20]
  mov     rdx, rax
  call    _fscanf
  cmp     eax, 1                  ; did fscanf return 1?
  jne     quit              ; if not, quit loop

;; copy TEMP_DOUBLE into ARRAYP
  mov     rax, ARRAYP
  mov     rdx, TEMP_DOUBLE
  mov     [rax], rdx
  add     rax, SIZEOF_DOUBLE
  mov     ARRAYP, rax

  add     rsp, 0x08
  pop     rcx
  loop     while_loop

quit:
  add     rsp, 0x08
  pop     rcx
  mov     rax, ARRAY_SIZE
  sub     eax, ecx

  leave
  ret
