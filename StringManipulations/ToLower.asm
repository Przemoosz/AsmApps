.const
	shadow_space_vector equ 32 ; 8 x 4 = 32 - space required for register (4 argument registers) copy in stack - "shadow space"
	byteSize equ 8
	NULL equ 0
	lowerLetterAsciiVector equ 32

.data
	AllocationErrorMessage byte "Failed to allocate memory in process Heap.", 10, NULL

.data?
	pointer typedef qword
	len qword ?
	processHeapHandle qword ?
	heapPointer pointer ?
	requestedHeapSize qword ?
	originalStringPointer pointer ?

.code
	externdef GetProcessHeap:proc
	externdef GetProcessHeaps:proc
	externdef HeapAlloc:proc
	externdef HeapFree:proc
	externdef HeapSize:proc
	externdef printf:proc

; rcx - pointer to string
ToLower proc 	
	xor rax, rax ; zero rax
	xor rdx, rdx ; zero rdx
	mov originalStringPointer, rcx
	loop_start: ; calculate length
		mov al, byte ptr[rcx + rdx]
		cmp al, 0
		je loop_end	
		inc rdx
		jmp loop_start

	loop_end:
		mov len, rdx ; save string length

	allign_size:	
		; zeros rcx, rdx
		xor rcx, rcx 
		xor rdx, rdx

		mov rax, len
		inc rax ; +1 for trailing 0 - end of string
		mov rcx, byteSize
  		div rcx
		; rax - quotient (number of 8 bytes blocks needed)
		; rdx - reminder (bytes that needs to go to additional block)
		cmp rdx, 0
		jg allign_additional_bytes
		jmp save_heap_size
	allign_additional_bytes:
		; string length not divisable by 8 -> adding additional 8 byte block for reminder 
		inc rax 
	save_heap_size: 
		imul rax, byteSize
		mov requestedHeapSize, rax
		
	allocate_memory:
		sub rsp, shadow_space_vector

		get_process_heap:
			call GetProcessHeap
			mov processHeapHandle, rax ; save process heap pointer

		request_memory_allocation:
			mov rcx, processHeapHandle ; Allcate in process heap
			mov dx, 00000004h ; ThrowErrors
			mov r8, requestedHeapSize ; HeapSize

			call HeapAlloc
			mov heapPointer, rax

			; Validate allocation on heap
			cmp heapPointer, NULL
			je Allocation_Error
		
			add	rsp, shadow_space_vector
	to_lower_string:
		xor rcx, rcx
		xor rax, rax
		mov rdx, originalStringPointer
		mov r9, heapPointer
		
		loop_start_to_lower:
			mov al, byte ptr [rdx + rcx]
			cmp al, 0
			je loop_done_to_lower
			cmp al, 'A'
			jl no_change_to_lower
			cmp al, 'Z'
			jg no_change_to_lower
		change_to_lower:
			add al, lowerLetterAsciiVector
			mov byte ptr [r9 + rcx], al
			inc rcx
			jmp loop_start_to_lower
		no_change_to_lower:
			mov byte ptr [r9 + rcx], al
			inc rcx
			jmp loop_start_to_lower
		loop_done_to_lower:
			mov byte ptr [r9 + rcx], NULL ; trailing 0 - end of string 
		mov rax, heapPointer
		ret
	Allocation_Error:
		lea rcx, AllocationErrorMessage
		call printf
		add rsp, shadow_space_vector
		mov rax, NULL
		ret
ToLower endp 
end