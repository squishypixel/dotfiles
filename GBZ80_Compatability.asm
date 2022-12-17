Gbz80Macros equ 1
gbz80 equ 1

;Fake registers in GB Ram

z80regbase equ &DFF0

r_ixl equ z80regbase+&0	
r_ixh equ z80regbase+&1
r_ix  equ z80regbase+&0
	
r_iyl equ z80regbase+&2
r_iyh equ z80regbase+&3
r_iy  equ z80regbase+&2

r_r   equ z80regbase+&4

;Shadow Regs
rs_f  equ z80regbase+&5
rs_a  equ z80regbase+&6

rs_c  equ z80regbase+&7
rs_b  equ z80regbase+&8

rs_e  equ z80regbase+&9
rs_d  equ z80regbase+&A

rs_l  equ z80regbase+&B
rs_h  equ z80regbase+&C

r_tmpA equ z80regbase+&D
r_tmpL equ z80regbase+&E
r_tmpH equ z80regbase+&F

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_neg
		cpl
		inc a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	macro z_ex_sphl		;ex (SP),HL

	ld (r_tmpA),a
	ld a,d
	ld (r_tmpH),a
	ld a,e
	ld (r_tmpL),a
		
	ld d,h
	ld e,l
			
	pop hl		;Grab the value that was on the top of the stack
	push de		;Put what was HL onto the stack
			
	ld a,(r_tmpH)
	ld d,a
	ld a,(r_tmpL)
	ld e,a
	ld a,(r_tmpA)		
	
		; push de			;Backup DE
			; ld d,h
			; ld e,l
			
			; inc sp		;Move back to SP position before pushing
			; inc sp
			
			; pop hl		;Grab the value that was on the top of the stack
			; push de		;Put what was HL onto the stack
			
			; dec sp		;Return to the last position
			; dec sp
		; pop de			;Restore DE
	endm
	
	macro z_ex_dehl		;ex de,hl
		push hl			;Push HL and DE on the stack, then pop them
		ld h,d			;	in the opposite order
		ld l,e
		pop de
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	macro z_ldi
	push af
		ld a,(hl)		;Copy a byte from (HL) to (DE) and inc the counter
		ld (de),a
		inc hl
		inc de
		dec bc
	pop af
	endm
	
	macro z_ldir
	push af
 \@Ldirb:			;Fake LDIR, copy BC bytes from HL to DE
		ldi a,(hl)
		ld (de),a
		inc de
		dec bc
		ld a,b
		or c
		jr nz, \@Ldirb
	pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;BUG:When interrupts are disabled with DI, HALT will not lock the cpu... GBZ80 skips it, but The instruction immediately following the  HALT instruction is "skipped" on all except the GBC. As a result, always put a NOP after the HALT instruction.
	macro z_halt
		halt
		nop
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_or_ixl	;or IXL
		push hl
			ld hl,r_ixl		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	macro z_or_ixh	;or IXH
		push hl
			ld hl,r_ixh		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	macro z_or_iyl	;or IYL
		push hl
			ld hl,r_iyl		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	macro z_or_iyh	;or IYH
		push hl
			ld hl,r_iyh		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	
	
	macro z_and_ixl	;and IXL
		push hl
			ld hl,r_ixl		;Use fake register in memory via HL
			and (hl)
		pop hl
	endm
	macro z_and_ixh	;and IXH
		push hl
			ld hl,r_ixh		;Use fake register in memory via HL
			and (hl)
		pop hl
	endm
	macro z_and_iyl	;and IYL
		push hl
			ld hl,r_iyl		;Use fake register in memory via HL
			and (hl)
		pop hl
	endm
	macro z_and_iyh	;and IYH
		push hl
			ld hl,r_iyh		;Use fake register in memory via HL
			and (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		macro z_ld_iy_plusn_a,aoffset	; Fake LD (Iy+n),a
			push hl
			push de
				push af
					ld a,(r_iyl)		;Get address into HL
					ld l,a
					ld a,(r_iyh)
					ld h,a
					ld de,\aoffset		;Add the offset
					add hl,de
				pop af
				ld (hl),a 				;ld (iy + \aoffset),a
			pop de
			pop hl
		endm
		macro z_ld_ix_plusn_a,aoffset	; Fake LD (Ix+n),a
			push hl
				push af
						ld hl,r_ixl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
				pop af
				ld (hl),a 				;ld (ix + \aoffset),a
			pop hl
		endm
		
		macro z_ld_iy_plusn_n,aoffset,aval	;Store an immidiate value into an (IY+n)
			push hl							; this mimmics LD (IY+2),&FF  - or similar
			push de
				push af
					ld a,(r_iyl)
					ld l,a
					ld a,(r_iyh)
					ld h,a
					ld de,\aoffset
					add hl,de
				pop af
				ld (hl),\aval 			;ld (iy + \aoffset),\aval
			pop de
			pop hl

		endm
			macro z_ld_ix_plusn_n,aoffset,aval	;Store an immidiate value into an (IX+n)
			push hl							; this mimmics LD (IX+2),&FF  - or similar
			push de
				push af
					ld a,(r_ixl)
					ld l,a
					ld a,(r_ixh)
					ld h,a
					ld de,\aoffset
					add hl,de
				pop af
				ld (hl),\aval 			;ld (iy + \aoffset),\aval
			pop de
			pop hl

		endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		macro z_ld_iy_plusn_h,aoffset	;ld (iy+n),h
			push af
			push de
				push hl
					ld a,h
					push af
						ld a,(r_iyl)
						ld l,a
						ld a,(r_iyh)
						ld h,a
						ld de,\aoffset
						add hl,de
					pop af
					ld (hl),a	;ld (iy + \aoffset),h
				pop hl
			pop de
			pop af
			
		endm
		macro z_ld_iy_plusn_l,aoffset
			push af
				push hl
					ld a,l
					push af
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					pop af
					ld (hl),a	;ld (iy + \aoffset),l
				pop hl
			pop af
		endm
		
		macro z_ld_iy_plusn_d,aoffset	;ld (iy+n),h
			push af
				push hl
					ld a,d
					push af
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					pop af
					ld (hl),a	;ld (iy + \aoffset),h
				pop hl
			pop af
			
		endm
		macro z_ld_iy_plusn_e,aoffset
			push af
				push hl
					ld a,e
					push af
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					pop af
					ld (hl),a	;ld (iy + \aoffset),l
				pop hl
			pop af
		endm
		macro z_ld_iy_plusn_b,aoffset	;ld (iy+n),h
			push af
				push hl
					ld a,d
					push af
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					pop af
					ld (hl),b	;ld (iy + \aoffset),h
				pop hl
			pop af
			
		endm
		macro z_ld_iy_plusn_c,aoffset
			push af
				push hl
					
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					
					ld (hl),c	;ld (iy + \aoffset),l
				pop hl
			pop af
		endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_ix_plusn_a,aoffset	;ld (ix+n),a
			push af
				push hl
					push af
						ld hl,r_ixl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					pop af
					ld (hl),a	;ld (ix + \aoffset),a
				pop hl
			pop af
			
		endm
	macro z_ld_ix_plusn_h,aoffset	;ld (ix+n),h
			push af
				push hl
					ld a,h
					push af
						ld hl,r_ixl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					pop af
					ld (hl),a	;ld (ix + \aoffset),l
				pop hl
			pop af
		endm
		macro z_ld_ix_plusn_l,aoffset
			push af
				push hl
					ld a,l
					push af
						ld hl,r_ixl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					pop af
					ld (hl),a	;ld (ix + \aoffset),l
				pop hl
			pop af
		endm
		
		macro z_ld_ix_plusn_d,aoffset	;ld (ix+n),h
			push af
				push hl
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					ld (hl),d	;ld (ix + \aoffset),l
				pop hl
			pop af
		endm
		macro z_ld_ix_plusn_e,aoffset
			push af
				push hl
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					ld (hl),e	;ld (ix + \aoffset),l
				pop hl
			pop af
		endm
		macro z_ld_ix_plusn_b,aoffset	;ld (ix+n),b
			push af
				push hl
					
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					
					ld (hl),b	;ld (ix + \aoffset),h
				pop hl
			pop af
		endm
		macro z_ld_ix_plusn_c,aoffset	;ld (ix+n),c
			push af
				push hl
					
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					
					ld (hl),c	;ld (ix + \aoffset),l
				pop hl
			pop af
		endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_add_iy_de	; add iy,de
		push hl
		push af
			ld a,(r_iyl)
			ld l,a
			ld a,(r_iyh)
			ld h,a
			
			add hl,de
			
			ld a,l
			ld (r_iyl),a
			ld a,h
			ld (r_iyh),a
		pop af
		pop hl
	endm		
	macro z_add_ix_de	; add ix,de
		push hl
		push af
			ld a,(r_ixl)
			ld l,a
			ld a,(r_ixh)
			ld h,a
			
			add hl,de
			
			ld a,l
			ld (r_ixl),a
			ld a,h
			ld (r_ixh),a
		pop af
		pop hl
	endm	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_add_iy_bc	; add iy,bc
		push hl
		push af
			ld hl,r_iyl
			ld a,(hl)
			add c
			ldi (hl),a
			ld a,(hl)
			adc b
			ld (hl),a
		pop af
		pop hl
	endm		
	macro z_add_ix_bc	; add ix,bc
		push hl
		push af
			ld hl,r_ixl
			ld a,(hl)
			add c
			ldi (hl),a
			ld a,(hl)
			adc b
			ld (hl),a
		pop af
		pop hl
	endm	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_iy ; ld a,(iy)
		push hl
			ld a,(r_iyl)
			ld l,a
			ld a,(r_iyh)
			ld h,a
			ld a,(hl)
		pop hl
	endm		
	macro z_ld_a_ix	; ld a,(ix)
		push hl
			ld a,(r_ixl)
			ld l,a
			ld a,(r_ixh)
			ld h,a
			ld a,(hl)
		pop hl
	endm		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
		macro z_ld_a_iy_plusn,aoffset	; ld a,(iy+n)
				push hl
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
					ld a,(hl)
				pop hl
		endm		
		macro z_ld_b_iy_plusn,aoffset	; ld b,(iy+n)
			push af
				push hl
						ld hl,r_iyl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					ld b,(hl)
				pop hl
			pop af
		endm		
		macro z_ld_c_iy_plusn,aoffset	; ld c,(iy+n)
			push af
				push hl
						ld hl,r_iyl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					ld c,(hl)
				pop hl
			pop af
		endm
		macro z_ld_d_iy_plusn,aoffset	; ld d,(iy+n)
			push af
			push hl
				ld hl,r_iyl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
				ld d,(hl)
			pop hl
			pop af
		endm		
		macro z_ld_e_iy_plusn,aoffset	; ld e,(iy+n)
			push af
			push hl
					ld hl,r_iyl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
				ld e,(hl)
			pop hl
			pop af
		endm		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		macro z_ld_a_ix_plusn,aoffset	; ld a,(ix+n)
			push hl
				ld a,l
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
				ld a,(hl)
			pop hl
		endm		
		macro z_ld_b_ix_plusn,aoffset	; ld b,(ix+n)
			push af
				push hl
						ld hl,r_ixl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					ld b,(hl)
				pop hl
			pop af
		endm		
		macro z_ld_c_ix_plusn,aoffset	; ld c,(ix+n)
			push af
				push hl
						ld hl,r_ixl
						ldi a,(hl)
						ld h,(hl)
						add \aoffset
						ld l,a
						jr nc,\@M
						inc h	;add carry
\@M:
					ld c,(hl)
				pop hl
			pop af
		endm
		macro z_ld_d_ix_plusn,aoffset	; ld d,(ix+n)
			push af
			push hl
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
				ld d,(hl)
			pop hl
			pop af
		endm		
		macro z_ld_e_ix_plusn,aoffset	; ld e,(ix+n)
			push af
			push hl
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
				ld e,(hl)
			pop hl
			pop af
		endm		
		macro z_ld_l_ix_plusn,aoffset	; ld l,(ix+n)
		push af
			push hl
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
				ld a,(hl)
			pop hl
			ld l,a
			pop af
		endm		
		macro z_ld_h_ix_plusn,aoffset	; ld h,(ix+n)
			push af
			push hl
					ld hl,r_ixl
					ldi a,(hl)
					ld h,(hl)
					add \aoffset
					ld l,a
					jr nc,\@M
					inc h	;add carry
\@M:
			ld a,(hl)
			pop hl
			ld h,a
			pop af
		endm		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_djnz,addr
		dec b					;Decrease B
		jp nz,\addr				;Jump if not zero
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_r				;I use R as a random source 
		LD a,(r_r)				;this will do some kind of random generaton
		inc a
		xor h
		xor l
		rlca
		xor b
		xor c
		rlca
		xor d
		xor e
		ld (r_r),a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load A from one of the fake memory based registers

	macro z_ld_a_iyl	;ld a,iyl
		LD a,(r_iyl)
	endm
	macro z_ld_a_iyh	;ld a,iyh
		LD a,(r_iyh)
	endm
	
	macro z_ld_a_ixl	;ld a,ixl
		LD a,(r_ixl)
	endm
	macro z_ld_a_ixh
		LD a,(r_ixh)	;ld a,ixh
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_a	;ld iyl,a
		LD (r_iyl),a			;Store A from one of the fake memory based registers
	endm
	macro z_ld_iyh_a	;ld iyh,a
		LD (r_iyh),a
	endm
	
	macro z_ld_ixl_a	;ld ixl,a
		LD (r_ixl),a
	endm
	macro z_ld_ixh_a	;ld ixh,a
		LD (r_ixh),a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load A from one of the fake memory based registers

	macro z_ld_c_iyl	;ld c,iyl
		push af
			LD a,(r_iyl)
			ld c,a
		pop af
	endm
	macro z_ld_c_iyh	;ld c,iyh
		push af
			LD a,(r_iyh)
			ld c,a
		pop af
	endm
	
	macro z_ld_c_ixl	;ld c,ixl
		push af
			LD a,(r_ixl)
			ld c,a
		pop af
	endm
	macro z_ld_c_ixh
		push af
			LD a,(r_ixh)	;ld c,ixh
			ld c,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_c	;ld iyl,c
		push af
			ld a,c
			LD (r_iyl),a			;Store A from one of the fake memory based registers
		pop af
	endm
	macro z_ld_iyh_c	;ld iyh,c
		push af
			ld a,c
			LD (r_iyh),a
		pop af
	endm
	
	macro z_ld_ixl_c	;ld ixl,c
		push af
			ld a,c
			LD (r_ixl),a
		pop af
	endm
	macro z_ld_ixh_c	;ld ixh,c
		push af
			ld a,c
			LD (r_ixh),a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load A from one of the fake memory based registers

	macro z_ld_b_iyl	;ld b,iyl
		push af
			LD a,(r_iyl)
			ld b,a
		pop af
	endm
	macro z_ld_b_iyh	;ld b,iyh
		push af
			LD a,(r_iyh)
			ld b,a
		pop af
	endm
	
	macro z_ld_b_ixl	;ld b,ixl
		push af
			LD a,(r_ixl)
			ld b,a
		pop af
	endm
	macro z_ld_b_ixh
		push af
			LD a,(r_ixh)	;ld b,ixh
			ld b,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_b	;ld iyl,b
		push af
			ld a,b
			LD (r_iyl),a			;Store A from one of the fake memory based registers
		pop af
	endm
	macro z_ld_iyh_b	;ld iyh,b
		push af
			ld a,b
			LD (r_iyh),a
		pop af
	endm
	
	macro z_ld_ixl_b	;ld ixl,b
		push af
			ld a,b
			LD (r_ixl),a
		pop af
	endm
	macro z_ld_ixh_b	;ld ixh,b
		push af
			ld a,b
			LD (r_ixh),a
		pop af
	endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load A from one of the fake memory based registers

	macro z_ld_e_iyl	;ld e,iyl
		push af
			LD a,(r_iyl)
			ld e,a
		pop af
	endm
	macro z_ld_e_iyh	;ld e,iyh
		push af
			LD a,(r_iyh)
			ld e,a
		pop af
	endm
	
	macro z_ld_e_ixl	;ld e,ixl
		push af
			LD a,(r_ixl)
			ld e,a
		pop af
	endm
	macro z_ld_e_ixh
		push af
			LD a,(r_ixh)	;ld b,ixh
			ld e,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_e	;ld iyl,b
		push af
			ld a,e
			LD (r_iyl),a			;Store A from one of the fake memory based registers
		pop af
	endm
	macro z_ld_iyh_e	;ld iyh,b
		push af
			ld a,e
			LD (r_iyh),a
		pop af
	endm
	
	macro z_ld_ixl_e	;ld ixl,b
		push af
			ld a,e
			LD (r_ixl),a
		pop af
	endm
	macro z_ld_ixh_e	;ld ixh,b
		push af
			ld a,e
			LD (r_ixh),a
		pop af
	endm	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load A from one of the fake memory based registers

	macro z_ld_d_iyl	;ld e,iyl
		push af
			LD a,(r_iyl)
			ld d,a
		pop af
	endm
	macro z_ld_d_iyh	;ld e,iyh
		push af
			LD a,(r_iyh)
			ld d,a
		pop af
	endm
	
	macro z_ld_d_ixl	;ld e,ixl
		push af
			LD a,(r_ixl)
			ld d,a
		pop af
	endm
	macro z_ld_d_ixh
		push af
			LD a,(r_ixh)	;ld b,ixh
			ld d,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_d	;ld iyl,b
		push af
			ld a,d
			LD (r_iyl),a			;Store A from one of the fake memory based registers
		pop af
	endm
	macro z_ld_iyh_d	;ld iyh,b
		push af
			ld a,d
			LD (r_iyh),a
		pop af
	endm
	
	macro z_ld_ixl_d	;ld ixl,b
		push af
			ld a,d
			LD (r_ixl),a
		pop af
	endm
	macro z_ld_ixh_d	;ld ixh,b
		push af
			ld a,d
			LD (r_ixh),a
		pop af
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_cp_iyl
		push hl
			ld hl,r_iyl		;Compare IYL via HL
			cp (hl)			;this means the flags are affected correctly
		pop hl
	endm
	macro z_cp_iyh
		push hl
			ld hl,r_iyh
			cp (hl)
		pop hl
	endm
	
	macro z_cp_ixl
		push hl
			ld hl,r_ixl
			cp (hl)
		pop hl
	endm
	macro z_cp_ixh
		push hl
			ld hl,r_ixh
			cp (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_inc_ixl
		push hl
			ld hl,r_ixl		;Increase IXL, by loading it into HL
			inc (hl)		;Then decreasing it, this means the flags 
		pop hl				;should be affected correctly
	endm
	macro z_inc_ixh
		push hl
			ld hl,r_ixh
			inc (hl)
		pop hl
	endm
	macro z_inc_iyl
		push hl
			ld hl,r_iyl
			inc (hl)
		pop hl
	endm
	macro z_inc_iyh
		push hl
			ld hl,r_iyh
			inc (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_dec_ixl		;dec ixl
		push hl
			ld hl,r_ixl		;Decrease IXL, by loading it into HL
			dec (hl)		;Then decreasing it, this means the flags 
		pop hl				;should be affected correctly
	endm
	macro z_dec_ixh		;dec ixh
		push hl
			ld hl,r_ixh
			dec (hl)
		pop hl
	endm
	macro z_dec_iyl		;dec iyl
		push hl
			ld hl,r_iyl
			dec (hl)
		pop hl
	endm
	macro z_dec_iyh		;dec iyh
		push hl
			ld hl,r_iyh
			dec (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_inc_iy	;inc iy
		push de
		push hl
			ld hl,r_iy
			ld e,(hl)		;Load in the fake IY to DE
			inc hl
			ld d,(hl)
			
			inc de			;Increase the fake IY
			
			ld (hl),d		;Save it back
			dec hl			
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_dec_iy	;dec iy
		push de
		push hl
			ld hl,r_iy
			ld e,(hl)
			inc hl
			ld d,(hl)
			dec de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
		macro z_inc_ix	;inc ix
		push de
		push hl
			ld hl,r_ix
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_dec_ix	;dec ix
		push de
		push hl
			ld hl,r_ix
			ld e,(hl)
			inc hl
			ld d,(hl)
			dec de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_inc_hl
		
		push af
			ld a,1
			add l
			ld l,a
			ld a,h
			adc 0
			ld h,a
		pop af
		
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_de	;Subtract DE from HL ;sbc hl,de
	push bc
		ld b,a
			ld a,l
			sbc e
			ld l,a
			ld a,h
			sbc d
			ld h,a
		ld a,b
	pop bc
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_bc		;Subtract BC from HL ;sbc hl,bc
	push de
		ld d,a
			ld a,l
			sbc c
			ld l,a
			ld a,h
			sbc b
			ld h,a
		ld a,d
	pop de
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_bc_from,addr	;GBZ80 can't load a register pair from an address in one go 
	push hl					;like... LD BC,(addr)
		ld hl,\addr			;We can fake it using HL to write from the address
		ld c,(hl)
		inc hl
		ld b,(hl)
	pop hl
	endm
	macro z_ld_de_from,addr	;ld de,(&0000)
	push hl
		ld hl,\addr
		ld e,(hl)
		inc hl
		ld d,(hl)
	pop hl
	endm
	macro z_ld_hl_from,addr	;ld hl,(&0000)
	push af
		ld hl,\addr
		ldi a,(hl)
		ld h,(hl)
		ld l,a
	pop af
	endm
	
		macro z_ld_ix_from,addr		;ld ix,(&1234)
			push af
				ld a,(\addr)			;Load in A from the address
				ld (r_ixl),a			;save into the low part
				ld a,(\addr+1)			;Load in A from addr+1
				ld (r_ixh),a			;Save into the high part
				
			pop af
		endm
		macro z_ld_iy_from,addr		;ld iy,(&1234)
			push af
				ld a,(\addr)			;Load in A from the address
				ld (r_iyl),a			;save into the low part
				ld a,(\addr+1)			;Load in A from addr+1
				ld (r_iyh),a			;Save into the high part
			pop af
		endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	macro z_ld_bc_to,addr	;GBZ80 can't load a register pair to an address in one go 
		push hl				;like... LD (addr),BC
			ld hl,\addr		;We can fake it using HL to write to the address
			ld (hl),c
			inc hl
			ld (hl),b
		pop hl
	endm
	macro z_ld_de_to,addr
		push hl
			ld hl,\addr
			ld (hl),e
			inc hl
			ld (hl),d
		pop hl
	endm
	macro z_ld_hl_to,addr	;ld (aaaa),hl
		push af
		push de
			ld de,\addr
			ld a,l
			ld (de),a
			inc de
			ld a,h
			ld (de),a
		pop de
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		macro z_ld_ix_to,addr
			push af
				ld a,(r_ixl)	;Save fake IX to an address 
				ld (\addr),a
				ld a,(r_ixh)
				ld (\addr+1),a
			pop af
		endm
		macro z_ld_iy_to,addr
			push af
				ld a,(r_iyl)
				ld (\addr),a
				ld a,(r_iyh)
				ld (\addr+1),a
			pop af
		endm
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		macro z_ld_ix,valu		;ld ix,&1234
			push de
			push hl
				ld de,\valu		;Load a 16 bit value into fake IX via HL
				ld hl,r_ixl
				ld (hl),e
				inc hl
				ld (hl),d
			pop hl
			pop de
		endm
		macro z_ld_iy,valu		;ld iy,&1234
			push af
			push hl
				ld hl,\valu
				ld a,l
				ld (r_iyl),a
				ld a,h
				ld (r_iyh),a
			pop hl
			pop af
		endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		macro z_push_ix		;Push IX
			ld (r_tmpA),a
			ld a,h
			ld (r_tmpH),a
			ld a,l
			ld (r_tmpL),a
		
			ld hl,r_ix
			ldi a,(hl)
			ld h,(hl)
			ld l,a
			
			push hl
			
			ld hl,r_tmpL
			ldi a,(hl)
			ld h,(hl)
			ld l,a
			ld a,(r_tmpA)
		
			; dec sp
			; dec sp
			; push hl
			; push af
				; ld a,(r_ixl)
				; ld l,a
				; ld a,(r_ixh)
				; ld h,a
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; push hl
				; dec sp
				; dec sp
				; dec sp
				; dec sp
			; pop af
			; pop hl
		endm
		
		macro z_pop_ix		;pop IX
			ld (r_tmpA),a
			ld a,h
			ld (r_tmpH),a
			ld a,l
			ld (r_tmpL),a
		
			pop hl
			ld a,l
			ld (r_ixl),a
			ld a,h
			ld (r_ixh),a
			
			ld hl,r_tmpL
			ldi a,(hl)
			ld h,(hl)
			ld l,a
			ld a,(r_tmpA)
			
			
			; push hl
			; push af
				
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; pop hl
				; ld a,h
				; ld (r_ixh),a
				; ld a,l
				; ld (r_ixl),a
				; dec sp
				; dec sp
				; dec sp
				; dec sp
				; dec sp
				; dec sp
			; pop af
			; pop hl
			; inc sp
			; inc sp
		endm

		macro z_push_iy		;Push Iy
			; dec sp
			; dec sp
			; push hl
			; push af
				; ld a,(r_iyl)
				; ld l,a
				; ld a,(r_iyh)
				; ld h,a
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; push hl
				; dec sp
				; dec sp
				; dec sp
				; dec sp
			; pop af
			; pop hl
			
			ld (r_tmpA),a
			ld a,h
			ld (r_tmpH),a
			ld a,l
			ld (r_tmpL),a
		
			ld hl,r_iy
			ldi a,(hl)
			ld h,(hl)
			ld l,a
			
			push hl
			
			ld hl,r_tmpL
			ldi a,(hl)
			ld h,(hl)
			ld l,a
			ld a,(r_tmpA)
		
			
		endm
		
		macro z_pop_iy		;pop Iy
			; push hl
			; push af
				
				; inc sp
				; inc sp
				; inc sp
				; inc sp
				; pop hl
				; ld a,h
				; ld (r_iyh),a
				; ld a,l
				; ld (r_iyl),a
				; dec sp
				; dec sp
				; dec sp
				; dec sp
				; dec sp
				; dec sp
			; pop af
			; pop hl
			; inc sp
			; inc sp
			
			ld (r_tmpA),a
			ld a,h
			ld (r_tmpH),a
			ld a,l
			ld (r_tmpL),a
		
			pop hl
			
			ld a,l
			ld (r_iyl),a
			ld a,h
			ld (r_iyh),a
			
			ld hl,r_tmpL
			ldi a,(hl)
			ld h,(hl)
			ld l,a
			ld a,(r_tmpA)
			
		endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		macro z_ld_ixl,valu		;ld ixl,n 
			push af
				ld a,\valu		;Transfer Immediate value into fake IXL
				ld (r_ixl),a
			pop af
		endm
		macro z_ld_ixh,valu		;ld ixh,n
			push af
				ld a,\valu
				ld (r_ixh),a
			pop af
		endm
		macro z_ld_iyl,valu		;ld iyl,n
			push af
				ld a,\valu
				ld (r_iyl),a
			pop af
		endm
		macro z_ld_iyh,valu		;ld iyh,n
			push af
				ld a,\valu
				ld (r_iyh),a
			pop af
		endm
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_b_ixl
		push af
			ld a,(r_ixl)	;transfer the shadow IXL reg into B
			ld b,a
		pop af
	endm
	macro z_ld_c_ixl
		push af
			ld a,(r_ixl)
			ld c,a
		pop af
	endm
	macro z_ld_d_ixl
		push af
			ld a,(r_ixl)
			ld d,a
		pop af
	endm
	macro z_ld_e_ixl
		push af
			ld a,(r_ixl)
			ld e,a
		pop af
	endm
	macro z_ld_h_ixl
		push af
			ld a,(r_ixl)
			ld h,a
		pop af
	endm
	macro z_ld_l_ixl
		push af
			ld a,(r_ixl)
			ld l,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_b_ixh
		push af
			ld a,(r_ixh)	;transfer the shadow IXH reg into B
			ld b,a
		pop af
	endm
	macro z_ld_c_ixh
		push af
			ld a,(r_ixh)
			ld c,a
		pop af
	endm
	macro z_ld_d_ixh
		push af
			ld a,(r_ixh)
			ld d,a
		pop af
	endm
	macro z_ld_e_ixh
		push af
			ld a,(r_ixh)
			ld e,a
		pop af
	endm
	macro z_ld_h_ixh
		push af
			ld a,(r_ixh)
			ld h,a
		pop af
	endm
	macro z_ld_l_ixh
		push af
			ld a,(r_ixh)
			ld l,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_ixl_b
		push af
			ld a,b			;transfer B into the shadow IXL reg
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_c
		push af
			ld a,c
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_d
		push af
			ld a,d
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_e
		push af
			ld a,e
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_h
		push af
			ld a,h
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_l
		push af
			ld a,l
			ld (r_ixl),a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_ixh_b
		push af
			ld a,b			;transfer B into the shadow IXH reg
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_c
		push af
			ld a,c
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_d
		push af
			ld a,d
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_e
		push af
			ld a,e
			ld (r_ixh),a
		pop af
	endm	
	macro z_ld_ixh_h
		push af
			ld a,h
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_l
		push af
			ld a,l
			ld (r_ixh),a
		pop af
	endm

	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		macro z_ld_iyl,valu
			push af
				ld a,\valu		;Transfer Immediate value into fake iyl
				ld (r_iyl),a
			pop af
		endm
		macro z_ld_iyh,valu
			push af
				ld a,\valu
				ld (r_iyh),a
			pop af
		endm
		macro z_ld_iyl,valu
			push af
				ld a,\valu
				ld (r_iyl),a
			pop af
		endm
		macro z_ld_iyh,valu
			push af
				ld a,\valu
				ld (r_iyh),a
			pop af
		endm
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_b_iyl
		push af
			ld a,(r_iyl)	;transfer the shadow iyl reg into B
			ld b,a
		pop af
	endm
	macro z_ld_c_iyl
		push af
			ld a,(r_iyl)
			ld c,a
		pop af
	endm
	macro z_ld_d_iyl
		push af
			ld a,(r_iyl)
			ld d,a
		pop af
	endm
	macro z_ld_e_iyl
		push af
			ld a,(r_iyl)
			ld e,a
		pop af
	endm
	macro z_ld_h_iyl
		push af
			ld a,(r_iyl)
			ld h,a
		pop af
	endm
	macro z_ld_l_iyl
		push af
			ld a,(r_iyl)
			ld l,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_b_iyh
		push af
			ld a,(r_iyh)	;transfer the shadow iyh reg into B
			ld b,a
		pop af
	endm
	macro z_ld_c_iyh
		push af
			ld a,(r_iyh)
			ld c,a
		pop af
	endm
	macro z_ld_d_iyh
		push af
			ld a,(r_iyh)
			ld d,a
		pop af
	endm
	macro z_ld_e_iyh
		push af
			ld a,(r_iyh)
			ld e,a
		pop af
	endm
	macro z_ld_h_iyh
		push af
			ld a,(r_iyh)
			ld h,a
		pop af
	endm
	macro z_ld_l_iyh
		push af
			ld a,(r_iyh)
			ld l,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_iyl_b
		push af
			ld a,b			;transfer B into the shadow iyl reg
			ld (r_iyl),a
		pop af
	endm
	macro z_ld_iyl_c
		push af
			ld a,c
			ld (r_iyl),a
		pop af
	endm
	macro z_ld_iyl_d
		push af
			ld a,d
			ld (r_iyl),a
		pop af
	endm
	macro z_ld_iyl_e
		push af
			ld a,e
			ld (r_iyl),a
		pop af
	endm
	macro z_ld_iyl_h
		push af
			ld a,h
			ld (r_iyl),a
		pop af
	endm
	macro z_ld_iyl_l
		push af
			ld a,l
			ld (r_iyl),a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_iyh_b
		push af
			ld a,b			;transfer B into the shadow iyh reg
			ld (r_iyh),a
		pop af
	endm
	macro z_ld_iyh_c
		push af
			ld a,c
			ld (r_iyh),a
		pop af
	endm
	macro z_ld_iyh_d
		push af
			ld a,d
			ld (r_iyh),a
		pop af
	endm
	macro z_ld_iyh_e
		push af
			ld a,e
			ld (r_iyh),a
		pop af
	endm	
	macro z_ld_iyh_h
		push af
			ld a,h
			ld (r_iyh),a
		pop af
	endm
	
	macro z_ld_iyh_l
		push af
			ld a,l
			ld (r_iyh),a
		pop af
	endm
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro gb_swap_a				;These are special GB commands
		swap a					;We can emulate them on the Z80
	endm						;with 4x RLCA
	macro gb_swap_b
		swap b
	endm
	macro gb_swap_c
		swap c
	endm
	macro gb_swap_d
		swap d
	endm
	macro gb_swap_e
		swap e
	endm
	macro gb_swap_f
		swap f
	endm
	macro gb_swap_h
		swap h
	endm
	macro gb_swap_l
		swap l
	endm
	
	macro gb_swap_hl
		swap (hl)
	endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ex_af_afs
		push bc
		push hl
			push af				;Transfer AF to DE
				ld hl,rs_f
				ld c,(hl)		;Get the shadow AF into BC
				inc hl
				ld b,(hl)
			
				push bc			;Transfer the ShadowAF from BC to AF
				pop af
			pop bc
			
			ld (hl),b			;Save the prevous AF
			dec hl
			ld (hl),c
		pop hl
		pop bc
	endm
	
	macro z_exx
		push af
		push bc
			ld b,h				;Backup HL into BC
			ld c,l
			
			ld hl,rs_l
			ldi a,(hl)			;Pull HL out of the fake shadow regs
			ld h,(hl)
			ld l,a
			push hl
				ld hl,rs_l
				ld (hl),c		;Store the backed up HL in the shadow regs
				inc hl
				ld (hl),b	
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				ld b,d
				ld c,e
				
				ld hl,rs_e
				ld e,(hl)			;Do the same with DE
				inc hl
				ld d,(hl)
				
				ld (hl),b
				dec hl
				ld (hl),c
				
			pop hl
		pop bc
		push de
		push hl
			ld d,b
			ld e,c
			
			ld hl,rs_c
			
			ld c,(hl)			;Do the same with BC
			inc hl
			ld b,(hl)
			
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; there seems to be a bug in VASM - it thinks the GBZ80 doesn't support SRL, but it does! --- FIXED IN LATEST VERSION
;	macro z_srl_a
		;db &CB,&3F
	;endm
;	macro z_srl_h
		;db &CB,&3C
	;endm
	
	
	macro z_or_ix_plusn,aoffset ; or (IX)
		push hl
			push af
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			or (hl)
		pop hl
	endm
		
	macro z_or_iy_plusn,aoffset ; or (IY)
		push hl
			push af
				ld hl,r_iyl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			or (hl)
		pop hl
	endm	
	
	
	macro z_inc_ix_plusn,aoffset ; inc (IX+n)
		push hl
			push af
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			inc (hl)
		pop hl
	endm
		
	macro z_inc_iy_plusn,aoffset ; inc (IY+n)
		push hl
			push af
				ld hl,r_iyl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			inc (hl)
		pop hl
	endm	
	
	
	macro z_dec_ix_plusn,aoffset ; dec (IX+n)
		push hl
			push af
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			dec (hl)
		pop hl
	endm
		
	macro z_and_ix_plusn,aoffset ; and (IX+n)
		push hl
			push af
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			and (hl)
		pop hl
	endm
		
	macro z_add_ix_plusn,aoffset ; and (IX+n)
		push hl
			push af
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			add (hl)
		pop hl
	endm
		
	macro z_dec_iy_plusn,aoffset ; dec (IY+n)
		push hl
			push af
				ld hl,r_iyl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			dec (hl)
		pop hl
	endm	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	macro z_add_ix_plusn,aoffset ; or (IX)
		push hl
			push af
				ld hl,r_ixl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			add (hl)
		pop hl
	endm
		
	macro z_add_iy_plusn,aoffset ; or (IX)
		push hl
			push af
				ld hl,r_iyl
				ldi a,(hl)
				ld h,(hl)
				add \aoffset
				ld l,a
				jr nc,\@M
				inc h	;add carry
\@M:
			pop af
			add (hl)
		pop hl
	endm	
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		macro z_bit7_iy_plusn,aoffset	; bit n,(iy+n)
			push hl
				push af
				push de
					ld a,l
						ld a,(r_iyl)
						ld l,a
						ld a,(r_iyh)
						ld h,a
						ld de,\aoffset
						add hl,de
				pop de
				pop af
				bit 7,(hl)
			pop hl
		endm		
	
		macro z_bit7_ix_plusn,aoffset	; bit n,(ix+n)
			push hl
				push af
				push de
					ld a,l
						ld a,(r_ixl)
						ld l,a
						ld a,(r_ixh)
						ld h,a
						ld de,\aoffset
						add hl,de
				pop de
				pop af
				bit 7,(hl)
			pop hl
		endm		

		macro z_bit0_iy_plusn,aoffset	; bit n,(iy+n)
			push hl
				push af
				push de
					ld a,l
						ld a,(r_iyl)
						ld l,a
						ld a,(r_iyh)
						ld h,a
						ld de,\aoffset
						add hl,de
				pop de
				pop af
				bit 0,(hl)
			pop hl
		endm		
	
		macro z_bit0_ix_plusn,aoffset	; bit n,(ix+n)
			push hl
				push af
				push de
					ld a,l
						ld a,(r_ixl)
						ld l,a
						ld a,(r_ixh)
						ld h,a
						ld de,\aoffset
						add hl,de
				pop de
				pop af
				bit 0,(hl)
			pop hl
		endm		