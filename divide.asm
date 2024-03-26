.macro print_int(%int)
	mv a0, %int
	li a7, 1
	ecall
.end_macro

.data
	alpha: .word 1
	beta: .word 0
	
.text
	lw a0 alpha
	lw a1 beta
	
	jal divide
	
	# print res
	print_int(a0)
    
    # return 0
    li a7 10
    ecall
	
	divide:
		mv t0 a0 # a
		mv t1 a1 # b
		li t2 0  # isResultNegative, 0 = false, 1 = true
		
		#############################
		###   SIGN VERIFICATION   ###
		#############################
		# a<0 ? a=-a : pass
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
			xori t2 t2 1 # a*-b=-c, -a*-b=c
		
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
		ret