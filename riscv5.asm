.globl main
.data
msg: .asciz "# "
newLine: .asciz "\n"
buffer: .space 512
.eqv ZERO_ASCII 48
.eqv EQ_ASCII 61
.eqv ADD_ASCII 43
.eqv SUB_ASCII 45
.eqv MUL_ASCII 120
.eqv DIV_ASCII 47

.text 
main:
	# a7 : Enviornment Call
	
	la a0, msg				# a0 = &msg
	li a7, 4				# printf("%s", msg)
	ecall
	
	la a0, buffer				# a0 = &buffer
	li a1, 512				# a1 = 512
	li a7, 8				# scanf("%s", buffer) 
	ecall
	
	la a0, buffer				# a0 = &buffer   
	li a7, 4        			# printf("%s", buffer)
	ecall
	
	la s0, buffer   			# s0 = &buffer
	li s1, 0				# s1 = 0
	li a0, 0				# a0 = 0
	li a1, 0				# a1 = 0
	li t3, 0				# t3 = 0
	li t4, 0				# t4 = 0
	
PARCING:
	add t1, s0, s1		            	# t1 = s0 + s1
	lb  t2, 0(t1)  		    	    	# t2 = buffer[ptr]
	
	li  t1, 120  		    	    	# t1 = 'x'
	beq t1, t2, OPERATE 	    	   	# if(t1==t2) OPERATE()
	
	li  t1, 48			    	# t1 = '0'
	bge t2, t1, LOOP        		# if(t2 >= t1) LOOP()
	
	jal x0, OPERATE    		    	# OPERATE()
	
LOOP:
	li t1, 10 				# t1 = 10
	mul t3, t3, t1				# t3 *= 10
	
	add t1, s0, s1				# t1 = s0 + s1
	lb t2, 0(t1)				# t2 = Buffer[ptr]
	add t3, t3, t2				# t3 += t2
	
	addi t3, t3, -48			# t3 += (-48)
	
	addi s1, s1, 1				# ptr++
	
	jal x0, PARCING				# get_operand()

LOOP2:
	addi s1, s1, 1				# ptr++
	
	add t1, s0, s1				# t1 = s0 + s1
	lb t2, 0(t1)				# t2 = Buffer[ptr]
	
	li  t1, 120				# t1 = 'x'
	beq t1, t2, RETURN			# if(t1==t2) RETURN()
	
	li  t1, 48				# t1 = '0'
	blt t2, t1, RETURN			# if(t1<t2) RETURN()
	
	li t1, 61				# t1 = '='
	beq t1, t2, RETURN			# if(t1==t2) RETURN()
	
	li t1, 10				# t1 = 10
	mul t4, t4, t1				# t4 *= 10
	
	add t1, s0, s1				# t1 = s0 + s1
	lb t2, 0(t1)				# t2 = Buffer[ptr]
	add t4, t4, t2				# t4 += t2
	
	addi t4, t4, -48			# t4 += (-48)
	
	jal x0, LOOP2 				# LOOP2()	
	
RETURN:
	jalr x0, 0(x1)				# return to caller	

OPERATE:
	add t1, s0, s1				# t1 = s0 + s1
	lb t2, 0(t1)				# t2 = Buffer[ptr]
	
	li  t1, 61				# t1 = '='
	beq t1, t2, EXIT			# if(t1==t2) EXIT()
	
	li  t1, 43				# t1 = '+'
	beq t1, t2, PLUS			# if(t1==t2) PLUS()
	
	li t1, 45				# t1 = '-'
	beq t1, t2, SUB				# if(t1==t2) SUB()
	
	li t1, 120				# t1 = 'x'
	beq t1, t2, MUL 			# if(t1==t2) MUL()
	
	li t1, 47				# t1 = '/'
	beq t1, t2, DIV				# if(t1==t2) DIV()
	
PLUS:
	jal x1, LOOP2				# LOOP2() 
	
	add t3, t3, t4				# t3 += t4
	add a0, x0, t3				# a0 = t3
	
	jal x0, PRINT				# PRINT()
	
SUB:
	jal x1, LOOP2 				# LOOP2()
	
	sub t3, t3, t4				# t3 -= t4
	add a0, x0, t3				# a0 = t3
	
	jal x0, PRINT				# PRINT()
	
MUL:
	jal x1, LOOP2				# LOOP2()
	
	mul t3, t3, t4				# t3 *= t4
	add a0, x0, t3				# a0 = t3
	
	jal x0, PRINT				# PRINT()
	
DIV:
	jal x1, LOOP2 				# LOOP2()
	
	div t3, t3, t4				# t3 /= t4
	add a0, x0, t3				# a0 = t3
	
	jal x0, PRINT				# PRINT()
	
PRINT:
	li a7, 1				# printf("%d", )		
	ecall
	
	la a0, newLine				# printf("%s", newLine)
	li a7, 4
	ecall
	
	li t4, 0				# t4 = 0
	jal x0, OPERATE				# PRINT()
	
EXIT:
	li a7, 10				# exit
	ecall
