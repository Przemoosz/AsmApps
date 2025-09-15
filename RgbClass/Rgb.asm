.const
	instanceVector equ 4
	fieldVector equ 1 
	printStackVector equ 56 
	rgbMin equ 0
	rgbMax equ 255
	errorCode equ -1
.data?
	; RGB Heap - Pointers 
	HBP qword ? ; Base pointer
	HSP qword ? ; Top Pointer

	; Heap Unused Pointers Stack
	HUBP qword ? ; Base pointer
	HUSP qword ? ; Top Pointer
.data
	align 4
	instances dword 128 dup(-1)
	HU qword 16 dup(0)
	HULength qword 0
	isInitialized dword 0
	rgbString byte "R: %d, G: %d, B: %d", 10, 0
.code
	externdef printf:proc
; rcx - R
; rdx - G
;  r8 - B
; return rax - pointer to instance
CreateRGB proc
	mov r12, rsp
	OneTimeSetup:
		call InitializeMemory

	argumentsValidation:
		call ValidateArgument ; Validate rcx (R)
		cmp rax, -1
		je handle_arg_error
		push rcx
		mov rcx, rdx

		call ValidateArgument ; Validate rdx (G)
		cmp rax, -1
		je handle_arg_error
		push rcx
		mov rcx, r8

		call ValidateArgument ; Validate r8 (B) 
		cmp rax, -1
		je handle_arg_error
	
	restore_arguments:
		pop rdx
		pop rcx
	
	create_and_save_instance:
		call GetFreePointer
		mov byte ptr[rax], cl ; As HSP is pointing to top of RGB stack next value is free cell
		mov byte ptr[rax+1], dl
		mov byte ptr[rax+2], r8b

		cmp rax, HSP
		jg increment_hsp ; if heap head pointer was used move it by 3 positions
		ret
	

		ret ; preserve original pointer - return rax as pointer to instance

	increment_hsp:
		mov rcx, HSP
		add rcx, 3
		mov HSP, rcx
		ret

	handle_arg_error:
		mov rax, errorCode
		mov rsp, r12 ; restore stack pointer if was changed
		ret
CreateRGB endp

; rcx - pointer to RGB
FreeRgbInstance proc
	validate_pointer:
		mov r8, HBP
		mov r9, HSP
		cmp r8, r9 ; invalid pointer if heap is empty (heap pointer == heap base pointer)
		je fail_validation

		cmp rcx, r8 ; pointer can not point outside of heap (pointer < heap base pointer)
		jle fail_validation

		mov rax, HSP
		sub rax, 2
		cmp rcx, rax  ; pointer can not point outside of heap (pointer > [heap pointer - 2])
					  ; [heap pointer - 2] -> last element begin position
		jg fail_validation
		je free_element_from_head	; free pointer by decrementing HSP by 2

		
		; adress should be mod 3 == 0
		mov rax, HBP
		mov rdx, rcx
		inc rax
		sub rdx, rax ; relative pointer to HBP
		mov rbx, 3 ; set divisor low to 3
		mov rax, rdx ; set dividend low
		mov rdx, 0 ; set dividend high to 0
		div rbx
		cmp rdx, 0 ; compare rest with 0
		jne fail_validation ; check if rdx % 3 == 0

	mark_pointer_as_free:
		mov rax, HUSP
		mov qword ptr[rax + 1], rcx ; mark pointer as free to use
		inc HULength ; increment length
		add HUSP, 8 ; move pointer by 8 bytes
		mov rax, 1 ; return true
		ret

	free_element_from_head:
		mov rax, HSP
		sub rax, 3
		mov HSP, rax
		mov rax, 1 ; return true
		ret

	fail_validation:
		mov rax, 0 ; return false
		ret

FreeRgbInstance endp

; rcx - pointer to RGB
RgbToString proc
	mov rax, rcx
	xor rdx, rdx
	xor r8, r8
	xor r9, r9

	sub rsp, printStackVector
	lea rcx, rgbString
	mov dl, byte ptr[rax]
	mov r8b, byte ptr[rax+1]
	mov r9b, byte ptr[rax+2]
	call printf
	add rsp, printStackVector
RgbToString endp


; rcx - argument, rax: 0 - success, -1 error
ValidateArgument proc
	cmp rcx, rgbMin ; rax < 0
	jl handle_arg_error
	
	cmp rcx, rgbMax ; rax > 255
	jg handle_arg_error

	mov rax, 0
	ret

	handle_arg_error:
	mov rax, errorCode
	ret
ValidateArgument endp

InitializeMemory proc
	was_initialized:
		xor rax, rax
		mov eax, isInitialized
		cmp eax, 1
		je finish_init
	heap_init:
		lea rax, instances 
		dec rax  ; point to bottom of RGB stack, next cell can be used as memory
		mov HBP, rax
		mov HSP, rax
	heap_unused_pointers_init:
		lea rax, HU 
		dec rax  ; point to bottom of RGB stack, next cell can be used as memory
		mov HUBP, rax
		mov HUSP, rax
		mov isInitialized, 1

	finish_init:
		ret
InitializeMemory endp

; rax -> free pointer
GetFreePointer proc
	mov rax, HULength
	cmp rax, 0
	jne reuse_pointer

	get_next_free_pointer:
		mov rax, HSP
		inc rax ; as it is poinitng to top element last byte in memory we need to increment by 1
		ret
	reuse_pointer:
		mov rcx, HUSP
		mov rax, qword ptr[rcx - 7]

		; pop pointer from stack
		sub rcx, 8 ; get last element pointer from HU

		mov HUSP, rcx ; decrement HU pointer by 8 
		dec HULength 
		ret	

GetFreePointer endp
end