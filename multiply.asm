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
	alpha: .word -20
	beta: .word 6
	
.text
	lw a0 alpha
	lw a1 beta
	
	jal multiply
	
	# print res
	print_int(a0)
    
    # return 0
    li a7 10
    ecall
	
	multiply:
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
		ret
