.const
	instanceVector equ 4
	fieldVector equ 1 
	printStackVector equ 56 
	rgbMin equ 0
	rgbMax equ 255
	errorCode equ -1
.data?
	; RGB Heap Pointers
	HBP qword ? ; Base pointer
	HSP qword ? ; Top Pointer

	; Heap Unused Pointers Pointers - Implemented as stack
	HUBP qword ? ; Base pointer
	HSP qword ? ; Top Pointer
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

		call ValidateArgument ; Validate rdx  (G)
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
	
	create_instance:
	    mov rax, HSP 
		inc rax
		mov byte ptr[rax], cl ; As HSP is pointing to top of RGB stack next value is free cell
		mov byte ptr[rax+1], dl
		mov byte ptr[rax+2], r8b
		add HSP, 3	; Move pointer  by 2 bytes

		ret ; preserve original pointer - return rax as pointer to instance

	handle_arg_error:
		mov rax, errorCode
		mov rsp, r12 ; restore stack pointer if was changed
		ret
CreateRGB endp

;
FreeRgbInstance proc
	

	
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
	one_time_setup:
		lea rax, instances 
		dec rax  ; point to bottom of RGB stack, next cell can be used as memory
		mov HBP, rax
		mov HSP, rax
		mov isInitialized, 1
	finish_init:
		ret
InitializeMemory endp

end