.section .data
prompt1:        .ascii "Enter first string: "
prompt1_len = . - prompt1
prompt2:        .ascii "Enter second string: "
prompt2_len = . - prompt2
msg_label:      .ascii "Hamming distance: "
msg_label_len = . - msg_label
newline:        .ascii "\n"

.section .bss
str1:    .space 256
str2:    .space 256
num_buf: .space 10

.section .text
.global _start
_start:
    movl $4, %eax
    movl $1, %ebx
    movl $prompt1, %ecx
    movl $prompt1_len, %edx
    int  $0x80
    movl $str1, %edi
    call read_line

    movl $4, %eax
    movl $1, %ebx
    movl $prompt2, %ecx
    movl $prompt2_len, %edx
    int  $0x80
    movl $str2, %edi
    call read_line

    movl $str1, %esi
    call str_len
    movl %eax, %ecx
    movl $str2, %esi
    call str_len
    movl %eax, %edx
    cmpl %ecx, %edx
    jae  len_ok
    movl %edx, %ecx
len_ok:

    movl $0, %eax
    movl $0, %esi
hamming_loop:
    cmpl %ecx, %esi
    je   print_answer
    movb str1(%esi), %bl
    movb str2(%esi), %bh
    cmpb %bl, %bh
    je   no_diff
    incl %eax
no_diff:
    incl %esi
    jmp  hamming_loop

print_answer:
    pushl %eax
    movl $4, %eax
    movl $1, %ebx
    movl $msg_label, %ecx
    movl $msg_label_len, %edx
    int  $0x80
    popl %eax
    call int_to_str
    movl %ecx, %edx
    movl %esi, %ecx
    movl $4, %eax
    movl $1, %ebx
    int  $0x80
    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int  $0x80

do_exit:
    movl $1, %eax
    movl $0, %ebx
    int  $0x80

read_line:
    movl %edi, %esi
rl_loop:
    movl $3, %eax
    movl $0, %ebx
    movl %esi, %ecx
    movl $1, %edx
    int  $0x80
    cmpl $1, %eax
    jne  rl_done
    cmpb $'\n', (%esi)
    je   rl_done
    incl %esi
    movl %esi, %eax
    subl %edi, %eax
    cmpl $255, %eax
    jl   rl_loop
rl_done:
    movb $0, (%esi)
    ret

str_len:
    movl $0, %eax
str_len_loop:
    cmpb $0, (%esi)
    je   str_len_done
    incl %eax
    incl %esi
    jmp  str_len_loop
str_len_done:
    ret

int_to_str:
    movl $num_buf, %edi
    addl $9, %edi
    movl $0, %ecx
    cmpl $0, %eax
    jne  int_to_str_loop
    movb $'0', (%edi)
    movl %edi, %esi
    movl $1, %ecx
    ret
int_to_str_loop:
    cmpl $0, %eax
    je   int_to_str_done
    movl $0, %edx
    movl $10, %ebx
    divl %ebx
    addb $'0', %dl
    movb %dl, (%edi)
    decl %edi
    incl %ecx
    jmp  int_to_str_loop
int_to_str_done:
    incl %edi
    movl %edi, %esi
    ret