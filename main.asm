.macro print_int(%int)
	mv a0, %int
	li a7, 1
	ecall
.end_macro

.macro wrap()
	li a0 10
	li a7 11
	ecall
.end_macro


.data
	inpt_expr: .string "3*2"
	
	
.text
	main:
		la a0 inpt_expr
		jal eval
		
		# print res
		print_int(a0)
		
		# return 0
    	li a7 10
		ecall
		
	eval:
		mv t0 a0  # expression
		li t1 0   # len
		
		# get string length
		start_string_len_eval:
		    lb t2, 0(t0)                         # t2 = curChar
		    beqz t2, end_string_len_eval # curChar == "\0"
		    addi t0, t0, 1                       # next char
		    addi t1, t1, 1                       # len++
		    j start_string_len_eval
		end_string_len_eval:
		
		# backup ra
		addi sp sp -4
		sw ra 0(sp)
		
		jal skip_blank
		mv t0 a0 # new address of the expression
		
		# recovery ra
		lw ra 0(sp)
		addi sp sp 4
		
		ret
		
		
	skip_blank:
		# backup
		addi sp sp -12
  		sw s0 0(sp)
  		sw t0 4(sp)
   		sw t1 8(sp)
	
		li s0 32 # " " in ascii
		mv t0 a0 # string
		
		# while (curChar == " ")
		start_skip_blank:
			lb t1 0(t0) # curChar
			
			# curChar == " " ? nextChar() : return
			beq t1 s0 next_char_skip_blank
			j ret_skip_blank
			
			# nextChar()
			next_char_skip_blank:
				addi t0 t0 1
				j start_skip_blank
		ret_skip_blank:
		
		add a0 t0 zero
		
		# recovery
		lw s0 0(sp)
	    lw t0 4(sp)
	    lw t1 8(sp)
	    addi sp sp 12
	    
	    
	    
		ret
		
	