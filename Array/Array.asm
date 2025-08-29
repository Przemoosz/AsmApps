.const
	vector equ 8h
	maxSize equ 128

.data
	List qword maxSize dup(-1)
	basePointer qword 0
	arraySize qword ?

.code

	; rcx - index
	; rdx - value
	AddElementAt proc

		validation:

			call ValidateIndex
			cmp rax, -1
			je err
		
		pointer_manipulation:
			lea r10, List ; pointer to begining of list

			mov basePointer, r10 ; saves base pointer

			mov rax, vector
			; mul rcx	; multiplication with over flow to rdx, rax
			imul rax, rcx ; multiplication by 8 (8 bytes = 64 bits = size of qword) without overflow vector to relative position to next element
			add r10, rax  ; adding vector to base pointer

		add_value:
			mov qword ptr[r10], rdx ; adding value to memory location 

		mov rax, 0 
		ret

		err:
			mov rax, -1
			ret

	AddElementAt endp

	; rcx - index
	GetElementFrom proc
	
		validation:
			call ValidateIndex
			cmp rax, -1
			je err

		pointer_manipulation:
			mov r8, basePointer
			mov rax, vector
			imul rax, rcx
			add r8, rax
			mov rax, qword ptr [r8] ; take element from memory location
			ret

		err:
			mov rax, -1
			ret

	GetElementFrom endp

	; rcx - size
	SetUpArray proc

		Validate:
			cmp ecx, 0
			jl err

			cmp ecx, maxSize
			jg err

		SetUpSizeAndPointer:
			mov arraySize, rcx

			lea r10, List ; list base address

			mov basePointer, r10 ; save base adress

			mov rax, basePointer

			ret

		err:
			mov rax, -1
			ret

	SetUpArray endp

	ValidateIndex proc

		; if value is less than 0 go to error
		cmp ecx, 0 
		jl err

		; if value greater than 128 go to error
		mov r8d, maxSize
		cmp ecx, r8d 
		jg err

		; if value greater than array size go to error

		mov r8, arraySize
		cmp rcx, arraySize
		jg err

		; success code: 0
		suc:
			mov rax, 0
			ret

		; failed code: -1
		err:
			mov rax, -1
			ret
	ValidateIndex endp

end
