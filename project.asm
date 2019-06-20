org 100h
     
.data
    size dw 4
    input1 db 4+1 dup(0)     
    input2 db 4+1 dup(0)
    extra_array 4+1 dup(0)
    operator db 1+1 dup(0)  
    res_size dw 10
    final_res db 10+1 dup(0)
    larger_num db 0 ;0 -> num1, 1 -> num2
    
    msg_welcome db '<< Minimal arithmetic calculator in 8086 assembly >>$'
    msg_about db '( developed by Mohammad Salek ^^ )$'
    msg_result db 'The result is:$'
    msg_wrong_number_input db 'Error: wrong input! (number should be between 0-9)$'
    msg_wrong_operator_input db 'Error: wrong input! (valid operators: +, -, *, /)$' 
    msg_error db 'Error!$'
    msg_exiting db 'Exiting now...$'
    
    newLine db 10, 13, '$'
    space db 32, '$'
    text_num1 db '(num1)', 32, ':', 32, '$'
    text_num2 db '(num2)', 32, ':', 32, '$'
    text_oprtr db '(oprtr): $'
    text_equal db '=$'
    
    ;one digit calculation:
    num1 db ?, '$'
    num2 db ?, '$'
    carry db 0, '$'
    res db ?, '$'   
    
.code 
    print_header:
        lea dx, msg_welcome
        call print
        call print_newLine
        call print_newLine       
    before_input1:        
        lea dx, text_num1
        call print
        mov bx, 0
        jmp get_input1       
    get_input1:
        call get_input 
        mov input1[bx], al        
    check_number:
        cmp al, '0'
        jb wrong_input_number
        cmp al, '9'
        jg wrong_input_number
        jmp correct_number
    wrong_input_number:
        call wrong_num
        jmp ending
    correct_number:                      
        inc bx
        cmp bx, size
        jge before_operator
        jmp get_input1    
    before_operator:
        call print_newLine
        lea dx, text_oprtr
        call print
        jmp get_operator        
    get_operator:
        call get_input 
        mov operator, al 
    check_operator:
        cmp al, 43;'+'
        je correct_operator
        cmp al, 45;'-'
        je correct_operator
        cmp al, 42;'*'
        je correct_operator
        cmp al, 47;'/'
        je correct_operator
        jmp wrong_input_operator
    wrong_input_operator:
        call wrong_operator
        jmp ending
    correct_operator:
        jmp before_input2       
    before_input2:
        call print_newLine
        mov bx, 0
        lea dx, text_num2
        call print
        jmp get_input2                    
    get_input2:
        call get_input 
        mov input2[bx], al       
    check_number2:
        cmp al, '0'
        jb wrong_input_number2
        cmp al, '9'
        jg wrong_input_number2
        jmp correct_number2
    wrong_input_number2:
        call wrong_num
        jmp ending
    correct_number2:                   
        inc bx
        cmp bx, size
        jge operations
        jmp get_input2
    operations:
        mov dl, operator
        cmp dl, '+'
        je _sum_
        cmp dl, '-'
        je _sub_
        cmp dl, '*'
        je _mul_
        cmp dl, '/'
        je _div_
        jmp ending
    _sum_:      
        call proc_sum
        jmp ending
    _sub_:    
        call proc_sub
        jmp ending    
    _mul_:    
        call proc_mul 
        jmp ending     
    _div_:    
        call proc_div
        jmp ending   
    ending:
        _show_final_res_in_ascii:
            mov si, 0
            mov ax, res_size
            dec ax ;last index 
        _skip_the_first_zeros:
            inc si
            mov dl, final_res[si]
            cmp dl, 0
            je _skip_the_first_zeros            
        _add_48_to_final_res:        
            add final_res[si], 48
            inc si
            cmp si, ax
            jg _add_48_done
            jmp _add_48_to_final_res        
        _add_48_done:     
            mov si, res_size
            mov final_res[si], '$'
            call print_newLine
            call print_newLine
            lea dx, final_res
            call print         
        call print_newLine
        call print_newLine
        call print_newLine
        lea dx, msg_exiting
        call print  
        call print_newLine
        call print_newLine
        lea dx, msg_about
        call print
        ret    
        
get_input proc
    mov ah, 01h
    int 21h
    ret
get_input endp

print_newLine proc
    lea dx, newLine
    mov ah, 09h
    int 21h
    ret
print_newLine endp

print_space proc
    lea dx, space
    mov ah, 09h
    int 21h
    ret
print_space endp

print proc
    mov ah, 09h
    int 21h
    ret        
print endp

proc_sum proc      
    ;move number1 to the final_res array:
    _SUM_num1_to_array:
        mov bx, size
        mov si, res_size
        dec bx
        dec si   
    _SUM_add_num1_to_array_:
        mov cl, input1[bx]
        sub cl, 48
        mov final_res[si], cl
        dec bx
        dec si
        cmp bx, 0
        jl _SUM_after_num1_added_to_array
        jmp _SUM_add_num1_to_array_        
    _SUM_after_num1_added_to_array:    
    _SUM_48_from_input2:
        mov bx, size
        dec bx
    _SUM_48_loop_:
        mov cl, input2[bx]
        sub cl, 48
        mov input2[bx], cl
        dec bx
        cmp bx, 0
        jl _SUM_48_done_
        jmp _SUM_48_loop_
     
    _SUM_48_done_:    
    _SUM_before_sum_loop:   
        mov bx, size
        dec bx
        mov si, res_size
        dec si
        mov carry, 0        
    _SUM_loop:
        mov cl, carry
        add cl, input2[bx]
        add cl, final_res[si]         
        cmp cl, 10
        jge _SUM_handle_carry
        mov carry, 0 ;remove the carry        
    _SUM_after_carry_handled:    
        mov final_res[si], cl
        dec bx
        dec si
        cmp bx, 0
        jl _SUM_end_loop
        jmp _SUM_loop        
    _SUM_handle_carry:
        sub cl, 10
        mov carry, 1
        jmp _SUM_after_carry_handled        
    _SUM_end_loop:
        cmp carry, 0
        je _SUM_carry_is_zero        
        ;carry is not zero:
        _SUM_carry_not_zero:
            mov cl, carry
            add cl, final_res[si]
            cmp cl, 10
            jge _SUM_carry_one_more_time
            jmp _SUM_finish_carry                    
        _SUM_carry_one_more_time:
            sub cl, 10
            mov final_res[si], cl
            mov carry, 1
            dec si
            jmp _SUM_carry_not_zero             
        _SUM_finish_carry:
            mov final_res[si], cl                          
    _SUM_carry_is_zero:   
    _SUM_ending:
        ret
proc_sum endp             
             
proc_sub proc  
  call find_larger_num  
  cmp larger_num, 0
  je _sub_num1_to_array
  ;transfer input1 to input2:
  mov bx, size
  dec bx
  _sub_transfer_loop:
      mov dl, input1[bx]
      mov dh, input2[bx]
      mov input2[bx], dl
      mov input1[bx], dh 
      dec bx
      cmp bx, 0
      jl _sub_transfer_done
      jmp _sub_transfer_loop 
  _sub_transfer_done:          
  ;move number1 to the final_res array:
  _sub_num1_to_array:
      mov bx, size
      mov si, res_size
      dec bx
      dec si  
  _sub_add_num1_to_array:
      mov cl, input1[bx]
      sub cl, 48
      mov final_res[si], cl
      dec bx
      dec si
      cmp bx, 0
      jl _sub_after_num1_added_to_array
      jmp _sub_add_num1_to_array 
  _sub_after_num1_added_to_array:  
  sub_48_from_input2:
     mov bx, size
     dec bx
  _sub_48_loop_:
     mov cl, input2[bx]
     sub cl, 48
     mov input2[bx], cl
     dec bx
     cmp bx, 0
     jl _sub_48_done_
     jmp _sub_48_loop_     
  _sub_48_done_:  
  sub_before_loop:
      xor dl, dl
      mov carry, 0
      mov si, res_size
      mov bx, size ;index of input2
      dec si
      dec bx   
  _loop_cout_sub:    
      mov dl, final_res[si]
      sub dl, input2[bx]
      sub dl, carry
      js _it_is_negative     
      mov carry, 0       
  _continue_after_neg:      
      mov final_res[si], dl
      dec si
      dec bx      
      cmp bx, 0
      jl _sub_finish_
      jmp _loop_cout_sub      
  _it_is_negative:
      add dl, input2[bx]
      add dl, carry
      add dl, 10
      sub dl, input2[bx]
      sub dl, carry
      mov carry, 1
      jmp _continue_after_neg      
  _sub_finish_:
      cmp carry, 0
      je _sub_carry_is_zero      
      ;There should not be any carry left!!
      lea dx, msg_error
      call print       
  _sub_carry_is_zero:  
      mov si, -1
      mov ax, res_size
      dec ax ;last index 
  _sub_skip_the_first_zeros:
      inc si
      mov dl, final_res[si]
      cmp dl, 0
      je _sub_skip_the_first_zeros      
  _sub_add_neg_sign_if_neg:
      cmp larger_num, 1
      jne _sub_add_48_to_final_res
      mov final_res[si-1], '-'  ;else it's negative!
      sub final_res[si-1], 48                                             
  _sub_add_48_to_final_res:
      ;this section is deleted here    
  _sub_add_48_to_final_done:     
   ret 
proc_sub endp                          
              
proc_mul proc        
;move input2 to extra_array:
    mov bx, size
    dec bx       
    _MUL_loop_move_to_array:          
        mov al, input2[bx]
        sub al, 48
        mov extra_array[bx], al
        dec bx
        cmp bx, 0
        jl _MUL_moving_to_array_done
        jmp _MUL_loop_move_to_array
    _MUL_moving_to_array_done:                                     
;until extra_array is zero:
    _MUL_extra_array_zero_check:
        mov bx, size
        dec bx
    _MUL_till_extra_array_zero_loop:
        mov al, extra_array[bx]
        cmp al, 0
        jne _MUL_extra_array_NOT_zero
        cmp bx, 0
        jl _MUL_extra_array_is_zero
        dec bx
        jmp _MUL_till_extra_array_zero_loop        
;add input1 to final_res:        
    _MUL_extra_array_NOT_zero:
        mov bx, size
        dec bx
        mov si, res_size
        dec si  
        mov carry, 0        
    _MUL_loop_to_add_all_input1_digits:        
        mov al, input1[bx]
        sub al, 48
        add al, final_res[si]
        add al, carry 
        cmp al, 10
        jge _MUL_carry_to_sum
        jmp _MUL_no_carry        
    _MUL_no_carry:       
        mov final_res[si], al             
        mov carry, 0
        jmp _MUL_next_digit        
    _MUL_carry_to_sum:
        sub al, 10
        mov final_res[si], al
        mov carry, 1
        jmp _MUL_next_digit        
    _MUL_next_digit:
        dec bx
        dec si
        cmp bx, 0
        jl _MUL_add_loop_done
        jmp _MUL_loop_to_add_all_input1_digits                                              
    _MUL_add_loop_done:
    _MUL_check_carry_loop:    
        cmp carry, 0
        je _MUL_carry_check_done
        mov al, final_res[si]
        add al, carry
        cmp al, 10
        jge _MUL_carry_NOT_zero_again
        jmp _MUL_carry_is_zero_this_time                  
    _MUL_carry_NOT_zero_again:
        sub al, 10
        mov final_res[si], al
        dec si
        mov carry, 1
        jmp _MUL_check_carry_loop                
    _MUL_carry_is_zero_this_time:
        mov final_res[si], al
        dec si
        mov carry, 0
        jmp _MUL_check_carry_loop
    _MUL_carry_check_done:                              
;sub 'one' from extra_array(extra_array is always bigger than 0):
    mov bx, size
    dec bx    
    _MUL_sub_one_loop:    
        mov al, extra_array[bx]
        cmp al, 0
        je _MUL_we_have_neg_carry
        sub al, 1
        mov extra_array[bx], al
        jmp _MUL_sub_is_done    
    _MUL_we_have_neg_carry:
        mov extra_array[bx], 9
        dec bx
        jmp _MUL_sub_one_loop               
;check if extra_array is zero:
    _MUL_sub_is_done:                         
        jmp _MUL_extra_array_zero_check                             
    _MUL_extra_array_is_zero:
        ret    
proc_mul endp
                                            
proc_div proc   
;if input2 is 0, output error:
    mov bx, size
    dec bx  
    _DIV_input2_zero_check_loop:
        mov al, input2[bx]
        cmp al, '0'
        jne _DIV_input2_is_NOT_zero
        dec bx
        cmp bx, 0
        jl _DIV_input2_IS_zero
        jmp _DIV_input2_zero_check_loop   
    _DIV_input2_IS_zero:
        call print_newLine
        call print_newLine 
        lea dx, msg_error
        call print
        jmp _DIV_its_done         
    _DIV_input2_is_NOT_zero:    
;copy input1 to extra_array:    
    mov bx, size
    dec bx    
    _DIV_copy_loop:
        cmp bx, 0
        jl _DIV_copy_complete
        mov al, input1[bx]
        mov extra_array[bx], al
        dec bx
        jmp _DIV_copy_loop            
    _DIV_copy_complete:        
;compare input2 with extra_array:
    _DIV_compare_things:
        mov bx, 0
    _DIV_compare_loop:
        cmp bx, size
        jge _DIV_were_equal    
        mov al, extra_array[bx]
        cmp al, input2[bx]                                                                      
        jg _DIV_extra_array_is_bigger
        jl _DIV_extra_array_is_smaller
        inc bx
        jmp _DIV_compare_loop        
    _DIV_were_equal:
        jmp _DIV_extra_array_is_bigger
;extra_array is bigger or equal: sub i2 from extra_array and add 1 to final_res
    _DIV_extra_array_is_bigger:
        mov bx, size
        dec bx
        mov carry, 0    
    _DIV_sub_loop:    
        mov al, extra_array[bx]
        add al, 10 
        sub al, input2[bx]
        sub al, carry
        cmp al, 10
        jge _DIV_no_carry_needed
        jmp _DIV_carry_needed                       
    _DIV_no_carry_needed:
        sub al, 10
        add al, 48
        mov extra_array[bx], al
        mov carry, 0
        jmp _DIV_next_digit          
    _DIV_carry_needed:
        add al, 48
        mov extra_array[bx], al
        mov carry, 1
        jmp _DIV_next_digit       
    _DIV_next_digit:
        dec bx
        cmp bx, 0
        jl _DIV_add_one_to_final_res
        jmp _DIV_sub_loop              
    ;add one to final_res:                  
    _DIV_add_one_to_final_res:
        mov bx, res_size
        dec bx
        mov carry, 0            
    _DIV_add_one_loop:    
        mov al, final_res[bx]
        add al, carry
        add al, 1
        cmp al, 10
        jge _DIV_we_have_carry
        jmp _DIV_no_carry_here                      
    _DIV_we_have_carry:
        sub al, 10
        mov final_res[bx], al
        mov carry, 1
        dec bx
        jmp _DIV_handle_carry        
    _DIV_handle_carry:    
        mov al, final_res[bx]
        add al, carry
        cmp al, 10
        jge _DIV_we_have_carry
        jmp _DIV_no_carry_here            
    _DIV_no_carry_here:
        mov final_res[bx], al
        mov carry, 0                   
        jmp _DIV_compare_things    
;extra_array is less: it's done, show the final_res:
    _DIV_extra_array_is_smaller:
        jmp _DIV_its_done    
    _DIV_its_done:         
        ret         
proc_div endp  
                              
wrong_num proc
    call print_newLine
    lea dx, msg_wrong_number_input
    call print
    ret 
wrong_num endp

wrong_operator proc
    call print_newLine
    lea dx, msg_wrong_operator_input
    call print
    ret         
wrong_operator endp

find_larger_num proc
    mov bx, 0
    mov dx, size
    dec dx    
    larger_find_loop:
        mov dl, input1[bx]
        mov dh, input2[bx]
        cmp dl, dh
        jl input2_is_larger:
        jg _find_larger_finish:
        inc bx
        cmp bx, dx
        jge _find_larger_finish
        jmp larger_find_loop    
    input2_is_larger:
        mov larger_num, 1
        jmp _find_larger_finish
    _find_larger_finish:
        ret                
find_larger_num endp    
         
end