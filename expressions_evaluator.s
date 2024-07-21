###################################################
#*************************************************#
#*                                               *#
#*   Progetto Assembly RISC-V                    *#
#*   Corso di Architetture degli Elaboratori     *#
#*                                               *#
#*   Progetto: Valutatore di Espressioni         *#
#*                                               *#
#*   Autore: Christian Alessandri                *#
#*   Matricola: 7133334                          *#
#*   Email: christian.alessandri@edu.unifi.it    *#
#*                                               *#
#*************************************************#
###################################################


.data
	inpt_expr: .string "5/0"
	str_err_div_4_zero: .string "MATH ERROR: Divide by zero"
	str_err_overflow: .string "HARDWARE ERROR: Expression generated an overflow"
	str_err_syntactical: .string "SYNTACTICAL ERROR: Illegal character"
	str_err_expr: .string "SYNTACTICAL ERROR: Illegal expression"
	
	
.text
	################
	###   MAIN   ###
	################
	main:
		la a0 inpt_expr
		li a1 0 # 0: mainExpr, 1: subExpr
		jal eval
		mv t0 a1
		
		# print inpt_expr
		la a0 inpt_expr
		jal print_string
		
		# print " "
		li a0 32
		jal print_char
		
		# print "="
		li a0 61
		jal print_char
		
		# print " "
		li a0 32
		jal print_char
		
		# print res
		mv a0 t0
		jal print_int
		
		j exit
		
	
	######################
	###   MATH ERROR   ###
	######################
	math_error:
		# print error
		la a0 str_err_div_4_zero
		jal print_string
		
		j exit
		
		
	##########################
	###   HARDWARE ERROR   ###
	##########################
	hardware_error:
		# print error
		la a0 str_err_overflow
		jal print_string
		
		j exit
		
	
	##############################
	###   SYNTACTICAL ERRORS   ###
	##############################
	syntactical_error:
		# print error
		la a0 str_err_syntactical
		jal print_string
		
		jal wrap
		jal wrap
		
		# print expr
		la a0 inpt_expr
		jal print_string
		
		jal wrap
		
		# print error indicator
		la t1 inpt_expr
		sub t0 t0 t1
		
		blank_space_start_syntactical_error:
		beqz t0 blank_space_end_syntactical_error
			li a0 32
			jal print_char
			addi t0 t0 -1
		j blank_space_start_syntactical_error
		blank_space_end_syntactical_error:
		
		li a0 94
		jal print_char
		
		j exit
		
	expression_error:
		# print error
		la a0 str_err_expr
		jal print_string
		
		jal wrap
		jal wrap
		
		# print expr
		la a0 inpt_expr
		jal print_string
		
		jal wrap
		
		# print error indicator
		la t1 inpt_expr
		sub t0 t0 t1
		
		blank_space_start_expression_error:
		beqz t0 blank_space_end_expression_error
			li a0 32
			jal print_char
			addi t0 t0 -1
		j blank_space_start_expression_error
		blank_space_end_expression_error:
		
		li a0 94
		jal print_char
		
		j exit
		

	################
	###   EVAL   ###
	################	
	eval:
		# backup
		addi sp sp -32
  		sw t0 0(sp)
   		sw t1 4(sp)
   		sw t2 8(sp)
   		sw t3 12(sp)
   		sw t4 16(sp)
   		sw t5 20(sp)
   		sw t6 24(sp)
   		sw ra 28(sp)
   		
		mv t0 a0  # expression address
		li t3 0   # stNum
		li t4 0   # op | 0: null, 1: +, 2: -, 3: *, 4: /
		li t5 0   # ndNum
		mv t6 a1  # 0: mainExpr, 1: subExpr
		
		mv a0 t0
		jal skip_blank
		mv t0 a0 # new expression address
		
		# curChar == "(" ? eval() : is_digit(curChar) ? string_2_int() : error
		lb t2 0(t0) # t2 = curChar
		li t1 40    # t3 = "("
		beq t2 t1 nest1_eval
		j is_num1_eval
		nest1_eval:
			mv a0 t0
			addi a0 a0 1
			li a1 1
			
			jal eval
			
			mv t0 a0 # new expression address
			addi t0 t0 1
			mv t3 a1 # stNum
			j end_if1_eval
		is_num1_eval:
			mv a0 t0
			
			jal string_2_int
			
			mv t0 a0 # new expression address
			mv t3 a1 # stNum
		
			addi t3 t3 1
			beqz t3 syntactical_error
			addi t3 t3 -1
		end_if1_eval:
		
		mv a0 t0
		jal skip_blank
		mv t0 a0 # new expression address
		
		# isOp(curChar) ? parseOp() : error
		lb t2 0(t0) # t2 = curChar
		
		li t1 43    # +
		beq t2 t1 parse_add1_eval
		
		li t1 45    # -
		beq t2 t1 parse_sub1_eval
		
		li t1 42    # *
		beq t2 t1 parse_mul1_eval
		
		li t1 47    # /
		beq t2 t1 parse_div1_eval
		j syntactical_error
		
		li t4 0
		parse_div1_eval:
		addi t4 t4 1
		parse_mul1_eval:
		addi t4 t4 1
		parse_sub1_eval:
		addi t4 t4 1
		parse_add1_eval:
		addi t4 t4 1
		
		addi t0 t0 1 # go to the next char
		mv a0 t0
		jal skip_blank
		mv t0 a0 # new expression address
		
		# curChar == "(" ? eval() : is_digit(curChar) ? string_2_int() : error
		lb t2 0(t0) # t2 = curChar
		li t1 40    # t3 = "("
		beq t2 t1 nest2_eval
		j is_num2_eval
		nest2_eval:
			mv a0 t0
			addi a0 a0 1
			li a1 1
			
			jal eval
			
			mv t0 a0 # new expression address
			addi t0 t0 1
			mv t5 a1 # ndNum
			
			j end_if2_eval
		is_num2_eval:
			add a0 t0 zero
		
			jal string_2_int
			
			mv t0 a0 # new expression address
			mv t5 a1 # ndNum
		
			addi t5 t5 1
			beqz t5 syntactical_error
			addi t5 t5 -1
		end_if2_eval:
		
		mv a0 t0
		jal skip_blank
		mv t0 a0 # new expression address
		
		# switch(op)
		li t1 1
		beq t1 t4 sum_eval
		addi t1 t1 1
		beq t1 t4 sub_eval
		addi t1 t1 1
		beq t1 t4 mul_eval
		
		# div_eval
			add a0 t3 zero
			add a1 t5 zero
		
			jal div
			mv t3 a0
		j end_switch_op_eval
		
		sum_eval:
			add a0 t3 zero
			add a1 t5 zero
			
			jal sum_n_check_overflow
			mv t3 a0
		j end_switch_op_eval
		
		sub_eval:
			add a0 t3 zero
			add a1 t5 zero
			
			jal sub_n_check_overflow
			mv t3 a0
		j end_switch_op_eval
		
		mul_eval:
			add a0 t3 zero
			add a1 t5 zero
			
			jal mul
			mv t3 a0
			
		end_switch_op_eval:
		
		# curChar == "\0" ? return : continue
		lb t2 0(t0)
		beqz t6 main_expr_eval
		# sub_expr_eval
			li t1 41 # 41 = ")"
			beq t2 t1 ret_eval
			j expression_error
		
		main_expr_eval:
			beqz t2 ret_eval
			j expression_error
		
		ret_eval:
		mv a0 t0
		mv a1 t3
		
		# recovery
  		lw t0 0(sp)
   		lw t1 4(sp)
   		lw t2 8(sp)
   		lw t3 12(sp)
   		lw t4 16(sp)
   		lw t5 20(sp)
   		lw t6 24(sp)
   		lw ra 28(sp)
   		addi sp sp 32
		ret
		
		
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

			# backup return address
			addi sp sp -4
			sw ra 0(sp)

			# res += digit * 10^i
			add a1 t3 zero
			jal mul
			add t4 a0 zero
			add t2 t2 t4

			# recovery return address
			lw ra 0(sp)
			addi sp sp 4
			
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
			# res *= base
			add a1 t0 zero
			jal mul
			addi t1 t1 -1 # exp--
		j start_loop_pow
		end_loop_pow:
		
		# recovery
		lw t0 0(sp)
	    lw t1 4(sp)
	    lw ra 8(sp)
	    addi sp sp 12
		ret
		
		
	################################
	###   SUM N CHECK OVERFLOW   ###
	################################
	sum_n_check_overflow:
		# backup
	    addi sp sp -16
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    sw t3 12(sp)
	    
		mv t0 a0     # stNum
		mv t1 a1     # ndNum
		li t2 0      # overflow checker
		add t3 t0 t1 # res
		
		# overflow check
		bltz t3 neg_res_sum
		
		# positive res
			bltz t0 stNum_ltz_n_pos_res_sum
			j ret_sum
			stNum_ltz_n_pos_res_sum:
			bltz t1 hardware_error
			j ret_sum
		
		# negative res
		neg_res_sum:
			bgtz t0 stNum_gtz_n_neg_res_sum
			j ret_sum
			stNum_gtz_n_neg_res_sum:
			bgtz t1 hardware_error
		
		ret_sum:
		mv a0 t3
		
		# recovery
	    lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    addi sp sp 16
		ret
	
	
	################################
	###   SUB N CHECK OVERFLOW   ###
	################################
	sub_n_check_overflow:
		# backup
	    addi sp sp -12
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    
		mv t0 a0     # stNum
		mv t1 a1     # ndNum
		sub t2 t0 t1 # res
		
		# overflow check
		bltz t2 neg_res_sub
		
		# positive res
			bltz t0 stNum_ltz_n_pos_res_sub
			j ret_sub
			stNum_ltz_n_pos_res_sub:
			bgez t1 hardware_error
			j ret_sub
		
		# negative res
		neg_res_sub:
			bgez t0 stNum_gez_n_neg_res_sub
			j ret_sub
			stNum_gez_n_neg_res_sub:
			bltz t1 hardware_error
		
		ret_sub:
		mv a0 t2
		
		# recovery
	    lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    addi sp sp 12
	    ret
		

	###############
	###   MUL   ###
	###############
	mul:
		# backup
	    addi sp sp -24
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    sw t3 12(sp)
	    sw t4 16(sp)
			sw t5 20(sp)

		mv t0 a0 # a
		mv t1 a1 # b
		li t2 0  # res
		li t4 0  # overflow checker, 1: positive res, 0: zero res, -1: negative res
		
		beqz t0 stNum_eqz_multiply
		beqz t1 ndNum_eqz_multiply
		
		bltz t0 stNum_ltz_multiply
		bltz t1 stNum_gtz_n_ndNum_ltz_multiply
		j stNum_n_ndNum_gtz_multiply
		
		stNum_ltz_multiply:
		bltz t1 stNum_n_ndNum_ltz_multiply
		j stNum_ltz_n_ndNum_gtz_multiply
		
		stNum_eqz_multiply:
		ndNum_eqz_multiply:
		li t4 0
		j end_sign_check_multiply
		
		stNum_n_ndNum_gtz_multiply:
		stNum_n_ndNum_ltz_multiply:
		li t4 1
		j end_sign_check_multiply
		
		stNum_gtz_n_ndNum_ltz_multiply:
		stNum_ltz_n_ndNum_gtz_multiply:
		li t4 -1
		
		end_sign_check_multiply:
		
		# while (b > 0)
		start_loop_multiply:
		beqz t1 check_overflow_multiply
			# if (y & 1)
			andi t3 t1 1
			beqz t3 least_significant_b_bit_neq_one
				add t2 t2 t0 # res += a
			least_significant_b_bit_neq_one:
			slli t0 t0 1
			srli t1 t1 1
		j start_loop_multiply
		
		check_overflow_multiply:
			beqz t4 zero_res_multiply
			addi t4 t4 -1
			beqz t4 pos_res_multiply
			
			# neg_res_multiply
				bltz t2 ret_multiply
				j hardware_error
			
			zero_res_multiply:
				beqz t2 ret_multiply
				j hardware_error
				
			pos_res_multiply:
				bgtz t2 ret_multiply
				j hardware_error
		
		ret_multiply:
		add a0 t2 zero
		
		# recovery
	    lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    lw t4 16(sp)
			lw t5 20(sp)
	    addi sp sp 24
		ret
		
	
	###############
	###   DIV   ###
	###############
	div:
		# backup
	    addi sp sp -28
	    sw t0 0(sp)
	    sw t1 4(sp)
	    sw t2 8(sp)
	    sw t3 12(sp)
	    sw t4 16(sp)
	    sw t5 20(sp)
	    sw t6 24(sp)
	    
		mv t0 a0 # a
		mv t1 a1 # b
		beqz t1 math_error # b == 0 ? error : continue
		# b == 1 ? return a : continue
		addi t1 t1 -1
		beqz t1 divider_equal_one_divide
		addi t1 t1 2
		beqz t1 divider_equal_minus_one_divide
		addi t1 t1 -1
		li t2 0  # isResultNegative, 0 = false, 1 = true
		
		# sign verification
		# a < 0 ? a = -a : pass
		bltz t0 a_negative_divide
		j b_sign_verification_divide
		a_negative_divide:
			li t2 1 # negative result
			
			# a = abs(a)
			add t3 t0 zero
			li t0 0
			sub t0 t0 t3
		
		# b < 0 ? b = -b : pass
		b_sign_verification_divide:
		bltz t1 b_negative_divide
		j end_sign_verification_divide
		b_negative_divide:
			# isResultNegative == 1 ? isResultNegative = 0 : isResultNegative = 1
			xori t2 t2 1 # a * -b = -c, -a * -b = c
		
			# b = abs(b)
			add t3 t1 zero
			li t1 0
			sub t1 t1 t3
		
		end_sign_verification_divide:
		li t3 0 # res
		
		# while (a > b)
		start_loop_divide:
		blt t0 t1 ret_divide
			li t4 0 # shiftValue = 0
			
			# while (a >= (b << shiftValue))
			start_shift_loop_divide:
			sll t5 t1 t4
			blt t0 t5 end_shift_loop_divide
				addi t4 t4 1 # shiftValue++
			j start_shift_loop_divide
			end_shift_loop_divide:
			
			# res += 1 << (shiftValue - 1)
			addi t4 t4 -1
			li t6 1
			sll t5 t6 t4
			add t3 t3 t5
			
			# a -= b << (shiftValue - 1)			
			sll t5 t1 t4
			sub t0 t0 t5
		j start_loop_divide
		
		ret_divide:
		beqz t2 pos_res_divide
			# res = -res
			add t4 t3 zero
			sub t3 t3 t4
			sub t3 t3 t4
			
		pos_res_divide:
		add a0 t3 zero
		j skip_special_cases_divide
		
		divider_equal_one_divide:
		add a0 t0 zero
		j skip_special_cases_divide
		
		divider_equal_minus_one_divide:
		li t6 -2147483648
		beq t0 t6 hardware_error
		sub t0 t0 t0
		sub t0 t0 t0
		
		skip_special_cases_divide:
		
		# recovery
		lw t0 0(sp)
	    lw t1 4(sp)
	    lw t2 8(sp)
	    lw t3 12(sp)
	    lw t4 16(sp)
	    lw t5 20(sp)
	    lw t6 24(sp)
	    addi sp sp 28
		ret
	

	#########################
	###   PRINT INTEGER   ###
	#########################
	print_int:
		addi sp sp -4
	  	sw a7 0(sp)
	  	
		li a7, 1
		ecall
		
	    lw a0 4(sp)
	    addi sp sp 4
	    ret
	    
	    
	########################
	###   PRINT STRING   ###
	########################
	print_string:
		addi sp sp -4
	  	sw a7 0(sp)
	  	
		li a7 4
		ecall
		
	    lw a0 4(sp)
	    addi sp sp 4
	    ret
	    
	      
	###########################
	###   PRINT CHARACTER   ###
	###########################
	print_char:
		addi sp sp -4
	  	sw a7 0(sp)
	  	
		li a7, 11
		ecall
		
	    lw a0 4(sp)
	    addi sp sp 4
	    ret
	    
	    
	#####################
	###   WRAP TEXT   ###
	#####################
	wrap:
		addi sp sp -8
	  	sw a0 0(sp)
	  	sw a7 4(sp)
	  		
		li a0 10
		li a7 11
		ecall
		
		lw a0 0(sp)
	    lw a7 4(sp)
	    addi sp sp 8
	    ret
	 
	
	####################
	###   RETURN 0   ###
	####################     
	exit:
    	li a7 10
		ecall
