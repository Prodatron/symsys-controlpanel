;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                              STARTMENU EDITOR                              @
;@                                                                            @
;@             (c) 2015-2015 by Prodatron / SymbiosiS (Jˆrn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;todo
;- quit -> saven, falls autosave
;- tree, move


;--- STARTMENU MANAGEMENT ROUTINES --------------------------------------------
;### STMINI -> searches for Extension Module and gets data location and startmenu size
;### STMBLK -> gets one startmenu block
;### STMENT -> loads entry from the actual block
;### STMLST -> generates list of actual block and updates list control
;### STMEDI -> loads an entry into the editor fields and updates display
;### STMSYS -> checks, if current entry is existing and system (read only)
;### STMSAV -> saves current entry if changed
;### STMMOV -> moves data at/behind address
;### STMLEN -> updates length vars after STMMOV
;### STMSWP -> swaps two entries
;### STMLAD -> gets entry address within list control

;--- STARTMENU EVENT ROUTINES -------------------------------------------------
;### STMLCL -> user clicked in list
;### STMLDW -> enter, if entry is submenu
;### STMLUP -> go to previous block
;### STMMUP -> moves entry up
;### STMMDW -> moves entry down
;### STMDEL -> deletes entry
;### STMADM -> add new submenu
;### STMADS -> add new shortcut


;==============================================================================
;### VARIABLES ################################################################
;==============================================================================

prgwin  db 0


;==============================================================================
;### MAIN #####################################################################
;==============================================================================

prgprz  call prgdbl
        call stmini

        ld de,cfgstmwin
        ld a,(App_BnkNum)
        call SyDesktop_WINOPN       ;open startmenu edit window
        ld (prgwin),a

        xor a
        call stmblk
        call stmlst

prgprz0 ld ix,(App_PrcID)           ;check for messages
        db #dd:ld h,-1
        ld iy,App_MsgBuf
        rst #08
        db #dd:dec l
        jr nz,prgprz0
        ld a,(App_MsgBuf+0)
        or a
        jr z,prgend1
        cp MSC_GEN_FOCUS
        jr z,prgfoc
        cp MSR_SYS_SELOPN
        jp z,selopna
        ;...
        cp MSR_DSK_WCLICK
        jr nz,prgprz0
        ld a,(App_MsgBuf+2)
        cp DSK_ACT_CLOSE
        jr z,prgend1
        cp DSK_ACT_MENU
        jr z,prgprz6
        cp DSK_ACT_CONTENT
        jr nz,prgprz0
prgprz6 ld hl,(App_MsgBuf+8)
        ld a,h
        or l
        jr z,prgprz0
        jp (hl)

;### PRGFOC -> Focus nehmen
prgfoc  ld a,(prgwin)
        call SyDesktop_WINMID
        jr prgprz0

;### PRGEND -> End program
prgend1 call stmsav
prgend  ld hl,(App_BegCode+prgpstnum)
        call SySystem_PRGEND
prgend0 rst #30
        jr prgend0

;### PRGDBL -> Check, if program is already running
prgdbln db "CP:Startmenu"
prgdbl  xor a
        ld (App_BegCode+prgdatnam),a
        ld e,0
        ld hl,prgdbln
        ld a,(App_BnkNum)
        call SySystem_PRGSRV
        or a
        ld a,"C"
        ld (App_BegCode+prgdatnam),a
        ret nz
        ld a,h
        ld c,MSC_GEN_FOCUS
        call msgsnd
        jp prgend

;### PRGWRN -> shows warning box
;### Input      HL=record
;### Output     [jumps to PRGPRZ0]
prgwrn  ld a,(App_BnkNum)
        ld b,1+8
        call SySystem_SYSWRN
        jp prgprz0


;==============================================================================
;### STARTMENU MANAGEMENT ROUTINES ############################################
;==============================================================================

stmdatadr   dw 0    ;startmenu data address
stmdatbnk   db 0    ;startmenu data bank
stmreclen   dw 0    ;length of actual menudata records

stmblknum   db 0    ;current block ID
stmblkadr   dw 0    ;current block address (behind len+tmp header)
stmentnum   db 0    ;current entry ID
stmentadr   dw 0    ;current entry address
stmentbuf   ds 255  ;current entry data
stmentopn   db 0    ;old opentype

stmpthids   ds 7    ;path block IDs
stmpthlen   db 0    ;path length
stmpthsln   db 7    ;length of current path string

extprcid    db 0    ;extension module process ID


;### STMINI -> searches for Extension Module and gets data location and startmenu size
stminin db "SymbOS Advan"
stmini  ld e,0
        ld hl,stminin
        ld a,(App_BnkNum)
        call SySystem_PRGSRV
        or a
        jp nz,prgend
        ld a,h
        ld (extprcid),a
        call stmini0
        db #dd:dec l
        jp nz,prgend
        ld hl,(App_MsgBuf+2)
        ld (stmdatadr),hl
        ld a,(App_MsgBuf+4)
        ld (stmdatbnk),a
        ld hl,(App_MsgBuf+6)
        ld (stmreclen),hl
        ret
stmini0 ld a,(extprcid)
        ld bc,256*FNC_DXT_STMDAT+MSR_DSK_EXTDSK
        push af
        call msgsnd
        pop af
        ld ix,(App_PrcID)
        db #dd:ld h,a
        ld iy,App_MsgBuf
        rst #08
        ret

;### STMBLK -> gets one startmenu block
;### Input      A=block ID (0-x)
;### Output     HL=address of first entry, (stmblkadr), (stmblknum) updated, BC=blocklength without lenword
;### Destroyed  AF,E
stmblk  ld (stmblknum),a
        ld hl,(stmdatadr)
        inc hl:inc hl
        or a
        ld e,a
        ld a,(stmdatbnk)
        jr z,stmblk2
stmblk1 rst #20:dw jmp_bnkrwd
        add hl,bc
        dec e
        jr nz,stmblk1
stmblk2 inc hl:inc hl:inc hl:inc hl
        ld (stmblkadr),hl
        ret

;### STMENT -> loads entry from the actual block
;### Input      A=entry ID (0-x)
;### Output     (stmentnum) updated, (stmentbuf)=entry data, A=length, ZF=1 -> no entry
;### Destroyed  AF,BC,DE,HL
stment  ld (stmentnum),a
        call stment0
        ld (stmentadr),hl
        ld e,a
        ld a,(App_BnkNum)
        add a:add a:add a:add a
        add e
        ld de,stmentbuf
        ld bc,255
        rst #20:dw jmp_bnkcop
        ld a,(stmentbuf)
        or a
        ret
stment0 ld hl,(stmblkadr)   ;a=num -> hl=adr, a=(stmdatbnk)
        or a
        ld e,a
        ld a,(stmdatbnk)
        ret z
stment1 rst #20:dw jmp_bnkrbt
        dec hl
        ld c,b
        ld b,0
        add hl,bc
        dec e
        jr nz,stment1
        ret

;### STMLST -> generates list of actual block and updates list control
;### Destroyed  AF,BC,DE,HL,IX,IY
stmlste db "-----",0

stmlst  call stmlst0
        ld (stmentobj+0),a
        xor a
        ld (stmentobj+2),a
        ld (stmentobj+12),a
        ld hl,stmentlst+1
        ld de,4
        set 7,(hl)
        ld b,max_entanz-1
stmlst4 add hl,de
        res 7,(hl)
        djnz stmlst4
        ld de,256*5+256-2
        ld a,(prgwin)
        call SyDesktop_WINDIN
        xor a
        jr stmedi
stmlst0 xor a
        ld de,stmlsttxt
        ld ix,stmentlst+1
stmlst1 push af
        push de
        call stment
        pop de
        jr z,stmlst3
        res 5,(ix+0)
        ld bc,4
        add ix,bc
        ld c,31
        ld a,(stmentbuf+1)
        or a
        ld hl,stmlste
        jr z,stmlst2
        cp 3
        ld hl,stmentbuf+2
        jr nz,stmlst2
        ld a,129
        ld (de),a
        inc de
        inc hl
        dec c
stmlst2 ldir
        inc de
        pop af
        inc a
        jr stmlst1
stmlst3 pop af
        ld b,a
        ld a,(stmblknum)
        or a
        ld a,b
        ret nz
        ld c,a
        ld ix,stmentlst+1
        ld de,4
        sub 7
stmlst5 sub 1
        jp p,stmlst6
        set 5,(ix+0)
stmlst6 add ix,de
        djnz stmlst5
        ld a,c
        ret

;### STMEDI -> loads an entry into the editor fields and updates display
;### Destroyed  AF,BC,DE,HL,IX,IY
stmedi  call stment
        scf
        jr z,stmedi0
        ld e,0
        call stmsys
        ld a,-2
        jr c,stmedi3            ;* system -> read only
        ld a,(stmentbuf+1)
        sub 1
stmedi0 ld e,13
        ld a,14
        jr c,stmedi4            ;* line -> show nothing
        ld a,64                 ;everything else -> hide "read only"
        ld (cfgstmdat0+2),a
        ld a,5+13
        ld hl,stmentbuf+3
        jr nz,stmedi1           ;* submenu
        dec hl                  ;* link
        push hl
        call strskp
        ld de,stmbufpti
        call strcop
        ld de,stmbufsti
        call strcop
        ld a,(hl)
        ld (stmentopn),a
        ld (stmobjrun+12),a
        ld a,13+13
        pop hl
stmedi1 ld (cfgstmgrp),a
        push af
        ld de,stmbufnmi
        call strcop
        ld ix,stmobjnmi
        call strinp
        ld ix,stmobjpti
        call strinp
        ld ix,stmobjsti
        call strinp
        pop af
        ld d,13
        sub d
        neg
        ld e,a
stmedi2 ld a,(prgwin)
        jp SyDesktop_WINDIN
stmedi3 ld e,a
        neg
        ld d,13
        add d
stmedi4 ld (cfgstmgrp),a
        ld a,1                  ;show "read only"
        ld (cfgstmdat0+2),a
        jr stmedi2

;### STMSYS -> checks, if current entry is existing and system (read only)
;### Input      E=1 -> ignore programs/autostart
;### Output     CF=1 system entry or no entry at all
;### Destroyed  AF,HL,E
stmsys  ld a,(stmentobj+0)
        or a
        scf
        ret z
        ld a,(stmblknum)
        or a
        jr z,stmsys1
        cp 2
        scf
        ccf
        ret nz              ;not block 0 (root) or 2 (programs) -> no readonly
        ld a,(stmentnum)
        cp 1
        ret nc              ;block 2 (programs), but not autostart -> no readonly
        dec e
        ret nz              ;not ignore autostart -> readonly
        ccf
        ret
stmsys1 ld a,(stmentobj+0)
        ld hl,stmentnum
        sub (hl)            ;a=anz-cur
        add e
        add e
        cp 10
        ret

;### STMSAV -> saves current entry if changed
;### Output     CF=1 no changes
;### Destroyed  AF,BC,DE,HL,IX,IY
stmsav  ld e,0
        call stmsys
        ret c               ;read only -> finished
        ld de,(stmentbuf+1)
        ld ix,stmobjnmi
        ld a,(stmobjnmi+8)
        or a
        jr nz,stmsav4
        ld hl,"-"
        ld (stmbufnmi),hl
        call strinp
        jr stmsav1
stmsav4 bit 7,(ix+00+12)
        jr nz,stmsav1       ;name changed
        dec e
        scf
        ret nz
        inc e
        bit 7,(ix+14+12)
        jr nz,stmsav1       ;path changed
        bit 7,(ix+28+12)
        jr nz,stmsav1       ;start-in changed
        ld a,(stmentopn)
        ld hl,stmobjrun+12
        cp (hl)
        scf
        ret z               ;no changes -> finished
stmsav1 res 7,(ix+00+12)
        res 7,(ix+14+12)
        res 7,(ix+28+12)
        dec e
        ld hl,stmbufnmi
        jr z,stmsav2
        ld de,stmentbuf+3
        call strcop
        jr stmsav3
stmsav2 ld de,stmentbuf+2
        call strcop
        ld hl,stmbufpti
        call strcop
        ld hl,stmbufsti
        call strcop
        ld hl,stmobjrun+12
        ldi
stmsav3 ex de,hl
        ld de,stmentbuf
        or a
        sbc hl,de
        ex de,hl            ;e=new length
        ld d,(hl)           ;d=old length
        ld a,e
        cp d
        ld (stmsav7+1),a
        ld (hl),a
        ld hl,0
        ld (stmlen1+1),hl
        jr z,stmsav6
        ld a,e
        sub d
        jr c,stmsav5
        push de
        ld e,a
        ld d,0
        call stmmem
        pop de
        ret c
stmsav5 ld c,d
        ld b,0
        ld d,b
        ld hl,(stmentadr)
        call stmmov
stmsav6 ld a,(stmdatbnk)
        add a:add a:add a:add a
        ld hl,App_BnkNum
        add (hl)
        ld hl,stmentbuf
        ld de,(stmentadr)
stmsav7 ld bc,0
        rst #20:dw jmp_bnkcop       ;copy updated entry
        call stmlen
        or a
        ret

;### STMMOV -> moves data at/behind address
;### Input      BC=old length, DE=new length, HL=start address; STMLEN has to be called later for finalisation
;### Destroyed  AF,BC,DE,HL,IX,IY
stmmov  ld (stmmov0+1),hl
        push de
        push bc
        ld hl,(stmdatadr)
        push hl
        ld a,(stmdatbnk)
        rst #20:dw jmp_bnkrwd
        ld e,c:ld d,b       ;de=len startmenu
        dec hl:dec hl
        add hl,bc
        rst #20:dw jmp_bnkrwd
        ex de,hl
        add hl,bc
        ex de,hl            ;de=len startmenu+icons
        dec hl:dec hl
        add hl,bc
        rst #20:dw jmp_bnkrwd
        ex de,hl
        add hl,bc           ;hl=len startmenu+icons+widgets
        pop bc
        add hl,bc           ;hl=datbeg + datlen (=datend)
        ld bc,(stmentadr)
        sbc hl,bc           ;hl=datbeg + datlen - entadr (=datlen at entry)
        pop de              ;de=oldlen
        sbc hl,de           ;hl=datbeg + datlen - entadr - oldlen (=datlen behind entry)
        ex (sp),hl          ;hl=newlen
        or a
        sbc hl,de           ;hl=dif (newlen-oldlen)
        ld (stmlen1+1),hl
        ld c,l
        ld b,h              
stmmov0 ld hl,0
        add hl,de           ;hl=entadr + entoldlen = source
        ld e,l:ld d,h
        add hl,bc           ;hl=entadr + entoldlen + dif = destination
        ex de,hl            ;hl=source, de=destination
        xor a
        rl b                ;cf=1 -> use ldir, cf=0 use lddr
        rla                 ;a=0 -> use lddr, a=1 use ldir
        pop bc              ;bc=length
        or a
        jr nz,stmmov1
        add hl,bc
        dec hl
        ex de,hl
        add hl,bc
        dec hl
        ex de,hl
stmmov1 ld (App_MsgBuf+6),bc
        ld (App_MsgBuf+8),a
        ld a,(extprcid)
        ld bc,256*FNC_DXT_STMCOP+MSR_DSK_EXTDSK
        call msgsnd
        jp stmini0

;### STMLEN -> updates length vars after STMMOV
;### Destroyed  AF,BC,DE,HL,IX,IY
stmlen  ld a,(stmdatbnk)
        ld hl,(stmdatadr)
        call stmlen1
        ld hl,(stmblkadr)
        dec hl:dec hl:dec hl:dec hl
        call stmlen1
stmlen0 ld a,(extprcid)
        ld bc,256*FNC_DXT_STMIIN+MSR_DSK_EXTDSK
        call msgsnd
        call stmini0
        or a
        ret
stmlen1 ld de,0
        rst #20:dw jmp_bnkrwd
        dec hl:dec hl
        ex de,hl
        add hl,bc
        ld c,l:ld b,h
        ex de,hl
        rst #20:dw jmp_bnkwwd
        ret

;### STMSWP -> swaps two entries
;### Input      A=first entry ID
stmswp  ld hl,(stmentnum)
        push hl
        call stment
        ld hl,(stmentadr)
        ld e,l
        ld d,h
        ld c,a
        ld b,0
        add hl,bc
        ld a,(stmdatbnk)
        rst #20:dw jmp_bnkrbt
        dec hl
        ld c,b
        ld b,a
        add a:add a:add a:add a
        push af
        add b
        ld b,0
        push de
        push bc
        rst #20:dw jmp_bnkcop
        pop bc
        pop hl
        add hl,bc
        ex de,hl
        pop af
        ld hl,App_BnkNum
        add (hl)
        ld hl,stmentbuf
        ld c,(hl)
        rst #20:dw jmp_bnkcop
        call stmlen0
        pop hl
        ld a,l
        jp stment

;### STMLAD -> gets entry address within list control
;### Input      A=entry ID
;### Output     HL=list control position, IX=list control entry
stmlad  ld b,a
        add a:add a
        ld c,a
        ld a,b
        ld b,0
        ld ix,stmentlst+1
        add ix,bc
        ld hl,stmentobj+12
        ret

;### STMRBL -> removes one submenu block and updates pointers
;### Input      A=block ID
;### Output     [no re-init done!]
;### Destroyed  AF,BC,DE,HL,IX,IY (stmblknum), (stmblkadr)
stmrbl  ld (stmrbl3+1),a
        call stmblk                 ;remove block
        dec hl:dec hl:dec hl:dec hl
        ld a,(stmdatbnk)
        rst #20:dw jmp_bnkrwd
        dec hl:dec hl
        inc bc:inc bc
        ld de,0
        push af
        call stmmov
        pop af
        ld hl,(stmdatadr)
        call stmlen1
        xor a                       ;update pointers
stmrbl1 push af
        call stmblk
        ld a,c
        or b
        jr z,stmrbl6
        xor a
stmrbl2 push af
        call stment0
        rst #20:dw jmp_bnkrwd
        inc c:dec c
        jr z,stmrbl5
        dec b:dec b:dec b           ;check if entry is submenu
        jr nz,stmrbl4
        rst #20:dw jmp_bnkrbt
        ld a,b
stmrbl3 cp 0                        ;check, if submenu block >= removed one
        jr c,stmrbl4
        dec a
        ld b,a
        dec hl
        ld a,(stmdatbnk)
        rst #20:dw jmp_bnkwbt       ;yes -> decrease it by 1
stmrbl4 pop af
        inc a
        jr stmrbl2
stmrbl5 pop af
        pop af
        inc a
        jr stmrbl1
stmrbl6 pop af
        ret

;### STMRBR -> removes a menu block and all nested submenus as well (recursive)
;### Input      E=block ID
;### Output     [re-init done]
;### Destroyed  AF,BC,DE,HL,IX,IY (stmblknum), (stmblkadr), (stmentnum)
stmrbrt ds 8    ;blockID stack
stmrbrp db 0    ;pointer to ID stack

stmrbr  xor a
        ld (stmrbrp),a
stmrbr0 ld hl,stmrbrp       ;add actual block to stack
        ld c,(hl)
        inc (hl)
        ld b,0
        ld hl,stmrbrt
        add hl,bc
        ld (hl),e
        ld a,e              ;get actual block
        call stmblk
        xor a
stmrbr1 push af
        call stment0
        ld a,(stmdatbnk)
        rst #20:dw jmp_bnkrwd
        inc c:dec c
        ld a,b
        pop bc
        jr z,stmrbr2
        cp 3                ;search for submenus inside actual block
        jr z,stmrbr3
        ld a,b
        inc a
        jr stmrbr1
stmrbr2 ld a,b              ;update menurecord size
        cp 1
        adc 0
        add a:add a:add a
        inc a
        cpl
        ld e,a
        ld d,-1
        call stmrec
        ld a,(stmblknum)    ;** no (more) submenus found -> delete actual block
        call stmrbl
        ld hl,stmrbrp
        dec (hl)            ;remove actual block from stack
        jp z,stmlen0        ;stack is empty -> finish, do a re-init
        dec (hl)
        ld c,(hl)
        ld b,0
        ld hl,stmrbrt
        add hl,bc
        ld e,(hl)           ;get previouse block from stack and continue...
        jr stmrbr0
stmrbr3 dec hl              ;** submenu entry found
        ld a,(stmdatbnk)
        ld b,0              ;set its type to 0
        rst #20:dw jmp_bnkwbt
        rst #20:dw jmp_bnkrbt
        ld e,b              ;remove its submenu block
        jr stmrbr0

;### STMNUM -> check, if maximum amount of entries per menu reached
;### Output     CF=1 maximum reached, HL=warning pointer
stmnum  ld a,(stmentobj+0)
        cp 24
        ccf
        ld hl,errnumobj
        ret

;### STMMEM -> check, if memory is full
;### Input      DE=additional memory
;### Output     CF=1 memory full, HL=warning pointer
stmmem  ld hl,(stmdatadr)
        ld a,(stmdatbnk)
        db #dd:ld l,3
stmmem1 rst #20:dw jmp_bnkrwd
        ex de,hl
        add hl,bc
        ex de,hl
        dec hl:dec hl
        add hl,bc
        db #dd:dec l
        jr nz,stmmem1
        ld hl,16383-256-2   ;(-2 for possible root seperator)
        or a
        sbc hl,de
        ld hl,errmemobj
        ret

;### STMREC -> updates stmreclen and checks, if it's too large
;### Input      DE=difference
;### Output     CF=1 record area full, HL=warning pointer
stmrec  ld hl,(stmreclen)
        add hl,de
        ld de,8             ;(+8 for possible root separator)
        add hl,de
        bit 2,h
        jr nz,stmrec1
        sbc hl,de
        ld (stmreclen),hl
        or a
        ret
stmrec1 scf
        ld hl,errmemobj
        ret

;### STMNAM -> generates name out of the filename or the fileheader
stmnamx db "EXE",0
stmnamy db "COM",0

stmnam  ld hl,stmbufpti     ;hl=complete path
        ld e,l              ;de=start of filename
        ld d,h
        ld bc,0             ;bc=start of extension
stmnam1 ld a,(hl)
        or a
        jr z,stmnam4
        cp 32
        jr z,stmnam4
        inc hl
        cp "."
        jr z,stmnam3
        cp "\"
        jr z,stmnam2
        cp "/"
        jr nz,stmnam1
stmnam2 ld e,l
        ld d,h
        jr stmnam1
stmnam3 ld c,l
        ld b,h
        jr stmnam1
stmnam4 ld a,c
        or b
        jr nz,stmnam8
stmnam5 ex de,hl            ;no header with name -> just take the filename
        ld de,stmbufnmi
        ld bc,50*256+255
stmnam6 ld a,(hl)
        ldi
        or a
        jr z,stmnam7
        cp "."
        jr z,stmnam7
        djnz stmnam6
stmnam7 xor a
        dec de
        ld (de),a
        ld ix,stmobjnmi
        call strinp
        ld e,16
        call stmedi2
        call stmrfs0
        ret
stmnam8 ld ix,stmnamx       ;check, if exe or com
        call stmnama
        jr z,stmnam9
        ld ix,stmnamy
        call stmnama
        jr nz,stmnam5
stmnam9 push de             ;exe or com -> take name from header
        ld hl,stmbufpti
        ld a,(App_BnkNum)
        db #dd:ld h,a
        call SyFile_FILOPN
        jr c,stmnamc
        ld hl,stmbufnmi
        ld de,(App_BnkNum)
        ld bc,48
        push af
        call SyFile_FILINP
        pop bc
        push af
        ld a,b
        call SyFile_FILCLO
        pop af
stmnamc pop de
        jr c,stmnam5
        ld hl,stmbufnmi+15  ;copy name
        ld de,stmbufnmi
        ld bc,25*256+255
stmnamd ld a,(hl)
        ldi
        cp 32
        jr c,stmnam7
        cp 127
        jr nc,stmnam7
        djnz stmnamd
        jr stmnam7
stmnama ld l,c              ;check extension
        ld h,b
        db #fd:ld l,4
stmnamb ld a,(hl)
        call clcucs
        cp (ix+0)
        ret nz
        inc hl
        inc ix
        db #fd:dec l
        jr nz,stmnamb
        ret


;==============================================================================
;### STARTMENU EVENT ROUTINES #################################################
;==============================================================================

;### STMRFS -> refresh actual entry from editor
stmrfs  call stmrfs0
        jp prgprz0
stmrfs0 call stmsav
        ret c
        ld a,(stmentnum)
        push af
        call stmlst0
        pop af
        ld (stmentnum),a
        call stment
        ld e,6
        jp stmedi2

;### STMLCL -> user clicked in list
stmlcl  call stmsav
        ld e,0
        rl e
        ld a,(App_MsgBuf+3)
        cp DSK_SUB_MDCLICK
        jr z,stmldw
stmlcl1 ld a,(stmentnum)
        dec e
        push af
        call nz,stmlst0
        pop af
        ld (stmentnum),a
        ld e,6
        call nz,stmedi2
        ld a,(stmentobj+12)
        ld hl,stmentnum
        cp (hl)
        call nz,stmedi
        jp prgprz0

;### STMLDW -> enter, if entry is submenu
stmldw  call stmsav
        ld e,1
        call stmsys
        jp c,prgprz0
        ld hl,(stmentbuf)
        inc l:dec l
        jp z,prgprz0
        ld a,h
        cp 3
        jr nz,stmlcl1
        ld hl,(stmpthsln)   ;extend path string
        ld h,0
        ld bc,stmtxtlct
        add hl,bc
        ex de,hl
        ld hl,stmentbuf+3
        call strcop
        ex de,hl
        ld (hl),a
        dec hl
        ld (hl),"/"
        ld bc,stmtxtlct-1
        or a
        sbc hl,bc
        ld a,l
        ld (stmpthsln),a
        ld hl,stmpthlen     ;extend path IDs
        inc (hl)
        ld l,(hl)
        ld h,0
        ld bc,stmpthids-1
        add hl,bc
        ld a,(stmblknum)
        ld (hl),a
        ld a,(stmentbuf+2)  ;enter new block
stmldw1 call stmblk
        call stmlst
        jp prgprz0

;### STMLUP -> go to previous block
stmlup  call stmsav
        ld hl,stmpthlen     ;shorten path IDs
        xor a
        cp (hl)
        jp z,prgprz0
        dec (hl)
        ld l,(hl)
        ld h,0
        ld bc,stmpthids
        add hl,bc
        ld a,(hl)
        push af
        ld hl,(stmpthsln)   ;shorten path string
        ld h,0
        ld bc,stmtxtlct-1
        add hl,bc
stmlup1 dec hl
        ld a,(hl)
        cp "/"
        jr nz,stmlup1
        inc hl
        ld (hl),0
        inc bc
        sbc hl,bc
        ld a,l
        ld (stmpthsln),a
        pop af
        jr stmldw1

;### STMMUP -> moves entry up
stmmup  ld e,0
        call stmsys
        jp c,prgprz0        ;system -> don't move
        call stmsav
        ld a,(stmentnum)
        push af
        sub 1
        jp c,prgprz0        ;entry 0 -> already on the top
        ld (stmentnum),a
        ld e,0
        call stmsys
        pop bc
        ld a,b
        ld (stmentnum),a
        jp c,prgprz0        ;other entry is system -> don't move
        dec a
        call stmswp         ;swap with previouse entry
        ld hl,stmentnum
        ld a,(hl)
        dec a
        push af
        call stmlad
        ld (hl),a
        set 7,(ix+0)
        res 7,(ix+4)
stmmup0 call stmlst0
        pop af
        ld (stmentnum),a
        call stment
stmmup1 ld e,6
        call stmedi2
        jp prgprz0

;### STMMDW -> moves entry down
stmmdw  ld e,0
        call stmsys
        jp c,prgprz0        ;system -> don't move
        call stmsav
        ld a,(stmentnum)
        inc a
        ld hl,stmentobj+0
        cp (hl)
        jp z,prgprz0        ;last entry -> already at the end
        ld (stmentnum),a
        ld e,0
        call stmsys
        ld hl,stmentnum
        dec (hl)
        jp c,prgprz0        ;other entry is system -> don't move
        ld a,(hl)
        call stmswp         ;swap with next entry
        ld hl,stmentnum
        ld a,(hl)
        inc a
        push af
        call stmlad
        ld (hl),a
        set 7,(ix+0)
        res 7,(ix-4)
        jr stmmup0

;### STMDEL -> deletes entry
stmdel  ld e,0
        call stmsys
        jp c,prgprz0
        ld a,(stmentbuf+1)
        dec a
        jr z,stmdel1
        ld a,(stmentnum)        ;** remove submenu(s)
        push af
        ld a,(stmblknum)
        push af
        ld de,(stmentbuf+2)
        call stmrbr
        pop af
        call stmblk
        pop af
        call stment
stmdel1 ld de,-8                ;** remove entry
        call stmrec
        ld de,0
        ld bc,(stmentbuf+0)
        ld b,e
        ld hl,(stmentadr)
        call stmmov
        call stmlen
        ld a,(stmblknum)
        or a
        jr nz,stmdel2
        ld a,(stmentobj)
        cp 10
        jr nz,stmdel2
        ld de,-8                ;last user defined entry in root -> remove seperator as well
        call stmrec
        xor a
        call stment
        ld de,0
        ld bc,2
        ld hl,(stmentadr)
        call stmmov
        call stmlen
stmdel2 call stmlst             ;update list
        jp prgprz0

;### STMADM -> add new submenu
stmadmd db stmadmd0-stmadmd,3,0,"New submenu",0:stmadmd0

stmadm  ld a,(stmpthlen)        ;too many submenus?
        cp 7
        ld hl,errsubobj
        jp nc,prgwrn
        call stmnum             ;too many entries?
        jp c,prgwrn
        ld de,5+stmadmd0-stmadmd
        call stmmem             ;memory full?
        jp c,prgwrn
        ld de,8+2+8
        call stmrec             ;too much record data?
        jp c,prgwrn
        call stmsav             ;save current entry
        ld e,-1
        ld hl,(stmdatadr)
        inc hl:inc hl
stmadm1 inc e                   ;search for last block
        ld a,(stmdatbnk)
        rst #20:dw jmp_bnkrwd
        add hl,bc
        ld a,c
        or b
        jr nz,stmadm1
        dec hl:dec hl
        ld a,e
        ld (stmadmd+2),a        ;store block ID in new entry record
        ld bc,0
        ld de,5
        push hl
        call stmmov             ;create space for new submenu block
        pop hl
        ld a,(stmdatbnk)
        ld bc,3
        rst #20:dw jmp_bnkwwd   ;write empty block
        inc hl:inc hl
        ld b,0
        rst #20:dw jmp_bnkwbt
        ld hl,(stmdatadr)
        call stmlen1            ;update total startmenu length
        ld iy,stmadmd
        call stmads0
        jp prgprz0

;### STMADS -> add new shortcut
stmadsd db stmadsd0-stmadsd,1,"New shortcut",0,0,0,0:stmadsd0
stmadsl db 2,0

stmads  call stmnum             ;too many entries?
        jp c,prgwrn
        ld de,stmadsd0-stmadsd
        call stmmem             ;memory full?
        jp c,prgwrn
        ld de,8
        call stmrec             ;too much record data?
        jp c,prgwrn
        call stmsav             ;save current entry
        ld iy,stmadsd
        call stmads0
        ld a,1
        ld (stmbrpf),a
        jp stmbrp

stmads0 ld a,(stmblknum)
        or a
        jr nz,stmads2
        ld a,(stmentobj+0)      ;** inside root
        cp 8
        jr nz,stmads3
        call stmadsy            ;no additional entries yet -> add separator as well
        push iy
        ld iy,stmadsl
        xor a
        call stmadsx
        pop iy
        xor a
        jr stmads1
stmads3 sub 10                  ;only add in seperated area
        ld hl,stmentnum
        cp (hl)
        jr nc,stmads2
        push af
        call stmadsy
        pop af
        inc a
        jr stmads1
stmads2 ld a,(stmentobj+0)      ;** not in root
        or a
        jr z,stmads1
        call stmadsy
        inc a
stmads1 push af
        call stmadsx
        pop af
        push af
        call stmlad
        ld (hl),a
        set 7,(ix+0)
        call stmlst0
        ld (stmentobj+0),a
        pop af
        ld (stmentnum),a
        ld (stmentobj+12),a
        call stmedi
        ld e,6
        jp stmedi2
;A=position, IY=record
stmadsx call stment
        ld e,(iy+0)
        ld d,0
        ld (stmsav7+1),de
        push iy
        push de
        ld bc,0
        ld hl,(stmentadr)
        call stmmov
        pop bc
        pop hl
        ld de,stmentbuf
        ldir
        jp stmsav6
stmadsy ld a,(stmentnum)
        call stmlad
        res 7,(ix+0)
        ret

;### STMBRP -> browse path
stmbrpf db 0        ;flag, if generate name

stmbrp  ld hl,stmbufpti
        ld de,filselbuf+4
        ld bc,110
        ldir
        xor a
        ld hl,stmbrp1
        jp selopn
stmbrp1 ld l,19
        ld de,stmbufpti
        ld bc,109
        ld ix,stmobjpti
        call stmbrp0
        ld hl,stmbrpf
        bit 0,(hl)
        ld (hl),0
        call nz,stmnam
        jp prgprz0
stmbrp0 push hl
        ld hl,filselbuf+4
        ldir
        call strinp
        set 7,(ix+12)
        pop de
        ld a,(prgwin)
        jp SyDesktop_WINDIN

;### STMBRS -> browse startin
stmbrs  ld hl,stmbufsti
        ld de,filselbuf+4
        ld bc,90
        ldir
        ld a,128
        ld hl,stmbrs1
        jp selopn
stmbrs1 ld l,22
        ld de,stmbufsti
        ld bc,89
        ld ix,stmobjsti
        call stmbrp0
        jp prgprz0

stmltr  jp prgprz0  ;tree


;==============================================================================
;### SUB ROUTINES #############################################################
;==============================================================================

;### MSGSND -> Send message to process
;### Input      A=process ID, C=command, B/E/D/L/H=Parameter1/2/3/4/5
msgsnd  db #dd:ld h,a
        ld a,(App_PrcID)
        db #dd:ld l,a
        ld iy,App_MsgBuf
        ld (App_MsgBuf+0),bc
        ld (App_MsgBuf+2),de
        ld (App_MsgBuf+4),hl
        rst #10
        ret

;### SELOPN -> starts a "file selection" session
;### Input      filselbuf+4=path, A=file[0]/directory[128] selection, HL=routine address, when selection has been completed
;### Output     (jumps to prgprz0) -> filselbuf+4 will contain selected path/file
selopn  db 0
        ld (selopn0+1),hl
        ld hl,filselbuf
        ld (App_MsgBuf+8),hl
        ld hl,App_BnkNum
        add (hl)
        ld l,a
        ld h,8
        ld (App_MsgBuf+6),hl
        ld hl,200
        ld (App_MsgBuf+10),hl
        ld hl,8000
        ld (App_MsgBuf+12),hl
        ld a,#c9
        ld (selopn),a
        ld iy,App_MsgBuf
        ld c,MSC_SYS_SELOPN
        call SySystem_SendMessage
        jp prgprz0
selopna ld ix,cfgstmwin
        ld (ix+51),0
        ld a,(App_MsgBuf+1)
        inc a
        jr nz,selopn1
        ld a,(App_MsgBuf+2)
        ld (ix+51),a
        jp prgprz0
selopn1 dec a
        ld a,0
        ld (selopn),a
selopn0 jp z,0
        jp prgprz0

;### MEMCHK -> checks, if enough memory available
;### Input      ?
;### Output     CF=0 ok, CF=1 memory full
;### Destroyed  ?
memchk  ;...
        or a
        ret

;### STRSKP -> skips text string (behind 0-terminator)
;### Input      HL=string
;### Output     HL=behind 0 terminator
strskp  xor a
        ld bc,-1
        cpir
        ret

;### STRCOP -> copies string until 0-terminator
;### Input      HL=source, DE=destination
;### Output     DE,HL=behind 0-terminator, A=0
;### Destroyed  F,BC,HL
strcop  ld a,(hl)
        ldi
        or a
        jr nz,strcop
        ret

;### STRLEN -> Ermittelt L‰nge eines Strings
;### Eingabe    HL=String (0-terminiert)
;### Ausgabe    HL=Stringende (0), BC=L‰nge (maximal 255, ohne Terminator)
;### Ver‰ndert  -
strlen  push af
        xor a
        ld bc,255
        cpir
        ld a,254
        sub c
        ld c,a
        dec hl
        pop af
        ret

;### STRINP -> Initialisiert Textinput (abh‰ngig vom String, den es bearbeitet)
;### Eingabe    IX=Control
;### Ausgabe    HL=Stringende (0), BC=L‰nge (maximal 255)
;### Ver‰ndert  AF
strinp  ld l,(ix+0)
        ld h,(ix+1)
        call strlen
        ld (ix+8),c
        ld (ix+4),c
        xor a
        ld (ix+2),a
        ld (ix+6),a
        ld (ix+12),a
        ret

;### CLCUCS -> Wandelt Klein- in Groﬂbuchstaben um
;### Eingabe    A=Zeichen
;### Ausgabe    A=ucase(Zeichen)
;### Ver‰ndert  F
clcucs  cp "a"
        ret c
        cp "z"+1
        ret nc
        add "A"-"a"
        ret


;==============================================================================
;### DATA AREA ################################################################
;==============================================================================


App_BegData

;icon !!first in data area!!
prgicn16c db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Desktop und Menu Links
db #12,#22,#22,#22,#22,#22,#22,#22,#22,#22,#22,#22,#1F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#1F,#FF,#F1,#1F,#FF,#FF,#FF,#F2,#00,#00,#2F,#F2,#1F,#FF,#F1,#81,#FF,#FF,#FF,#F0,#12,#11,#0F,#F2
db #1F,#FF,#F1,#88,#1F,#FF,#FF,#F0,#21,#11,#0F,#F2,#1F,#FF,#F1,#88,#81,#FF,#FF,#F0,#11,#11,#0F,#F2,#1F,#FF,#F1,#88,#88,#1F,#FF,#F0,#11,#11,#0F,#F2,#1F,#FF,#F1,#88,#81,#FF,#FF,#F2,#00,#00,#2F,#F2
db #1F,#FF,#F1,#81,#88,#1F,#FF,#FF,#FF,#FF,#FF,#F2,#1F,#FF,#F1,#1F,#18,#1F,#F1,#1F,#1F,#11,#F1,#12,#66,#66,#66,#66,#F1,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#61,#61,#16,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2
db #66,#66,#66,#66,#66,#66,#66,#F2,#00,#00,#2F,#F2,#6F,#F0,#F0,#61,#16,#16,#16,#F0,#12,#11,#0F,#F2,#6F,#0F,#FF,#66,#66,#66,#66,#F0,#21,#11,#0F,#F2,#66,#66,#66,#61,#11,#61,#16,#F0,#11,#11,#0F,#F2
db #61,#16,#11,#66,#66,#66,#66,#F0,#11,#11,#0F,#F2,#66,#66,#66,#61,#16,#11,#16,#F2,#00,#00,#2F,#F2,#61,#61,#11,#66,#66,#66,#66,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#FF,#FF,#F1,#1F,#1F,#11,#F1,#12
db #61,#11,#61,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#61,#16,#16,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#11,#11,#11,#11,#11,#11,#11,#12

max_entanz  equ 24      ;maximum of 24 entries per block
max_entnam  equ 48      ;maximum of 48 chars per entry name (including 0-terminator)
max_entpth  equ 100     ;maximum of 48 chars per entry target (including 0-terminator)
max_entdir  equ 100     ;maximum of 48 chars per entry start in (including 0-terminator)

stmlsttxt   ds 24*32    ;list text (24entries, 32chars max/entry)

stmtxttit   db "Startmenu Editor",0
stmtxtcls   db "Close",0
stmtxtlcd   db "Current location:",0

stmtxtlct   db "/Start/",0:ds 256-8

stmtxtlup   db "<<",0
stmtxtent   db ">>",0
stmtxtltr   db "Tree",0
stmtxtasc   db "Add shortcut",0
stmtxtasm   db "Add submenu",0
stmtxtdel   db "Delete",0
stmtxtmup   db "Entry up",0
stmtxtmdw   db "Entry down",0
stmtxtedi   db "Edit entry",0
stmtxtnms   db "[entry is read only]",0
stmtxtnmd   db "Name",0
stmtxtptd   db "Target",0
stmtxtbrw   db "Browse",0
stmtxtstd   db "Start in",0
stmtxtrnd   db "Run",0
stmtxtrfs   db "Refresh",0

stmbufnmi   ds 50
stmbufpti   ds 110
stmbufsti   ds 90

stmtxtrun0  db "Default",0
stmtxtrun1  db "Normal window",0
stmtxtrun2  db "Minimized",0
stmtxtrun3  db "Maximized",0

filselbuf   db "*  ",0
            ds 256-4

errmemtxt1  db "Memory full!",0
errmemtxt2  db "There is no memory left for",0
errmemtxt3  db "completing this operation.",0

errnumtxt1  db "Too many entries! The maximum",0
errnumtxt2  db "amount of entries (24) for this",0
errnumtxt3  db "submenu has been reached.",0

errsubtxt1  db "Too many nested submenus!",0
errsubtxt2  db "The deepest level for a",0
errsubtxt3  db "submenu is 8.",0


;==============================================================================
;### TRANSFER AREA ############################################################
;==============================================================================

App_BegTrns
;### PRGPRZS -> stack for application process
        ds 128
prgstk  ds 6*2
        dw prgprz
App_PrcID db 0

;### App_MsgBuf -> message buffer
App_MsgBuf ds 14


;### ALERT BOXES ##############################################################

errmemobj   dw errmemtxt1,4*1+2, errmemtxt2,4*1+2, errmemtxt3,4*1+2     ;memory full
errnumobj   dw errnumtxt1,4*1+2, errnumtxt2,4*1+2, errnumtxt3,4*1+2     ;too many entries
errsubobj   dw errsubtxt1,4*1+2, errsubtxt2,4*1+2, errsubtxt3,4*1+2     ;too many submenus


;### STARTMENU EDITOR #########################################################

cfgstmwin   dw #1501,0,50,3,220,171,0,0,220,171,220,171,220,171,prgicnsml,stmtxttit,0,0,cfgstmgrp,0,0:ds 136+14
cfgstmgrp   db 13,0:dw cfgstmdat,0,0,2*256+2,0,0,0
cfgstmdat
dw 00,     255*256+0, 2,           0,0,1000,1000,0      ;00=Hintergrund
dw 00,     255*256+1, stmobjlcd,   4,  8, 22,  8,0      ;01=Beschreibung  Location
dw stmlup, 255*256+16,stmtxtlup,  150, 4, 32, 12,0      ;02=Button "<<"
dw stmldw, 255*256+16,stmtxtent,  184, 4, 32, 12,0      ;03=Button ">>"
dw stmltr, 255*256+64,stmtxtltr,  184, 4, 32, 12,0      ;04=Button "Tree" [inactive]
dw 00,     255*256+1, stmobjlct,   4, 18,212,  8,0      ;05=Text          Location
dw stmlcl, 255*256+41,stmentobj,  4,  30,142, 68,0      ;06=Liste Eintr‰ge
dw stmads, 255*256+16,stmtxtasc,  150,30, 66, 12,0      ;07=Button "Add shortcut"
dw stmadm, 255*256+16,stmtxtasm,  150,44, 66, 12,0      ;08=Button "Add submenu"
dw stmmup, 255*256+16,stmtxtmup,  150,58, 66, 12,0      ;09=Button "Entry Up"
dw stmmdw, 255*256+16,stmtxtmdw,  150,72, 66, 12,0      ;10=Button "Entry Down"
dw stmdel, 255*256+16,stmtxtdel,  150,86, 66, 12,0      ;11=Button "Delete"
dw 00,     255*256+3, stmobjedi,   0,101,220, 70,0      ;12=Rahmen Edit

dw 00,     255*256+0, 2,           8,109,204, 56,0      ;13=Edit Clear
cfgstmdat0
dw 00,     255*256+1, stmobjnms,   8,113,190,  8,0      ;14=Beschreibung "read only"

dw 00,     255*256+1, stmobjnmd,   8,113, 22,  8,0      ;15=Beschreibung  Name
dw 00,     255*256+32,stmobjnmi,  42,111,170, 12,0      ;16=Input         Name
dw stmrfs, 255*256+16,stmtxtrfs, 164,153, 48, 12,0      ;17=Button "Refresh"
dw 00,     255*256+1, stmobjptd,   8,127, 22,  8,0      ;18=Beschreibung  Target
dw 00,     255*256+32,stmobjpti,  42,125,128, 12,0      ;19=Input         Target
dw stmbrp, 255*256+16,stmtxtbrw, 172,125, 40, 12,0      ;20=Button Browse Target
dw 00,     255*256+1, stmobjstd,   8,141, 22,  8,0      ;21=Beschreibung  Start in
dw 00,     255*256+32,stmobjsti,  42,139,128, 12,0      ;22=Input         Start in
dw stmbrs, 255*256+16,stmtxtbrw, 172,139, 40, 12,0      ;23=Button Browse Start in
dw 00,     255*256+1, stmobjrnd,   8,154, 22,  8,0      ;24=Beschreibung  Run
dw 00,     255*256+42,stmobjrun,  42,153, 78, 10,0      ;25=Input         Run

stmobjlcd   dw stmtxtlcd,2+4
stmobjlct   dw stmtxtlct,1+0+128
stmobjedi   dw stmtxtedi,2+4
stmobjnms   dw stmtxtnms,2+12

stmobjnmd   dw stmtxtnmd,2+4
stmobjptd   dw stmtxtptd,2+4
stmobjstd   dw stmtxtstd,2+4
stmobjrnd   dw stmtxtrnd,2+4

stmobjnmi   dw stmbufnmi,0,0,0,0,49,0   ;**\
stmobjpti   dw stmbufpti,0,0,0,0,109,0  ;   don't change
stmobjsti   dw stmbufsti,0,0,0,0,89,0   ;**/

stmentobj   dw 0,0,stmentlst,0,256*0+1,stmentrow,0,1
stmentrow   dw 0,132,00,0
stmentlst
dw 00,00*32+stmlsttxt, 01,01*32+stmlsttxt, 02,02*32+stmlsttxt, 03,03*32+stmlsttxt, 04,04*32+stmlsttxt, 05,05*32+stmlsttxt, 06,06*32+stmlsttxt, 07,07*32+stmlsttxt
dw 08,08*32+stmlsttxt, 09,09*32+stmlsttxt, 10,10*32+stmlsttxt, 11,11*32+stmlsttxt, 12,12*32+stmlsttxt, 13,13*32+stmlsttxt, 14,14*32+stmlsttxt, 15,15*32+stmlsttxt
dw 16,16*32+stmlsttxt, 17,17*32+stmlsttxt, 18,18*32+stmlsttxt, 19,19*32+stmlsttxt, 20,20*32+stmlsttxt, 21,21*32+stmlsttxt, 22,22*32+stmlsttxt, 23,23*32+stmlsttxt

stmobjrun   dw 4,0,stmlstrun,0,1,stmrowrun,0,1
stmrowrun   dw 0,1000,0,0
stmlstrun   dw 0,stmtxtrun0, 0,stmtxtrun1, 0,stmtxtrun2, 0,stmtxtrun3
