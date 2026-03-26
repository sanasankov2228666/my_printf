default rel
section .text

; global _start

global my_printf

;________________________________________________________________________________________________________________________________________


; =====================================  my_printf  =====================================
;                       
; 	entery:    rdi - format string
;                  rsi, rdx, rcx, r8, r9, stack from right to left - substitutions args
;
; 	exit:      rax - num of outputed symbols                               
; 	expected:  
;	destr:     rax
;
; =======================================================================================

my_printf:

        push rbp
        push rbx
        mov rbp, rsp

        ; ======= put args in stack ========

        push rdi    ; arg1       [rbp-8]
        push r9     ; arg5       [rbp-16] 
        push r8     ; arg5       [rbp-32]
        push rcx    ; arg4       [rbp-32]
        push rdx    ; arg3       [rbp-40]
        push rsi    ; arg2       [rbp-48] 

        push rax    ; save al    [rbp-56] 

        ; ======= allocate memory ==========

        sub rsp, 16                         ; arg int counter, arg float counter
        %define fmt_ptr      [rbp-8]        ; ptr on format string
        %define int_cnt      [rbp-64]       ; count args
        %define flt_cnt      [rbp-72]       ; count args
        
        ; ============ init ===============

        mov qword int_cnt, 0    ; clear memory
        mov qword flt_cnt, 0

        mov rdi, fmt_ptr        ; rdi = frm str for all func  
        lea r8, [buffer_out]    ; r8  = buffer out ptr for all func
        xor r9, r9              ; r9  = buffer offset ptr for all func

        ; ========== func begin ===========

buffer_going:

        cmp r9, 4000            ; if buffer overload is full
        jb buffer_ok

        call buf_output 

buffer_ok:
        
        mov al, [rdi]           ; al = [fromat string + cur]
        
        cmp al, 0               ; if end of string
        je end_buffer_going

        cmp al, '%'             ; if specifier
        je prcsng_spec

        mov [r8 + r9], al       ; [buffer + cur] = al, if default symbil
        inc rdi                 ; inc offsets
        inc r9

        cmp al, 10              ; if \n
        jne not_new_line        

        call buf_output

        not_new_line:

        jmp buffer_going        ; Jump into the cycle

end_buffer_going:

        call buf_output

; ======= get saved regs ========

        add rsp, 16

        pop rax
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9
        pop rdi
        pop rbx
        pop rbp

        ret

;________________________________________________________________________________________________________________________________________

; ================================ buf output  ===============================
;                       
; 	entery:        void
; 	exit:          r9 = 0, buf outputed on screen                          
; 	expected:      r8 - buffer, r9 - offset
;	destr:         rax, rsi, rdx
;
; ============================================================================

buf_output:

        mov rax, 0x01
        mov fmt_ptr, rdi
        mov rdi, 1              ; stdout
        mov rsi, r8             ; rsi = buffer
        mov rdx, r9             ; rdx = len
        syscall                 ; write (stdout, buffer, len)

        mov rdi, fmt_ptr
        xor r9, r9

        ret

; ===========================================================================================================================
;                                               proccessing specifiers
;============================================================================================================================

prcsng_spec:

        xor rax, rax        ; rax = 0

        inc rdi             
        mov al, [rdi]       ; take letter after %

        cmp rax, 'b'        
        jb bad_spec
        cmp rax, 'x'          
        ja bad_spec         ; if unc format

normal_spec:

        sub rax, 'b'

        lea rsi, [jump_table_spec]
        jmp [rsi + rax*8]
  
end_spec_prcsng:

        inc rdi
        jmp buffer_going

bad_spec:

        call prcsng_un
        jmp end_spec_prcsng

;______________________________________________________________________________________________________________________________________
;
;                                              FUNCTIONS FOR PROCCESING SPEC
;______________________________________________________________________________________________________________________________________


;============================================
;              processing unknown
;============================================

prcsng_un:

        cmp al, 0
        je end_frmt_str

        mov [r8 + r9], al   ; put symbol after %(_)
        inc r9

end_frmt_str:

        ret

; ___________________________________________________________________

;============================================
;               processing bin
;============================================

prcsng_b:

        call take_int
        mov rcx, 32

        mov byte [r8 + r9], '0'
        inc r9
        mov byte [r8 + r9], 'b'
        inc r9

        test rdx, rdx
        jne skip_zero_b          ; if not 0

        mov byte [r8 + r9], '0'  ; if 0
        inc r9

        jmp ret_bin

skip_zero_b:

        dec rcx

        mov eax, edx
        shr eax, cl              ; put 0 or 1 from number on cx place in begin
        and eax, 1

        cmp eax, 0
        je skip_zero_b

        add al, '0'              ; al = asci code
        mov [r8 + r9], al        ; put sym in buffer
        inc r9

        test rcx, rcx            ; if end of number
        je ret_bin                 

loop_out_b:

        dec rcx

        mov eax, edx
        shr eax, cl
        and eax, 1 

        add al, '0'

        mov [r8 + r9], al
        inc r9

        test rcx, rcx
        jnz loop_out_b

ret_bin:

        ret

; ___________________________________________________________________

;============================================
;               processing char
;============================================

prcsng_c:

        call take_int

        and rdx, 255

        mov [r8 + r9], dl
        inc r9

        ret

; ___________________________________________________________________

;============================================
;                processing d
;============================================

prcsng_d:

        call take_int

flt_out_help:
    
        mov eax, edx
        xor rcx, rcx

        test edx, edx
        jns positive            ; if not sign

        mov byte [r8 + r9], '-'
        inc r9
        neg eax                 ; to out put same num with -

positive:

        sub rsp, 32             ; buffer for number
        mov rsi, rsp

        mov ebx, 10             ; bx = 10

; ========== loop processing int ==========

convert_num:

        xor edx, edx
        div ebx
        add dl, '0'

        dec rsi
        mov [rsi], dl
        inc rcx

        test eax, eax
        jnz convert_num

; ============== end loop ================

copy_in_buffer:

        mov al, [rsi]
        mov [r8 + r9], al

        inc r9
        inc rsi
        dec rcx
        jnz copy_in_buffer

        add rsp, 32
        ret

; ___________________________________________________________________

;============================================
;               processing string
;============================================

prcsng_x:

        call take_int
        mov ecx, 8 

        mov byte [r8 + r9], '0'
        inc r9
        mov byte [r8 + r9], 'x'
        inc r9

        test rdx, rdx
        jne skip_zero_hex          ; if not 0

        mov byte [r8 + r9], '0'    ; if 0
        inc r9
        jmp ret_hex

skip_zero_hex:

        dec cx
        rol edx, 4           ; put last 4 bytes in the begin
        mov al, dl                  
        and al, 0Fh          ; put this number in al

        cmp al, 0                  
        je skip_zero_hex     ; if still zero

        inc rcx
        cmp al, 10
    	jl is_digit          ; output not zero sym

        add al, 7

        jmp is_digit
        
loop_hex:

        rol edx, 4
        mov al, dl
        and al, 0Fh

        cmp al, 10
   	    jl is_digit

        add al, 7

is_digit:

    	add al, '0'
        mov [r8 + r9], al
        inc r9
        loop loop_hex

ret_hex:

        ret

; ___________________________________________________________________

;============================================
;               processing pointer
;============================================

prcsng_p:

        call take_int
        mov ecx, 16 

        mov byte [r8 + r9], '0'
        inc r9
        mov byte [r8 + r9], 'x'
        inc r9

loop_ptr:

        rol rdx, 4
        mov al, dl
        and al, 0Fh

        cmp al, 10
        jl is_digit_ptr

        add al, 7

is_digit_ptr:

    	add al, '0'
        mov [r8 + r9], al
        inc r9
        loop loop_ptr

        ret        

; ___________________________________________________________________

;============================================
;             processing octagone
;============================================

prcsng_o:

        call take_int
        mov eax, edx
        xor rcx, rcx

        sub rsp, 32               ; buffer for number
        mov rsi, rsp
        add rsi, 31
        mov byte [rsi], 0         ; end of buffer

        mov ebx, 8                ; bx = 10

; ========== loop processing oct ==========

convert_oct:

        xor edx, edx
        div ebx
        add dl, '0'

        dec rsi
        mov [rsi], dl
        inc rcx

        test eax, eax
        jnz convert_oct

; =============== end loop ================

copy_in_buffer_hex:

        mov al, [rsi]
        mov [r8 + r9], al

        inc r9
        inc rsi
        dec rcx
        jnz copy_in_buffer_hex

        add rsp, 32
        ret

; ___________________________________________________________________

;============================================
;              processing string
;============================================

prcsng_s:

        call take_int
        cmp rdx, 0
        je end_loop_prc_s

; ======= proccessing string loop =======

loop_prc_s:

        mov al, [rdx]
        cmp al, 0
        je end_loop_prc_s

        mov [r8 + r9], al
        inc r9
        inc rdx

        cmp r9, 4000
        jb have_place

        push rdx
        call buf_output
        pop rdx

have_place:

        jmp loop_prc_s

; =========== end loop =============

end_loop_prc_s:

        ret

; ___________________________________________________________________

;============================================
;              processing float
;============================================

prcsng_f:

        call take_flt

; ============ check if inf/nan =============

        movd edx, xmm8            ; edx = IEEE 754 32-bit
        test edx, edx                   
        jns pos_flot

        mov byte [r8 + r9], '-'        ; check if neg
        inc r9                    
        and edx, 0x7FFFFFFF       ; put sign bit in 0
        movd xmm8, edx            ; ret xmm8

pos_flot:

        mov eax, edx              ; copy edx in eax
        and eax, 0x7F800000       ; take exp
        cmp eax, 0x7F800000       ; if exp not 111...
        jne default_flt

        and edx, 0x007FFFFF       ; take M
        cmp edx, 0                ; if M == 0 
        jne if_nan                                      
        jmp if_inf

default_flt:       

        cvttss2si edx, xmm8      ; take integer part of xmm8
        cvtsi2ss xmm9, edx       ; xmm9 = (float) edx
        subss xmm8, xmm9         ; xmm8 = xmm8 - [xmm8]

        call flt_out_help        ; output int part
        mov byte [r8 + r9], '.'  ; put dot
        inc r9

        movd xmm9, [million_flt] ; xmm9 = 1000000,0
        mulss xmm8, xmm9         ; xmm8 = xmm8 * 10^6

        cvttss2si edx, xmm8      ; put int in edx

        test edx, edx
        jns print_frac           ; if >= 0

        neg edx                  ; take abs

; ============= printing frac part ==============

print_frac:           

        mov eax, edx            ; eax - divisible
        sub rsp, 32             ; buffer for number
        mov rsi, rsp

        mov ebx, 10             ; ebx = 10 - divider
        mov rcx, 6

loop_scaning:

        xor edx, edx
        div ebx
        add dl, '0'

        dec rsi
        mov [rsi], dl
        loop loop_scaning

        mov rcx, 6

put_frac_buf:

        mov al, [rsi]
        mov [r8 + r9], al

        inc r9
        inc rsi
        loop put_frac_buf

        add rsp, 32
        ret        

; ============= if nan ===============
if_nan:
        mov byte [r8 + r9], 'N'
        mov byte [r8 + r9 + 1], 'A'
        mov byte [r8 + r9 + 2], 'N'
        add r9, 3

        ret
; ============= if inf ===============
if_inf:
        mov byte [r8 + r9], 'i'
        mov byte [r8 + r9 + 1], 'n'
        mov byte [r8 + r9 + 2], 'f'
        add r9, 3

        ret

;______________________________________________________________________________________________________________________________________
;
;                                               FUNCTIONS FOT TAKING ARGS
;______________________________________________________________________________________________________________________________________


; ================================== take arg  ===============================
;                       
; 	entery:        void
; 	exit:          rdx - arg                          
; 	expected:      ---
;	destr:         rax, rdi
;
; ============================================================================

take_int:

        mov rax, int_cnt

        cmp rax, 5
        jae stack_argument

        mov rdx, [rbp - 48 + rax*8]
        inc rax

        mov int_cnt, rax
        ret

stack_argument:

        mov rcx, flt_cnt
        cmp rcx, 8
        jb skip_f_args

        add rax, rcx 
        sub rax, 8

skip_f_args:

        mov rdx, [rbp - 16 + rax*8]
        mov rax, int_cnt
        inc rax
            
        mov int_cnt, rax
        ret

;_______________________________________________________________________________


; ============================= take float arg  =============================
;                       
; 	entery:        void
; 	exit:          xmm8 - arg                          
; 	expected:      ---
;	destr:         rax, rdi
;
; ============================================================================

take_flt:

        mov rax, flt_cnt

        cmp rax, 8                ; if flt args > 6, take from stack
        jae stack_f_argument    

        lea rsi, [float_args]     ; get jump adres
        jmp [rsi + rax*8]         ; jump on current arg

; ===== proccesing args in regs =====

arg1:
        cvtsd2ss xmm8, xmm0
        jmp ret_take
arg2:
        cvtsd2ss xmm8, xmm1
        jmp ret_take
arg3:
        cvtsd2ss xmm8, xmm2
        jmp ret_take
arg4:
        cvtsd2ss xmm8, xmm3
        jmp ret_take
arg5:
        cvtsd2ss xmm8, xmm4
        jmp ret_take
arg6:
        cvtsd2ss xmm8, xmm5
        jmp ret_take
arg7:
        cvtsd2ss xmm8, xmm6
        jmp ret_take
arg8:
        cvtsd2ss xmm8, xmm7
        jmp ret_take

; ========== stack argument =========

stack_f_argument:

        mov rcx, int_cnt
        cmp rcx, 5
        jb skip_i_args

        add rax, rcx
        sub rax, 5

skip_i_args:

        movsd xmm8, [rbp - 40 + rax*8]
        cvtsd2ss xmm8, xmm8

ret_take:

        mov rax, flt_cnt
        inc rax
        mov flt_cnt, rax
        ret

;__________________________________________________________________________________________________________________________________________


; ============================================================================================================================
;                                                       MAIN
; ============================================================================================================================

; _start:

;         mov rdi, format_str
;         mov rsi, str
;         mov rdx, 65
;         mov rcx, 123
;         mov r8, 234
;         mov r9, -345
;         push 1234
;         push 2345

;         call my_printf

;         mov rax, 0x3C
;         xor rdi, rdi
;         syscall


; _______________________________________________________________________________________________________________________________________

; ============================================================================================================================
;                                                       DATA
; ============================================================================================================================

section .data
align 8

    million_flt: dd 1000000.0

jump_table_spec:
align 8

    dq prcsng_b      ; 0  = 'b'
    dq prcsng_c      ; 1  = 'c'
    dq prcsng_d      ; 2  = 'd'
    dq prcsng_un     ; 3  = 'e'
    dq prcsng_f      ; 4  = 'f'
    dq prcsng_un     ; 5  = 'g'
    dq prcsng_un     ; 6  = 'h'
    dq prcsng_d      ; 7  = 'i'
    dq prcsng_un     ; 8  = 'j'
    dq prcsng_un     ; 9  = 'k'
    dq prcsng_un     ; 10 = 'l'
    dq prcsng_un     ; 11 = 'm'
    dq prcsng_un     ; 12 = 'n'
    dq prcsng_o      ; 13 = 'o'
    dq prcsng_p      ; 14 = 'p'
    dq prcsng_un     ; 15 = 'q'
    dq prcsng_un     ; 16 = 'r'
    dq prcsng_s      ; 17 = 's'
    dq prcsng_un     ; 18 = 't'
    dq prcsng_un     ; 19 = 'u'
    dq prcsng_un     ; 20 = 'v'
    dq prcsng_un     ; 21 = 'w'
    dq prcsng_x      ; 22 = 'x'


; ======== JUMP TABLE FOR FLOAT ARGS ==========

float_args:
align 8 

    dq arg1
    dq arg2
    dq arg3
    dq arg4
    dq arg5
    dq arg6
    dq arg7
    dq arg8


; ============================================================================================================================
;                                                      RODATA
; ============================================================================================================================

; section .rodata

; ; ======== JUMP TABLE FOR SPEC ==========

; jump_table_spec:
; align 8

;     dq prcsng_b  - jump_table_spec      ; 0  = 'b'
;     dq prcsng_c  - jump_table_spec      ; 1  = 'c'
;     dq prcsng_d  - jump_table_spec      ; 2  = 'd'
;     dq prcsng_un - jump_table_spec      ; 3  = 'e'
;     dq prcsng_f  - jump_table_spec      ; 4  = 'f'
;     dq prcsng_un - jump_table_spec      ; 5  = 'g'
;     dq prcsng_un - jump_table_spec      ; 6  = 'h'
;     dq prcsng_d  - jump_table_spec      ; 7  = 'i'
;     dq prcsng_un - jump_table_spec      ; 8  = 'j'
;     dq prcsng_un - jump_table_spec      ; 9  = 'k'
;     dq prcsng_un - jump_table_spec      ; 10 = 'l'
;     dq prcsng_un - jump_table_spec      ; 11 = 'm'
;     dq prcsng_un - jump_table_spec      ; 12 = 'n'
;     dq prcsng_o  - jump_table_spec      ; 13 = 'o'
;     dq prcsng_p  - jump_table_spec      ; 14 = 'p'
;     dq prcsng_un - jump_table_spec      ; 15 = 'q'
;     dq prcsng_un - jump_table_spec      ; 16 = 'r'
;     dq prcsng_s  - jump_table_spec      ; 17 = 's'
;     dq prcsng_un - jump_table_spec      ; 18 = 't'
;     dq prcsng_un - jump_table_spec      ; 19 = 'u'
;     dq prcsng_un - jump_table_spec      ; 20 = 'v'
;     dq prcsng_un - jump_table_spec      ; 21 = 'w'
;     dq prcsng_x  - jump_table_spec      ; 22 = 'x'


; ; ======== JUMP TABLE FOR FLOAT ARGS ==========

; float_args:
; align 8 

;     dq arg1 - float_args
;     dq arg2 - float_args
;     dq arg3 - float_args
;     dq arg4 - float_args
;     dq arg5 - float_args
;     dq arg6 - float_args
;     dq arg7 - float_args
;     dq arg8 - float_args


; ============================================================================================================================
;                                                       BSS
; ============================================================================================================================


section .bss

    buffer_out:  resb 4096

section .note.GNU-stack noalloc noexec nowrite progbits