 .data
.equ JP1,0xFF200060
.equ PS2KEYBOARD,0xFF200100
.equ TIMER,0xff202000
.equ ADDR_VGA, 0x08000000

Grab_And_Backward:
.incbin "grab and backward.bmp"

Grab_And_Forward:
.incbin "grab and forward.bmp"

Grab_And_Left:
.incbin "grab and left.bmp"

Grab_And_Right:
.incbin "grab and right.bmp"

Grab_And_Still:
.incbin "grab and still.bmp"

Release_And_Still:
.incbin "release and still.bmp"

Release_And_Forward:
.incbin "release and forward.bmp"

Release_And_Backward:
.incbin "release and backward.bmp"

Release_And_Left:
.incbin "release and left.bmp"

Release_And_Right:
.incbin "release and right.bmp"


.text
.section .exceptions,"ax"
ISR:
ldwio	et,0(r8)
srli	et,et,27
andi	et,et,0x01
bne		et,r0,isensor1
isensor0:
#enable motor0 forward
movia	et,0xffdffffc
and		et,et,r10
stwio	et,0(r8)
movia	r4,85000000
call	timer

movia	et, 0xffdfffff
and		et,et,r10
stwio	et, 0(r8)
movia	r4,15000000
call	timer

ldwio	et,0(r8)
srli	et,et,27
andi	et,et,0x01
beq		et,r0,isensor0
br iexit
isensor1:
#enable motor0 reverse
movia	et, 0xffdffffe
and	et,et,r10
stwio	et, 0(r8)
movia	r4,85000000
call	timer

movia	et, 0xffdfffff
and		et,et,r10
stwio	et, 0(r8)
movia	r4,15000000
call	timer

ldwio	et,0(r8)
srli	et,et,28
andi	et,et,0x01
beq		et,r0,isensor1

iexit:
movia	et, 0xffdfffff
and		et,et,r10
stwio	et, 0(r8)
movia	et, 0xffffffff
stwio	et, 12(r8)
addi ea,ea,-4
eret


.global _start
_start:

Initial_RAS:
movia r12,Release_And_Still
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
IRAS_loopy:
	IRAS_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,IRAS_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,IRAS_loopy



movia	r8,JP1        
movia	r9,0x07f557ff    
stwio	r9,4(r8)
movia	r10,0xffdffeff #ffdffcff for grab, ffdffeff for release

#load sensor 0
movia	r9,0xff3ffbff
stwio	r9,0(r8)

movia	r9,0xff5fffff
stwio	r9,0(r8)

#load sensor 1
movia	r9,0xff3fefff
stwio	r9,0(r8)

movia	r9,0xff5fffff
stwio	r9,0(r8)

#enable sensor interrupt
movia	r9,0x18000000
stwio	r9,8(r8)

#enable IRQ11 & PIE
movia	r9,0x0800
wrctl	ctl3,r9
movia	r9,0x01
wrctl	ctl0,r9

stwio	r10,0(r8) 

#Polling for keyboard
movia r14,PS2KEYBOARD
#read keyboard
Read_Keyboard:
ldwio r13,0(r14)
andi r15,r13,0x08000 #check valid bit
beq r15,r0, Read_Keyboard
andi r13,r13,0x00FF #store input number into r13

#Check_Instruction:
movui r15,0x1d
beq r13,r15,Car_Forward
movui r15,0x1b
beq r13,r15,Car_Backward
movui r15,0x1c
beq r13,r15,Car_Left
movui r15,0x23
beq r13,r15,Car_Right
movui r15,0x29
beq r13,r15,Car_Grab


_end:
movia r16,0xffdffeff #check whether release
beq r16,r10,end_RAS
br end_GAS


##disable motor
movia	r9, 0xffdfffff
stwio	r9, 0(r8)

Car_Forward:

	mov r18, r0
	movia	 r9, 0xffdfffcb       # motor1 enabled (bit0=0), direction set to forward (bit1=0) 
	and	r9,r9,r10
	stwio	 r9, 0(r8)
	#movi r12, 0x0f3
	CF_draw:
	movia r16,0xffdffeff #check whether release
	beq r16,r10,RAF
	br GAF
	
	CF_read:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CF_draw
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x1d
	beq  r16,r15,CF_draw
	
	movui r15,0xf0
	bne  r16,r15,CF_draw
	
	CF_read1:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CF_read1
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x1d
	bne  r16,r15,CF_draw
	
	movia	r9, 0xffdfffff
    and	r9,r9,r10
	stwio	r9, 0(r8)
br _end

Car_Backward:
	mov r18,r0
	movia	 r9, 0xffdfffe3       # motor1 enabled (bit0=0), direction set to backward (bit1=1) 
	and	r9,r9,r10
	stwio	 r9, 0(r8)
	movi r12, 0x0fb
	
	CB_draw:
	movia r16,0xffdffeff #check whether release
	beq r16,r10,RAB
	br GAB
	
	CB_read:		
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CB_draw
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x1b
	beq  r16,r15,CB_draw

	movui r15,0xf0
	bne  r16,r15,CB_draw
	
	CB_read1:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CB_read1
	andi r16,r16,0x00FF	
	movui r15,0x1b
	bne  r16,r15,CB_draw
	movia	r9, 0xffdfffff
    and	r9,r9,r10
	stwio	r9, 0(r8)

br _end

Car_Left:

	mov r18, r0
	movia	 r9, 0xffdfffc3       # motor1 enabled (bit0=0), direction set to forward (bit1=0) 
	and	r9,r9,r10
	stwio	 r9, 0(r8)
	#movi r12, 0x0f3

	CL_draw:
	movia r16,0xffdffeff #check whether release
	beq r16,r10,RAL
	br GAL
	
	
	CL_read:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CL_draw
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x1c
	beq  r16,r15,CL_draw
	
	movui r15,0xf0
	bne  r16,r15,CL_draw
	
	CL_read1:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CL_read1
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x1c
	bne  r16,r15,CL_draw
	
	movia	r9, 0xffdfffff
    and	r9,r9,r10
	stwio	r9, 0(r8)
   
br _end	

Car_Right:
	mov r18,r0
	movia	 r9, 0xffdfffeb       # motor1 enabled (bit0=0), direction set to backward (bit1=1) 
	and	r9,r9,r10
	stwio	 r9, 0(r8)
	movi r12, 0x0fb
	
    CR_draw:
	movia r16,0xffdffeff #check whether release
	beq r16,r10,RAR
	br GAR
	
	CR_read:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CR_draw
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x23
	beq  r16,r15,CR_draw

	movui r15,0xf0
	bne  r16,r15,CR_draw
	
	CR_read1:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CR_read1
	andi r16,r16,0x00FF	
	movui r15,0x23
	bne  r16,r15,CR_draw
	movia	r9, 0xffdfffff
    and	r9,r9,r10
	stwio	r9, 0(r8)
br _end



Car_Grab:

	CG_read:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CG_read
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x29
	beq  r16,r15,CG_read
	
	movui r15,0xf0
	bne  r16,r15,CG_read
	
	CG_read1:
	ldwio r16,0(r14)
	andi r15,r16,0x08000 #check valid bit
	beq r15,r0, CG_read1
	andi r16,r16,0x00FF #store input number into r13
	movui r15,0x29
	bne  r16,r15,CG_read

	xori	r10,r10,0x0200
    stwio	r10,0(r8)
     movia r16,0xffdffeff #check whether release
	beq r16,r10,RAS
br GAS

GAB:
movia r12,Grab_And_Backward
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
GAB_loopy:
	GAB_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,GAB_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,GAB_loopy
br CB_read



GAF:
movia r12,Grab_And_Forward
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
GAF_loopy:
	GAF_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,GAF_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,GAF_loopy
br CF_read


GAS:
movia r12,Grab_And_Still
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
GAS_loopy:
	GAS_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,GAS_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,GAS_loopy
br _end

end_GAS:
movia r12,Grab_And_Still
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
eGAS_loopy:
	eGAS_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,eGAS_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,eGAS_loopy
br Read_Keyboard

RAS:
movia r12,Release_And_Still
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
RAS_loopy:
	RAS_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,RAS_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,RAS_loopy
br _end

end_RAS:
movia r12,Release_And_Still
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
eRAS_loopy:
	eRAS_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,eRAS_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,eRAS_loopy
br Read_Keyboard


RAF:
movia r12,Release_And_Forward
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
RAF_loopy:
	RAF_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,RAF_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,RAF_loopy
br CF_read

RAB:
movia r12,Release_And_Backward
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
RAB_loopy:
	RAB_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,RAB_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,RAB_loopy
br CB_read

RAL:
movia r12,Release_And_Left
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
RAL_loopy:
	RAL_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,RAL_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,RAL_loopy
br CL_read

RAR:
movia r12,Release_And_Right
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
RAR_loopy:
	RAR_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,RAR_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,RAR_loopy
br CR_read

GAL:
movia r12,Grab_And_Left
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
GAL_loopy:
	GAL_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,GAL_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,GAL_loopy
br CL_read

GAR:
movia r12,Grab_And_Right
movia r22,ADDR_VGA
mov r17,r0
mov r23,r0
mov r11,r0
GAR_loopy:
	GAR_loopx:
	ldh r19,0(r12)
	
	muli r11,r17,2
	add r11,r11,r23
	add r11,r11,r22

	sthio r19,0(r11)
	
	addi r12,r12,2
	addi r17,r17,1
	movi r24,320
	bne r24,r17,GAR_loopx
	mov r17,r0
	addi r23,r23,1024
movia r24,245760
bne r24,r23,GAR_loopy
br CR_read


.global timer
timer: 
	movia r20, TIMER
	mov r21, r4
	stwio r21, 8(r20)
	srli	r4,r4,16
	mov r21, r4
	stwio r21, 12(r20)

	stwio r21, 12(r20)
	stwio r0, 0(r20)
	movi r21, 0x06
	stwio r21, 4(r20)

T_loop: 
	ldwio r21, 0(r20)
	andi r21, r21, 0x01
	beq r21, r0, T_done
	br T_loop
T_done:
ret