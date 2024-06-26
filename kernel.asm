; syscall is a big chunk
; kernels responsibility to restore everything before you go back
; kernel needs to have a way to recieve the trap reason
; loading in a register or memory?
; yank all registers and put them in memory before anything else happens
; Need a new instruction to tell CPU where that memory address is 

; kernel.asm
; needs to read in the instructions
; needs to be able to respond to CPU emu
; It needs to know the reason in order to know how to respond
; it does that by doing a syscall check on the number 
; It needs to keep track of the timer
; can use read and write instructions
; syscall is used in prime because it doesn't have access


start: 
    ; sent trap handler address
    setTrapAddr .trap_handler_store
    ; Read the program length
    read r0     ; Read the first byte into r0
    shl r0 8 r0    ; Shift r0 left by 8 bits
    read r1        ; Read the second byte into r1
    or r0 r1 r0    ; Combine r0 and r1 using OR operation, store in r2

    ; Initialize loop counter and memory address
    loadLiteral 1024 r2     ; r2 is the memory address where the program starts
    loadLiteral 0 r3        ; r3 is our loop counter

instruc_loadin:
    ; Read and assemble ans instruction word
    ; Remember to use r1 to store the full word
    ; r2 will be used to read in the next byte

    ; clear r1 for new word
    loadLiteral 0 r4
    ; read in the 1st byte
    read r1
    ; shift 3 places because we read in 1 byte
    shl r1 24 r1
    ; combine
    or r4 r1 r4

    read r1
    ; shift 2 places because we read in 1 byte
    shl r1 16 r1
    ; combine
    or r4 r1 r4

    read r1
    ; shift 1 place because we read in 1 byte
    shl r1 8 r1
    ; combine
    or r4 r1 r4

    ; read the 4th byte
    read r1
    or r4 r1 r4

    ; we have the word (a line of code), so store it in memory
    ; store the instruction word in memory
    store r4 r2

    ; Increment counter and memory address
    ; Increment loop counter
    add r2 1 r2
    ; Increment memory address
    add r3 1 r3

    ; Compare loop counter with program length
    ; Compare counter (r4) with length (r0), result in r5
    lt r3 r0 r4
    ; If the loop counter is less than program length, then we have more instructions to write, jump to loop_end
    cmove r4 .instruc_loadin r7
    ; After storing all instructions, the instruction pointer (r7) is reset to 1024 to begin execution of the loaded program.
    ; ; set back to user mode
    ; setUserMode
    ; move the pointer back to 1024
    loadLiteral 1024 r7


trap_handler_store:
    store r0 0
    store r1 1
    store r2 2
    store r3 3
    store r4 4
    store r5 5

    ; sending memory address to CPU '6' stands for the c.memory[num] on the CPU side
    load 6 r5
    loadLiteral .trap_reset r4
    ; Check the trap reason and handle (all the checks/ hooks)

    ; if 0, run read 
    eq r5 0 r0
    loadLiteral .read_instruct r3
    cmove r0 r3 r7

    ; if 1, run write
    eq r5 1 r0
    loadLiteral .write_instruct r3
    cmove r0 r3 r7

    ; if 2, then halt
    eq r5 2 r0
    loadLiteral .halt r3
    cmove r0 r3 r7

    ; if 3, timer
    eq r5 3 r0
    loadLiteral .timer_fired r3
    cmove r0 r3 r7
    ; cmove r0 .timer_fired r7

    ; if 4, throw memory out of bounds
    eq r5 4 r0 
    cmove r0 .mem_bounds r7

    ; if 5, throw illegal instruction
    eq r5 5 r0
    cmove r0 .illegal_instruc r7

    eq r5 8 r0
    loadLiteral .timer_fired_num r3
    cmove r0 r3 r7

    ; unreachable syscall
    move r4 r7
    

read_instruct:
    ; allow read 
    read r6
    ; jump to exit
    move r4 r7

write_instruct:
    ; allow read 
    write r6
    ; jump to exit
    move r4 r7

illegal_instruc:
    ; \nIllegal instruction!
    ; \nTimer fired XXXXXXXX times\n
    write 10    ; new line
    write 'I'
    write 'l'
    write 'l'
    write 'e'
    write 'g'
    write 'a'
    write 'l'
    write 32    ; space
    write 'i'
    write 'n'
    write 's'
    write 't'
    write 'r'
    write 'u'
    write 'c'
    write 't'
    write 'i'
    write 'o'
    write 'n'
    write '!'

    ;print number of times a time was fired
    loadLiteral .timer_fired_num r0
    move r0 r7

mem_bounds:
; \nOut of bounds memory access!
; \nTimer fired XXXXXXXX times\n
    write 10    ; new line
    write 'O'
    write 'u'
    write 't'
    write 32    ; space
    write 'o'
    write 'f'
    write 32    ; space
    write 'b'
    write 'o'
    write 'u'
    write 'n'
    write 'd'
    write 's'
    write 32    ; space
    write 'm'
    write 'e'
    write 'm'
    write 'o'
    write 'r'
    write 'y'
    write 32    ; space
    write 'a'
    write 'c'
    write 'c'
    write 'e'
    write 's'
    write 's'
    write '!'

    ; print number of times a time was fired
    loadLiteral .timer_fired_num r0
    move r0 r7

halt:
    ; \nProgram has exited
    ; \nTimer fired XXXXXXXX times\n
    write 10    ; new line
    write 'P'
    write 'r'
    write 'o'
    write 'g'
    write 'r'
    write 'a'
    write 'm'
    write 32
    write 'h'
    write 'a'
    write 's'
    write 32
    write 'e'
    write 'x'
    write 'i'
    write 't'
    write 'e'
    write 'd'

    ;print number of times a time was fired
    loadLiteral .timer_fired_num r0
    move r0 r7

timer_fired:
    ; \nTimer fired!\n
    write 10    ; new line
    write 'T'
    write 'i'
    write 'm'
    write 'e'
    write 'r'
    write 32
    write 'f'
    write 'i'
    write 'r'
    write 'e'
    write 'd'
    write '!'
    write 10

    ; jump to reset
    move r4 r7

timer_fired_num:
    write 10    ; new line
	write 'T'
	write 'i'
	write 'm'
	write 'e'
	write 'r'
	write 32
	write 'f'
	write 'i'
	write 'r'
	write 'e'
	write 'd'
	write 32

	load 8 r0
	loadLiteral 28 r1

timer_loop:
	shr r0 r1 r2
	and r2 15 r2
	lt r2 10 r3	

	loadLiteral .hex r5
	cmove r3 r5 r7
	add r2 87 r2

continue:
	write r2
	sub r1 4 r1	

	eq r1 0 r3
	loadLiteral .timer_two r5
	cmove r3 r5 r7
	loadLiteral .timer_loop r5
	move r5 r7

hex:
	add r2 48 r2
	loadLiteral .continue r5
	move r5 r7	
	
timer_two:
	and r0 15 r2
	lt r2 10 r3

	loadLiteral .next_hex r5
	cmove r3 r5 r7
	add r2 87 r2
	loadLiteral .timer_finish r5
	move r5 r7

next_hex:
	add r2 48 r2

timer_finish:
	write r2				
	write 32
	write 't'
	write 'i'
	write 'm'
	write 'e'
	write 's'
	write 10
	halt 					; Finally: halt!

trap_reset:
    ; Reset registers
    load 0 r0
    load 1 r1
    load 2 r2
    load 3 r3
    load 4 r4
    load 5 r5

    setIptr 7
    ; set back to user mode
    setUserMode


