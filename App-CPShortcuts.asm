;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                      DESKTOP AND STARTMENU SHORTCUTS                       @
;@                                                                            @
;@             (c) 2004-2025 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


;==============================================================================
;### CODE-TEIL ################################################################
;==============================================================================

;### PRGPRZ -> Programm-Prozess
prgsubnum   db 0            ;Zwischenspeicher für zu öffnendes Subwin

prgwin      db 0            ;Nummer des Haupt-Fensters

windatprz   equ 3   ;Prozeßnummer
windatsup   equ 51  ;Nummer des Superfensters+1 oder 0

prgprz  call prgdbl
        call prglng
        ld a,(App_PrcID)
        ld (prgwinlnk+windatprz),a
        call sysini
        call lnkini

        ld a,(App_BnkNum)
        ld de,prgwinlnk
        call SyDesktop_WINOPN
        jp c,prgend
        ld (prgwin),a           ;Fenster wurde geöffnet -> Nummer merken

prgprz0 call msgget
        jr nc,prgprz0
        cp MSC_GEN_FOCUS        ;*** Application soll sich Focus nehmen
        jp z,prgfoc
        cp MSR_SYS_SELOPN       ;*** Browse-Fenster wurde geschlossen
        jp z,prgbrc
        cp MSR_DSK_WCLICK       ;*** Fenster-Aktion wurde geklickt
        jr nz,prgprz0
        ld a,(iy+2)
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jp z,prgend
        cp DSK_ACT_CONTENT      ;*** Inhalt wurde geklickt
        jp nz,prgprz0
        ld l,(iy+8)
        ld h,(iy+9)
        ld a,h
        or l
        jr z,prgprz0
        jp (hl)

;### PRGFOC -> Focus nehmen
prgfoc  ld a,(prgwin)
        call SyDesktop_WINTOP
        jp prgprz0

;### PRGBRO -> Browse-Fenster öffnen
;### Eingabe    A=Typ (1=für Link-Pfad, 2=Icon, 3=Extension-Applikation, 4=Font, 5=key load, 6=key save)
;###            HL=Text
prgbron db 0        ;type
prgbro  ld d,0
prgbro0 ld e,a
        ld a,(prgbron)
        or a
        ret nz
        ld a,e
        ld (prgbron),a
        ld (App_MsgBuf+8),hl
        ld a,(App_BnkNum)
        add d
        ld l,a
        ld h,8
        ld (App_MsgBuf+6),hl
        ld hl,100
        ld (App_MsgBuf+10),hl
        ld hl,5000
        ld (App_MsgBuf+12),hl
        ld l,MSC_SYS_SELOPN
        ld (App_MsgBuf),hl
        ld a,(App_PrcID)
        db #dd:ld l,a
        db #dd:ld h,PRC_ID_SYSTEM
        ld iy,App_MsgBuf
        rst #10
        ret

;### PRGBRC -> Browse-Fenster schließen
;### Eingabe    P1=Typ (0=Ok, 1=Abbruch, 2=FileAuswahl bereits in Benutzung, 3=kein Speicher frei, 4=kein Fenster frei), P2=PfadLänge
prgbrc  ld a,(App_MsgBuf+1)
        or a
        jr z,prgbrc1
        inc a
        jr z,prgbrc4
        xor a
        ld (prgbron),a
        jp prgprz0
prgbrc4 ld a,(App_MsgBuf+2)
        ld (prgwinlnk+windatsup),a
        jp prgprz0
prgbrc1 ld hl,prgbron
        ld e,(hl)
        ld (hl),0
        ld a,(App_MsgBuf+2)           ;A=Pfadlänge
        dec e
        jr z,prgbrc3
        dec e
        jr z,prgbrc5
        jp prgprz0
prgbrc5 ld hl,lnkicnchs1        ;*** Link Icon
        ld de,0
        jp lnkicf0
prgbrc3 call prgbrc2            ;*** Link Applikation
        ld e,18
        call lnklsc0
        jp lnkicf
prgbrc2 ld (prgobjlnk5b+8),a
        ld (prgobjlnk5b+4),a
        xor a
        ld (prgobjlnk5b+2),a
        ld (prgobjlnk5b+6),a
        ret

;### PRGLNG -> load language pack
prglnge db ".exe",0

prglng  ld hl,(App_BegCode)
        ld de,App_BegCode
        dec h
        add hl,de               ;HL=code area end=path
        push hl
prglng1 ld a,(hl)
        inc hl
        or a
        jr nz,prglng1
        ld bc,-11
        add hl,bc
        ex de,hl
        ld hl,prglnge
        ld bc,5
        ldir
        pop de
        ld a,(App_BnkNum)
        ld c,a
        ld hl,texts_int
        ld ix,256*2+9           ;default language=9 (english), pack=2
        ld iyl,0                ;language-file version 0
        jp SySystem_LNGLOD

;### PRGDBL -> Check, if program is already running
prgdbln db "CP:Shortcuts"
prgdbl  xor a
        ld (App_BegCode+prgdatnam),a
        ld hl,prgdbln
        call prgdbl0
        or a
        ld a,"C"
        ld (App_BegCode+prgdatnam),a
        ret nz
        ld a,h
        db #dd:ld h,a
        ld a,(App_PrcID)
        db #dd:ld l,a
        ld iy,App_MsgBuf
        ld (iy+0),MSC_GEN_FOCUS     ;send focus message to running control panel
        rst #10
        jp prgend
prgdbl0 ld e,0
        ld a,(App_BnkNum)
        jp SySystem_PRGSRV

;### PRGEND -> Programm beenden
prgend  ld hl,(App_BegCode+prgpstnum)
        call SySystem_PRGEND
prgend0 rst #30
        jr prgend0

;### MSGGET -> Message für Programm abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgget  db #dd:ld h,-1
msgget1 ld a,(App_PrcID)
        db #dd:ld l,a           ;IXL=Rechner-Prozeß-Nummer
        ld iy,App_MsgBuf        ;IY=Messagebuffer
        rst #08                 ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        or a
        db #dd:dec l
        ret nz
        ld iy,App_MsgBuf
        ld a,(App_MsgBuf)
        or a
        jr z,prgend
        scf
        ret


bnknumget   db 0
bnknumput   db 0

sysini  ld e,7
        ld hl,jmp_sysinf
        rst #28                 ;DE=System, IX=Data, IY=Transfer
        ld a,(App_BnkNum)
        add a:add a:add a:add a
        db #fd:add l
        ld (bnknumget),a
        rlca:rlca:rlca:rlca
        ld (bnknumput),a
        ld hl,jmp_sysinf        ;*** Systempfad holen
        ld de,256*31+5
        ld ix,syssyspth
        ld iy,0
        rst #28
        ret


;==============================================================================
;### LINK-FENSTER #############################################################
;==============================================================================

lnkadrmen   equ 0               ;Offset Menunamen (20*20)
lnkadrpth   equ 0+400           ;Offset Pfade     (28*32)
lnkadricn   equ 0+400+896       ;Offset Iconnamen (8*24)
lnkadrspr   equ 0+400+896+192   ;Offset Sprites   (8*147)
lnklenall   equ 0+400+896+192+1176  ;Gesamtlänge der Linkdaten

lnklstnum   db 0    ;0=Desktop, 1=Startmenu
lnkentnum   db 0    ;ausgewählter Eintrag

;### LNKINI -> Link-Fenster initialisieren
lnkini  ld e,9                  ;*** Icons updaten
        rst #20:dw jmp_sysinf
        ld e,7                  ;*** Namen, Pfade und Icons holen
        ld hl,jmp_sysinf
        rst #28             ;DE=System, IX=Data, IY=Transfer
        push ix:pop hl
        ld de,lnkcfgdat
        ld bc,lnklenall
        ld a,(bnknumget)
        rst #20:dw jmp_bnkcop
        ld hl,jmp_sysinf        ;*** Anzahlen holen
        ld de,256*36+5
        ld ix,cfgicnanz
        ld iy,66+2+6+5
        rst #28
        call lnklsi
        call lnkeni
        ret

;### LNKLSI -> ausgewählte Liste initialisieren
lnklsi  call lnklsi1
        ld de,lnkcfgdat
        add hl,de
        ex de,hl                ;DE=Namen
        ld a,(ix+0)             ;A=Anzahl
        ld (prgobjlnk1),a
        ld a,20
        ld hl,lnkentlst+1       ;HL=Listeneinträge
        push hl
lnklsi2 res 7,(hl)
        inc hl
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl:inc hl
        ex de,hl
        add hl,bc
        ex de,hl
        dec a
        jr nz,lnklsi2
        ld ix,prgobjlnk1        ;Liste resetten
        ld (ix+2),a
        ld (ix+12),a
        pop hl
        set 7,(hl)              ;erster Eintrag ist markiert
        ld a,(lnklstnum)
        ld ix,prgdatlnk1
        ld iy,prgdatlnk2
        or a
        jr z,lnklsi3
        res 7,(ix+2+00)         ;Startmenu -> 1 x Langname aktivieren
        set 7,(ix+2+16)
        set 7,(ix+2+32)
        res 7,(iy+2+00)         ;Startmenu -> Icon-Grafik deaktivieren
        ld a,21
        ld (prggrplnk),a
        ret
lnklsi3 set 7,(ix+2+00)         ;Desktop   -> 2 x Kurzname aktivieren
        res 7,(ix+2+16)
        res 7,(ix+2+32)
        set 7,(iy+2+00)         ;Desktop   -> Icon-Grafik aktivieren
        ld a,30
        ld (prggrplnk),a
        ret
; -> A=Listentyp, HL=Namen-Adressenoffset, BC=Namenlänge, (IX)=Anzahl
lnklsi1 ld a,(lnklstnum)
        ld hl,lnkadricn
        ld bc,24
        ld ix,cfgicnanz
        cp 1
        ret c
        ld hl,lnkadrmen
        ld bc,20
        ld ix,cfgmenanz
        ret

;### LNKENI -> ausgewählten Eintrag initialisieren
lnkeni  call lnklsi1
        cp 1
        ld a,(prgobjlnk1+12)
        ld (lnkentnum),a
        call lnkeni0
        ld de,prgobjlnk6x
        ld bc,19
        ldir
        ld bc,12-19
        add hl,bc
        ld de,prgobjlnk6y
        ld bc,12
        ldir
        push iy
        pop hl
        ld de,prgobjlnk5x
        ld bc,31
        ldir
        ld ix,prgobjlnk6b
        call strinp
        ld ix,prgobjlnk6c
        call strinp
        ld ix,prgobjlnk6d
        call strinp
        ld ix,prgobjlnk5b
        call strinp
        ld a,(lnklsttyp)
        cp 1
        ret z
lnkeni5 ld a,(lnkentnum)
        inc a
        ld bc,147
        ld hl,400+896+192-147
        ld de,4
        ld ix,cfgicnpos-4
lnkeni3 add hl,bc
        add ix,de
        dec a
        jr nz,lnkeni3
        ld bc,lnkcfgdat
        add hl,bc
        ld (prgdatlnk3+4),hl
        ld e,(ix+0)
        ld d,(ix+1)
        push de
        ex (sp),ix
        ld iy,prginplnk8c
        call lnkeni4
        pop ix
        ld e,(ix+2)
        ld d,(ix+3)
        push de
        pop ix
        ld iy,prginplnk8d
lnkeni4 ld de,0
        push iy
        call clcn32
        ex (sp),iy
        pop hl
        db #fd:ld e,l
        db #fd:ld d,h
        or a
        sbc hl,de
        inc l
        ld (iy-6),l
        ld (iy-10),l
        ret
;A=Nummer, ZF=Listentyp (0=Desktop, 1=Startmenu) -> IY=Pfad, HL=Name
lnkeni0 ld de,32
        ld iy,400
        jr z,lnkeni1
        ld iy,32*20+400
lnkeni1 or a
        jr z,lnkeni2
        add hl,bc
        add iy,de
        dec a
        jr lnkeni1
lnkeni2 ld de,lnkcfgdat
        add iy,de
        add hl,de
        ret

;### LNKLSC -> Listen-Typ wurde geklickt
lnklsc  call lnkenc2
        ld a,(lnklsttyp)
        ld hl,lnklstnum
        cp (hl)
        jp z,prgprz0
        ld (hl),a
        call lnklsi
        ld e,4
        call lnklsc0
        ld e,20
        call lnklsc0
        ld a,(lnklsttyp)
        cp 1
        jr z,lnklsc1
        ld e,-9
        ld d,21
        call lnklsc0
lnklsc1 jr lnkenc1
lnklsc0 ld a,(prgwin)
        jp SyDesktop_WININH

;### LNKENC -> Eintrag wurde in Liste geklickt
lnkencf db 0
lnkenc  call lnkenc2
        ld a,(prgobjlnk1+12)
        ld hl,lnkentnum
        cp (hl)
        jp z,prgprz0
lnkenc1 call lnkeni
        ld e,14         ;Name aktualisieren
        call lnklsc0
        ld e,15
        call lnklsc0
        ld e,16
        call lnklsc0
        ld e,18         ;Pfad aktualisieren
lnkenc8 call lnklsc0
        ld a,(lnklsttyp)
        cp 1
        jp z,prgprz0
        ld e,23         ;Icon aktualisieren
        call lnklsc0
        ld e,27         ;Pos aktualisieren
        call lnklsc0
        ld e,29
        call lnklsc0
        jp prgprz0

lnkenc2 call lnklsi1    ;A=Listentyp, HL=Namen-Adressenoffset, BC=Namenlänge, (IX)=Anzahl
        cp 1
        push af
        xor a
        ld (lnkencf),a
        ld a,(lnklstnum)
        cp 1
        ld a,(lnkentnum)
        call lnkeni0    ;IY=Pfad, HL=Name
        pop af
        ex de,hl
        ld hl,prgobjlnk6x
        ld c,-1
        ld b,19
        jr z,lnkenc3    ;*** Startmenu
        push bc         ;*** Desktop
        push de
        push iy
        push hl
        ld a,(lnkentnum)
        add a:add a
        ld e,a
        ld d,0
        ld iy,cfgicnpos
        add iy,de
        ld ix,prginplnk8c
        xor a
        ld bc,0
        ld de,10000
        push iy
        call clcr16
        pop iy
        jr c,lnkenc6
        ld (iy+0),l
        ld (iy+1),h
lnkenc6 ld ix,prginplnk8d
        xor a
        ld bc,0
        ld de,10000
        push iy
        call clcr16
        pop iy
        jr c,lnkenc7
        ld (iy+2),l
        ld (iy+3),h
lnkenc7 pop hl
        pop iy
        pop de
        pop bc
        ld b,12
        call lnkenc4
        ld hl,prgobjlnk6y
        ld b,12
lnkenc3 call lnkenc4
        push iy
        pop de
        ld hl,prgobjlnk5x
        ld bc,31
        ldir
        ld a,(lnkencf)
        or a
        ret z
        ld e,4
        jp lnklsc0
lnkenc4 ld a,(de)
        cp (hl)
        jr z,lnkenc5
        ld a,1
        ld (lnkencf),a
lnkenc5 ldi
        djnz lnkenc4
        ret

;### LNKEDW -> Eintrag in Liste nach unten schieben
lnkedw  call lnkedw0
lnkedw1 jp z,prgprz0
lnkedw2 call lnkeni5
        ld e,4
        jp lnkenc8
lnkedw0 ld a,(lnkentnum)
        ld e,a
        inc a
        ld d,a
        ld ix,prgobjlnk1
        cp (ix+0)
        jr lnkeup1

;### LNKEUP -> Eintrag in Liste nach oben schieben
lnkeup  call lnkeup0
        jr lnkedw1
lnkeup0 ld a,(lnkentnum)
        ld e,a
        ld d,a
        dec d
        or a
lnkeup1 ret z                   ;E=alte, D=neue Position
        ld c,a
        ld a,d
        ld d,c                  ;D=unteres zu tauschendes Element
        ld (lnkentnum),a        ;neue Pos eintragen
        ld (prgobjlnk1+12),a
        ld bc,lnkentlst+1
        add a:add a
        ld l,a
        ld h,0
        add hl,bc
        set 7,(hl)              ;neue Markierung setzen
        ld a,e
        add a:add a
        ld l,a
        ld h,0
        add hl,bc
        res 7,(hl)              ;alte Markierung löschen
        call lnklsi1            ;A=Listentyp, HL=Namen-Adressenoffset, BC=Namenlänge, (IX)=Anzahl
        push af
        push de
        ld a,d
        call lnkesw             ;Name verschieben
        pop de
        pop af
        push af
        push de
        ld hl,lnkadrpth
        jr z,lnkeup2
        ld hl,20*32+lnkadrpth
lnkeup2 ld bc,32
        ld a,d
        call lnkesw             ;Pfad verschieben
        pop de
        pop af
        jr z,lnkeup3
        ld hl,lnkadrspr
        ld bc,147
        ld a,d
        call lnkesw             ;Icon verschieben
lnkeup3 ld a,1
        or a
        ret

;### LNKESW -> Elemente vertauschen
;Eingabe    A=Nummer des unteren Elements, HL=Adressen-Offset des ersten Element, BC=Elementlänge
lnkeswb ds 147
lnkesw  ld de,lnkcfgdat
        add hl,de
lnkesw1 ld e,l
        ld d,h
        add hl,bc
        dec a
        jr nz,lnkesw1           ;DE=oberer, HL=unterer Name
        push hl
        push de
        ld de,lnkeswb           ;unteren in Buffer
        push bc:ldir:pop bc
        pop hl                  ;oberen in unteren
        pop de
        push hl
        push bc:ldir:pop bc
        pop de
        ld hl,lnkeswb           ;Buffer in oberen
        ldir
        ret

;### LNKADD -> Fügt Eintrag in Liste hinzu
lnkaddn1 db "New Link",0
lnkaddn2 db "New":ds 12-3:db "Link",0
lnkaddi1 db 6,24,24,#30,#F0,#F0,#F0,#80,#00,#20,#00,#00,#00,#C0,#00,#20,#00,#00,#00,#A0,#00,#20,#00,#00,#00,#90,#00,#20,#00,#00,#00,#F0,#80,#20,#00,#00,#00,#77,#80,#20,#00,#00,#00,#00,#C4,#20,#F3,#FF,#DF,#6C,#C4,#20,#F7,#FF,#FF,#EC,#C4
         db #20,#80,#00,#00,#20,#C4,#20,#80,#00,#00,#20,#C4,#20,#91,#11,#11,#20,#C4,#20,#B3,#AB,#AB,#A8,#C4,#20,#A3,#AB,#BB,#A8,#C4,#20,#91,#11,#11,#20,#C4,#20,#80,#00,#00,#20,#C4,#20,#B1,#B2,#B0,#A8,#C4,#20,#80,#00,#00,#20,#C4,#20,#F0
         db #F0,#F0,#E0,#C4,#20,#00,#00,#00,#00,#C4,#20,#00,#00,#00,#00,#C4,#20,#00,#00,#00,#00,#C4,#30,#F0,#F0,#F0,#F0,#C4,#11,#FF,#FF,#FF,#FF,#CC
lnkaddi2 db 2,8,8,#70,#80,#40,#C0,#40,#E0,#40,#20,#51,#A8,#41,#A8,#40,#20,#70,#E0

lnkadd  call lnkenc2
        call lnklsi1        ;A=Listentyp, HL=Namen-Adressenoffset, BC=Namenlänge, (IX)=Anzahl
        ld d,a              ;D=Listentyp
        ld e,20
        ld iy,lnkadrpth
        jr z,lnkadd1
        ld e,8
        ld iy,20*32+lnkadrpth
lnkadd1 ld a,(ix+0)
        cp e
        jp z,prgprz0
        inc (ix+0)          ;Anzahl erhöhen
        ld e,a              ;E=Nummer des neuen Eintrages
        push de
        ld ix,lnkadrspr
lnkadd2 add hl,bc
        ld de,32
        add iy,de
        ld de,147
        add ix,de
        dec a
        jr nz,lnkadd2
        ld de,lnkcfgdat     ;HL=Name, IY=Pfad, IX=Sprite
        add hl,de
        add iy,de
        add ix,de
        pop af
        push af
        dec a
        ex de,hl
        ld hl,lnkaddn1
        jr z,lnkadd4
        ld hl,lnkaddn2
lnkadd4 ldir                ;Dummy Name kopieren
        push iy:pop de
        ld hl,syssyspth     ;Dummy Pfad setzen
        ld bc,32
        ldir
        or a
        jr z,lnkadd5
        push ix             ;Dummy Icon kopieren
        pop de
        ld hl,lnkaddi1
        ld bc,147
        ldir
lnkadd5 ld bc,lnkentlst+1
        ld a,(lnkentnum)
        add a:add a
        ld l,a
        ld h,0
        add hl,bc
        res 7,(hl)          ;alte Markierung löschen
        pop de
        ld a,e
        add a:add a
        ld l,a
        ld h,0
        add hl,bc
        set 7,(hl)          ;neue Markierung setzen
        ld hl,prgobjlnk1
        inc (hl)
        ld a,e
        jr lnkdel2

;### LNKDEL -> Löscht Eintrag aus Liste
lnkdel  ld a,(prgobjlnk1)
        dec a
        jp z,prgprz0
        push af
lnkdel1 call lnkedw0            ;Eintrag ganz nach unten schieben
        jr nz,lnkdel1
        pop af
        ld (prgobjlnk1),a       ;Liste hat einen Eintrag weniger
        ld hl,lnkentlst+1
        set 7,(hl)              ;erster Eintrag ist markiert
        call lnklsi1            ;A=Listentyp, HL=Namen-Adressenoffset, BC=Namenlänge, (IX)=Anzahl
        dec (ix+0)
        xor a
lnkdel2 ld (prgobjlnk1+12),a    ;erster Eintrag ausgewählt
        ld e,4
        call lnklsc0            ;Liste aktualisieren
        jp lnkenc1              ;Eintrag aktualisieren

;### LNKICF -> Icon des Files verwenden
lnkicfh db 0
lnkicf  ld a,(lnklstnum)
        dec a
        jp z,prgprz0
        ld hl,prgobjlnk5x
        ld de,109
lnkicf0 push de
        ld a,(App_BnkNum)
        db #dd:ld h,a
        call SyFile_FILOPN
        pop ix
        jp c,prgprz0
        ld (lnkicfh),a
        ld b,a
        ld iy,0
        ld c,0
        db #dd:ld a,l
        db #dd:or h
        jr z,lnkicf1
        ld a,b
        call SyFile_FILPOI
        jp c,lnkicfe
lnkicf1 ld a,(App_BnkNum)
        ld e,a
        ld a,(lnkicfh)
        ld hl,lnkeswb
        ld bc,147
        call SyFile_FILINP
        jp c,lnkicfe
        jp nz,lnkicfe
        call lnkicf2
        ld ix,lnkeswb
        ld a, 6:cp (ix+0):jp nz,prgprz0
        ld a,24:cp (ix+1):jp nz,prgprz0
        ld a,24:cp (ix+2):jp nz,prgprz0
        ld a,(lnkentnum)
        ld hl,lnkadrspr
        ld bc,147
lnkicf3 or a
        jr z,lnkicf4
        add hl,bc
        dec a
        jr lnkicf3
lnkicf4 ld de,lnkcfgdat
        add hl,de
        ex de,hl
        ld hl,lnkeswb
        ldir
        ld e,23
        call lnklsc0
        jp prgprz0
lnkicf2 ld a,(lnkicfh)
        call SyFile_FILCLO
        ret
lnkicfe call lnkicf2
        jp prgprz0

;### LNKICC -> Icon auswählen
lnkicc  ld a,2
        ld hl,lnkicnchs
        call prgbro
        jp prgprz0

;### LNKBRW -> Browse-Button wurde geklickt
lnkbrw  ld a,1
        ld hl,prgobjlnkka
        call prgbro
        jp prgprz0

;### LNKAPL -> Link-Fenster APPLY-Button
lnkapl  call lnkact
        jp prgprz0

;### LNKOKY -> Link-Fenster OK-Button
lnkoky  call lnkact
        jp prgend

;### LNKACT -> Link-Einstellungen übernehmen
lnkact  call lnkenc2                ;aktuellen Eintrag übernehmen
        ld e,7                      ;*** Namen, Pfade und Icons speichern
        ld hl,jmp_sysinf
        rst #28                     ;DE=System, IX=Data, IY=Transfer
        push ix
        pop de
        ld hl,lnkcfgdat
        ld bc,lnklenall
        ld a,(bnknumput)
        rst #20:dw jmp_bnkcop
        ld hl,jmp_sysinf            ;*** Anzahlen speichern
        ld de,256*36+6
        ld ix,cfgicnanz
        ld iy,66+2+6+5
        rst #28
        jp SyDesktop_DSKBGR         ;*** Hintergrund neu aufbauen


;==============================================================================
;### SUB-ROUTINEN #############################################################
;==============================================================================

;### STRINP -> Initialisiert Textinput (abhängig vom String, den es bearbeitet)
;### Eingabe    IX=Control
;### Ausgabe    HL=Stringende (0), BC=Länge (maximal 255)
;### Verändert  AF
strinp  ld l,(ix+0)
        ld h,(ix+1)
        call strlen
        ld (ix+8),c
        ld (ix+4),c
        xor a
        ld (ix+2),a
        ld (ix+6),a
        ret

;### STRLEN -> Ermittelt Länge eines Strings
;### Eingabe    HL=String
;### Ausgabe    HL=Stringende (0), BC=Länge (maximal 255)
;### Verändert  -
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

;### CLCR16 -> Wandelt String in 16Bit Zahl um
;### Eingabe    IX=String, A=Terminator, BC=Untergrenze (>=0), DE=Obergrenze (<=65534)
;### Ausgabe    IX=String hinter Terminator, HL=Zahl, CF=1 -> Ungültiges Format (zu groß/klein, falsches Zeichen/Terminator)
;### Veraendert AF,DE,IYL
clcr16  ld hl,0
        db #fd:ld l,a
clcr161 ld a,(ix+0)
        inc ix
        db #fd:cp l
        jr z,clcr163
        sub "0"
        jr c,clcr162
        cp 10
        jr nc,clcr162
        push af
        push de
        ld a,10
        ex de,hl
        call clcm16
        pop de
        pop af
        add l
        ld l,a
        ld a,0
        adc h
        ld h,a
        jr clcr161
clcr162 scf
        ret
clcr163 sbc hl,bc
        ret c
        add hl,bc
        inc de
        sbc hl,de
        jr nc,clcr162
        add hl,de
        or a
        ret

;### CLCN32 -> Wandelt 32Bit-Zahl in ASCII-String um (mit 0 abgeschlossen)
;### Eingabe    DE,IX=Wert, IY=Adresse
;### Ausgabe    IY=Adresse letztes Zeichen
;### Veraendert AF,BC,DE,HL,IX,IY
clcn32t dw 1,0,     10,0,     100,0,     1000,0,     10000,0
        dw #86a0,1, #4240,#f, #9680,#98, #e100,#5f5, #ca00,#3b9a
clcn32z ds 4

clcn32  ld (clcn32z),ix
        ld (clcn32z+2),de
        ld ix,clcn32t+36
        ld b,9
        ld c,0
clcn321 ld a,"0"
        or a
clcn322 ld e,(ix+0):ld d,(ix+1):ld hl,(clcn32z):  sbc hl,de:ld (clcn32z),hl
        ld e,(ix+2):ld d,(ix+3):ld hl,(clcn32z+2):sbc hl,de:ld (clcn32z+2),hl
        jr c,clcn325
        inc c
        inc a
        jr clcn322
clcn325 ld e,(ix+0):ld d,(ix+1):ld hl,(clcn32z):  add hl,de:ld (clcn32z),hl
        ld e,(ix+2):ld d,(ix+3):ld hl,(clcn32z+2):adc hl,de:ld (clcn32z+2),hl
        ld de,-4
        add ix,de
        inc c
        dec c
        jr z,clcn323
        ld (iy+0),a
        inc iy
clcn323 djnz clcn321
        ld a,(clcn32z)
        add "0"
        ld (iy+0),a
        ld (iy+1),0
        ret

;### CLCM16 -> Multipliziert zwei Werte (16bit)
;### Eingabe    A=Wert1, DE=Wert2
;### Ausgabe    HL=Wert1*Wert2 (16bit), A=0
;### Veraendert AF,DE
clcm16  ld hl,0
        or a
clcm161 rra
        jr nc,clcm162
        add hl,de
clcm162 sla e
        rl d
        or a
        jr nz,clcm161
        ret


;==============================================================================
;### DATEN-TEIL ###############################################################
;==============================================================================

App_BegData

prgicn16c  db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Desktop und Menu Links
db #12,#22,#22,#22,#22,#22,#22,#22,#22,#22,#22,#22,#1F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#1F,#FF,#F1,#1F,#FF,#FF,#FF,#F2,#00,#00,#2F,#F2,#1F,#FF,#F1,#81,#FF,#FF,#FF,#F0,#12,#11,#0F,#F2
db #1F,#FF,#F1,#88,#1F,#FF,#FF,#F0,#21,#11,#0F,#F2,#1F,#FF,#F1,#88,#81,#FF,#FF,#F0,#11,#11,#0F,#F2,#1F,#FF,#F1,#88,#88,#1F,#FF,#F0,#11,#11,#0F,#F2,#1F,#FF,#F1,#88,#81,#FF,#FF,#F2,#00,#00,#2F,#F2
db #1F,#FF,#F1,#81,#88,#1F,#FF,#FF,#FF,#FF,#FF,#F2,#1F,#FF,#F1,#1F,#18,#1F,#F1,#1F,#1F,#11,#F1,#12,#66,#66,#66,#66,#F1,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#61,#61,#16,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2
db #66,#66,#66,#66,#66,#66,#66,#F2,#00,#00,#2F,#F2,#6F,#F0,#F0,#61,#16,#16,#16,#F0,#12,#11,#0F,#F2,#6F,#0F,#FF,#66,#66,#66,#66,#F0,#21,#11,#0F,#F2,#66,#66,#66,#61,#11,#61,#16,#F0,#11,#11,#0F,#F2
db #61,#16,#11,#66,#66,#66,#66,#F0,#11,#11,#0F,#F2,#66,#66,#66,#61,#16,#11,#16,#F2,#00,#00,#2F,#F2,#61,#61,#11,#66,#66,#66,#66,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#FF,#FF,#F1,#1F,#1F,#11,#F1,#12
db #61,#11,#61,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#61,#16,#16,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#11,#11,#11,#11,#11,#11,#11,#12


;==============================================================================
;%%% MULTI LANGUAGE TEXTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;==============================================================================

texts_int
read"App-CPShortcuts-texts.asm"
texts_int_end

list
texts_int_len   equ texts_int_end-texts_int
nolist


;### EXTENDED!!! ##############################################################

lnkcfgdat   db 0        ;ab hier Texte, Pfade, Icons und Font im verlängerten Speicherbereich

;==============================================================================
;### TRANSFER-TEIL ############################################################
;==============================================================================

App_BegTrns

;### PRGPRZS -> Stack für Programm-Prozess
        ds 128
prgstk  ds 6*2
        dw prgprz
App_PrcID db 0

;### App_MsgBuf -> message buffer
App_MsgBuf ds 14


;### LINKS ####################################################################

prgwinlnk   dw #1501,0,50,5,160,167,0,0,160,167,160,167,160,167,prgicnsml,prgtitlnk,0,0,prggrplnk,0,0:ds 136+14
prggrplnk   db 30,0:dw prgdatlnk,0,0,3*256+2,0,0,0
prgdatlnk
dw 00,     255*256+0, 2,           0,0,1000,1000,0      ;00=Hintergrund
dw lnkoky, 255*256+16,prgbuttxt1,  19,152,44,12,0       ;01="Ok"-Button
dw prgend, 255*256+16,prgbuttxt2,  66,152,44,12,0       ;02="Cancel"-Button
dw lnkapl, 255*256+16,prgbuttxt3, 113,152,44,12,0       ;03="Apply"-Button
dw lnkenc, 255*256+41,prgobjlnk1, 4,   4, 92, 58,0      ;04=Liste Einträge
dw lnklsc, 255*256+18,prgobjlnk2a,100, 4, 52,  8,0      ;05=Radio Desktop
dw lnklsc, 255*256+18,prgobjlnk2b,100,14, 52,  8,0      ;06=Radio Startmenu
dw 0     , 255*256+64,prgobjlnk2b,100,14, 52,  8,0      ;07=*quatsch*
dw lnkeup, 255*256+16,prgtxtlnk3a,100,36, 27, 12,0      ;08=Button "Up"
dw lnkedw, 255*256+16,prgtxtlnk3b,129,36, 27, 12,0      ;09=Button "Down"
dw lnkdel, 255*256+16,prgtxtlnk3c,100,50, 27, 12,0      ;10=Button "Del"
dw lnkadd, 255*256+16,prgtxtlnk3d,129,50, 27, 12,0      ;11=Button "Add"
dw 00,     255*256+3, prgobjlnk4,   0,65,160, 86,0      ;12=Rahmen Edit
dw 00,     255*256+1, prgobjlnk6a,  8,77, 25,  8,0      ;13=Beschreibung  Name
prgdatlnk1
dw 00,     255*256+32,prgobjlnk6b, 34,75,118, 12,0      ;14=Input Lang    Name
dw 00,     255*256+32,prgobjlnk6c, 34,75, 59, 12,0      ;15=Input Teil1   Name
dw 00,     255*256+32,prgobjlnk6d, 93,75, 59, 12,0      ;16=Input Teil2   Name
dw 00,     255*256+1, prgobjlnk5a,  8,91, 25,  8,0      ;17=Beschreibung  Pfad
dw 00,     255*256+32,prgobjlnk5b, 34,89, 74, 12,0      ;18=Input         Pfad
dw lnkbrw, 255*256+16,prgtxtlnk5c,110,89, 42, 12,0      ;19=Button Browse Pfad
prgdatlnk2
dw 00,     255*256+0, 2,           08,103,144,40,0      ;20=Fläche        Icon
dw 00,     255*256+1, prgobjlnk7a,  8,105,25,  8,0      ;21=Beschreibung  Icon
dw 00,     255*256+2, 0,           34,103,26, 26,0      ;22=Rahmen        Icon
prgdatlnk3
dw 00,     255*256+8, prgicnbig,   35,104,24, 24,0      ;23=Grafik        Icon
dw lnkicf, 255*256+16,prgtxtlnk7b, 64,103,88, 12,0      ;24=Button File   Icon
dw lnkicc, 255*256+16,prgtxtlnk7c, 64,117,88, 12,0      ;25=Button Choose Icon
dw 00,     255*256+1, prgobjlnk8a, 24,133,39,  8,0      ;26=Beschreibung  X
dw 00,     255*256+32,prgobjlnk8c, 64,131,22, 12,0      ;27=Input         X
dw 00,     255*256+1, prgobjlnk8b, 90,133,39,  8,0      ;28=Beschreibung  Y
dw 00,     255*256+32,prgobjlnk8d,130,131,22, 12,0      ;29=Input         Y

lnklsttyp   db 0
prgobjlnk2k ds 4
prgobjlnk2a dw lnklsttyp,prgtxtlnk2a,2+4+000,prgobjlnk2k
prgobjlnk2b dw lnklsttyp,prgtxtlnk2b,2+4+256,prgobjlnk2k
prgobjlnk4  dw prgtxtlnk4,2+4
prgobjlnk5a dw prgtxtlnk5a,2+4
prgobjlnk5b dw prgobjlnk5x,0,0,0,0,255,0
prgobjlnkka db "*  ",0
prgobjlnk5x ds 256
lnkicnchs   db "icn",0
lnkicnchs1  ds 256

prgobjlnk6a dw prgtxtlnk6a,2+4
prgobjlnk6b dw prgobjlnk6x,0,0,0,0,19,0
prgobjlnk6c dw prgobjlnk6x,0,0,0,0,11,0
prgobjlnk6d dw prgobjlnk6y,0,0,0,0,11,0
prgobjlnk6x ds 20
prgobjlnk6y ds 12
prgobjlnk7a dw prgtxtlnk7a,2+4

prgobjlnk8a dw prgtxtlnk8a,256*1+2+4
prgobjlnk8b dw prgtxtlnk8b,256*1+2+4
prgobjlnk8c dw prginplnk8c,0,0,0,0,5,0
prginplnk8c ds 6
prgobjlnk8d dw prginplnk8d,0,0,0,0,5,0
prginplnk8d ds 6

prgobjlnk1  dw 0,0,lnkentlst,0,256*0+1,lnkentrow,0,1
lnkentrow   dw 0,92,00,0
lnkentlst   dw 00,0,01,0,02,0,03,0,04,0,05,0,06,0,07,0,08,0,09,0
            dw 10,0,11,0,12,0,13,0,14,0,15,0,16,0,17,0,18,0,19,0

syssyspth   ds 32

;### CONFIG ###################################################################
cfgicnanz   db 4    ;Desktop  -> Anzahl Icons
cfgmenanz   db 6    ;Desktop  -> Anzahl Startmenu-Programm-Einträge
cfglstanz   db 0    ;Desktop  -> Anzahl Taskleisten-Shortcuts
cfghrdtyp   db 0    ;Hardware -> Computer-Typ
cfgicnpos   dw 000,000
            dw 000,044
            dw 000,088
            dw 000,132
            dw 052,000
            dw 052,044
            dw 052,088
            dw 052,132

App_EndTrns

relocate_table
relocate_end
