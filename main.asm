#############################################
###                                       ###
###   Università degli Studi di Firenze   ###
###   Expressions Evaluator               ###
###                                       ###
###   Developed by:                       ###
###      Christian Alessandri (7133334)   ###
###                                       ###
#############################################


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
	inpt_expr: .string "o3*2"
	str_err_div_4_zero: .string "MATH ERROR: Divide by zero"                     # exit code: -1
	str_err_overflow: .string "HARDWARE ERROR: Expression generated an overflow" # exit code: -2
	str_err_syntactical: .string "SYNTACTICAL ERROR: Unrecognized character"     # exit code: -3
	
	
.text
	main:
		la a0 inpt_expr
		jal eval
		
		# print res
		print_int(a0)
		
		# return 0
    	li a7 10
		ecall
		
	
	######################
	###   MATH ERROR   ###
	######################
	syntactical_error:
		# print error
		la a0 str_err_div_4_zero
		li a7 4
		ecall
		
		# exit with error code -1
		li a0 -1
		li a7 93
		ecall
		
		
	##########################
	###   HARDWARE ERROR   ###
	##########################
	syntactical_error:
		# print error
		la a0 str_err_div_4_zero
		li a7 4
		ecall
		
		# exit with error code -2
		li a0 -1
		li a7 93
		ecall
		
		
	#############################
	###   SYNTACTICAL ERROR   ###
	#############################
	syntactical_error:
		# print error
		la a0 str_err_syntactical
		li a7 4
		ecall
		
		# exit with error code -3
		li a0 -3
		li a7 93
		ecall
		

	################
	###   EVAL   ###
	################	
	eval:
		mv t0 a0  # expression
		li t1 0   # len
		
		# get string length
		start_string_len_eval:
		    lb t2 0(t0)                 # t2 = curChar
		    beqz t2 end_string_len_eval # curChar == "\0"
		    addi t0 t0 1                # next char
		    addi t1 t1 1                # len++
		    j start_string_len_eval
		end_string_len_eval:
		sub a0 a0 t2
		
		# backup ra
		addi sp sp -4
		sw ra 0(sp)
		
		jal skip_blank
		mv t0 a0 # new expression address
		
		# recovery ra
		lw ra 0(sp)
		addi sp sp 4
		
		# curChar == "(" ? handleEval() : pass
		lb t2 0(t0) # t2 = curChar
		li t3 40    # t3 = "("
		beq t2 t3 nest1_eval
		j isNum1_eval
		nest1_eval:
			mv a0 t0
			jal handle_eval
			mv t0 a0 # new expression address
			mv s0 a1 # stNum
			
		isNum1_eval:
			mv a0 t0
			jal string_2_int
			mv t0 a0 # new expression address
			mv s0 a1 # stNum
		
			addi s0 s0 1
			beqz s0 syntactical_error
			addi s0 s0 -1
			
			
			
		ret
		
	
	#######################
	###   HANDLE EVAL   ###
	#######################
	handle_eval:
		
		
	######################
	###   SKIP BLANK   ###
	######################
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
		
	
	#########################
	###   STRING TO INT   ###
	#########################	
	string_2_int:
		# backup
		addi sp sp -24
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    sw t3 12(sp)
	    sw t4 16(sp)
	    sw t5 20(sp)
	    
		mv t0 a0 # string
		li t1 0  # numLen
		
		# parse string
		start_parse_string_string_2_int:
			lb t2, 0(t0)   # t2 = curChar
		    addi t2 t2 -48 # curChar -= 48, 48 = "0"
		    
		    # t2 < 0 || t2 > 9 ? error : pass
		    bltz t2 end_parse_string_string_2_int
		    addi t2 t2 -10
		    bgtz t2 end_parse_string_string_2_int
		    addi t2 t2 10
		    
		    addi t1 t1 1 # numLen++
		    
		    # store curDigit
		    addi sp sp -4
		    sw t2, 0(sp)
		    
		    addi t0, t0, 1 # next char
		j start_parse_string_string_2_int
		end_parse_string_string_2_int:
		
		li t2 0 # res
		li t5 0 # i = 0
		# while i < numLen
		start_make_int_string_2_int:
		beq t5 t1 end_make_int_string_2_int
			# backup ra
			addi sp sp -4
			sw ra 0(sp)
		
			# pow
			li a0 10
			add a1 t5 zero
			jal pow
			
			# recovery ra
			lw ra 0(sp)
			addi sp, sp, 4
			
			# recovery digit
			lw t3 0(sp)
			addi sp, sp, 4
			
			# res += digit * 10^i
			mul t4 t3 a0
			add t2 t2 t4
			
			addi t5 t5 1   # i++
		j start_make_int_string_2_int
		end_make_int_string_2_int:
		
		add a0 t0 zero
		beqz t5 nan_error_string_2_int
		add a1 t2 zero
		j recovery_string_2_int
		nan_error_string_2_int:
		li a1 -1
		
		# recovery
		recovery_string_2_int:
		lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    lw t4 16(sp)
	    lw t5 20(sp)
	    addi sp sp 24
		ret
		
	
	###############
	###   POW   ###
	###############	
	pow:
		# backup
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
		
		# recovery
		lw t0 0(sp)
	    lw t1 4(sp)
	    lw ra 8(sp)
	    addi sp sp 12
		ret
		

	####################
	###   MULTIPLY   ###
	####################
	multiply:
		# backup
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
		
		# recovery
	    lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    addi sp sp 16
		ret
	
