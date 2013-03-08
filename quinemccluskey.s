! Globals 
! ===========================================================
.global varMax
.global maxPrimes
.global maxMinterms
.global count1s
.global pow
.global intToImplicant
.global printImplicant
.global prune
.global main

! ROData segment
! ===========================================================
.section ".rodata"
.align 4
.endl:	 .asciz "\n"
.intFmt:	 .asciz "%d"
.pointerFmt:	 .asciz "0x%x"
.funcPointerFmt:	 .asciz "0x%x (0x%x)"
.boolStr:	 .asciz "false\0true"
.stringFmt:	 .asciz "%s"
.deallocDeRef:	 .asciz "Attempt to dereference a pointer into deallocated stack space.\n"
.nullPtrDeRef:	 .asciz "Attempt to dereference NULL pointer.\n"
.doubleDelete:	 .asciz "Double delete detected. Memory region has already been released in heap space.\n"
.memLeak:	 .asciz "%d memory leak(s) detected in heap space.\n"
.arrayBounds:	 .asciz "Index value of %d is outside legal range [0,%d).\n"
.___string0:	 .asciz "-"
.___string1:	 .asciz "printing"
.___string2:	 .asciz " "
.___string3:	 .asciz "G"
.___string4:	 .asciz ":"
.___string5:	 .asciz "Number of variables: "
.___string6:	 .asciz "Number of prime implicants: "
.___string7:	 .asciz "Prime Implicants: "
.___string8:	 .asciz ", "

! Data segment
! ===========================================================
.section ".data"
.align 4
.rc_first_data:	.skip 4
.rc_float1:	.single 0r1
varMax:	.word 10
maxPrimes:	.word 5905
maxMinterms:	.word 1024

! BSS segment
! ===========================================================
.section ".bss"
.align 4
.rc_initialized:	.skip 4
.floatConverter:	.skip 4
.allocTBL:	.skip 4
.allocTBL_rows:	.skip 4
.rc_heapEnd:	.skip 4

! Text segment
! ===========================================================
.section ".text"

! .rcfunc_setup function
! ===========================================================
.rcfunc_setup:
	save %sp, -(92 + 0) & -8, %sp
	
	! Allocate the allocTBL
	call malloc, 1
	mov 8, %o0
	set .allocTBL, %l0
	st %o0, [%l0]
	
	! Also update the heapEnd variable
	set .rc_heapEnd, %l0
	st %o0, [%l0]
	
	! Initialize global variables
	call .rcfunc_init, 0
	nop
	
	! Call main with all its original parameters.
	mov %i0, %o0
	mov %i1, %o1
	mov %i2, %o2
	mov %i3, %o3
	mov %i4, %o4
	call main
	mov %i5, %o5
	mov %o0, %i0
	
	ret
	restore

! .rcfunc_teardown function
! ===========================================================
.rcfunc_teardown:
	save %sp, -(92 + 0) & -8, %sp
	
	! Look for any non-deleted memory
	set .allocTBL, %l0
	ld [%l0], %l0
	set .allocTBL_rows, %l1
	ld [%l1], %l1
	mov %g0, %l2     ! %l2 is the row we are looking at
	mov %g0, %l4     ! %l4 is the number of memleaks found
.rcfunc_teardown_memleak_search_start:
	cmp %l2, %l1
	bge .rcfunc_teardown_memleak_search_end
	nop
	
	ld [%l0], %l3    ! Gets the valid byte
	cmp %g0, %l3
	be .rcfunc_teardown_memleak_pass
	add %l0, 4, %l0  ! Skip to the address
	inc %l4
	call free, 1
	mov %l0, %o0
	
.rcfunc_teardown_memleak_pass:
	add %l0, 4, %l0  ! Skip to the next row
	ba .rcfunc_teardown_memleak_search_start
	inc %l2
.rcfunc_teardown_memleak_search_end:
	
	! Check if we found any memory leaks
	cmp %l4, %g0
	be .rcfunc_teardown_no_memleaks
	nop
	set .memLeak, %o0
	call printf, 2
	mov %l4, %o1
	
.rcfunc_teardown_no_memleaks:
	
	! Free the allocTBL
	set .allocTBL, %l0
	ld [%l0], %o0
	call free, 1
	nop
	
	ret
	restore

! .rcfunc_new function
! ===========================================================
.rcfunc_new:
	save %sp, -(92 + 0) & -8, %sp
	
	! Call malloc and initialize the memory (by flooding it with zeros)
	call malloc, 1
	mov %i0, %o0
	mov %i0, %o2
	mov %o0, %i0
	call memset, 3
	mov %g0, %o1
	
	mov %o0, %l7
	
	! Update the allocTBL
	set .allocTBL, %l0
	ld [%l0], %l0
	set .allocTBL_rows, %l1
	ld [%l1], %l1
	! Look for any invalid rows
	mov %g0, %l2             ! %l2 is the row we are looking at
.rcfunc_new_search_start:
	cmp %l2, %l1
	bge .rcfunc_new_no_invalid_rows
	nop
	
	ld [%l0], %l3            ! Gets the valid byte
	cmp %g0, %l3
	bne .rcfunc_new_not_invalid
	nop
	mov 1, %l3
	st %l3, [%l0]
	add %l0, 4, %l0          ! Skip to the address
	st %i0, [%l0]
	ba .rcfunc_new_tblupdated
	nop
	
.rcfunc_new_not_invalid:
	add %l0, 8, %l0          ! Skip to the next row
	ba .rcfunc_new_search_start
	inc %l2
	
.rcfunc_new_no_invalid_rows:
	add %l1, 1, %o0          ! Update the row count
	set .allocTBL_rows, %l0
	st %o0, [%l0]
	call .mul, 2             ! Realloc the table
	mov 8, %o1
	mov %o0, %l4
	set .allocTBL, %o0
	ld [%o0], %o0
	call realloc, 2
	mov %l4, %o1
	set .allocTBL, %l0       ! Update the location of the table
	st %o0, [%l0]
	sub %l4, 4, %l4          ! Update the table
	add %l4, %o0, %l4
	st %i0, [%l4]
	mov 1, %l3               ! Set the valid bit
	sub %l4, 4, %l4
	st %l3, [%l4]
	
.rcfunc_new_tblupdated:
	
	! Update the location of the heap
	set .rc_heapEnd, %l0
	ld [%l0], %l1
	cmp %i0, %l7
	blu .rcfunc_new_noupdate
	nop
	st %l7, [%l0]
.rcfunc_new_noupdate:
	
	ret
	restore

! .rcfunc_delete function
! ===========================================================
.rcfunc_delete:
	save %sp, -(92 + 0) & -8, %sp
	
	! Check if this address exists in the table of allocated memory
	set .allocTBL, %l0
	ld [%l0], %l0
	set .allocTBL_rows, %l1
	ld [%l1], %l1
	! Look for any invalid rows
	mov %g0, %l2             ! %l2 is the row we are looking at
.rcfunc_delete_search_start:
	cmp %l2, %l1
	bge .rcfunc_delete_not_found
	nop
	
	ld [%l0], %l3            ! Gets the valid byte
	cmp %g0, %l3
	be .rcfunc_delete_continue
	add %l0, 4, %l0          ! Skip to the address
	ld [%l0], %l3
	cmp %i0, %l3
	bne .rcfunc_delete_continue
	nop
	sub %l0, 4, %l0          ! Update the valid bit
	st %g0, [%l0]
	call free, 1             ! Free the memory
	mov %i0, %o0
	ba .rcfunc_delete_success
	
	
.rcfunc_delete_continue:
	add %l0, 4, %l0          ! Skip to the next row
	ba .rcfunc_delete_search_start
	inc %l2
	
.rcfunc_delete_not_found:
	set .doubleDelete, %o0
	call printf, 1
	nop
	call exit, 1
	mov 1, %o0
.rcfunc_delete_success:
	ret
	restore

! .rcfunc_rtc_deref function
! ===========================================================
.rcfunc_rtc_deref:
	save %sp, -(92 + 0) & -8, %sp
	nop
	cmp %i0, 0
	bne .rcfunc_rtc_deref_not0
	nop
	set .nullPtrDeRef, %o0
	call printf, 1
	nop
	call exit, 1
	mov 1, %o0
.rcfunc_rtc_deref_not0:
	set .rc_heapEnd, %l0
	ld [%l0], %l0
	cmp %i0, %l0
	bleu .rcfunc_rtc_deref_pass	!Pointing into data, heap, or BSS
	nop
.rcfunc_rtc_deref_fail:
	set .stringFmt, %o0
	set .deallocDeRef, %o1
	call printf, 2
	nop
	call exit, 1
	mov 1, %o0
.rcfunc_rtc_deref_pass:
	ret
	restore

! .rcfunc_init function
! ===========================================================
.rcfunc_init:
	set -(92 + 0) & -8, %g2
	save %sp, %g2, %sp
	
	ret
	restore

! count1s function
! ===========================================================
count1s:
	set -(92 + 32) & -8, %g2
	save %sp, %g2, %sp
	
	! count = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! count <- %l0
	set -8, %l6	! AddressOf(count = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! count = 0 <- %l0
	
._whilestart0:
	! (i)>(0)
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bg ._bg2
	mov 1, %l0
	mov 0, %l0
._bg2:
	set -12, %l6	! AddressOf((i)>(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)>(0) <- %l0
	
	set -12, %l6	! AddressOf((i)>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)>(0) -> %l0
	cmp %l0, 0
	be ._whileend1
	nop
	
	! (i)&(1)
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set 1, %l1	! 1 -> %l1
	and %l0, %l1, %l0
	set -16, %l6	! AddressOf((i)&(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)&(1) <- %l0
	
	! (count)+((i)&(1))
	set -4, %l6	! AddressOf(count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! count -> %l0
	set -16, %l6	! AddressOf((i)&(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! (i)&(1) -> %l1
	add %l0, %l1, %l0
	set -20, %l6	! AddressOf((count)+((i)&(1))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (count)+((i)&(1)) <- %l0
	
	! count = (count)+((i)&(1))
	set -20, %l6	! AddressOf((count)+((i)&(1))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (count)+((i)&(1)) -> %l0
	set -4, %l6	! AddressOf(count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! count <- %l0
	set -24, %l6	! AddressOf(count = (count)+((i)&(1))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! count = (count)+((i)&(1)) <- %l0
	
	! (i)/(2)
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 2, %o1	! 2 -> %o1
	call .div, 2
	nop
	set -28, %l6	! AddressOf((i)/(2)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (i)/(2) <- %o0
	
	! i = (i)/(2)
	set -28, %l6	! AddressOf((i)/(2)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)/(2) -> %l0
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	set -32, %l6	! AddressOf(i = (i)/(2)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i = (i)/(2) <- %l0
	
	ba ._whilestart0
	nop
._whileend1:
	! return count
	set -4, %l6	! AddressOf(count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %i0	! count -> %i0
	ret
	restore

! pow function
! ===========================================================
pow:
	set -(92 + 28) & -8, %g2
	save %sp, %g2, %sp
	
	! (e)<(0)
	set 72, %l6	! AddressOf(e) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! e -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bl ._bl3
	mov 1, %l0
	mov 0, %l0
._bl3:
	set -4, %l6	! AddressOf((e)<(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (e)<(0) <- %l0
	
	! if ((e)<(0))
	set -4, %l6	! AddressOf((e)<(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (e)<(0) -> %l0
	cmp %l0, %g0
	be ._else4
	nop
	! return 0
	set 0, %i0	! 0 -> %i0
	ret
	restore
	ba ._endif5
	nop
._else4:
._endif5:
	! r = 1
	set 1, %l0	! 1 -> %l0
	set -8, %l6	! AddressOf(r) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! r <- %l0
	set -12, %l6	! AddressOf(r = 1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! r = 1 <- %l0
	
._whilestart6:
	! --(e)
	set 72, %l6	! AddressOf(e) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! e -> %l0
	set -16, %l6	! AddressOf(--(e)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! --(e) <- %l0
	dec %l0
	set 72, %l6	! AddressOf(e) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! e <- %l0
	
	! (--(e))>(0)
	set -16, %l6	! AddressOf(--(e)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! --(e) -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bg ._bg8
	mov 1, %l0
	mov 0, %l0
._bg8:
	set -20, %l6	! AddressOf((--(e))>(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (--(e))>(0) <- %l0
	
	set -20, %l6	! AddressOf((--(e))>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (--(e))>(0) -> %l0
	cmp %l0, 0
	be ._whileend7
	nop
	
	! (r)*(b)
	set -8, %l6	! AddressOf(r) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! r -> %o0
	set 68, %l6	! AddressOf(b) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! b -> %o1
	call .mul, 2
	nop
	set -24, %l6	! AddressOf((r)*(b)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (r)*(b) <- %o0
	
	! r = (r)*(b)
	set -24, %l6	! AddressOf((r)*(b)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (r)*(b) -> %l0
	set -8, %l6	! AddressOf(r) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! r <- %l0
	set -28, %l6	! AddressOf(r = (r)*(b)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! r = (r)*(b) <- %l0
	
	ba ._whilestart6
	nop
._whileend7:
	! return r
	set -8, %l6	! AddressOf(r) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %i0	! r -> %i0
	ret
	restore

! intToImplicant function
! ===========================================================
intToImplicant:
	set -(92 + 56) & -8, %g2
	save %sp, %g2, %sp
	
	! ret = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(ret) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ret <- %l0
	set -8, %l6	! AddressOf(ret = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ret = 0 <- %l0
	
	! pos = 1
	set 1, %l0	! 1 -> %l0
	set -12, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos <- %l0
	set -16, %l6	! AddressOf(pos = 1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos = 1 <- %l0
	
._whilestart9:
	! (i)>(0)
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bg ._bg11
	mov 1, %l0
	mov 0, %l0
._bg11:
	set -20, %l6	! AddressOf((i)>(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)>(0) <- %l0
	
	set -20, %l6	! AddressOf((i)>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)>(0) -> %l0
	cmp %l0, 0
	be ._whileend10
	nop
	
	! (i)&(1)
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set 1, %l1	! 1 -> %l1
	and %l0, %l1, %l0
	set -24, %l6	! AddressOf((i)&(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)&(1) <- %l0
	
	! ((i)&(1))==(1)
	set -24, %l6	! AddressOf((i)&(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)&(1) -> %l0
	set 1, %l1	! 1 -> %l1
	cmp %l0, %l1
	be ._be12
	mov 1, %l0
	mov 0, %l0
._be12:
	set -28, %l6	! AddressOf(((i)&(1))==(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((i)&(1))==(1) <- %l0
	
	! if (((i)&(1))==(1))
	set -28, %l6	! AddressOf(((i)&(1))==(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((i)&(1))==(1) -> %l0
	cmp %l0, %g0
	be ._else13
	nop
	! (3)*(pos)
	set 3, %o0	! 3 -> %o0
	set -12, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! pos -> %o1
	call .mul, 2
	nop
	set -32, %l6	! AddressOf((3)*(pos)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (3)*(pos) <- %o0
	
	! (ret)+((3)*(pos))
	set -4, %l6	! AddressOf(ret) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ret -> %l0
	set -32, %l6	! AddressOf((3)*(pos)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! (3)*(pos) -> %l1
	add %l0, %l1, %l0
	set -36, %l6	! AddressOf((ret)+((3)*(pos))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (ret)+((3)*(pos)) <- %l0
	
	! ret = (ret)+((3)*(pos))
	set -36, %l6	! AddressOf((ret)+((3)*(pos))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (ret)+((3)*(pos)) -> %l0
	set -4, %l6	! AddressOf(ret) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ret <- %l0
	set -40, %l6	! AddressOf(ret = (ret)+((3)*(pos))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ret = (ret)+((3)*(pos)) <- %l0
	
	ba ._endif14
	nop
._else13:
._endif14:
	! (pos)*(4)
	set -12, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! pos -> %o0
	set 4, %o1	! 4 -> %o1
	call .mul, 2
	nop
	set -44, %l6	! AddressOf((pos)*(4)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (pos)*(4) <- %o0
	
	! pos = (pos)*(4)
	set -44, %l6	! AddressOf((pos)*(4)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (pos)*(4) -> %l0
	set -12, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos <- %l0
	set -48, %l6	! AddressOf(pos = (pos)*(4)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos = (pos)*(4) <- %l0
	
	! (i)/(2)
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 2, %o1	! 2 -> %o1
	call .div, 2
	nop
	set -52, %l6	! AddressOf((i)/(2)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (i)/(2) <- %o0
	
	! i = (i)/(2)
	set -52, %l6	! AddressOf((i)/(2)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)/(2) -> %l0
	set 68, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	set -56, %l6	! AddressOf(i = (i)/(2)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i = (i)/(2) <- %l0
	
	ba ._whilestart9
	nop
._whileend10:
	! return ret
	set -4, %l6	! AddressOf(ret) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %i0	! ret -> %i0
	ret
	restore

! printImplicant function
! ===========================================================
printImplicant:
	set -(92 + 48) & -8, %g2
	save %sp, %g2, %sp
	
	! (numVars)-(1)
	set 72, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	set 1, %l1	! 1 -> %l1
	sub %l0, %l1, %l0
	set -4, %l6	! AddressOf((numVars)-(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (numVars)-(1) <- %l0
	
	! pow(4, (numVars)-(1))
	set 4, %l0	! 4 -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -4, %l6	! AddressOf((numVars)-(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (numVars)-(1) -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call pow, 2
	nop
	set -8, %l6	! AddressOf(pow(4, (numVars)-(1))) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! pow(4, (numVars)-(1)) <- %o0
	
	! (3)*(pow(4, (numVars)-(1)))
	set 3, %o0	! 3 -> %o0
	set -8, %l6	! AddressOf(pow(4, (numVars)-(1))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! pow(4, (numVars)-(1)) -> %o1
	call .mul, 2
	nop
	set -12, %l6	! AddressOf((3)*(pow(4, (numVars)-(1)))) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (3)*(pow(4, (numVars)-(1))) <- %o0
	
	! mask = (3)*(pow(4, (numVars)-(1)))
	set -12, %l6	! AddressOf((3)*(pow(4, (numVars)-(1)))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (3)*(pow(4, (numVars)-(1))) -> %l0
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mask <- %l0
	set -20, %l6	! AddressOf(mask = (3)*(pow(4, (numVars)-(1)))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mask = (3)*(pow(4, (numVars)-(1))) <- %l0
	
._whilestart15:
	! (mask)>(0)
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! mask -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bg ._bg17
	mov 1, %l0
	mov 0, %l0
._bg17:
	set -24, %l6	! AddressOf((mask)>(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (mask)>(0) <- %l0
	
	set -24, %l6	! AddressOf((mask)>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (mask)>(0) -> %l0
	cmp %l0, 0
	be ._whileend16
	nop
	
	! (implicant)&(mask)
	set 68, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! implicant -> %l0
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! mask -> %l1
	and %l0, %l1, %l0
	set -28, %l6	! AddressOf((implicant)&(mask)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (implicant)&(mask) <- %l0
	
	! ((implicant)&(mask))==(mask)
	set -28, %l6	! AddressOf((implicant)&(mask)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (implicant)&(mask) -> %l0
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! mask -> %l1
	cmp %l0, %l1
	be ._be18
	mov 1, %l0
	mov 0, %l0
._be18:
	set -32, %l6	! AddressOf(((implicant)&(mask))==(mask)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((implicant)&(mask))==(mask) <- %l0
	
	! if (((implicant)&(mask))==(mask))
	set -32, %l6	! AddressOf(((implicant)&(mask))==(mask)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((implicant)&(mask))==(mask) -> %l0
	cmp %l0, %g0
	be ._else19
	nop
	! cout 1
	set 1, %o1	! 1 -> %o1
	set .intFmt, %o0
	call printf, 2
	nop
	
	ba ._endif20
	nop
._else19:
	! (implicant)&(mask)
	set 68, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! implicant -> %l0
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! mask -> %l1
	and %l0, %l1, %l0
	set -36, %l6	! AddressOf((implicant)&(mask)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (implicant)&(mask) <- %l0
	
	! ((implicant)&(mask))==(0)
	set -36, %l6	! AddressOf((implicant)&(mask)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (implicant)&(mask) -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	be ._be21
	mov 1, %l0
	mov 0, %l0
._be21:
	set -40, %l6	! AddressOf(((implicant)&(mask))==(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((implicant)&(mask))==(0) <- %l0
	
	! if (((implicant)&(mask))==(0))
	set -40, %l6	! AddressOf(((implicant)&(mask))==(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((implicant)&(mask))==(0) -> %l0
	cmp %l0, %g0
	be ._else22
	nop
	! cout 0
	set 0, %o1	! 0 -> %o1
	set .intFmt, %o0
	call printf, 2
	nop
	
	ba ._endif23
	nop
._else22:
	! cout -
	set .stringFmt, %o0
	set .___string0, %o1
	call printf, 2
	nop
	
._endif23:
._endif20:
	! (mask)/(4)
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! mask -> %o0
	set 4, %o1	! 4 -> %o1
	call .div, 2
	nop
	set -44, %l6	! AddressOf((mask)/(4)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (mask)/(4) <- %o0
	
	! mask = (mask)/(4)
	set -44, %l6	! AddressOf((mask)/(4)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (mask)/(4) -> %l0
	set -16, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mask <- %l0
	set -48, %l6	! AddressOf(mask = (mask)/(4)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mask = (mask)/(4) <- %l0
	
	ba ._whilestart15
	nop
._whileend16:
	ret
	restore

! BITVECTOR.isBitSet function
! ===========================================================
BITVECTOR.isBitSet:
	set -(92 + 44) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! (bit)/(32)
	set 68, %l6	! AddressOf(bit) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! bit -> %o0
	set 32, %o1	! 32 -> %o1
	call .div, 2
	nop
	set -4, %l6	! AddressOf((bit)/(32)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (bit)/(32) <- %o0
	
	! index = (bit)/(32)
	set -4, %l6	! AddressOf((bit)/(32)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (bit)/(32) -> %l0
	set -8, %l6	! AddressOf(index) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! index <- %l0
	set -12, %l6	! AddressOf(index = (bit)/(32)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! index = (bit)/(32) <- %l0
	
	! (bit)%(32)
	set 68, %l6	! AddressOf(bit) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! bit -> %o0
	set 32, %o1	! 32 -> %o1
	call .rem, 2
	nop
	set -16, %l6	! AddressOf((bit)%(32)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (bit)%(32) <- %o0
	
	! pow(2, (bit)%(32))
	set 2, %l0	! 2 -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -16, %l6	! AddressOf((bit)%(32)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (bit)%(32) -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call pow, 2
	nop
	set -20, %l6	! AddressOf(pow(2, (bit)%(32))) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! pow(2, (bit)%(32)) <- %o0
	
	! mask = pow(2, (bit)%(32))
	set -20, %l6	! AddressOf(pow(2, (bit)%(32))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! pow(2, (bit)%(32)) -> %l0
	set -24, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mask <- %l0
	set -28, %l6	! AddressOf(mask = pow(2, (bit)%(32))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mask = pow(2, (bit)%(32)) <- %l0
	
	! BITVECTOR.vectors
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -32, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[index]
	set -32, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -8, %l6	! AddressOf(index) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! index -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error24
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error25
	nop
._rtc_array_bounds_error24:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error25:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -36, %l6	! AddressOf(BITVECTOR.vectors[index]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[index] <- %l0
	
	! (BITVECTOR.vectors[index])&(mask)
	set -36, %l6	! AddressOf(BITVECTOR.vectors[index]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! BITVECTOR.vectors[index] -> %l0
	set -24, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! mask -> %l1
	and %l0, %l1, %l0
	set -40, %l6	! AddressOf((BITVECTOR.vectors[index])&(mask)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (BITVECTOR.vectors[index])&(mask) <- %l0
	
	! ((BITVECTOR.vectors[index])&(mask))==(mask)
	set -40, %l6	! AddressOf((BITVECTOR.vectors[index])&(mask)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (BITVECTOR.vectors[index])&(mask) -> %l0
	set -24, %l6	! AddressOf(mask) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! mask -> %l1
	cmp %l0, %l1
	be ._be26
	mov 1, %l0
	mov 0, %l0
._be26:
	set -44, %l6	! AddressOf(((BITVECTOR.vectors[index])&(mask))==(mask)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((BITVECTOR.vectors[index])&(mask))==(mask) <- %l0
	
	! return ((BITVECTOR.vectors[index])&(mask))==(mask)
	set -44, %l6	! AddressOf(((BITVECTOR.vectors[index])&(mask))==(mask)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %i0	! ((BITVECTOR.vectors[index])&(mask))==(mask) -> %i0
	ret
	restore

! BITVECTOR.setBit function
! ===========================================================
BITVECTOR.setBit:
	set -(92 + 44) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! (bit)/(32)
	set 68, %l6	! AddressOf(bit) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! bit -> %o0
	set 32, %o1	! 32 -> %o1
	call .div, 2
	nop
	set -4, %l6	! AddressOf((bit)/(32)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (bit)/(32) <- %o0
	
	! index = (bit)/(32)
	set -4, %l6	! AddressOf((bit)/(32)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (bit)/(32) -> %l0
	set -8, %l6	! AddressOf(index) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! index <- %l0
	set -12, %l6	! AddressOf(index = (bit)/(32)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! index = (bit)/(32) <- %l0
	
	! BITVECTOR.vectors
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -16, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[index]
	set -16, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -8, %l6	! AddressOf(index) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! index -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error27
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error28
	nop
._rtc_array_bounds_error27:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error28:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -20, %l6	! AddressOf(BITVECTOR.vectors[index]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[index] <- %l0
	
	! BITVECTOR.vectors
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -24, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[index]
	set -24, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -8, %l6	! AddressOf(index) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! index -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error29
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error30
	nop
._rtc_array_bounds_error29:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error30:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -28, %l6	! AddressOf(BITVECTOR.vectors[index]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[index] <- %l0
	
	! (bit)%(32)
	set 68, %l6	! AddressOf(bit) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! bit -> %o0
	set 32, %o1	! 32 -> %o1
	call .rem, 2
	nop
	set -32, %l6	! AddressOf((bit)%(32)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (bit)%(32) <- %o0
	
	! pow(2, (bit)%(32))
	set 2, %l0	! 2 -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -32, %l6	! AddressOf((bit)%(32)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (bit)%(32) -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call pow, 2
	nop
	set -36, %l6	! AddressOf(pow(2, (bit)%(32))) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! pow(2, (bit)%(32)) <- %o0
	
	! (BITVECTOR.vectors[index])|(pow(2, (bit)%(32)))
	set -28, %l6	! AddressOf(BITVECTOR.vectors[index]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! BITVECTOR.vectors[index] -> %l0
	set -36, %l6	! AddressOf(pow(2, (bit)%(32))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! pow(2, (bit)%(32)) -> %l1
	or %l0, %l1, %l0
	set -40, %l6	! AddressOf((BITVECTOR.vectors[index])|(pow(2, (bit)%(32)))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (BITVECTOR.vectors[index])|(pow(2, (bit)%(32))) <- %l0
	
	! BITVECTOR.vectors[index] = (BITVECTOR.vectors[index])|(pow(2, (bit)%(32)))
	set -40, %l6	! AddressOf((BITVECTOR.vectors[index])|(pow(2, (bit)%(32)))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (BITVECTOR.vectors[index])|(pow(2, (bit)%(32))) -> %l0
	set -20, %l6	! AddressOf(BITVECTOR.vectors[index]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! BITVECTOR.vectors[index] <- %l0
	set -44, %l6	! AddressOf(BITVECTOR.vectors[index] = (BITVECTOR.vectors[index])|(pow(2, (bit)%(32)))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[index] = (BITVECTOR.vectors[index])|(pow(2, (bit)%(32))) <- %l0
	
	ret
	restore

! BITVECTOR.getUnion function
! ===========================================================
BITVECTOR.getUnion:
	set -(92 + 48) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! i = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	set -8, %l6	! AddressOf(i = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i = 0 <- %l0
	
._whilestart31:
	! (i)<((maxMinterms)/(32))
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set 32, %l1	! (maxMinterms)/(32) -> %l1
	cmp %l0, %l1
	bl ._bl33
	mov 1, %l0
	mov 0, %l0
._bl33:
	set -12, %l6	! AddressOf((i)<((maxMinterms)/(32))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)<((maxMinterms)/(32)) <- %l0
	
	set -12, %l6	! AddressOf((i)<((maxMinterms)/(32))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)<((maxMinterms)/(32)) -> %l0
	cmp %l0, 0
	be ._whileend32
	nop
	
	! BITVECTOR.vectors
	set 72, %l0	! AddressOf(result) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -16, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[i]
	set -16, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error34
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error35
	nop
._rtc_array_bounds_error34:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error35:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -20, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	
	! BITVECTOR.vectors
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -24, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[i]
	set -24, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error36
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error37
	nop
._rtc_array_bounds_error36:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error37:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -28, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	
	! BITVECTOR.vectors
	set 68, %l0	! AddressOf(other) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -32, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[i]
	set -32, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error38
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error39
	nop
._rtc_array_bounds_error38:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error39:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -36, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	
	! (BITVECTOR.vectors[i])|(BITVECTOR.vectors[i])
	set -28, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! BITVECTOR.vectors[i] -> %l0
	set -36, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! BITVECTOR.vectors[i] -> %l1
	or %l0, %l1, %l0
	set -40, %l6	! AddressOf((BITVECTOR.vectors[i])|(BITVECTOR.vectors[i])) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (BITVECTOR.vectors[i])|(BITVECTOR.vectors[i]) <- %l0
	
	! BITVECTOR.vectors[i] = (BITVECTOR.vectors[i])|(BITVECTOR.vectors[i])
	set -40, %l6	! AddressOf((BITVECTOR.vectors[i])|(BITVECTOR.vectors[i])) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (BITVECTOR.vectors[i])|(BITVECTOR.vectors[i]) -> %l0
	set -20, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	set -44, %l6	! AddressOf(BITVECTOR.vectors[i] = (BITVECTOR.vectors[i])|(BITVECTOR.vectors[i])) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] = (BITVECTOR.vectors[i])|(BITVECTOR.vectors[i]) <- %l0
	
	! ++(i)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -48, %l6	! AddressOf(++(i)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(i) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	
	ba ._whilestart31
	nop
._whileend32:
	ret
	restore

! BITVECTOR.getIntersection function
! ===========================================================
BITVECTOR.getIntersection:
	set -(92 + 48) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! i = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	set -8, %l6	! AddressOf(i = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i = 0 <- %l0
	
._whilestart40:
	! (i)<((maxMinterms)/(32))
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set 32, %l1	! (maxMinterms)/(32) -> %l1
	cmp %l0, %l1
	bl ._bl42
	mov 1, %l0
	mov 0, %l0
._bl42:
	set -12, %l6	! AddressOf((i)<((maxMinterms)/(32))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)<((maxMinterms)/(32)) <- %l0
	
	set -12, %l6	! AddressOf((i)<((maxMinterms)/(32))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)<((maxMinterms)/(32)) -> %l0
	cmp %l0, 0
	be ._whileend41
	nop
	
	! BITVECTOR.vectors
	set 72, %l0	! AddressOf(result) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -16, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[i]
	set -16, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error43
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error44
	nop
._rtc_array_bounds_error43:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error44:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -20, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	
	! BITVECTOR.vectors
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -24, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[i]
	set -24, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error45
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error46
	nop
._rtc_array_bounds_error45:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error46:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -28, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	
	! BITVECTOR.vectors
	set 68, %l0	! AddressOf(other) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -32, %l6	! AddressOf(BITVECTOR.vectors) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors <- %l0
	
	! BITVECTOR.vectors[i]
	set -32, %l0	! AddressOf(BITVECTOR.vectors) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i -> %o0
	set 32, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error47
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error48
	nop
._rtc_array_bounds_error47:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error48:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -36, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	
	! (BITVECTOR.vectors[i])&(BITVECTOR.vectors[i])
	set -28, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! BITVECTOR.vectors[i] -> %l0
	set -36, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! BITVECTOR.vectors[i] -> %l1
	and %l0, %l1, %l0
	set -40, %l6	! AddressOf((BITVECTOR.vectors[i])&(BITVECTOR.vectors[i])) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (BITVECTOR.vectors[i])&(BITVECTOR.vectors[i]) <- %l0
	
	! BITVECTOR.vectors[i] = (BITVECTOR.vectors[i])&(BITVECTOR.vectors[i])
	set -40, %l6	! AddressOf((BITVECTOR.vectors[i])&(BITVECTOR.vectors[i])) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (BITVECTOR.vectors[i])&(BITVECTOR.vectors[i]) -> %l0
	set -20, %l6	! AddressOf(BITVECTOR.vectors[i]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] <- %l0
	set -44, %l6	! AddressOf(BITVECTOR.vectors[i] = (BITVECTOR.vectors[i])&(BITVECTOR.vectors[i])) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! BITVECTOR.vectors[i] = (BITVECTOR.vectors[i])&(BITVECTOR.vectors[i]) <- %l0
	
	! ++(i)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -48, %l6	! AddressOf(++(i)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(i) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	
	ba ._whilestart40
	nop
._whileend41:
	ret
	restore

! VECTOR.addItem function
! ===========================================================
VECTOR.addItem:
	set -(92 + 20) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! VECTOR.items
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -4, %l6	! AddressOf(VECTOR.items) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items <- %l0
	
	! VECTOR.count
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 23620, %l1
	add %l0, %l1, %l0
	set -8, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.count <- %l0
	
	! ++(VECTOR.count)
	set -8, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! VECTOR.count -> %l0
	set -12, %l6	! AddressOf(++(VECTOR.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(VECTOR.count) <- %l0
	inc %l0
	set -8, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! VECTOR.count <- %l0
	
	! VECTOR.items[++(VECTOR.count)]
	set -4, %l0	! AddressOf(VECTOR.items) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -12, %l6	! AddressOf(++(VECTOR.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! ++(VECTOR.count) -> %o0
	set 5905, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error49
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error50
	nop
._rtc_array_bounds_error49:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error50:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -16, %l6	! AddressOf(VECTOR.items[++(VECTOR.count)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items[++(VECTOR.count)] <- %l0
	
	! VECTOR.items[++(VECTOR.count)] = item
	set 68, %l6	! AddressOf(item) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! item -> %l0
	set -16, %l6	! AddressOf(VECTOR.items[++(VECTOR.count)]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! VECTOR.items[++(VECTOR.count)] <- %l0
	set -20, %l6	! AddressOf(VECTOR.items[++(VECTOR.count)] = item) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items[++(VECTOR.count)] = item <- %l0
	
	ret
	restore

! ROW.matchAgainst function
! ===========================================================
ROW.matchAgainst:
	set -(92 + 168) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! ROW.implicant
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -4, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	
	! i1 = ROW.implicant
	set -4, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! ROW.implicant -> %l0
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i1 <- %l0
	set -12, %l6	! AddressOf(i1 = ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i1 = ROW.implicant <- %l0
	
	! ROW.implicant
	set 68, %l0	! AddressOf(row) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -16, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	
	! i2 = ROW.implicant
	set -16, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! ROW.implicant -> %l0
	set -20, %l6	! AddressOf(i2) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i2 <- %l0
	set -24, %l6	! AddressOf(i2 = ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i2 = ROW.implicant <- %l0
	
	! difs = 0
	set 0, %l0	! 0 -> %l0
	set -28, %l6	! AddressOf(difs) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! difs <- %l0
	set -32, %l6	! AddressOf(difs = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! difs = 0 <- %l0
	
	! implicant = 0
	set 0, %l0	! 0 -> %l0
	set 72, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! implicant <- %l0
	set -36, %l6	! AddressOf(implicant = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! implicant = 0 <- %l0
	
	! pos = 1
	set 1, %l0	! 1 -> %l0
	set -40, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos <- %l0
	set -44, %l6	! AddressOf(pos = 1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos = 1 <- %l0
	
._whilestart51:
	! (i1)>(0)
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i1 -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bg ._bg53
	mov 1, %l0
	mov 0, %l0
._bg53:
	set -48, %l6	! AddressOf((i1)>(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i1)>(0) <- %l0
	
	set -48, %l6	! AddressOf((i1)>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i1)>(0) -> %l0
	cmp %l0, 1
	be ._shortcircuit54
	nop
	
	! (i2)>(0)
	set -20, %l6	! AddressOf(i2) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i2 -> %l0
	set 0, %l1	! 0 -> %l1
	cmp %l0, %l1
	bg ._bg55
	mov 1, %l0
	mov 0, %l0
._bg55:
	set -52, %l6	! AddressOf((i2)>(0)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i2)>(0) <- %l0
	
	! ((i1)>(0))||((i2)>(0))
._shortcircuit54:
	set -48, %l6	! AddressOf((i1)>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i1)>(0) -> %l0
	set -52, %l6	! AddressOf((i2)>(0)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! (i2)>(0) -> %l1
	or %l0, %l1, %l0
	and %l0, 1, %l0
	set -56, %l6	! AddressOf(((i1)>(0))||((i2)>(0))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((i1)>(0))||((i2)>(0)) <- %l0
	
	set -56, %l6	! AddressOf(((i1)>(0))||((i2)>(0))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((i1)>(0))||((i2)>(0)) -> %l0
	cmp %l0, 0
	be ._whileend52
	nop
	
	! (i1)&(3)
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i1 -> %l0
	set 3, %l1	! 3 -> %l1
	and %l0, %l1, %l0
	set -60, %l6	! AddressOf((i1)&(3)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i1)&(3) <- %l0
	
	! (i2)&(3)
	set -20, %l6	! AddressOf(i2) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i2 -> %l0
	set 3, %l1	! 3 -> %l1
	and %l0, %l1, %l0
	set -64, %l6	! AddressOf((i2)&(3)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i2)&(3) <- %l0
	
	! ((i1)&(3))!=((i2)&(3))
	set -60, %l6	! AddressOf((i1)&(3)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i1)&(3) -> %l0
	set -64, %l6	! AddressOf((i2)&(3)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! (i2)&(3) -> %l1
	cmp %l0, %l1
	bne ._bne56
	mov 1, %l0
	mov 0, %l0
._bne56:
	set -68, %l6	! AddressOf(((i1)&(3))!=((i2)&(3))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((i1)&(3))!=((i2)&(3)) <- %l0
	
	! if (((i1)&(3))!=((i2)&(3)))
	set -68, %l6	! AddressOf(((i1)&(3))!=((i2)&(3))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((i1)&(3))!=((i2)&(3)) -> %l0
	cmp %l0, %g0
	be ._else57
	nop
	! (i1)&(3)
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i1 -> %l0
	set 3, %l1	! 3 -> %l1
	and %l0, %l1, %l0
	set -72, %l6	! AddressOf((i1)&(3)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i1)&(3) <- %l0
	
	! ((i1)&(3))==(2)
	set -72, %l6	! AddressOf((i1)&(3)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i1)&(3) -> %l0
	set 2, %l1	! 2 -> %l1
	cmp %l0, %l1
	be ._be59
	mov 1, %l0
	mov 0, %l0
._be59:
	set -76, %l6	! AddressOf(((i1)&(3))==(2)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((i1)&(3))==(2) <- %l0
	
	set -76, %l6	! AddressOf(((i1)&(3))==(2)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((i1)&(3))==(2) -> %l0
	cmp %l0, 1
	be ._shortcircuit60
	nop
	
	! (i2)&(3)
	set -20, %l6	! AddressOf(i2) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i2 -> %l0
	set 3, %l1	! 3 -> %l1
	and %l0, %l1, %l0
	set -80, %l6	! AddressOf((i2)&(3)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i2)&(3) <- %l0
	
	! ((i2)&(3))==(2)
	set -80, %l6	! AddressOf((i2)&(3)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i2)&(3) -> %l0
	set 2, %l1	! 2 -> %l1
	cmp %l0, %l1
	be ._be61
	mov 1, %l0
	mov 0, %l0
._be61:
	set -84, %l6	! AddressOf(((i2)&(3))==(2)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((i2)&(3))==(2) <- %l0
	
	! (((i1)&(3))==(2))||(((i2)&(3))==(2))
._shortcircuit60:
	set -76, %l6	! AddressOf(((i1)&(3))==(2)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((i1)&(3))==(2) -> %l0
	set -84, %l6	! AddressOf(((i2)&(3))==(2)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! ((i2)&(3))==(2) -> %l1
	or %l0, %l1, %l0
	and %l0, 1, %l0
	set -88, %l6	! AddressOf((((i1)&(3))==(2))||(((i2)&(3))==(2))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (((i1)&(3))==(2))||(((i2)&(3))==(2)) <- %l0
	
	set -88, %l6	! AddressOf((((i1)&(3))==(2))||(((i2)&(3))==(2))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (((i1)&(3))==(2))||(((i2)&(3))==(2)) -> %l0
	cmp %l0, 1
	be ._shortcircuit62
	nop
	
	! (difs)==(1)
	set -28, %l6	! AddressOf(difs) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! difs -> %l0
	set 1, %l1	! 1 -> %l1
	cmp %l0, %l1
	be ._be63
	mov 1, %l0
	mov 0, %l0
._be63:
	set -92, %l6	! AddressOf((difs)==(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (difs)==(1) <- %l0
	
	! ((((i1)&(3))==(2))||(((i2)&(3))==(2)))||((difs)==(1))
._shortcircuit62:
	set -88, %l6	! AddressOf((((i1)&(3))==(2))||(((i2)&(3))==(2))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (((i1)&(3))==(2))||(((i2)&(3))==(2)) -> %l0
	set -92, %l6	! AddressOf((difs)==(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! (difs)==(1) -> %l1
	or %l0, %l1, %l0
	and %l0, 1, %l0
	set -96, %l6	! AddressOf(((((i1)&(3))==(2))||(((i2)&(3))==(2)))||((difs)==(1))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ((((i1)&(3))==(2))||(((i2)&(3))==(2)))||((difs)==(1)) <- %l0
	
	! if (((((i1)&(3))==(2))||(((i2)&(3))==(2)))||((difs)==(1)))
	set -96, %l6	! AddressOf(((((i1)&(3))==(2))||(((i2)&(3))==(2)))||((difs)==(1))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ((((i1)&(3))==(2))||(((i2)&(3))==(2)))||((difs)==(1)) -> %l0
	cmp %l0, %g0
	be ._else64
	nop
	! return false
	set 0, %i0	! false -> %i0
	ret
	restore
	ba ._endif65
	nop
._else64:
._endif65:
	! difs = 1
	set 1, %l0	! 1 -> %l0
	set -28, %l6	! AddressOf(difs) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! difs <- %l0
	set -100, %l6	! AddressOf(difs = 1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! difs = 1 <- %l0
	
	! (2)*(pos)
	set 2, %o0	! 2 -> %o0
	set -40, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! pos -> %o1
	call .mul, 2
	nop
	set -104, %l6	! AddressOf((2)*(pos)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (2)*(pos) <- %o0
	
	! (implicant)+((2)*(pos))
	set 72, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! implicant -> %l0
	set -104, %l6	! AddressOf((2)*(pos)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! (2)*(pos) -> %l1
	add %l0, %l1, %l0
	set -108, %l6	! AddressOf((implicant)+((2)*(pos))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (implicant)+((2)*(pos)) <- %l0
	
	! implicant = (implicant)+((2)*(pos))
	set -108, %l6	! AddressOf((implicant)+((2)*(pos))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (implicant)+((2)*(pos)) -> %l0
	set 72, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! implicant <- %l0
	set -112, %l6	! AddressOf(implicant = (implicant)+((2)*(pos))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! implicant = (implicant)+((2)*(pos)) <- %l0
	
	ba ._endif58
	nop
._else57:
	! (i1)&(3)
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i1 -> %l0
	set 3, %l1	! 3 -> %l1
	and %l0, %l1, %l0
	set -116, %l6	! AddressOf((i1)&(3)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i1)&(3) <- %l0
	
	! ((i1)&(3))*(pos)
	set -116, %l6	! AddressOf((i1)&(3)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! (i1)&(3) -> %o0
	set -40, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! pos -> %o1
	call .mul, 2
	nop
	set -120, %l6	! AddressOf(((i1)&(3))*(pos)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! ((i1)&(3))*(pos) <- %o0
	
	! (implicant)+(((i1)&(3))*(pos))
	set 72, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! implicant -> %l0
	set -120, %l6	! AddressOf(((i1)&(3))*(pos)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! ((i1)&(3))*(pos) -> %l1
	add %l0, %l1, %l0
	set -124, %l6	! AddressOf((implicant)+(((i1)&(3))*(pos))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (implicant)+(((i1)&(3))*(pos)) <- %l0
	
	! implicant = (implicant)+(((i1)&(3))*(pos))
	set -124, %l6	! AddressOf((implicant)+(((i1)&(3))*(pos))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (implicant)+(((i1)&(3))*(pos)) -> %l0
	set 72, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! implicant <- %l0
	set -128, %l6	! AddressOf(implicant = (implicant)+(((i1)&(3))*(pos))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! implicant = (implicant)+(((i1)&(3))*(pos)) <- %l0
	
._endif58:
	! (pos)*(4)
	set -40, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! pos -> %o0
	set 4, %o1	! 4 -> %o1
	call .mul, 2
	nop
	set -132, %l6	! AddressOf((pos)*(4)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (pos)*(4) <- %o0
	
	! pos = (pos)*(4)
	set -132, %l6	! AddressOf((pos)*(4)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (pos)*(4) -> %l0
	set -40, %l6	! AddressOf(pos) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos <- %l0
	set -136, %l6	! AddressOf(pos = (pos)*(4)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! pos = (pos)*(4) <- %l0
	
	! (i1)/(4)
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i1 -> %o0
	set 4, %o1	! 4 -> %o1
	call .div, 2
	nop
	set -140, %l6	! AddressOf((i1)/(4)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (i1)/(4) <- %o0
	
	! i1 = (i1)/(4)
	set -140, %l6	! AddressOf((i1)/(4)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i1)/(4) -> %l0
	set -8, %l6	! AddressOf(i1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i1 <- %l0
	set -144, %l6	! AddressOf(i1 = (i1)/(4)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i1 = (i1)/(4) <- %l0
	
	! (i2)/(4)
	set -20, %l6	! AddressOf(i2) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! i2 -> %o0
	set 4, %o1	! 4 -> %o1
	call .div, 2
	nop
	set -148, %l6	! AddressOf((i2)/(4)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (i2)/(4) <- %o0
	
	! i2 = (i2)/(4)
	set -148, %l6	! AddressOf((i2)/(4)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i2)/(4) -> %l0
	set -20, %l6	! AddressOf(i2) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i2 <- %l0
	set -152, %l6	! AddressOf(i2 = (i2)/(4)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i2 = (i2)/(4) <- %l0
	
	ba ._whilestart51
	nop
._whileend52:
	! ROW.covered
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 132, %l1
	add %l0, %l1, %l0
	set -156, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.covered <- %l0
	
	! ROW.covered
	set 68, %l0	! AddressOf(row) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 132, %l1
	add %l0, %l1, %l0
	set -160, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.covered <- %l0
	
	! ROW.covered = true
	set 1, %l0	! true -> %l0
	set -160, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! ROW.covered <- %l0
	set -164, %l6	! AddressOf(ROW.covered = true) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.covered = true <- %l0
	
	! ROW.covered = ROW.covered = true
	set -164, %l6	! AddressOf(ROW.covered = true) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! ROW.covered = true -> %l0
	set -156, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! ROW.covered <- %l0
	set -168, %l6	! AddressOf(ROW.covered = ROW.covered = true) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.covered = ROW.covered = true <- %l0
	
	! return true
	set 1, %i0	! true -> %i0
	ret
	restore

! ROW.print function
! ===========================================================
ROW.print:
	set -(92 + 8) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! cout printing
	set .stringFmt, %o0
	set .___string1, %o1
	call printf, 2
	nop
	
	! ROW.implicant
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -4, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	
	! printImplicant(ROW.implicant, numVars)
	set -4, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! ROW.implicant -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set 68, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call printImplicant, 2
	nop
	
	! cout  
	set .stringFmt, %o0
	set .___string2, %o1
	call printf, 2
	nop
	
	! ROW.covered
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 132, %l1
	add %l0, %l1, %l0
	set -8, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.covered <- %l0
	
	! cout ROW.covered
	set -8, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! ROW.covered -> %l1
	mov %l1, %o1
	call .mul, 2
	set 6, %o0
	set .boolStr, %l1
	call printf, 0
	add %o0, %l1, %o0
	
	! cout endl
	set .endl, %o0
	call printf, 1
	nop
	
	ret
	restore

! GROUP.addRow function
! ===========================================================
GROUP.addRow:
	set -(92 + 24) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! GROUP.rows
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -4, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! GROUP.count
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 139264, %l1
	add %l0, %l1, %l0
	set -8, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! ++(GROUP.count)
	set -8, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! GROUP.count -> %l0
	set -12, %l6	! AddressOf(++(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(GROUP.count) <- %l0
	inc %l0
	set -8, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! GROUP.rows[++(GROUP.count)]
	set -4, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -12, %l6	! AddressOf(++(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! ++(GROUP.count) -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error66
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error67
	nop
._rtc_array_bounds_error66:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error67:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -16, %l6	! AddressOf(GROUP.rows[++(GROUP.count)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[++(GROUP.count)] <- %l0
	
	! ROW.implicant
	set -16, %l0	! AddressOf(GROUP.rows[++(GROUP.count)]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -20, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	
	! ROW.implicant = implicant
	set 68, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! implicant -> %l0
	set -20, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	set -24, %l6	! AddressOf(ROW.implicant = implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant = implicant <- %l0
	
	ret
	restore

! GROUP.print function
! ===========================================================
GROUP.print:
	set -(92 + 36) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! row = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row <- %l0
	set -8, %l6	! AddressOf(row = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row = 0 <- %l0
	
._whilestart68:
	! GROUP.count
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 139264, %l1
	add %l0, %l1, %l0
	set -12, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! (row)<(GROUP.count)
	set -4, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! row -> %l0
	set -12, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! GROUP.count -> %l1
	cmp %l0, %l1
	bl ._bl70
	mov 1, %l0
	mov 0, %l0
._bl70:
	set -16, %l6	! AddressOf((row)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (row)<(GROUP.count) <- %l0
	
	set -16, %l6	! AddressOf((row)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (row)<(GROUP.count) -> %l0
	cmp %l0, 0
	be ._whileend69
	nop
	
	! GROUP.rows
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -20, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! ++(row)
	set -4, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! row -> %l0
	set -24, %l6	! AddressOf(++(row)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(row) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row <- %l0
	
	! GROUP.rows[++(row)]
	set -20, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -24, %l6	! AddressOf(++(row)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! ++(row) -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error71
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error72
	nop
._rtc_array_bounds_error71:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error72:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -28, %l6	! AddressOf(GROUP.rows[++(row)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[++(row)] <- %l0
	
	! ROW.print
	set -28, %l1	! AddressOf(GROUP.rows[++(row)]) ->%l1
	add %l1, %fp, %l1
	ld [%l1], %l1
	set ROW.print, %l0
	set -36, %l2	! AddressOf(ROW.print) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! ROW.print(numVars)
	set 68, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -36, %l0	! AddressOf(ROW.print) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 1
	nop
	
	ba ._whilestart68
	nop
._whileend69:
	ret
	restore

! TABLE.addToGroup function
! ===========================================================
TABLE.addToGroup:
	set -(92 + 16) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -4, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -4, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 68, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error73
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error74
	nop
._rtc_array_bounds_error73:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error74:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -8, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.addRow
	set -8, %l1	! AddressOf(TABLE.groups[group]) ->%l1
	add %l1, %fp, %l1
	ld [%l1], %l1
	set GROUP.addRow, %l0
	set -16, %l2	! AddressOf(GROUP.addRow) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! GROUP.addRow(i)
	set 72, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -16, %l0	! AddressOf(GROUP.addRow) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 1
	nop
	
	ret
	restore

! TABLE.generateNextTable function
! ===========================================================
TABLE.generateNextTable:
	set -(92 + 316) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! group = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group <- %l0
	set -20, %l6	! AddressOf(group = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group = 0 <- %l0
	
._whilestart75:
	! (group)<(varMax)
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set 10, %l1	! varMax -> %l1
	cmp %l0, %l1
	bl ._bl77
	mov 1, %l0
	mov 0, %l0
._bl77:
	set -24, %l6	! AddressOf((group)<(varMax)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (group)<(varMax) <- %l0
	
	set -24, %l6	! AddressOf((group)<(varMax)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (group)<(varMax) -> %l0
	cmp %l0, 0
	be ._whileend76
	nop
	
	! row = 0
	set 0, %l0	! 0 -> %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row <- %l0
	set -28, %l6	! AddressOf(row = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row = 0 <- %l0
	
._whilestart78:
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -32, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -32, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error80
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error81
	nop
._rtc_array_bounds_error80:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error81:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -36, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.count
	set -36, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 139264, %l1
	add %l0, %l1, %l0
	set -40, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! (row)<(GROUP.count)
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! row -> %l0
	set -40, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! GROUP.count -> %l1
	cmp %l0, %l1
	bl ._bl82
	mov 1, %l0
	mov 0, %l0
._bl82:
	set -44, %l6	! AddressOf((row)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (row)<(GROUP.count) <- %l0
	
	set -44, %l6	! AddressOf((row)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (row)<(GROUP.count) -> %l0
	cmp %l0, 0
	be ._whileend79
	nop
	
	! nextGrpRow = 0
	set 0, %l0	! 0 -> %l0
	set -12, %l6	! AddressOf(nextGrpRow) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! nextGrpRow <- %l0
	set -48, %l6	! AddressOf(nextGrpRow = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! nextGrpRow = 0 <- %l0
	
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -52, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -52, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error83
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error84
	nop
._rtc_array_bounds_error83:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error84:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -56, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.rows
	set -56, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -60, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! GROUP.rows[row]
	set -60, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! row -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error85
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error86
	nop
._rtc_array_bounds_error85:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error86:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -64, %l6	! AddressOf(GROUP.rows[row]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[row] <- %l0
	
	! ROW.matchAgainst
	set -64, %l1	! AddressOf(GROUP.rows[row]) ->%l1
	add %l1, %fp, %l1
	ld [%l1], %l1
	set ROW.matchAgainst, %l0
	set -72, %l2	! AddressOf(ROW.matchAgainst) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! matcher = ROW.matchAgainst
	set -72, %l0	! AddressOf(ROW.matchAgainst) ->%l0
	add %l0, %fp, %l0
	set -80, %l1	! AddressOf(matcher) ->%l1
	add %l1, %fp, %l1
	set -88, %l2	! AddressOf(matcher = ROW.matchAgainst) ->%l2
	add %l2, %fp, %l2
	ld [%l0], %l3
	st %l3, [%l1]
	st %l3, [%l2]
	ld [%l0+4], %l3
	st %l3, [%l1+4]
	st %l3, [%l2+4]
	
._whilestart87:
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -92, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! (group)+(1)
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set 1, %l1	! 1 -> %l1
	add %l0, %l1, %l0
	set -96, %l6	! AddressOf((group)+(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (group)+(1) <- %l0
	
	! TABLE.groups[(group)+(1)]
	set -92, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -96, %l6	! AddressOf((group)+(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! (group)+(1) -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error89
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error90
	nop
._rtc_array_bounds_error89:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error90:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -100, %l6	! AddressOf(TABLE.groups[(group)+(1)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[(group)+(1)] <- %l0
	
	! GROUP.count
	set -100, %l0	! AddressOf(TABLE.groups[(group)+(1)]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 139264, %l1
	add %l0, %l1, %l0
	set -104, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! (nextGrpRow)<(GROUP.count)
	set -12, %l6	! AddressOf(nextGrpRow) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! nextGrpRow -> %l0
	set -104, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! GROUP.count -> %l1
	cmp %l0, %l1
	bl ._bl91
	mov 1, %l0
	mov 0, %l0
._bl91:
	set -108, %l6	! AddressOf((nextGrpRow)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (nextGrpRow)<(GROUP.count) <- %l0
	
	set -108, %l6	! AddressOf((nextGrpRow)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (nextGrpRow)<(GROUP.count) -> %l0
	cmp %l0, 0
	be ._whileend88
	nop
	
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -112, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! (group)+(1)
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set 1, %l1	! 1 -> %l1
	add %l0, %l1, %l0
	set -116, %l6	! AddressOf((group)+(1)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (group)+(1) <- %l0
	
	! TABLE.groups[(group)+(1)]
	set -112, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -116, %l6	! AddressOf((group)+(1)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! (group)+(1) -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error92
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error93
	nop
._rtc_array_bounds_error92:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error93:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -120, %l6	! AddressOf(TABLE.groups[(group)+(1)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[(group)+(1)] <- %l0
	
	! GROUP.rows
	set -120, %l0	! AddressOf(TABLE.groups[(group)+(1)]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -124, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! GROUP.rows[nextGrpRow]
	set -124, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -12, %l6	! AddressOf(nextGrpRow) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! nextGrpRow -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error94
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error95
	nop
._rtc_array_bounds_error94:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error95:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -128, %l6	! AddressOf(GROUP.rows[nextGrpRow]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[nextGrpRow] <- %l0
	
	! matcher(GROUP.rows[nextGrpRow], implicant)
	set -128, %l0	! AddressOf(GROUP.rows[nextGrpRow]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -16, %l0	! AddressOf(implicant) ->%l0
	add %l0, %fp, %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -80, %l0	! AddressOf(matcher) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 2
	nop
	set -132, %l6	! AddressOf(matcher(GROUP.rows[nextGrpRow], implicant)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! matcher(GROUP.rows[nextGrpRow], implicant) <- %o0
	
	! if (matcher(GROUP.rows[nextGrpRow], implicant))
	set -132, %l6	! AddressOf(matcher(GROUP.rows[nextGrpRow], implicant)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! matcher(GROUP.rows[nextGrpRow], implicant) -> %l0
	cmp %l0, %g0
	be ._else96
	nop
	! dup = false
	set 0, %l0	! false -> %l0
	set -136, %l6	! AddressOf(dup) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! dup <- %l0
	set -140, %l6	! AddressOf(dup = false) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! dup = false <- %l0
	
	! nr = 0
	set 0, %l0	! 0 -> %l0
	set -144, %l6	! AddressOf(nr) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! nr <- %l0
	set -148, %l6	! AddressOf(nr = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! nr = 0 <- %l0
	
._whilestart98:
	! TABLE.groups
	set 76, %l6	! AddressOf(nextTbl) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! nextTbl -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -152, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -152, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error100
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error101
	nop
._rtc_array_bounds_error100:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error101:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -156, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.count
	set -156, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 139264, %l1
	add %l0, %l1, %l0
	set -160, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! (nr)<(GROUP.count)
	set -144, %l6	! AddressOf(nr) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! nr -> %l0
	set -160, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! GROUP.count -> %l1
	cmp %l0, %l1
	bl ._bl102
	mov 1, %l0
	mov 0, %l0
._bl102:
	set -164, %l6	! AddressOf((nr)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (nr)<(GROUP.count) <- %l0
	
	set -164, %l6	! AddressOf((nr)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (nr)<(GROUP.count) -> %l0
	cmp %l0, 0
	be ._whileend99
	nop
	
	! TABLE.groups
	set 76, %l6	! AddressOf(nextTbl) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! nextTbl -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -168, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -168, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error103
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error104
	nop
._rtc_array_bounds_error103:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error104:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -172, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.rows
	set -172, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -176, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! GROUP.rows[nr]
	set -176, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -144, %l6	! AddressOf(nr) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! nr -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error105
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error106
	nop
._rtc_array_bounds_error105:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error106:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -180, %l6	! AddressOf(GROUP.rows[nr]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[nr] <- %l0
	
	! ROW.implicant
	set -180, %l0	! AddressOf(GROUP.rows[nr]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -184, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	
	! (ROW.implicant)==(implicant)
	set -184, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! ROW.implicant -> %l0
	set -16, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! implicant -> %l1
	cmp %l0, %l1
	be ._be107
	mov 1, %l0
	mov 0, %l0
._be107:
	set -188, %l6	! AddressOf((ROW.implicant)==(implicant)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (ROW.implicant)==(implicant) <- %l0
	
	! if ((ROW.implicant)==(implicant))
	set -188, %l6	! AddressOf((ROW.implicant)==(implicant)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (ROW.implicant)==(implicant) -> %l0
	cmp %l0, %g0
	be ._else108
	nop
	! dup = true
	set 1, %l0	! true -> %l0
	set -136, %l6	! AddressOf(dup) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! dup <- %l0
	set -192, %l6	! AddressOf(dup = true) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! dup = true <- %l0
	
	ba ._whileend99
	nop
	ba ._endif109
	nop
._else108:
._endif109:
	! ++(nr)
	set -144, %l6	! AddressOf(nr) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! nr -> %l0
	set -196, %l6	! AddressOf(++(nr)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(nr) <- %l0
	inc %l0
	set -144, %l6	! AddressOf(nr) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! nr <- %l0
	
	ba ._whilestart98
	nop
._whileend99:
	! !(dup)
	set -136, %l6	! AddressOf(dup) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! dup -> %l0
	cmp %l0, %g0
	be ._be110
	mov 1, %l0
	mov 0, %l0
._be110:
	set -200, %l6	! AddressOf(!(dup)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! !(dup) <- %l0
	
	! if (!(dup))
	set -200, %l6	! AddressOf(!(dup)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! !(dup) -> %l0
	cmp %l0, %g0
	be ._else111
	nop
	! TABLE.addToGroup
	set 76, %l6	! AddressOf(nextTbl) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! nextTbl -> %l1
	set TABLE.addToGroup, %l0
	set -208, %l2	! AddressOf(TABLE.addToGroup) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! TABLE.addToGroup(group, implicant)
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -16, %l6	! AddressOf(implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! implicant -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -208, %l0	! AddressOf(TABLE.addToGroup) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 2
	nop
	
	ba ._endif112
	nop
._else111:
._endif112:
	ba ._endif97
	nop
._else96:
._endif97:
	! ++(nextGrpRow)
	set -12, %l6	! AddressOf(nextGrpRow) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! nextGrpRow -> %l0
	set -212, %l6	! AddressOf(++(nextGrpRow)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(nextGrpRow) <- %l0
	inc %l0
	set -12, %l6	! AddressOf(nextGrpRow) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! nextGrpRow <- %l0
	
	ba ._whilestart87
	nop
._whileend88:
	! ++(row)
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! row -> %l0
	set -216, %l6	! AddressOf(++(row)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(row) <- %l0
	inc %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row <- %l0
	
	ba ._whilestart78
	nop
._whileend79:
	! ++(group)
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set -220, %l6	! AddressOf(++(group)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(group) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group <- %l0
	
	ba ._whilestart75
	nop
._whileend76:
	! group = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group <- %l0
	set -224, %l6	! AddressOf(group = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group = 0 <- %l0
	
	! allPrimes = true
	set 1, %l0	! true -> %l0
	set 72, %l6	! AddressOf(allPrimes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! allPrimes <- %l0
	set -228, %l6	! AddressOf(allPrimes = true) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! allPrimes = true <- %l0
	
._whilestart113:
	! (group)<((varMax)+(1))
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set 11, %l1	! (varMax)+(1) -> %l1
	cmp %l0, %l1
	bl ._bl115
	mov 1, %l0
	mov 0, %l0
._bl115:
	set -232, %l6	! AddressOf((group)<((varMax)+(1))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (group)<((varMax)+(1)) <- %l0
	
	set -232, %l6	! AddressOf((group)<((varMax)+(1))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (group)<((varMax)+(1)) -> %l0
	cmp %l0, 0
	be ._whileend114
	nop
	
	! row = 0
	set 0, %l0	! 0 -> %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row <- %l0
	set -236, %l6	! AddressOf(row = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row = 0 <- %l0
	
._whilestart116:
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -240, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -240, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error118
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error119
	nop
._rtc_array_bounds_error118:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error119:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -244, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.count
	set -244, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 139264, %l1
	add %l0, %l1, %l0
	set -248, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.count <- %l0
	
	! (row)<(GROUP.count)
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! row -> %l0
	set -248, %l6	! AddressOf(GROUP.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! GROUP.count -> %l1
	cmp %l0, %l1
	bl ._bl120
	mov 1, %l0
	mov 0, %l0
._bl120:
	set -252, %l6	! AddressOf((row)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (row)<(GROUP.count) <- %l0
	
	set -252, %l6	! AddressOf((row)<(GROUP.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (row)<(GROUP.count) -> %l0
	cmp %l0, 0
	be ._whileend117
	nop
	
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -256, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -256, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error121
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error122
	nop
._rtc_array_bounds_error121:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error122:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -260, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.rows
	set -260, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -264, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! GROUP.rows[row]
	set -264, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! row -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error123
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error124
	nop
._rtc_array_bounds_error123:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error124:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -268, %l6	! AddressOf(GROUP.rows[row]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[row] <- %l0
	
	! ROW.covered
	set -268, %l0	! AddressOf(GROUP.rows[row]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 132, %l1
	add %l0, %l1, %l0
	set -272, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.covered <- %l0
	
	! !(ROW.covered)
	set -272, %l6	! AddressOf(ROW.covered) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! ROW.covered -> %l0
	cmp %l0, %g0
	be ._be125
	mov 1, %l0
	mov 0, %l0
._be125:
	set -276, %l6	! AddressOf(!(ROW.covered)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! !(ROW.covered) <- %l0
	
	! if (!(ROW.covered))
	set -276, %l6	! AddressOf(!(ROW.covered)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! !(ROW.covered) -> %l0
	cmp %l0, %g0
	be ._else126
	nop
	! VECTOR.addItem
	set 68, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! primes -> %l1
	set VECTOR.addItem, %l0
	set -284, %l2	! AddressOf(VECTOR.addItem) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -288, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[group]
	set -288, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! group -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error128
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error129
	nop
._rtc_array_bounds_error128:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error129:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -292, %l6	! AddressOf(TABLE.groups[group]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[group] <- %l0
	
	! GROUP.rows
	set -292, %l0	! AddressOf(TABLE.groups[group]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -296, %l6	! AddressOf(GROUP.rows) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows <- %l0
	
	! GROUP.rows[row]
	set -296, %l0	! AddressOf(GROUP.rows) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! row -> %o0
	set 1024, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error130
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error131
	nop
._rtc_array_bounds_error130:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error131:
	set 136, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -300, %l6	! AddressOf(GROUP.rows[row]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! GROUP.rows[row] <- %l0
	
	! ROW.implicant
	set -300, %l0	! AddressOf(GROUP.rows[row]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -304, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ROW.implicant <- %l0
	
	! VECTOR.addItem(ROW.implicant)
	set -304, %l6	! AddressOf(ROW.implicant) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! ROW.implicant -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -284, %l0	! AddressOf(VECTOR.addItem) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 1
	nop
	
	ba ._endif127
	nop
._else126:
	! allPrimes = false
	set 0, %l0	! false -> %l0
	set 72, %l6	! AddressOf(allPrimes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	st %l0, [%l6]	! allPrimes <- %l0
	set -308, %l6	! AddressOf(allPrimes = false) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! allPrimes = false <- %l0
	
._endif127:
	! ++(row)
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! row -> %l0
	set -312, %l6	! AddressOf(++(row)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(row) <- %l0
	inc %l0
	set -8, %l6	! AddressOf(row) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! row <- %l0
	
	ba ._whilestart116
	nop
._whileend117:
	! ++(group)
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set -316, %l6	! AddressOf(++(group)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(group) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group <- %l0
	
	ba ._whilestart113
	nop
._whileend114:
	ret
	restore

! TABLE.print function
! ===========================================================
TABLE.print:
	set -(92 + 44) & -8, %g2
	save %sp, %g2, %sp
	
	mov %g1, %l7
	! cout TABLE
	mov %l7, %o1	! AddressOf(this) -> %o1
	set .pointerFmt, %o0
	call printf, 2
	nop
	
	! cout  
	set .stringFmt, %o0
	set .___string2, %o1
	call printf, 2
	nop
	
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -4, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! TABLE.groups[0]
	set -4, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set 0, %o0	! 0 -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error132
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error133
	nop
._rtc_array_bounds_error132:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error133:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -8, %l6	! AddressOf(TABLE.groups[0]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[0] <- %l0
	
	! &(TABLE.groups[0])
	set -8, %l0	! AddressOf(TABLE.groups[0]) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -12, %l6	! AddressOf(&(TABLE.groups[0])) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! &(TABLE.groups[0]) <- %l0
	
	! cout &(TABLE.groups[0])
	set -12, %l6	! AddressOf(&(TABLE.groups[0])) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! &(TABLE.groups[0]) -> %o1
	set .pointerFmt, %o0
	call printf, 2
	nop
	
	! cout endl
	set .endl, %o0
	call printf, 1
	nop
	
	! group = 0
	set 0, %l0	! 0 -> %l0
	set -16, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group <- %l0
	set -20, %l6	! AddressOf(group = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group = 0 <- %l0
	
._whilestart134:
	! (group)<((varMax)+(1))
	set -16, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set 11, %l1	! (varMax)+(1) -> %l1
	cmp %l0, %l1
	bl ._bl136
	mov 1, %l0
	mov 0, %l0
._bl136:
	set -24, %l6	! AddressOf((group)<((varMax)+(1))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (group)<((varMax)+(1)) <- %l0
	
	set -24, %l6	! AddressOf((group)<((varMax)+(1))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (group)<((varMax)+(1)) -> %l0
	cmp %l0, 0
	be ._whileend135
	nop
	
	! cout G
	set .stringFmt, %o0
	set .___string3, %o1
	call printf, 2
	nop
	
	! cout group
	set -16, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! group -> %o1
	set .intFmt, %o0
	call printf, 2
	nop
	
	! cout :
	set .stringFmt, %o0
	set .___string4, %o1
	call printf, 2
	nop
	
	! cout endl
	set .endl, %o0
	call printf, 1
	nop
	
	! TABLE.groups
	mov %l7, %l0	! AddressOf(this) -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -28, %l6	! AddressOf(TABLE.groups) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups <- %l0
	
	! ++(group)
	set -16, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! group -> %l0
	set -32, %l6	! AddressOf(++(group)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(group) <- %l0
	inc %l0
	set -16, %l6	! AddressOf(group) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! group <- %l0
	
	! TABLE.groups[++(group)]
	set -28, %l0	! AddressOf(TABLE.groups) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -32, %l6	! AddressOf(++(group)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! ++(group) -> %o0
	set 11, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error137
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error138
	nop
._rtc_array_bounds_error137:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error138:
	set 139268, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -36, %l6	! AddressOf(TABLE.groups[++(group)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! TABLE.groups[++(group)] <- %l0
	
	! GROUP.print
	set -36, %l1	! AddressOf(TABLE.groups[++(group)]) ->%l1
	add %l1, %fp, %l1
	ld [%l1], %l1
	set GROUP.print, %l0
	set -44, %l2	! AddressOf(GROUP.print) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! GROUP.print(numVars)
	set 68, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -44, %l0	! AddressOf(GROUP.print) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 1
	nop
	
	ba ._whilestart134
	nop
._whileend135:
	ret
	restore

! prune function
! ===========================================================
prune:
	set -(92 + 28) & -8, %g2
	save %sp, %g2, %sp
	
	! new essentials
	set 23624, %o0
	call .rcfunc_new
	nop
	set -4, %l6	! AddressOf(essentials) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! essentials <- %o0
	
	! new matrix
	set 24186880, %o0
	call .rcfunc_new
	nop
	set -8, %l6	! AddressOf(matrix) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! matrix <- %o0
	
	! changeMade = false
	set 0, %l0	! false -> %l0
	set -12, %l6	! AddressOf(changeMade) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! changeMade <- %l0
	set -16, %l6	! AddressOf(changeMade = false) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! changeMade = false <- %l0
	
	! pow(2, numVars)
	set 2, %l0	! 2 -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set 72, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call pow, 2
	nop
	set -20, %l6	! AddressOf(pow(2, numVars)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! pow(2, numVars) <- %o0
	
	! maxMinterm = pow(2, numVars)
	set -20, %l6	! AddressOf(pow(2, numVars)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! pow(2, numVars) -> %l0
	set -24, %l6	! AddressOf(maxMinterm) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! maxMinterm <- %l0
	set -28, %l6	! AddressOf(maxMinterm = pow(2, numVars)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! maxMinterm = pow(2, numVars) <- %l0
	
	! delete matrix
	set -8, %l6	! AddressOf(matrix) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! matrix -> %o0
	call .rcfunc_delete
	nop
	
	! return essentials
	set -4, %l6	! AddressOf(essentials) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %i0	! essentials -> %i0
	ret
	restore

! main function
! ===========================================================
main:
	set -(92 + 152) & -8, %g2
	save %sp, %g2, %sp
	
	! Check if we already initalized
	set .rc_initialized, %l0
	ld [%l0], %l1
	cmp %l1, 1
	be .main_skip_init
	nop
	
	! Mark that we have initalized
	set 1, %l1
	st %l1, [%l0]
	
	! Call setup with all parameters given to main. (setup will call main)
	mov %i0, %o0
	mov %i0, %o0
	mov %i1, %o1
	mov %i2, %o2
	mov %i3, %o3
	mov %i4, %o4
	mov %i5, %o5
	call .rcfunc_setup
	nop
	
	! .rcfunc_setup will return what main returned.
	mov %o0, %i0
	
	! Call teardown
	call .rcfunc_teardown
	nop
	
	ret
	restore
.main_skip_init:
	
	! mintermCount = 0
	set 0, %l0	! 0 -> %l0
	set -8, %l6	! AddressOf(mintermCount) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mintermCount <- %l0
	set -12, %l6	! AddressOf(mintermCount = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mintermCount = 0 <- %l0
	
	! numVars = 1
	set 1, %l0	! 1 -> %l0
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVars <- %l0
	set -20, %l6	! AddressOf(numVars = 1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVars = 1 <- %l0
	
	! numVarsP = 1
	set 1, %l0	! 1 -> %l0
	set -24, %l6	! AddressOf(numVarsP) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVarsP <- %l0
	set -28, %l6	! AddressOf(numVarsP = 1) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVarsP = 1 <- %l0
	
	! new primes
	set 23624, %o0
	call .rcfunc_new
	nop
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! primes <- %o0
	
	! new currentTable
	set 1531948, %o0
	call .rcfunc_new
	nop
	set -32, %l6	! AddressOf(currentTable) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! currentTable <- %o0
	
._whilestart139:
	set 1, %l0	! true -> %l0
	cmp %l0, 0
	be ._whileend140
	nop
	
	call inputInt, 0
	nop
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! i <- %o0
	! (i)==(-(1))
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -1, %l1	! -(1) -> %l1
	cmp %l0, %l1
	be ._be141
	mov 1, %l0
	mov 0, %l0
._be141:
	set -48, %l6	! AddressOf((i)==(-(1))) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)==(-(1)) <- %l0
	
	! if ((i)==(-(1)))
	set -48, %l6	! AddressOf((i)==(-(1))) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)==(-(1)) -> %l0
	cmp %l0, %g0
	be ._else142
	nop
	ba ._whileend140
	nop
	ba ._endif143
	nop
._else142:
._endif143:
._whilestart144:
	! (i)>(numVarsP)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -24, %l6	! AddressOf(numVarsP) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! numVarsP -> %l1
	cmp %l0, %l1
	bg ._bg146
	mov 1, %l0
	mov 0, %l0
._bg146:
	set -52, %l6	! AddressOf((i)>(numVarsP)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)>(numVarsP) <- %l0
	
	set -52, %l6	! AddressOf((i)>(numVarsP)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)>(numVarsP) -> %l0
	cmp %l0, 0
	be ._whileend145
	nop
	
	! ++(numVars)
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	set -56, %l6	! AddressOf(++(numVars)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(numVars) <- %l0
	inc %l0
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVars <- %l0
	
	! (numVarsP)*(2)
	set -24, %l6	! AddressOf(numVarsP) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! numVarsP -> %o0
	set 2, %o1	! 2 -> %o1
	call .mul, 2
	nop
	set -60, %l6	! AddressOf((numVarsP)*(2)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! (numVarsP)*(2) <- %o0
	
	! numVarsP = (numVarsP)*(2)
	set -60, %l6	! AddressOf((numVarsP)*(2)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (numVarsP)*(2) -> %l0
	set -24, %l6	! AddressOf(numVarsP) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVarsP <- %l0
	set -64, %l6	! AddressOf(numVarsP = (numVarsP)*(2)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVarsP = (numVarsP)*(2) <- %l0
	
	ba ._whilestart144
	nop
._whileend145:
	! TABLE.addToGroup
	set -32, %l6	! AddressOf(currentTable) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! currentTable -> %l1
	set TABLE.addToGroup, %l0
	set -72, %l2	! AddressOf(TABLE.addToGroup) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! count1s(i)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call count1s, 1
	nop
	set -76, %l6	! AddressOf(count1s(i)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! count1s(i) <- %o0
	
	! intToImplicant(i)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call intToImplicant, 1
	nop
	set -80, %l6	! AddressOf(intToImplicant(i)) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! intToImplicant(i) <- %o0
	
	! TABLE.addToGroup(count1s(i), intToImplicant(i))
	set -76, %l6	! AddressOf(count1s(i)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! count1s(i) -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -80, %l6	! AddressOf(intToImplicant(i)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! intToImplicant(i) -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -72, %l0	! AddressOf(TABLE.addToGroup) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 2
	nop
	
	! ++(mintermCount)
	set -8, %l6	! AddressOf(mintermCount) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! mintermCount -> %l0
	set -84, %l6	! AddressOf(++(mintermCount)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(mintermCount) <- %l0
	inc %l0
	set -8, %l6	! AddressOf(mintermCount) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! mintermCount <- %l0
	
	ba ._whilestart139
	nop
._whileend140:
	! --(numVars)
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	set -88, %l6	! AddressOf(--(numVars)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! --(numVars) <- %l0
	dec %l0
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! numVars <- %l0
	
	! cout Number of variables: 
	set .stringFmt, %o0
	set .___string5, %o1
	call printf, 2
	nop
	
	! cout numVars
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o1	! numVars -> %o1
	set .intFmt, %o0
	call printf, 2
	nop
	
	! cout endl
	set .endl, %o0
	call printf, 1
	nop
	
	! allPrimes = false
	set 0, %l0	! false -> %l0
	set -92, %l6	! AddressOf(allPrimes) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! allPrimes <- %l0
	set -96, %l6	! AddressOf(allPrimes = false) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! allPrimes = false <- %l0
	
._whilestart147:
	! !(allPrimes)
	set -92, %l6	! AddressOf(allPrimes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! allPrimes -> %l0
	cmp %l0, %g0
	be ._be149
	mov 1, %l0
	mov 0, %l0
._be149:
	set -100, %l6	! AddressOf(!(allPrimes)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! !(allPrimes) <- %l0
	
	set -100, %l6	! AddressOf(!(allPrimes)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! !(allPrimes) -> %l0
	cmp %l0, 0
	be ._whileend148
	nop
	
	! new nextTable
	set 1531948, %o0
	call .rcfunc_new
	nop
	set -36, %l6	! AddressOf(nextTable) ->%l6
	add %l6, %fp, %l6
	st %o0, [%l6]	! nextTable <- %o0
	
	! TABLE.generateNextTable
	set -32, %l6	! AddressOf(currentTable) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l1	! currentTable -> %l1
	set TABLE.generateNextTable, %l0
	set -108, %l2	! AddressOf(TABLE.generateNextTable) ->%l2
	add %l2, %fp, %l2
	st %l0, [%l2]
	st %l1, [%l2+4]
	
	! TABLE.generateNextTable(primes, allPrimes, nextTable)
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! primes -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -92, %l0	! AddressOf(allPrimes) ->%l0
	add %l0, %fp, %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -36, %l0	! AddressOf(nextTable) ->%l0
	add %l0, %fp, %l0
	mov %l0, %o2
	set 76, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -108, %l0	! AddressOf(TABLE.generateNextTable) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l1       ! func -> %l1
	ld [%l0+4], %g1     ! this -> %g1
	call %l1, 3
	nop
	
	! delete currentTable
	set -32, %l6	! AddressOf(currentTable) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! currentTable -> %o0
	call .rcfunc_delete
	nop
	
	! currentTable = nextTable
	set -36, %l6	! AddressOf(nextTable) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! nextTable -> %l0
	set -32, %l6	! AddressOf(currentTable) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! currentTable <- %l0
	set -112, %l6	! AddressOf(currentTable = nextTable) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! currentTable = nextTable <- %l0
	
	ba ._whilestart147
	nop
._whileend148:
	! delete currentTable
	set -32, %l6	! AddressOf(currentTable) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! currentTable -> %o0
	call .rcfunc_delete
	nop
	
	! i = 0
	set 0, %l0	! 0 -> %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	set -116, %l6	! AddressOf(i = 0) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i = 0 <- %l0
	
	! cout Number of prime implicants: 
	set .stringFmt, %o0
	set .___string6, %o1
	call printf, 2
	nop
	
	! VECTOR.count
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! primes -> %l0
	set 23620, %l1
	add %l0, %l1, %l0
	set -120, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.count <- %l0
	
	! cout VECTOR.count
	set -120, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %o1	! VECTOR.count -> %o1
	set .intFmt, %o0
	call printf, 2
	nop
	
	! cout endl
	set .endl, %o0
	call printf, 1
	nop
	
	! cout Prime Implicants: 
	set .stringFmt, %o0
	set .___string7, %o1
	call printf, 2
	nop
	
	! VECTOR.items
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! primes -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -124, %l6	! AddressOf(VECTOR.items) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items <- %l0
	
	! ++(i)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -128, %l6	! AddressOf(++(i)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(i) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	
	! VECTOR.items[++(i)]
	set -124, %l0	! AddressOf(VECTOR.items) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -128, %l6	! AddressOf(++(i)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! ++(i) -> %o0
	set 5905, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error150
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error151
	nop
._rtc_array_bounds_error150:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error151:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -132, %l6	! AddressOf(VECTOR.items[++(i)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items[++(i)] <- %l0
	
	! printImplicant(VECTOR.items[++(i)], numVars)
	set -132, %l6	! AddressOf(VECTOR.items[++(i)]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! VECTOR.items[++(i)] -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call printImplicant, 2
	nop
	
	! cout printImplicant(VECTOR.items[++(i)], numVars)
	
._whilestart152:
	! VECTOR.count
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! primes -> %l0
	set 23620, %l1
	add %l0, %l1, %l0
	set -136, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.count <- %l0
	
	! (i)<(VECTOR.count)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -136, %l6	! AddressOf(VECTOR.count) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l1	! VECTOR.count -> %l1
	cmp %l0, %l1
	bl ._bl154
	mov 1, %l0
	mov 0, %l0
._bl154:
	set -140, %l6	! AddressOf((i)<(VECTOR.count)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! (i)<(VECTOR.count) <- %l0
	
	set -140, %l6	! AddressOf((i)<(VECTOR.count)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! (i)<(VECTOR.count) -> %l0
	cmp %l0, 0
	be ._whileend153
	nop
	
	! cout , 
	set .stringFmt, %o0
	set .___string8, %o1
	call printf, 2
	nop
	
	! VECTOR.items
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! primes -> %l0
	set 0, %l1
	add %l0, %l1, %l0
	set -144, %l6	! AddressOf(VECTOR.items) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items <- %l0
	
	! ++(i)
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! i -> %l0
	set -148, %l6	! AddressOf(++(i)) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! ++(i) <- %l0
	inc %l0
	set -4, %l6	! AddressOf(i) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! i <- %l0
	
	! VECTOR.items[++(i)]
	set -144, %l0	! AddressOf(VECTOR.items) ->%l0
	add %l0, %fp, %l0
	ld [%l0], %l0
	set -148, %l6	! AddressOf(++(i)) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! ++(i) -> %o0
	set 5905, %l2
	cmp %o0, 0
	bl ._rtc_array_bounds_error155
	nop
	cmp %o0, %l2
	bl ._rtc_array_bounds_not_error156
	nop
._rtc_array_bounds_error155:
	mov %o0, %o1
	set .arrayBounds, %o0
	call printf, 2
	mov %l2, %o2
	call exit, 1
	mov 1, %o0
._rtc_array_bounds_not_error156:
	set 4, %o1
	call .mul, 2
	nop
	add %l0, %o0, %l0
	set -152, %l6	! AddressOf(VECTOR.items[++(i)]) ->%l6
	add %l6, %fp, %l6
	st %l0, [%l6]	! VECTOR.items[++(i)] <- %l0
	
	! printImplicant(VECTOR.items[++(i)], numVars)
	set -152, %l6	! AddressOf(VECTOR.items[++(i)]) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l6
	ld [%l6], %l0	! VECTOR.items[++(i)] -> %l0
	mov %l0, %o0
	set 68, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	set -16, %l6	! AddressOf(numVars) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %l0	! numVars -> %l0
	mov %l0, %o1
	set 72, %l1
	add %sp, %l1, %l1
	st %l0, [%l1]
	call printImplicant, 2
	nop
	
	! cout printImplicant(VECTOR.items[++(i)], numVars)
	
	ba ._whilestart152
	nop
._whileend153:
	! cout endl
	set .endl, %o0
	call printf, 1
	nop
	
	! delete primes
	set -40, %l6	! AddressOf(primes) ->%l6
	add %l6, %fp, %l6
	ld [%l6], %o0	! primes -> %o0
	call .rcfunc_delete
	nop
	
	ret
	restore

