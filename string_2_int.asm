.macro print_int(%int)
	mv a0 %int
	li a7 1
	ecall
.end_macro

.macro wrap()
	li a0 10
	li a7 11
	ecall
.end_macro


.data
	data: .string "123456789"
	
	
.text
	la a0 data
	
	jal string_2_int
	print_int(a0)
    
    # return 0
    li a7 10
    ecall
	
	
	string_2_int:
		addi sp sp -20
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    sw t3 12(sp)
	    sw t4 16(sp)
	    
		mv t0, a0 # string
		li t1 0   # len

		# string length
		start_string_len_string_2_int:
		    lb t2, 0(t0)                         # t2 = curChar
		    beqz t2, end_string_len_string_2_int # curChar == "\0"
		    addi t0, t0, 1                       # next char
		    addi t1, t1, 1                       # len++
		    j start_string_len_string_2_int
		end_string_len_string_2_int:
		
		# reset string address
		sub t0, t0, t1
		
		# parse string
		start_parse_string_string_2_int:
			lb t2, 0(t0)                           # t2 = curChar
		    beqz t2, end_parse_string_string_2_int # curChar == "\0"
		    
		    addi t2 t2 -48                         # 48 = "0"
		    
		    # t2 < 0 || t2 > 9 ? error : pass
		    bltz t2 error_string_2_int
		    addi t2 t2 -10
		    bgtz t2 error_string_2_int
		    addi t2 t2 10
		    
		    # store curDigit
		    addi sp sp -4
		    sw t2, 0(sp)
		    
		    addi t0, t0, 1                         # next char
		j start_parse_string_string_2_int
		end_parse_string_string_2_int:
		
		li t2 0 # res
		li t0 0 # i = 0
		# while i < len
		start_make_int_string_2_int:
		beq t0 t1 end_make_int_string_2_int
			# backup ra
			addi sp sp -4
			sw ra 0(sp)
		
			# pow
			li a0 10
			add a1 t0 zero
			jal pow
			
			# recovery ra
			lw ra 0(sp)
			
			# recovery digit
			addi sp, sp, 4
			lw t3 0(sp)
			addi sp, sp, 4
			
			# res += digit * 10^i
			mul t4 t3 a0
			add t2 t2 t4
			
			addi t0 t0 1   # i++
		j start_make_int_string_2_int
		
		error_string_2_int:
		li a0 -1
		j ret_string_2_int
		end_make_int_string_2_int:
		add a0 t2 zero
		ret_string_2_int:
		lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    lw t4 16(sp)
	    addi sp sp 20
		ret
		
		
	pow:
		# backup t0 and t1
		addi sp sp -12
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw ra 8(sp)
			
		# pow algorithm
		mv t0 a0 # base
		mv t1 a1 # exp
		li a0 1  # res
		start_loop_pow:
		beqz t1 end_loop_pow
			# mul a0 a0 t0 
			# res *= base
			add a1 t0 zero
			jal multiply
			addi t1 t1 -1 # exp--
		j start_loop_pow
		end_loop_pow:
		# recovery t0 and t1
		lw t0 0(sp)
	    lw t1 4(sp)
	    lw ra 8(sp)
	    addi sp sp 12
		ret
		

	multiply:
	    addi sp sp -16
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    sw t3 12(sp)

		mv t0 a0 # a
		mv t1 a1 # b
		li t2 0 # res
		
		# while (b > 0)
		start_loop_multiply:
		beqz t1 ret_multiply
			# if (y & 1)
			andi t3 t1 1
			beqz t3 least_significant_b_bit_neq_one
				add t2 t2 t0 # res += a
			least_significant_b_bit_neq_one:
			slli t0 t0 1
			srli t1 t1 1
		j start_loop_multiply
		
		ret_multiply:
		add a0 t2 zero
		
		# restore t0, t1, t2 and t3
	    lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    addi sp sp 16
		ret
