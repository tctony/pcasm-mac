;; -*- mode: nasm -*-

extern read_int, print_int
extern read_char, print_char
extern print_string, print_nl
extern sub_dump_regs, sub_dump_mem, sub_dump_math, sub_dump_stack

;; usage: dump_regs number
%macro  dump_regs 1
  push qword %1
  push qword %1                 ; align to 16
  call sub_dump_regs
  add  rsp, 0x10
%endmacro

;; usage: dump_mem number, start-address, paragraphs-count(optional, default 2)
%macro  dump_mem 2-3 2
  push    rax
  push    qword %1
  mov     rax, %2
  push    rax
  push    qword %3
  call    sub_dump_mem
  add     rsp, 0x18
  pop     rax
%endmacro

; %macro	dump_math 1
; ;; TODO
;   ; push    dword %1
;   ; call    sub_dump_math
; %endmacro

;; usage: dump_stack number, paragraphs-count above rbp(optional, default 1), paragraphs-count below rbp(optional, default 1)
%macro  dump_stack 1-3 1, 2
  push    qword %3
  push    qword %2
  push    qword %1
  push    qword %1              ; align to 16
  call    sub_dump_stack
  add     rsp, 0x20
%endmacro
