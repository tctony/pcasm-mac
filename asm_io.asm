;;
;; file: asm_io.asm
;; Assembly I/O routines
;; To assemble for DJGPP
;;   nasm -f coff -d COFF_TYPE asm_io.asm
;; To assemble for Borland C++ 5.x
;;   nasm -f obj -d OBJ_TYPE asm_io.asm
;; To assemble for Microsoft Visual Studio
;;   nasm -f win32 -d COFF_TYPE asm_io.asm
;; To assemble for Linux
;;   nasm -f elf -d ELF_TYPE asm_io.asm
;; To assemble for Watcom
;;   nasm -f obj -d OBJ_TYPE -d WATCOM asm_io.asm
;; IMPORTANT NOTES FOR WATCOM
;;   The Watcom compiler's C library does not use the
;;   standard C calling convention. For example, the
;;   putchar() function gets its argument from the
;;   the value of EAX, not the stack.
default rel

%define NL 10
%define CF_MASK 00000001h
%define PF_MASK 00000004h
%define AF_MASK 00000010h
%define ZF_MASK 00000040h
%define SF_MASK 00000080h
%define DF_MASK 00000400h
%define OF_MASK 00000800h
;; more for flag registry
;;
;; Linux C doesn't put underscores on labels
;;
%ifdef ELF_TYPE
%define _scanf   scanf
%define _printf  printf
%define _getchar getchar
%define _putchar putchar
%endif

;;
;; Watcom puts underscores at end of label
;;
%ifdef WATCOM
%define _scanf   scanf_
%define _printf  printf_
%define _getchar getchar_
%define _putchar putchar_
%endif


%ifdef OBJ_TYPE
segment .data public align=4 class=data use32
%else
segment .data
%endif

  int_format      db  "%d", 0
  string_format   db  "%s", 0

reg_format:
  db  "Register Dump # %d", NL
  db  "rax = 0x%016llx rbx = 0x%016llx rcx = 0x%016llx rdx = 0x%016llx", NL
  db  "rsi = 0x%016llx rdi = 0x%016llx rbp = 0x%016llx rsp = 0x%016llx", NL
  db  "r8  = 0x%016llx r9  = 0x%016llx r10 = 0x%016llx r11 = 0x%016llx", NL
  db  "r12 = 0x%016llx r13 = 0x%016llx r14 = 0x%016llx r15 = 0x%016llx", NL
  db  "rip = 0x%016llx flags = %04llx %s %s %s %s %s %s %s", NL
  db  0

;; flags
  unset_flag      db	"  ", 0
  carry_flag      db  "CF", 0
  parity_flag     db	"PF", 0
  aux_carry_flag  db	"AF", 0
  zero_flag       db  "ZF", 0
  sign_flag       db  "SF", 0
  dir_flag        db	"DF", 0
  overflow_flag   db	"OF", 0

  mem_format_header  db  "Memory Dump # %d Address = 0x%016llx", NL, 0
  mem_format_addr    db  "0x%016llx: ", 0
  mem_format_hex     db  "%02x ", 0

stack_format:
  db  "Stack Dump # %d", NL
  db  "RBP = %.16X RSP = %.16X", NL, 0

  stack_line_format   db  "%+4d  %.8X  %.8X", NL, 0

;; TODO
; math_format1:
;   db  "Math Coprocessor Dump # %d Control Word = %.4X"
;   db  " Status Word = %.4X", NL, 0

;   valid_st_format     db  "ST%d: %.10g", NL, 0
;   invalid_st_format   db  "ST%d: Invalid ST", NL, 0
;   empty_st_format     db  "ST%d: Empty", NL, 0

;;
;; code is put in the _TEXT segment
;;
%ifdef OBJ_TYPE
segment text public align=1 class=code use32
%else
segment .text
%endif

extern  _scanf, _printf, _getchar, _putchar

global	read_int, print_int,
global  read_char, print_char
global  print_string, print_nl
global  sub_dump_regs, sudump_math, sub_dump_stack, sub_dump_mem

read_int:
  enter 0x20, 0
  mov   [rbp-0x10], rdi         ; save rdi to stack
  mov   [rbp-0x18], rsi         ; save rsi to stack

  mov   rdi, int_format
  lea   rsi, [rbp-0x04]
  mov   al, 0
  call	_scanf

  mov   rsi, [rbp-0x18]
  mov   rdi, [rbp-0x10]
  mov   eax, [rbp-0x04]
  leave
  ret

print_int:
  enter 0x10, 0
  mov   [rbp-0x08], rdi
  mov   [rbp-0x10], rsi

  mov   rdi, int_format
  mov   esi, eax
  call	_printf

  mov   rsi, [rbp-0x10]
  mov   rdi, [rbp-0x08]
  leave
  ret

read_char:
  enter 0, 0

  call	_getchar

  leave
  ret

print_char:
  enter	0x10, 0
  mov   [rbp-0x08], rdi

  mov   di, ax
  call	_putchar

  mov   rdi, [rbp-0x08]
  leave
  ret

print_string:
  enter	0x10, 0
  mov   [rbp-0x08], rdi
  mov   [rbp-0x10], rsi

  mov   rdi, string_format
  mov   rsi, rax
  call	_printf

  mov   rsi, [rbp-0x10]
  mov   rdi, [rbp-0x08]
  leave
  ret

print_nl:
  enter	0x10, 0
  mov   [rbp-0x08], rdi

  mov   di, NL
  call	_putchar

  mov   rdi, [rbp-0x08]
  leave
  ret

sub_dump_regs:
  enter   0x50, 0

  mov     [rbp-0x08], rax

  pushf
  mov     rax, [rsp]
  mov     [rbp-0x10], rax
  popf

  mov     [rbp-0x18], rdi
  mov     [rbp-0x20], rsi
  mov     [rbp-0x28], rdx
  mov     [rbp-0x30], rcx
  mov     [rbp-0x38], r8
  mov     [rbp-0x40], r9
  mov     [rbp-0x48], r10
  mov     [rbp-0x50], r11
  ; more(xmms, sts, x87s, cs, fs, gs etc) to save, but ingored here, hope it's ok

;; left to right order
  mov     rdi, reg_format       ;
  mov     rsi, qword [rbp+0x18] ; #
  mov     rdx, qword [rbp-0x08] ; rax
  mov     rcx, rbx              ; rbx
  mov      r8, qword [rbp-0x30] ; rcx
  mov      r9, qword [rbp-0x28] ; rdx

;; right to left order, x64 abi p20
  push    qword 0                  ; align to 16

;; check_flag flag_mask flag_string
%macro check_flag 2
  test    qword [rbp-0x10], %1
  jz      %%flag_off
  mov     rax, %2
  jmp     %%push_result
%%flag_off:
  mov     rax, unset_flag
%%push_result:
  push    rax
%endmacro

  check_flag CF_MASK, carry_flag
  check_flag PF_MASK, parity_flag
  check_flag AF_MASK, aux_carry_flag
  check_flag ZF_MASK, zero_flag
  check_flag SF_MASK, sign_flag
  check_flag DF_MASK, dir_flag
  check_flag OF_MASK, overflow_flag

%unmacro check_flag 2

  push    qword [rbp-0x10]      ; rflags
  mov     rax, [rbp+0x08]       ; return address
  sub     rax, 5+2+2            ; 5(callq), 2(pushq), 2(pushq)
  push    rax                   ; rip
  push    r15                   ; r15
  push    r14                   ; r14
  push    r13                   ; r13
  push    r12                   ; r12
  push    r11                   ; r11
  push    r10                   ; r10
  push    qword [rbp-0x40]      ; r9
  push    qword [rbp-0x38]      ; r8
  lea     rax, [rbp+0x20]       ; remove previous rbp, return address, two qword of #
  push    rax                   ; rsp
  push    qword [rbp]           ; rbp
  push    qword [rbp-0x18]      ; rdi
  push    qword [rbp-0x20]      ; rsi

  mov     al, 0
  call	  _printf

  add	    rsp, 0xb0             ; push 22 word

  mov     r11, [rbp-0x50]
  mov     r10, [rbp-0x48]
  mov     r9 , [rbp-0x40]
  mov     r8 , [rbp-0x38]
  mov     rcx, [rbp-0x30]
  mov     rdx, [rbp-0x28]
  mov     rsi, [rbp-0x20]
  mov     rdi, [rbp-0x18]

  mov     rax, [rbp-0x08]

  leave
  ret

sub_dump_mem:
  enter	  0, 0      ; didn't save regs here, so context may changed after return

  mov     rdi, mem_format_header
  mov     rsi, [rbp+0x20]       ; number
  mov     rdx, [rbp+0x18]       ; address
  call	  _printf

  mov     rsi, [rbp+0x18]
  and     rsi, 0xfffffffffffffff0 ; move to start of paragraph
  mov     rcx, [rbp+0x10]         ; paragraphs-count

paragraph_loop:
  push    rcx
  push    rsi
  mov     rdi, mem_format_addr
  call    _printf

  xor     rcx, rcx
mem_hex_loop:
  push    rax
  push    rcx
  mov     rdi, mem_format_hex
  mov     rax, [rsp+0x10]
  xor     rsi, rsi
  mov     sil, [rax+rcx]
  call	  _printf
  pop     rcx
  pop     rax
  inc     rcx
  cmp	    rcx, 0x10
  jl	    mem_hex_loop

  mov	    rax, '"'
  call	  print_char

  xor	    rcx, rcx
mem_char_loop:
  push    rax
  push    rcx
  xor	    rax, rax
  mov     rsi, [rsp+0x10]
  mov	    al, [rsi+rcx]
  test    al, al
  jz      null_char
  cmp	    al, 32
  jl	    non_printable
  cmp	    al, 126
  jg	    non_printable
  jmp	    mem_char_loop_continue
null_char:
  mov     al, '.'
  jmp	    mem_char_loop_continue
non_printable:
  mov	    al, '?'
mem_char_loop_continue:
  call	  print_char
  pop     rcx
  pop     rax
  inc     rcx
  cmp     rcx, 0x10
  jl	    mem_char_loop

  mov	    rax, '"'
  call	  print_char

  call	  print_nl

  pop     rsi
  add     rsi, 0x10                 ; next paragraph
  pop     rcx
  dec     rcx
  jnz	    paragraph_loop

  leave
  ret

;; function sub_dump_math
;;   prints out state of math coprocessor without modifying the coprocessor
;;   or regular processor state
;; Parameters:
;;  dump number - dword at [ebp+8]
;; Local variables:
;;   ebp-108 start of fsave buffer
;;   ebp-116 temp double
;; Notes: This procedure uses the Pascal convention.
;;   fsave buffer structure:
;;   ebp-108   control word
;;   ebp-104   status word
;;   ebp-100   tag word
;;   ebp-80    ST0
;;   ebp-70    ST1
;;   ebp-60    ST2 ...
;;   ebp-10    ST7
;;
;; TODO
; sub_dump_math:
;   enter	116,0
;   pusha
;   pushf

;   fsave	[ebp-108]	; save coprocessor state to memory
;   mov	eax, [ebp-104]  ; status word
;   and	eax, 0FFFFh
;   push	eax
;   mov	eax, [ebp-108]  ; control word
;   and	eax, 0FFFFh
;   push	eax
;   push	dword [ebp+8]
;   push	dword math_format1
;   call	_printf
;   add	esp, 16
; ;;
; ;; rotate tag word so that tags in same order as numbers are
; ;; in the stack
; ;;
;   mov	cx, [ebp-104]	; ax = status word
;   shr	cx, 11
;   and	cx, 7           ; cl = physical state of number on stack top
;   mov	bx, [ebp-100]   ; bx = tag word
;   shl     cl,1		; cl *= 2
;   ror	bx, cl		; move top of stack tag to lowest bits

;   mov	edi, 0		; edi = stack number of number
;   lea	esi, [ebp-80]   ; esi = address of ST0
;   mov	ecx, 8          ; ecx = loop counter
; tag_loop:
;   push	ecx
;   mov	ax, 3
;   and	ax, bx		; ax = current tag
;   or	ax, ax		; 00 -> valid number
;   je	valid_st
;   cmp	ax, 1		; 01 -> zero
;   je	zero_st
;   cmp	ax, 2		; 10 -> invalid number
;   je	invalid_st
;   push	edi		; 11 -> empty
;   push	dword empty_st_format
;   call	_printf
;   add	esp, 8
;   jmp	short cont_tag_loop
; zero_st:
;   fldz
;   jmp	short print_real
; valid_st:
;   fld	tword [esi]
; print_real:
;   fstp	qword [ebp-116]
;   push	dword [ebp-112]
;   push	dword [ebp-116]
;   push	edi
;   push	dword valid_st_format
;   call	_printf
;   add	esp, 16
;   jmp	short cont_tag_loop
; invalid_st:
;   push	edi
;   push	dword invalid_st_format
;   call	_printf
;   add	esp, 8
; cont_tag_loop:
;   ror	bx, 2		; mov next tag into lowest bits
;   inc	edi
;   add	esi, 10         ; mov to next number on stack
;   pop	ecx
;   loop    tag_loop

;   frstor	[ebp-108]       ; restore coprocessor state
;   popf
;   popa
;   leave
;   ret	4

;; TODO
; sub_dump_stack:
;   enter   0,0
;   pusha
;   pushf

;   lea     eax, [ebp+20]
;   push    eax             ; original ESP
;   push    dword [ebp]     ; original EBP
;   push	dword [ebp+8]   ; # of dump
;   push	dword stack_format
;   call	_printf
;   add	esp, 16

;   mov	ebx, [ebp]	; ebx = original ebp
;   mov	eax, [ebp+16]   ; eax = # dwords above ebp
;   shl	eax, 2          ; eax *= 4
;   add	ebx, eax	; ebx = & highest dword in stack to display
;   mov	edx, [ebp+16]
;   mov	ecx, edx
;   add	ecx, [ebp+12]
;   inc	ecx		; ecx = # of dwords to display

; stack_line_loop:
;   push	edx
;   push	ecx		; save ecx & edx

;   push	dword [ebx]	; value on stack
;   push	ebx		; address of value on stack
;   mov	eax, edx
;   sal	eax, 2		; eax = 4*edx
;   push	eax		; offset from ebp
;   push	dword stack_line_format
;   call	_printf
;   add	esp, 16

;   pop	ecx
;   pop	edx

;   sub	ebx, 4
;   dec	edx
;   loop	stack_line_loop

;   popf
;   popa
;   leave
;   ret     12
