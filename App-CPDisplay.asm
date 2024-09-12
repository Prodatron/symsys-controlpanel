;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                              DISPLAY SETTINGS                              @
;@                                                                            @
;@             (c) 2004-2015 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;todo
;- nc/pcw -> nur 2 farben, kein def


relocate_start

;==============================================================================
;### CODE-TEIL ################################################################
;==============================================================================

;### PROGRAMM-KOPF ############################################################

prgdatcod       equ 0           ;Länge Code-Teil (Pos+Len beliebig; inklusive Kopf!)
prgdatdat       equ 2           ;Länge Daten-Teil (innerhalb 16K Block)
prgdattra       equ 4           ;Länge Transfer-Teil (ab #C000)
prgdatorg       equ 6           ;Original-Origin
prgdatrel       equ 8           ;Anzahl Einträge Relocator-Tabelle
prgdatstk       equ 10          ;Länge Stack (Transfer-Teil beginnt immer mit Stack)
prgdatrsv       equ 12          ;*reserved* (3 bytes)
prgdatnam       equ 15          ;program name (24+1[0] chars)
prgdatflg       equ 40          ;flags (+1=16colour icon available)
prgdat16i       equ 41          ;file offset of 16colour icon
prgdatrs2       equ 43          ;*reserved* (5 bytes)
prgdatidn       equ 48          ;"SymExe10"
prgdatcex       equ 56          ;zusätzlicher Speicher für Code-Bereich
prgdatdex       equ 58          ;zusätzlicher Speicher für Data-Bereich
prgdattex       equ 60          ;zusätzlicher Speicher für Transfer-Bereich
prgdatres       equ 62          ;*reserviert* (26 bytes)
prgdatver       equ 88          ;required OS version (minor, major)
prgdatism       equ 90          ;Icon (klein)
prgdatibg       equ 109         ;Icon (gross)
prgdatlen       equ 256         ;Datensatzlänge

prgpstdat       equ 6           ;Adresse Daten-Teil
prgpsttra       equ 8           ;Adresse Transfer-Teil
prgpstspz       equ 10          ;zusätzliche Prozessnummern (4*1)
prgpstbnk       equ 14          ;Bank (1-8)
prgpstmem       equ 48          ;zusätzliche Memory-Bereiche (8*5)
prgpstnum       equ 88          ;Programm-Nummer
prgpstprz       equ 89          ;Prozess-Nummer

prgcodbeg   dw prgdatbeg-prgcodbeg  ;Länge Code-Teil
            dw prgtrnbeg-prgdatbeg  ;Länge Daten-Teil
            dw prgtrnend-prgtrnbeg  ;Länge Transfer-Teil
prgdatadr   dw #1000                ;Original-Origin                    POST Adresse Daten-Teil
prgtrnadr   dw relocate_count       ;Anzahl Einträge Relocator-Tabelle  POST Adresse Transfer-Teil
prgprztab   dw prgstk-prgtrnbeg     ;Länge Stack                        POST Tabelle Prozesse
            dw 0                    ;*reserved*
prgbnknum   db 0                    ;*reserved*                         POST bank number
            db "CP:Display":ds 14:db 0 ;Name
            db 1                    ;flags (+1=16c icon)
            dw prgicn16c-prgcodbeg  ;16 colour icon offset
            ds 5                    ;*reserved*
prgmemtab   db "SymExe10"           ;SymbOS-EXE-Kennung                 POST Tabelle Speicherbereiche
            dw 0                    ;zusätzlicher Code-Speicher
            dw 0                    ;zusätzlicher Data-Speicher
            dw 0                    ;zusätzlicher Transfer-Speicher
            ds 26                   ;*reserviert*
            db 1,3                  ;required OS version (3.0)

prgicndsp2 db 2,8,8,#77,#EE,#BC,#D3,#E8,#F1,#D8,#F1,#F8,#F1,#F8,#F1,#BC,#D3,#77,#EE
prgicndsp1 db 6,24,24,#00,#77,#FF,#FF,#FF,#CC,#00,#8F,#0F,#1F,#87,#64,#11,#0F,#0F,#1F,#86,#EC,#22,#00,#00,#33,#D9,#EC,#45,#0F,#0F,#3F,#DB,#EC,#45,#FF,#FF,#DE,#97,#EC,#45,#F0,#F0,#F3,#FB,#EC,#45,#C0,#F0,#E2,#5E,#EC
           db #45,#B0,#F0,#E3,#9F,#E4,#45,#F0,#F0,#F3,#4F,#E8,#45,#B0,#F0,#E3,#3D,#E4,#45,#F0,#F0,#D7,#3E,#EC,#45,#F0,#F0,#8F,#F5,#EC,#45,#F0,#F1,#4F,#DB,#EC,#45,#F0,#E3,#3D,#D3,#EC,#45,#00,#57,#3E,#5B,#EC
           db #45,#0F,#8F,#E4,#5B,#C8,#77,#FF,#4F,#EB,#7B,#80,#30,#E3,#3D,#E2,#78,#00,#00,#DF,#3E,#6B,#48,#00,#11,#0A,#E5,#2E,#68,#00,#11,#05,#4B,#1E,#E4,#00,#00,#C2,#04,#3F,#C0,#00,#00,#30,#F0,#F0,#00,#00


;### PRGPRZ -> Programm-Prozess
prgwin      db 0        ;Nummer des Haupt-Fensters
colwin      db -1       ;Nummer des Palette-Fensters

dskprzn     db 2
sysprzn     db 3
windatprz   equ 3       ;Prozeßnummer
windatsup   equ 51      ;Nummer des Superfensters+1 oder 0

prgid   db "CP:Display",0,0

prgprz  call prgdbl
        ld a,(prgprzn)
        ld (prgwindsp+windatprz),a
        ld (prgwincol+windatprz),a
        call dspini
        ld c,MSC_DSK_WINOPN
        ld a,(prgbnknum)
        ld b,a
        ld de,prgwindsp
        call msgsnd
prgprz1 call msgdsk             ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        cp MSR_DSK_WOPNER
        jp z,prgend             ;kein Speicher für Fenster -> Prozeß beenden
        cp MSR_DSK_WOPNOK
        jr nz,prgprz1           ;andere Message als "Fenster geöffnet" -> ignorieren
        ld a,(prgmsgb+4)
        ld (prgwin),a           ;Fenster wurde geöffnet -> Nummer merken

prgprz0 call msgget
        jr nc,prgprz0
        ld c,a
        ld a,(savprz)
        or a
        jr z,prgprz2
        db #dd:cp h
        jr nz,prgprz2
        ld a,c
        cp MSR_SAV_CONFIG
        jp z,savsto
        jr prgprz0
prgprz2 ld a,c
        cp MSC_GEN_FOCUS        ;*** Application soll sich Focus nehmen
        jp z,prgfoc
        cp MSR_SYS_SELOPN       ;*** Browse-Fenster wurde geschlossen
        jp z,prgbrc
        cp MSR_DSK_WCLICK       ;*** Fenster-Aktion wurde geklickt
        jr nz,prgprz0
        ld a,(iy+2)
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jr z,prgprz3
        cp DSK_ACT_CONTENT      ;*** Inhalt wurde geklickt
        jr nz,prgprz0
        ld l,(iy+8)
        ld h,(iy+9)
        ld a,h
        or l
        jr z,prgprz0
        xor a
        jp (hl)
prgprz3 ld a,(colwin)
        cp (iy+1)
        jp z,colcnc
        jp dspcnc

;### PRGWRN -> Alert-Fenster anzeigen
prgwrn  ld (prgmsgb+1),hl
        ld a,(prgbnknum)
        ld c,a
        ld (prgmsgb+3),bc
        ld a,MSC_SYS_SYSWRN
        ld (prgmsgb),a
        ld ix,(prgprzn)
        db #dd:ld h,PRC_ID_SYSTEM
        ld iy,prgmsgb
        rst #10
        ret

;### PRGBRO -> Browse-Fenster öffnen
;### Eingabe    A=Typ (1=Desktop-Hintergrundgrafik, 2=Screensaver, 3=Col-Load, 4=Col-Save), HL=Maske/Pfad, D=Flag, if "Save" (64)
prgbron db 0
prgbro  ld e,a
        ld a,(prgbron)
        or a
        ret nz
        ld a,e
        ld (prgbron),a
        ld (prgmsgb+8),hl
        ld a,(prgbnknum)
        or d
        ld l,a
        ld h,8
        ld (prgmsgb+6),hl
        ld hl,100
        ld (prgmsgb+10),hl
        ld hl,5000
        ld (prgmsgb+12),hl
        ld l,MSC_SYS_SELOPN
devact0 ld (prgmsgb),hl
devact1 ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        ld iy,prgmsgb
        rst #10
        ret

;### PRGBRC -> Browse-Fenster schließen
;### Eingabe    P1=Typ (0=Ok, 1=Abbruch, 2=FileAuswahl bereits in Benutzung, 3=kein Speicher frei, 4=kein Fenster frei), P2=PfadLänge
prgbrc  ld a,(prgmsgb+1)
        inc a
        jr nz,prgbrc0
        ld a,(prgmsgb+2)
        ld (prgwindsp+windatsup),a
        jp prgprz0
prgbrc0 ld hl,prgbron
        ld e,(hl)
        ld (hl),0
        ld hl,(prgmsgb+1)           ;L=Typ, H=Pfadlänge
        ld a,l
        or a
        jp nz,prgprz0
        dec e:jr z,prgbrc3
        dec e:jr z,prgbrc2
        dec e:jp z,colldx
        dec e:jp z,colsvx
        jp prgprz0
prgbrc3 call prgbrc1                ;*** Desktop-Hintergrundgrafik
        ld hl,dspobjdatkb
        call prgbrc4
        ld e,17
        call dsppn6
        ld a,-1
        ld (dspobjstab),a
        ld de,256*16+256-6
        call dsppn6
        call dspbgc0
        jp dspbgc3
prgbrc1 ld ix,dspobjdatk
        jp strinp
prgbrc2 ld ix,dspobjdatm            ;*** Screen-Saver
        call strinp
        ld a,1
        ld (scrsavflg),a
        ld de,256*12+256-2
        call dsppn6
        jp savchk
prgbrc4 call strlen
        ld a,c
        cp 32
        ld hl,prgmsgpth
        ld b,1
        push af
        call nc,prgwrn
        pop af
        ret

;### PRGFOC -> Focus nehmen
prgfoc  ld a,(prgwin)
        ld b,a
        ld c,MSC_DSK_WINMID
        call msgsnd
        jp prgprz0

;### PRGDBL -> Test, ob Programm bereits läuft
prgdbl  xor a
        ld (prgcodbeg+prgdatnam),a
        ld hl,prgid
        ld b,l
        ld e,h
        ld l,a
        ld c,MSC_SYS_PRGSRV
        ld a,(prgbnknum)
        ld d,a
        ld a,PRC_ID_SYSTEM
        call msgsnd1
prgdbl1 db #dd:ld h,PRC_ID_SYSTEM
        call msgget1
        jr nc,prgdbl1
        cp MSR_SYS_PRGSRV
        jr nz,prgdbl1
        ld a,"C"
        ld (prgcodbeg+prgdatnam),a
        ld a,(prgmsgb+1)
        or a
        ret nz
        ld a,(prgmsgb+9)
        ld c,MSC_GEN_FOCUS
        call msgsnd1
        jr prgend

;### PRGEND -> Programm beenden
prgend  ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        ld iy,prgmsgb
        ld (iy+0),MSC_SYS_PRGEND
        ld a,(prgcodbeg+prgpstnum)
        ld (iy+1),a
        rst #10
prgend0 rst #30
        jr prgend0

;### MSGGET -> Message für Programm abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgget  db #dd:ld h,-1
msgget1 ld a,(prgprzn)
        db #dd:ld l,a           ;IXL=Rechner-Prozeß-Nummer
        ld iy,prgmsgb           ;IY=Messagebuffer
        rst #08                 ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        or a
        db #dd:dec l
        ret nz
        ld iy,prgmsgb
        ld a,(iy+0)
        or a
        jr z,prgend
        scf
        ret

;### MSGDSK -> Message für Programm von Deskzop-Prozess abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgdsk  call msgget
        jr nc,msgdsk            ;keine Message
        ld a,(dskprzn)
        db #dd:cp h
        jr nz,msgdsk            ;Message von anderem als Desktop-Prozeß -> ignorieren
        ld a,(prgmsgb)
        ret

;### MSGSND -> Message an Desktop-Prozess senden
;### Eingabe    C=Kommando, B/E/D/L/H=Parameter1/2/3/4/5
msgsnd  ld a,(dskprzn)
msgsnd1 db #dd:ld h,a
        ld a,(prgprzn)
        db #dd:ld l,a
        ld iy,prgmsgb
        ld (prgmsgb+0),bc
        ld (prgmsgb+2),de
        ld (prgmsgb+4),hl
        rst #10
        ret

;### SYSCLL -> Betriebssystem-Funktion aufrufen
;### Eingabe    (SP)=Modul/Funktion, AF,BC,DE,HL,IX,IY=Register
;### Ausgabe    AF,BC,DE,HL,IX,IY=Register
sysclln db 0
syscll  ld (prgmsgb+04),bc      ;Register in Message-Buffer kopieren
        ld (prgmsgb+06),de
        ld (prgmsgb+08),hl
        ld (prgmsgb+10),ix
        ld (prgmsgb+12),iy
        push af
        pop hl
        ld (prgmsgb+02),hl
        pop hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld (prgmsgb+00),de      ;Modul und Funktion in Message-Buffer kopieren
        ld a,e
        ld (sysclln),a
        ld iy,prgmsgb
        ld a,(prgprzn)          ;Desktop und System-Prozessnummer holen
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #10                 ;Message senden
syscll1 rst #30
        ld iy,prgmsgb
        ld a,(prgprzn)
        db #dd:ld l,a
        ld a,(sysprzn)
        db #dd:ld h,a
        rst #18                 ;auf Antwort warten
        db #dd:dec l
        jr nz,syscll1
        ld a,(prgmsgb)
        sub 128
        ld e,a
        ld a,(sysclln)
        cp e
        jr nz,syscll1
        ld hl,(prgmsgb+02)      ;Register aus Message-Buffer holen
        push hl
        pop af
        ld bc,(prgmsgb+04)
        ld de,(prgmsgb+06)
        ld hl,(prgmsgb+08)
        ld ix,(prgmsgb+10)
        ld iy,(prgmsgb+12)
        ret

;### CLCDEZ -> Rechnet Byte in zwei Dezimalziffern um
;### Eingabe    A=Wert
;### Ausgabe    L=10er-Ascii-Ziffer, H=1er-Ascii-Ziffer
;### Veraendert AF
clcdez  ld l,0
clcdez1 sub 10
        jr c,clcdez2
        inc l
        jr clcdez1
clcdez2 add "0"+10
        ld h,a
        ld a,"0"
        add l
        ld l,a
        ret

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

;### CLCM16 -> Multipliziert zwei Werte (16bit)
;### Eingabe    A=Wert1, DE=Wert2
;### Ausgabe    HL=Wert1*Wert2 (16bit)
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

;### PRGRUN -> Startet Applikation
prgrun  ld c,MSC_SYS_PRGRUN
        call SySystem_SendMessage
prgrun1 call SySystem_WaitMessage
        cp MSR_SYS_PRGRUN
        jr nz,prgrun1
        ld a,(iy+1)
        ld l,(iy+8)
        ld h,(iy+9)
        ret
SySystem_SendMessage
        ld iy,prgmsgb
        ld (iy+0),c
        ld (prgmsgb+1),hl
        ld (iy+3),a
        ld (prgmsgb+4),de
        db #dd:ld h,3       ;3 is the number of the system manager process
        ld a,(prgprzn)
        db #dd:ld l,a
        rst #10
        ret
SySystem_WaitMessage
        ld iy,prgmsgb
SySWMs1 db #dd:ld h,3       ;3 is the number of the system manager process
        ld a,(prgprzn)
        db #dd:ld l,a
        rst #08             ;wait for a system manager message
        db #dd:dec l
        jr nz,SySWMs1
        ld a,(iy+0)
        ret


;==============================================================================
;### DISPLAY-FENSTER ##########################################################
;==============================================================================

cfghrdtyp   db 0    ;bit[0-4] Computer type     0=464, 1=664, 2=6128, 3=464Plus, 4=6128Plus,
                    ;                               5=*reserved*
                    ;                           6=Enterprise 64/128,
                    ;                           7=MSX1, 8=MSX2, 9=MSX2+, 10=MSX TurboR,
                    ;                               11=*reserved*
                    ;                           12=PCW8xxx, 13=PCW9xxx
                    ;                           14=PcW16
                    ;                           15=NC100, 16=NC150, 17=NC200
                    ;                           18=SymbOS Virtual Machine
                    ;                               19=*reserved*
                    ;                           20=ZX Spectrum Next
                    ;                               21-31=*reserved*

;### DSPINI -> Display-Fenster initialisieren
dspini  ld hl,jmp_sysinf            ;*** Computer-Typ holen
        ld de,256*6+5
        ld ix,cfgsf2flg
        ld iy,66+2+6+8-5
        rst #28
        ld a,(cfgcpctyp)
        and #1f
        ld (cfgcpctyp),a
        cp 7
        jr nc,dspini8
        ld a,(cfgsf2flg)            ;cpc/ep
        bit 3,a
        jp z,dspini2                ;cpc/ep ohne g9k
dspinig ld a,10
        ld (dspobjdats0),a
        ld a,15
        jr dspini9
dspini8 cp 12
        jr c,dspinia
        cp 15
        jr nc,dspinid
        ld hl,dspmodobj0            ;pcw
        ld a,13
        jr dspini3
dspinid cp 18
        jr nz,dspinif               ;svm
        ld a,svmmod_cnt-1
        ld (dspobjdatu+4),a
        jr dspinig
dspinif jr nc,dspinie
        ld hl,dspmodobj15           ;nc
        ld (prgdatdspd0+4+16),hl
        ld hl,dspmodobj16
        ld (prgdatdspd0+4+32),hl
        ld hl,dspmodobj14
        ld a,15
        jr dspini3
dspinie cp 20
        ;jr nz,...
        ld hl,dspmodobj20           ;nxt
        ld (prgdatdspd0+4+16),hl
        ld hl,dspmodobj21
        ld (prgdatdspd0+4+32),hl
        ld hl,dspmodobj7
        ld a,15
        jr dspini3
dspinia ld a,10                     ;msx
        ld (dspobjdats0),a
        ld a,(cfgsf2flg)
        bit 3,a
        ld a,15
        jr z,dspini4
dspini9 ld hl,prgdatdspd1           ;msx mit g9k
        ld de,prgdatdspd0
        ld bc,4*16
        ldir
        inc a
        jr dspini5
dspini4 ld hl,dspmodobj6            ;msx ohne g9k
        ld (prgdatdspd0+4+16),hl
        ld hl,dspmodobj5
dspini3 ld (prgdatdspd0+4+00),hl
dspini5 ld (prggrpdspd),a
dspini2 ld hl,jmp_sysinf            ;*** Colour-Settings holen
        ld de,cfgcolend-cfgcolbeg*256+5
        ld ix,cfgcolbeg
        ld iy,66+2+6+9+32+33
        rst #28
        call colakt0
        ld e,7                      ;*** Screensaver-Infos holen
        ld hl,jmp_sysinf
        rst #28             ;DE=System, IX=Data, IYL=Bank
        push ix
        pop hl
        ld bc,3432
        add hl,bc
        ld (savadr),hl
        db #fd:ld a,l
        ld (savadr+2),a
        ld de,scrsavflg
        ld bc,99
        ld a,(prgbnknum)
        add a:add a:add a:add a
        db #fd:add l
        rst #20:dw jmp_bnkcop
        ld hl,scrsavfil
        ld de,dspobjdatmb
        ld bc,32
        ldir
        ld ix,dspobjdatm
        call strinp
        ld a,(scrsavdly)
        ld de,0
        db #dd:ld l,a
        db #dd:ld h,e
        ld iy,dspobjdatob
        call clcn32
        ld ix,dspobjdato
        call strinp
        call savini
dspini0 xor a                       ;*** Pen Selection resetten
        ld (dsppnp),a
        call dsppn9
        ld bc,256*DSK_SRV_MODGET+MSC_DSK_DSKSRV  ;*** Mode holen und setzen
        call msgsnd
dspini1 call msgdsk
        cp MSR_DSK_DSKSRV
        jr nz,dspini1
        ld hl,(prgmsgb+2)           ;L=Mode, H=virtual desktop
        ld (dspmodstab),hl
        ld a,l
        call dspmds0
        call dspset1
        ld hl,dsppncn               ;*** Farbbuffer resetten
        ld de,dsppncn+1
        ld (hl),-1
        ld bc,5*2*2-1
        ldir
        ld hl,jmp_sysinf            ;*** Hintergrundbild-Infos holen
        ld de,256*33+5
        ld ix,cfgbgrmem
        ld iy,33
        rst #28
        ld a,(cfgbgrmem)
        ld (dspobjstab),a
        call dspbgc0
        ld hl,cfgbgrmem+1
        ld de,dspobjdatkb
        ld bc,32
        ldir
        call prgbrc1
        call dspcsh                 ;*** Farben holen und setzen
dspini6 ld a,(cfgcpctyp)            ;*** Color-Def an Farbtiefe/System anpassen
        ld hl,29*256+16
        cp 6
        jr nz,dspinib
        ld a,(dspmodstab)       ;ep -> show 4 colour/taskbar or 16 colour definition (if G9K)
        cp 5
        jr c,dspini7
        jr dspinic
dspinib dec h
        ld a,(dspmodstab)       ;others -> show 4 or 16 colour definition
        cp 5
        jr c,dspini7
        cp 6
        jr z,dspini7
        cp 20
        jr nc,dspinic
        cp 14
        jr nc,dspini7
dspinic ld hl,41*256+64
dspini7 ld a,l
        ld (prgdatdspe3+2+00),a
        ld (prgdatdspe3+2+16),a
        ld a,h
        ld (prggrpdspc),a
        ret

;### DSPDIS -> Display-Einstellungen nicht übernehmen
dspdis  ld hl,dsppnco
        ld b,9
dspdis1 ld a,9
        sub b
        cp 8
        jr nz,dspdis2
        ld a,16
dspdis2 ld e,a              ;E=Pen
        ld d,(hl)
        inc hl
        ld a,(hl)
        inc hl
        bit 7,a
        jr nz,dspdis3
        push bc
        push hl
        ld l,a              ;DL=RGB
        ld bc,256*DSK_SRV_COLSET+MSC_DSK_DSKSRV
        call msgsnd         ;Farbe setzen
        pop hl
        pop bc
dspdis3 djnz dspdis1
        ret

;### DSPACT -> Display-Einstellungen übernehmen
dspact  ld hl,jmp_sysinf            ;*** Colour-Settings setzen
        ld de,cfgcolend-cfgcolbeg*256+6
        ld ix,cfgcolbeg
        ld iy,66+2+6+9+32+33
        rst #28
        ld ix,dspobjdatob           ;*** Screensaver setzen
        xor a
        ld bc,1
        ld de,99
        call clcr16
        jr nc,dspact7
        ld l,10
dspact7 ld a,l
        ld (scrsavdly),a
        ld hl,dspobjdatmb
        ld de,scrsavfil
        ld bc,32
        ldir
        ld a,(savadr+2)
        add a:add a:add a:add a
        ld hl,prgbnknum
        add (hl)
        ld hl,scrsavflg
        ld de,(savadr)
        ld bc,99
        rst #20:dw jmp_bnkcop
        ld hl,256*3+MSC_SYS_SYSCFG
        call devact0
        ld de,(dspmodstab)          ;*** Mode setzen
        ld hl,colsetx
        ld a,(hl)
        ld (hl),0
        or e
        ld e,a
        ld bc,256*DSK_SRV_MODSET+MSC_DSK_DSKSRV
        call msgsnd
        db #dd:ld l,0           ;IXL=Flag, ob Änderung
        ld a,(dspobjstab)           ;*** Hintergrundbild-Infos sichern
        ld hl,cfgbgrmem
        ld e,(hl)
        cp e
        jr z,dspact1
        db #dd:inc l
dspact1 ld (hl),a
        ld hl,dspobjdatkb
        ld de,cfgbgrmem+1
        ld bc,32*256+32
dspact2 ld a,(de)
        cp (hl)
        ldi
        jr z,dspact3
        db #dd:inc l
        jr dspact4
dspact3 or a
        jr z,dspact5
dspact4 djnz dspact2
dspact5 db #dd:inc l
        db #dd:dec l
        jr z,dspact6
        ld hl,jmp_sysinf 
        ld de,256*33+6
        ld ix,cfgbgrmem
        ld iy,33
        rst #28
        ld hl,256*2+MSC_SYS_SYSCFG
        call devact0
dspact6 jp dspini0

;### DSPAPL -> Display-Fenster APPLY-Button
dspapl  call dspact
        jp prgprz0

;### DSPOKY -> Display-Fenster OK-Button
dspoky  call dspact
dspoky1 call savrem
        jp prgend

;### DSPCNC -> Display-Fenster CANCEL/CLOSE-Button
dspcnc  call dspdis
        jr dspoky1

;### DSPTAB -> Tab wurde geklickt
dspacttab db 0                  ;aktueller Tab

dsptab  ld a,(dsptabdat0)       ;*** Tab angeklickt
        ld hl,(dspacttab)
        cp l
        jp z,prgprz0            ;gleicher wie aktueller -> nichts machen
        ld (dspacttab),a
        cp 1
        ld hl,prggrpdspa
        jr c,dsptab1
        ld hl,prggrpdspb
        jr z,dsptab1
        cp 3
        ld hl,prggrpdspc
        jr c,dsptab1
        ld hl,prggrpdspd
dsptab1 ld (prgwindsp0),hl      ;Tab wechseln
        ld e,-1
        call dsppn6
        jp prgprz0

;### DSPBGC -> "Desktop"-Tab -> Hintergrund-Farbe wurde geklickt
dspbgc  call dspbgc0
dspbgc3 ld e,7
        call dsppn6
        jp prgprz0
dspbgc0 ld a,(dspobjstab)
        cp -1
        jr z,dspbgc1
        ld l,a
        xor a
        ld h,0
dspbgc4 ld (prgdatdspa1),hl
        ld (prgdatdspa1-2),a
        ret
dspbgc1 ld hl,sprdspbgr
        ld a,8
        jr dspbgc4

;### DSPBRW -> "Desktop"-Tab -> Browse-Button wurde geklickt
dspbrw  ld a,1
        ld hl,dspobjdatka
        ld d,0
        call prgbro
        jp prgprz0

;### DSPSET -> "Modi"-Tab -> Screenmode wurde per Slider geklickt
dspset  ld a,(cfgcpctyp)
        cp 18
        ld a,(dspobjdatu+2)     ;rechnet slider-stellung in mode+vir um
        jr nz,dspset6
        ld l,a
        add 32
        ld (dspmodstab),a
        ld h,0
        add hl,hl
        ld bc,dspobjtxnt
        jr dspset7
dspset6 add a              
        add a
        ld l,a
        ld h,0
        ld bc,dspobjtxmt
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (dspmodstab),bc
        inc hl
dspset7 call dspset5
        ld e,15
        call dsppn6
        jp dspmds
dspset1 ld a,(cfgcpctyp)
        cp 18
        ld a,(dspmodstab)       ;rechnet mode+vir in slider stellung um
        jr nz,dspset8
        sub 32
        ld (dspobjdatu+2),a
        ld bc,dspobjtxnt
        jr dspset9
dspset8 cp 11
        ld c,-4
        jr z,dspset4
        add a
        sub 16
        jr nc,dspset3
        xor a
dspset3 ld c,a
        ld a,(dspmodsvir)
        cp 3
        jr c,dspset2
        xor a
dspset2 inc c
        dec c
        jr z,dspset4
        srl a
        inc c
dspset4 add c
        ld bc,dspobjtxmt+2
        ld (dspobjdatu+2),a
        add a
dspset9 add a
        ld l,a
        ld h,0
dspset5 add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld (dspobjdatt),hl
        ret

;### DSPMDS -> "Modi"-Tab -> Screenmode wurde per Radio-Button geklickt
dspmdst dw sprdspmd2                                            ;0      pcw
        dw sprdspmd1,sprdspmd2                                  ;1-2    cpc
        dw 0        ,0                                          ;3-4    *not defined*
        dw sprdspmd0,sprdspmd1,sprdspmd1                        ;5-7    msx
        dw sprdspmd0,sprdspmd1,sprdspmd1,sprdspmd2              ;8-11   msx+g9k
        dw 0        ,0                                          ;12-13  *not defined*
        dw sprdspmd0,sprdspmd1,sprdspmd2                        ;14-16  nc
        dw 0        ,0        ,0                                ;17-19  *not defined*
        dw sprdspmd2,sprdspmd2                                  ;20-21  znx
        dw 0,0,0,0,0,0,0,0,0,0                                  ;22-31  *not defined*
        dw sprdspmd0,sprdspmd0,sprdspmd0,sprdspmd0,sprdspmd0    ;32-45  svm
        dw sprdspmd1,sprdspmd1,sprdspmd1,sprdspmd1,sprdspmd1
        dw sprdspmd2,sprdspmd2,sprdspmd2,sprdspmd2

dspmds  call dspini6
        ld a,(dspmodstab)
        call dspmds0
        ld e,7
        call dsppn6
        jp prgprz0
;A=Mode -> Mode setzen
dspmds0 add a
        ld l,a
        ld h,0
        ld bc,dspmdst
        add hl,bc
        ld c,(hl)
        inc hl
        ld h,(hl)
        ld l,c
        ld (prgdatdsp1),hl
        ret

;### DSPCOL -> Farbe setzen
dspcol  ld a,(dspobjdat4+2)     ;R
        ld d,a
        call dspcsh2
        ld (dspobjdspr),a
        ld a,(dspobjdat5+2)     ;G
        ld e,a
        call dspcsh2
        ld (dspobjdspg),a
        ld a,e
        add a:add a:add a:add a
        ld e,a
        ld a,(dspobjdat6+2)     ;B
        ld h,a
        call dspcsh2
        ld (dspobjdspb),a
        ld a,h
        or e
        ld e,a                  ;DE=RGB
        ld a,(dsppnp)
        ld h,a
        add a
        ld l,a
        ld a,h
        cp 8
        jr nz,dspcol1
        ld a,16
dspcol1 ld h,0
        ld bc,dsppncn           ;neue Farbe eintragen
        add hl,bc
;A=Pen, DE=Farbe, HL=Tabelle -> Farbe eintragen und setzen, zurück zum Hauptprogramm
dspcol2 ld (hl),e
        inc hl
        ld (hl),d
        ld l,d
        ld d,e
        ld e,a
        ld bc,256*DSK_SRV_COLSET+MSC_DSK_DSKSRV
        call msgsnd             ;Farbe setzen
        call dsppn8
        jp prgprz0

;### DSPPNx -> "Colour"-Tab -> Pen wurde geklickt
dsppnp  db 0                            ;angewählter Pen
dsppofs db 0                            ;Pen offset (0/4)
dsppns0 dw  9,31,53,75,9,31,53,75,97    ;Pen-Selektion-Offset
dsppncn dw -1,-1,-1,-1,-1,-1,-1,-1,-1   ;neue Farben
dsppnco dw -1,-1,-1,-1,-1,-1,-1,-1,-1   ;alte Farben

dsppn0  ld c,0:jr dsppn5
dsppn1  ld c,1:jr dsppn5
dsppn2  ld c,2:jr dsppn5
dsppn3  ld c,3:jr dsppn5
dsppn4  ld c,8
dsppn5  ld a,(dsppofs)
        add c
        ld c,a
        ld a,(dsppnp)
        cp c
        jp z,prgprz0
        ld a,c
        ld (dsppnp),a
        call dsppn9
        call dspcsh
        call dsppn7
        jp prgprz0
dsppn7  ld de,256*25+256-2  ;Pen-Auswahl
        call dsppnb
dsppn8  ld de,256*07+256-3  ;RGB-Slider
        call dsppnb
        ld de,256*13+256-3  ;RGB-Werte
dsppnb  ld a,(colwin)
        jr dsppna
;E=Objekt/-1 -> ein/alle Objekt(e) des Display-Fensters neu aufbauen
dsppn6  ld a,(prgwin)
dsppna  ld c,MSC_DSK_WININH
        ld b,a
        jp msgsnd
;A=Pen -> Selector setzen
dsppn9  add a
        ld e,a
        ld d,0
        ld hl,dsppns0
        add hl,de
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld hl,(dsppns1)
        ld (dsppns2),hl
        ld (dsppns1),bc
        ret

;### DSPCSH -> "Colour"-Tab -> Farbe über Slider zeigen (Slider-Werte setzen)
dspcsh  call dspcsh5
        ld h,(hl)
        ld l,a
        bit 7,h
        jr z,dspcsh1
        push de                 ;** Farbe noch nicht gebuffert -> Lesen und Buffern
        ld a,(dsppnp)
        cp 8
        jr c,dspcsh4
        ld a,16
dspcsh4 ld e,a
        ld bc,256*DSK_SRV_COLGET+MSC_DSK_DSKSRV
        call msgsnd             ;Commando senden
dspcsh3 call msgdsk
        cp MSR_DSK_DSKSRV
        jr nz,dspcsh3
        ld a,(prgmsgb+1)
        cp 3
        jr nz,dspcsh3
        ld bc,(prgmsgb+3)       ;BC=Farbe
        pop de
        ld hl,dsppncn           ;als Neu setzen
        add hl,de
        ld (hl),c
        inc hl
        ld (hl),b
        ld hl,dsppnco           ;als Alt setzen
        add hl,de
        ld (hl),c
        inc hl
        ld (hl),b
        ld l,c
        ld h,b
;HL=RGB -> Slider und Werte setzen
dspcsh1 ld a,h                  ;**R*
        ld (dspobjdat4+2),a
        call dspcsh2
        ld (dspobjdspr),a
        ld a,l                  ;**G*
        and #f0
        rrca:rrca:rrca:rrca
        ld (dspobjdat5+2),a
        call dspcsh2
        ld (dspobjdspg),a
        ld a,l                  ;**B*
        and #0f
        ld (dspobjdat6+2),a
        call dspcsh2
        ld (dspobjdspb),a
        ret
;A=0-15 -> A="0"-"F"
dspcsh2 add "0"
        cp "9"+1
        ret c
        add "A"-"9"-1
        ret
;-> HL=Farbe+1, A=(HL-1)
dspcsh5 ld a,(dsppnp)
        add a
        ld e,a
        ld d,0
        ld hl,dsppncn
        add hl,de
        ld a,(hl)
        inc hl
        ret
dspcsh6 call dspcsh
        call dspcsh5
        ld c,a
        ld b,(hl)
        dec hl
        ret

;### DSPMOV -> RGB wird zu GBR
dspmov  call dspcsh6        ;A=Farbe1, (HL)=Farbe2
        and #f0
        rrca:rrca:rrca:rrca
        ld d,a              ;** D=G
        ld a,c
        and #0f             ;A=B
        add a:add a:add a:add a
        or b
dspmov1 ld e,a              ;** E=B*16+R -> DE=neues RGB
        push de
        push hl
        ex de,hl
        call dspcsh1
        pop hl
        pop de
        ld a,(dsppnp)
        jp dspcol2

;### DSPFLP -> RGB wird zu BGR
dspflp  call dspcsh6
        and #0f
        ld d,a
        ld a,c
        and #f0
        or b
        jr dspmov1

;### DSPBRG -> RGB -> RGB*5/4
dspbrg  xor a
        ld (dspbrg1),a
        ld a,#c9
        ld (dspbrg2),a
dspbrg3 call dspcsh6
        push hl
        ld a,b
        call dspbrg1
        call dspbrg2
        ld d,a
        ld a,c
        and #0f
        call dspbrg1
        call dspbrg2
        ld e,a
        ld a,c
        and #f0
        rrca:rrca:rrca:rrca
        call dspbrg1
        call dspbrg2
        add a:add a:add a:add a
        or e
        pop hl
        jr dspmov1
;A=A*4/3, max 15, B verändert
dspbrg1 nop
        add a
        add a
        ld b,-1
dspbrg4 inc b
        sub 3
        jr nc,dspbrg4
        ld a,b
        cp 16
        ret c
        ld a,15
        ret
;A=A*3/4, B verändert
dspbrg2 ld b,a
        add a
        add b
        srl a:srl a             ;A=A*5/4
        ret

;### DSPBRG -> RGB -> RGB*4/5
dspdrk  xor a
        ld (dspbrg2),a
        ld a,#c9
        ld (dspbrg1),a
        jr dspbrg3


;==============================================================================
;### SCREEN-SAVER #############################################################
;==============================================================================

savprz  db 0
savadr  dw 0:db 0

;### SAVCHK -> Screensaver wurde an/ausgeschaltet
savchk  call savini
        call savshw
        jp prgprz0

;### SAVSHW -> Zeigt Screensaver-Vorschau
savshw  call savpic
        ld e,7
        jp dsppn6

;### SAVTST -> Testet temporären Screensaver
savtst  ld c,MSC_SAV_START
        call savrem1
        jp prgprz0

;### SAVCFG -> Fordert temporären Screensaver zur Konfiguration auf
savcfg  ld c,MSC_SAV_CONFIG
        call savrem1
        jp prgprz0

;### SAVSTO -> Übernimmt geänderte Konfiguration von temporärem Screensaver
savsto  ld a,(prgbnknum)
        add a:add a:add a:add a
        or (iy+1)
        ld l,(iy+2)
        ld h,(iy+3)
        ld de,scrsavcfg
        ld bc,64
        rst #20:dw jmp_bnkcop
        jp prgprz0

;### SAVBRW -> "Screensaver"-Tab -> Browse-Button wurde geklickt
savbrw  ld a,2
        ld hl,dspobjdatma
        ld d,0
        call prgbro
        jp prgprz0

;### SAVINI -> Aktualisiert temporären Screensaver
savinih db 0
savinic db 0

savini  call savrem
        ld a,(scrsavflg)    ;** Test, ob neuer Screensaver gewünscht
        or a
        ret z                   ;nein -> fertig
        ld a,(prgbnknum)    ;** neuen Screensaver laden
        ld hl,dspobjdatmb
        call prgrun
        or a
        ret nz
        ld a,h
        ld (savprz),a           ;Prozessnummer merken
        db #dd:ld h,a           ;IXH=Screensaver-Prozeß-Nummer
        ld a,(prgprzn)
        db #dd:ld l,a           ;IXL=Programm-Prozeß-Nummer
        ld iy,prgmsgb           ;IY=Messagebuffer
        ld (iy+0),MSC_SAV_INIT  ;Init-Commando
        ld a,(prgbnknum)
        ld (iy+1),a             ;Config-Daten Ram-Bank
        ld hl,scrsavcfg
        ld (iy+2),l             ;Config-Daten Adresse
        ld (iy+3),h
        rst #10                 ;Config-Daten (64 Bytes) an Screensaver senden (falls der damit was anfangen kann)
savini1 ld a,(prgbnknum)    ;** Screensaver-Vorschaubild laden
        ld hl,dspobjdatmb
        db #dd:ld h,a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOPN
        ret c
        ld (savinih),a

        ld ix,40
        ld iy,0
        ld c,0
        push af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI
        pop bc
        jp c,savinie
        ld a,(prgbnknum)
        ld e,a
        ld a,b
        ld hl,savinic
        ld bc,1
        push af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        pop bc
        jp c,savinie
        ld a,(savinic)
        rla
        ld ix,256
        jr nc,savini4
        ld ixl,8
savini4 ld iy,0
        ld c,0
        ld a,b
        push af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI
        pop bc
        jp c,savinie
        ld a,(prgbnknum)
        ld e,a
        ld a,b
        ld hl,sprdspsav
        ld bc,16*40+3
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        jp c,savinie
        jp nz,savinie
        call savini2
        ld ix,sprdspsav
        ld a,16:cp (ix+0):jr nz,savini3
        ld a,64:cp (ix+1):jr nz,savini3
        ld a,40:cp (ix+2):jr z,savpic
savini3 ld (ix+0),16
        ld (ix+0),64
        ld (ix+0),40
        ld hl,sprdspsav+3
        ld de,sprdspsav+4
        ld (hl),#f0
        ld bc,16*40-1
        ldir
        jr savpic
savini2 ld a,(savinih)
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        ret
savinie call savini2
        jr savini3

;### SAVPIC -> Updated Screensaver-Vorschau
savpic  ld a,(scrsavflg)
        or a
        ld hl,1
        jr z,savpic1
        ld a,8
        ld hl,sprdspsav
savpic1 ld (prgdatdspb1-2),a
        ld (prgdatdspb1),hl
        ret

;### SAVREM -> Entfernt temporären Screensaver
savrem  ld c,MSC_GEN_QUIT
        call savrem1
        xor a
        ld (savprz),a
        jr savpic
savrem1 ld a,(savprz)
        or a
        ret z
        db #dd:ld h,a           ;IXH=Screensaver-Prozeß-Nummer
        ld a,(prgprzn)
        db #dd:ld l,a           ;IXL=Programm-Prozeß-Nummer
        ld iy,prgmsgb           ;IY=Messagebuffer
        ld (iy+0),c             ;Quit-Commando
        rst #10                 ;alten Screensaver auffordern, sich zu beenden
        ret


;==============================================================================
;### COLOUR-SETTINGS ##########################################################
;==============================================================================

coltabdef
db 00,01,-1,    #80,-1,      08,-1,          09,-1,    #80,-1
db 04,-1,       05,-1,       10,-1,          11,-1,    #80,-1
db 20,24,-1,    21,25,-1,    22,26,27,28,-1, 30,-1,    #80,-1
db 32,-1,       33,-1,       44,36,34,48,-1, 42,37,-1,  58,-1
db 38,-1,       40,-1,       #80,-1,         46,-1, 44+#80,-1
db 62,66,70,-1, 63,67,71,-1, 60,64,68,72,-1, 61,-1,     74,-1
db #80,-1,      #80,-1,      76,-1,          77,-1,    #80,-1
db 78,-1,       80,-1,       82,-1,          84,-1,    #80,-1
db 12,-1,       14,-1,       16,-1,          18,-1,    #80,-1
db 50,-1,       52,-1,       54,-1,          56,-1,    #80,-1

coltabprv
db 0,0,2,3,0
db 0,1,2,3,0
db 0,1,2,3,0
db 0,1,2,3,4
db 0,1,4,3,0
db 0,1,2,3,4
db 2,2,2,3,0
db 3,1,0,1,0
db 3,2,0,1,0
db 1,2,3,0,0

dspobjtxtrx db "Frame 1 ",0
            db "Frame 2 ",0
            db "Backgr. ",0
            db "Text    ",0
dspobjtxtry db "Colour 1",0
            db "Colour 2",0
            db "Colour 3",0
            db "Colour 4",0
dspobjtxtrz db "Bar "

;### COLGET -> Setzt Zeiger auf Nibble-Gruppe
;### Eingabe    A=Nummer
;### Ausgabe    IX=Zeiger
;### Verändert  AF,E
colget  ld ix,coltabdef
colget1 or a
        ret z
colget2 ld e,(ix+0)
        inc ix
        inc e
        jr nz,colget2
        dec a
        jr colget1

;### COLAKT -> Holt Einstellungen des aktuellen Elements
colakt  call colakt0
        ld e,-1
        ld c,MSC_DSK_WINPIN
        ld a,(prgwin)
        ld b,a
        ld hl,25
        ld (prgmsgb+6),hl
        ld l,55
        ld (prgmsgb+8),hl
        ld l,58
        ld (prgmsgb+10),hl
        ld l,66
        call msgsnd
        ld de,256*20+256-3
        ld c,MSC_DSK_WINDIN
        ld a,(prgwin)
        ld b,a
        call msgsnd
        jp prgprz0
colakt0 ld a,3                      ;** Buttons
        ld (dspobjradr),a
colakt5 ld a,(dspobjdats0+12)
        push af
        ld c,a
        add a
        add a
        add c
        ld c,a
        ld b,5
        ld iy,prgdatdspe1
colakt1 ld a,c
        call colget
        ld l,(ix+0)
        res 7,l
        srl l
        ld h,0
        ld de,cfgcolwr1
        push af
        add hl,de
        pop af
        ld a,(hl)
        jr nc,colakt2
        rrca:rrca:rrca:rrca
colakt2 and 15
        add 192
        ld (iy+4),a
        ld (iy+2),2
        ld (iy+2-80),18
        bit 7,(ix+0)
        jr z,colakt4
colakt3 ld (iy+2),64
        ld (iy+2-80),64
colakt4 ld de,16
        add iy,de
        inc c
        djnz colakt1
        pop af                      ;** Button oder Grafik
        cp 7
        ld hl,dspobjtxtrx
        jr c,colakt9
        ld hl,dspobjtxtry
colakt9 ld de,dspobjtxtr1
        ld bc,4*9
        ldir
        cp 2
        jr nz,colakta
        ld hl,dspobjtxtrz
        ld de,dspobjtxtr1+27
        ld bc,4
        ldir
colakta ld c,a                      ;** Example
        add a
        add a
        add c
        ld c,a
        ld b,0
        ld ix,coltabprv
        add ix,bc
        call colakt6
        ld e,a
        call colakt6
        add a:add a:add a:add a
        or e
        ld (prgdatdspe2+5),a
        call colakt6
        ld e,a
        or 192
        ld (prgdatdspe2+4),a
        call colakt6
        add a:add a:add a:add a
        or e
        ld e,a
        ld (dspobjdatr6+2),a
        ld a,(ix+0)
        or a
        jr z,colakt8
        call colakt7
        ld d,a
        add a:add a:add a:add a
        or d
        xor e
        ld (dspobjdatr7+2),a
        ld a,1-64
colakt8 add 64
        ld (prgdatdspe2+32+2),a
        ret
colakt6 ld a,(ix+0)
colakt7 inc ix
        add a:add a:add a:add a
        ld l,a
        ld h,0
        ld bc,prgdatdspe1+4
        add hl,bc
        ld a,(hl)
        and 15
        ret

;### COLSET -> Setzt Farbe eines Elements
colsetx db 0

colsetf inc a
colsete inc a
colsetd inc a
colsetc inc a
colsetb inc a
colseta inc a
colset9 inc a
colset8 inc a
colset7 inc a
colset6 inc a
colset5 inc a
colset4 inc a
colset3 inc a
colset2 inc a
colset1 inc a
colset0 ld c,a
        add a:add a:add a:add a
        ld b,a
        ld a,(dspobjdats0+12)
        ld e,a
        add a
        add a
        add e
        ld hl,dspobjradr
        add (hl)
        call colget
colsetg ld l,(ix+0)
        inc l
        jr z,colsetj
        dec l
        srl l
        ld h,0
        ld de,cfgcolwr1
        push af
        add hl,de
        pop af
        ld a,(hl)
        jr c,colseth
        and #f0
        or c
        jr colseti
colseth and #0f
        or b
colseti ld (hl),a
        inc ix
        jr colsetg
colsetj call colakt5
        ld de,256*15+256-8
        ld c,MSC_DSK_WININH
        ld a,(prgwin)
        ld b,a
        call msgsnd
        ld a,#80
        ld (colsetx),a
        jp prgprz0

;### COLDTB -> Opens/focusses palette define window (for EP-Taskbar)
coldtb  ld hl,4*256+64
        jr coldef0

;### COLDEF -> Opens/focusses palette define window
coldef  ld hl,0*256+2
coldef0 ld a,l
        ld (prgdatdspc1+2),a
        ld a,h
        ld (dsppofs),a
        ld (dsppnp),a
        call dsppn9
        call dspcsh
        ld a,(colwin)
        cp -1
        jr nz,coldef2
        ld c,MSC_DSK_WINOPN
        ld a,(prgbnknum)
        ld b,a
        ld de,prgwincol
        call msgsnd
coldef1 call msgdsk             ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        cp MSR_DSK_WOPNER
        jp z,prgprz0            ;kein Speicher für Fenster -> dann halt nicht
        cp MSR_DSK_WOPNOK
        jr nz,coldef1           ;andere Message als "Fenster geöffnet" -> ignorieren
        ld a,(prgmsgb+4)
        ld (colwin),a           ;Fenster wurde geöffnet -> Nummer merken
        jp prgprz0
coldef2 ld c,MSC_DSK_WINTOP
coldef3 ld b,a
        call msgsnd
        jp prgprz0

;### COLCNC -> Closes palette define window
colcnc  ld hl,colwin
        ld a,(hl)
        cp -1
        jp z,prgprz0
        ld (hl),-1
        ld c,MSC_DSK_WINCLS
        jr coldef3

colselext db "scd",0
colselpth db "colour.scd"
          ds 256-10

;### COLLOD -> Load Colour-Definition (open)
collod  ld a,3
        ld hl,colselext
        ld d,0
        call prgbro
        jp prgprz0

;### COLSAV -> Save Colour-Definition (open)
colsav  ld a,4
        ld hl,colselext
        ld d,64
        call prgbro
        jp prgprz0

;### COLLDX -> Load Colour-Definition (execute)
colldx  ld a,(prgbnknum)
        ld hl,colselpth
        db #dd:ld h,a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOPN
        jp c,prgprz0
        push af
        ld de,(prgbnknum)
        ld hl,cfgcolbeg
        ld bc,cfgcolend-cfgcolbeg
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        pop af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        xor a
        ld (dspobjdats0+12),a
        ld a,#80
        ld (colsetx),a
        ld e,7
        call dsppn6
        jp colakt

;### COLSVX -> Save Colour-Definition (execute)
colsvx  ld a,(prgbnknum)
        ld hl,colselpth
        db #dd:ld h,a
        xor a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILNEW
        jp c,prgprz0
        push af
        ld de,(prgbnknum)
        ld hl,cfgcolbeg
        ld bc,cfgcolend-cfgcolbeg
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOUT
        pop af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        jp prgprz0


;==============================================================================
;### DATEN-TEIL ###############################################################
;==============================================================================

prgdatbeg

prgicn16c db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Anzeige
db #88,#88,#83,#33,#33,#33,#33,#33,#33,#33,#33,#88,#88,#88,#32,#22,#22,#22,#22,#2F,#12,#22,#03,#18,#88,#83,#22,#22,#22,#22,#22,#2F,#12,#20,#33,#18,#88,#30,#00,#00,#00,#00,#00,#FF,#F1,#03,#33,#18
db #83,#02,#22,#22,#22,#22,#22,#FF,#F1,#23,#33,#18,#83,#02,#33,#33,#33,#33,#33,#21,#12,#23,#33,#18,#83,#02,#11,#11,#11,#11,#11,#FF,#F1,#73,#33,#18,#83,#02,#11,#88,#11,#11,#11,#F8,#E7,#61,#33,#18
db #83,#02,#18,#11,#11,#11,#11,#FE,#76,#67,#13,#18,#83,#02,#11,#11,#11,#11,#11,#F7,#67,#66,#71,#18,#83,#02,#18,#11,#11,#11,#11,#76,#66,#17,#13,#18,#83,#02,#11,#11,#11,#11,#17,#67,#66,#71,#33,#18
db #83,#02,#11,#11,#11,#11,#76,#66,#17,#13,#33,#18,#83,#02,#11,#11,#11,#17,#67,#66,#71,#23,#33,#18,#83,#02,#11,#11,#11,#76,#66,#17,#11,#23,#33,#18,#83,#02,#00,#00,#07,#67,#66,#71,#E1,#23,#33,#18
db #83,#02,#22,#22,#76,#66,#17,#18,#E1,#23,#31,#88,#83,#33,#33,#37,#67,#66,#71,#FE,#E1,#33,#18,#88,#88,#11,#11,#76,#66,#17,#11,#F8,#E1,#11,#88,#88,#88,#88,#33,#27,#66,#71,#21,#FE,#E1,#88,#88,#88
db #88,#83,#20,#20,#17,#12,#22,#F8,#E1,#18,#88,#88,#88,#83,#02,#02,#21,#22,#22,#21,#13,#18,#88,#88,#88,#88,#11,#20,#02,#00,#22,#33,#11,#88,#88,#88,#88,#88,#88,#11,#11,#11,#11,#11,#88,#88,#88,#88

;Anzeige
prgtitdsp   db "Display",0
prgtitcol   db "Palette",0

prgbuttxt1  db "Ok",0
prgbuttxt2  db "Cancel",0
prgbuttxt3  db "Apply",0
prgbuttxt4  db "Load",0
prgbuttxt5  db "Save",0
prgbuttxt6  db "Define...",0
prgbuttxt7  db "Taskbar...",0

;### DISPLAY ##################################################################

dsptabtxt1  db "Deskt.",0
dsptabtxt2  db "Saver",0
dsptabtxt3  db "Colours",0
dsptabtxt4  db "Modi",0

dspobjtxtb  db "Background",0
dspobjtxtc  db 0
dspobjtxtd  db "Browse...",0
dspobjtxte  db "Browse",0
dspobjtxtf  db "Setup",0
dspobjtxtg  db "Screensaver",0
dspobjtxth  db "Wait",0
dspobjtxti  db "min",0
dspobjtxtj  db "Test",0

dspobjtxt2  db "Elements",0
dspobjtxtk  db "Definition",0
dspobjtxt3  db "Palette",0
dspobjtxt4  db "R",0
dspobjtxt5  db "G",0
dspobjtxt6  db "B",0
dspobjtxt7  db "Roll",0
dspobjtxt8  db "Flip",0
dspobjtxt9  db "Bright",0
dspobjtxta  db "Dark",0
dspobjdspr  db "3",0
dspobjdspg  db "6",0
dspobjdspb  db "9",0

dspobjtxt1  db "Screenmodi",0
dspobjtxm0  db "720 x 256 (2 colours)",0
dspobjtxm1  db "320 x 200 (4 colours)",0
dspobjtxm2  db "640 x 200 (2 colours)",0
dspobjtxm5  db "256 x 212 (16 colours)",0
dspobjtxm6  db "512 x 212 (4 colours)",0
dspobjtxm7  db "512 x 212 (16 colours)",0
dspobjtxm14 db "480 x 128 (2 colours)",0
dspobjtxm15 db "480 x 192 (2 colours)",0
dspobjtxm16 db "480 x 256 (2 colours)",0
dspobjtxm20 db "640 x 226 (16 colours)",0
dspobjtxm21 db "640 x 256 (16 colours)",0

dspobjtxm32 db "320x200 (legacy)",0
dspobjtxm33 db "512x256 (2:1)",0
dspobjtxm34 db "640x360 (16:9)",0
dspobjtxm35 db "640x480 (VGA)",0
dspobjtxm36 db "640x512 (Amiga)",0
dspobjtxm37 db "800x480 (WVGA)",0
dspobjtxm38 db "860x360 (43:18)",0
dspobjtxm39 db "960x540 (qHD)",0
dspobjtxm40 db "1280x720 (HD ready)",0
dspobjtxm41 db "1280x1024 (Insane)",0
dspobjtxm42 db "1720x720 (qUWQHD)",0
dspobjtxm43 db "1920x1080 (FullHD)",0
dspobjtxm44 db "3440x1440 (UltrawideQHD)",0
dspobjtxm45 db "3840x1600 (QuadHD+)",0

dspobjtxm8  db "Low",0
dspobjtxm9  db "High",0
dspobjtxma  db "384x240x16 (normal)",0
dspobjtxmb  db "384x240x16 (512 virtual)",0
dspobjtxmc  db "384x240x16 (1000 virtual)",0
dspobjtxmd  db "512x212x16 (normal)",0
dspobjtxme  db "512x212x16 (1000 virtual)",0
dspobjtxmf  db "768x240x16 (normal)",0
dspobjtxmg  db "768x240x16 (1000 virtual)",0
dspobjtxmh  db "1024x212x16 (normal)",0

dspobjtxtr1 db "Frame 1 ",0
dspobjtxtr2 db "Frame 2 ",0
dspobjtxtr3 db "Backgr. ",0
dspobjtxtr4 db "Text    ",0
dspobjtxtr5 db "Invert",0

dspobjtxtr6 db "Preview",0

dspobjtxts1 db "Title",0
dspobjtxts2 db "Status",0
dspobjtxts3 db "Slider",0
dspobjtxts4 db "Menu (1)",0
dspobjtxts5 db "Menu (2)",0
dspobjtxts6 db "Taskbar",0
dspobjtxts7 db "Icons",0
dspobjtxts8 db "Content",0
dspobjtxts9 db "Symbols",0
dspobjtxtsa db "Startlogo",0

dspobjtxmt  dw 256*0+08,dspobjtxma,256*1+08,dspobjtxmb,256*2+08,dspobjtxmc   ; 8
            dw 256*0+09,dspobjtxmd,256*2+09,dspobjtxme                       ; 9
            dw 256*0+10,dspobjtxmf,256*2+10,dspobjtxmg                       ;10
            dw 256*0+11,dspobjtxmh                                           ;11
dspobjtxnt  dw dspobjtxm32,dspobjtxm33,dspobjtxm34,dspobjtxm35,dspobjtxm36,dspobjtxm37,dspobjtxm38,dspobjtxm39,dspobjtxm40,dspobjtxm41,dspobjtxm42,dspobjtxm43,dspobjtxm44,dspobjtxm45
svmmod_cnt  equ 14  ;see DSPMDST as well!

sprdspmonu  db 20,80,9
db #7F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#EF
db #88,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11
db #88,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11
db #88,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11
db #88,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11
db #88,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11
db #88,#77,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#11
db #88,#74,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#C3,#11
db #88,#74,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#C3,#11

sprdspmonl  db 2,8,44
db #88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74
db #88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74
db #88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74
db #88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74,#88,#74

sprdspmonr  db 2,8,44
db #C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11
db #C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11
db #C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11
db #C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11,#C3,#11

sprdspmond  db 20,80,11
db #88,#74,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#C3,#11
db #88,#74,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#C3,#11
db #88,#03,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0E,#11
db #88,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11
db #88,#00,#00,#00,#00,#02,#00,#08,#02,#01,#01,#01,#02,#05,#05,#05,#15,#8D,#05,#11
db #88,#00,#00,#00,#00,#11,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#8C,#00,#32,#C6,#0A,#11
db #88,#00,#00,#00,#00,#22,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#4D,#37,#36,#C5,#05,#11
db #88,#00,#00,#00,#00,#23,#05,#05,#05,#05,#05,#05,#05,#05,#44,#00,#11,#8A,#0A,#11
db #88,#00,#00,#00,#00,#22,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A,#4D,#05,#05,#05,#05,#11
db #8F,#0F,#0F,#0F,#0F,#2F,#AF,#AF,#AF,#AF,#AF,#AF,#AF,#AF,#4F,#0F,#0F,#0F,#0F,#1F
db #7F,#FF,#FF,#FF,#FC,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F3,#FF,#FF,#FF,#EF

sprdspmonb  db 10,40,5
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #F5,#D7,#4E,#0A,#08,#01,#05,#27,#BE,#FA
db #F2,#AF,#8D,#04,#00,#00,#02,#1B,#5F,#F4
db #F5,#D7,#4E,#0A,#08,#01,#05,#27,#BE,#FA
db #7A,#EB,#AF,#AF,#8F,#1F,#5F,#5F,#7D,#E5

sprdspmd0 db 16,64,40
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#FF,#0C,#00,#03,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#FF,#30,#3C,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #FF,#FF,#03,#F0,#F3,#0F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#C0,#F0
db #FF,#FF,#30,#F0,#C3,#CF,#CC,#00,#CC,#00,#33,#33,#33,#FF,#30,#30
db #FF,#FF,#30,#F0,#C3,#3F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#C0,#F0
db #FF,#FF,#0C,#00,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #FF,#FF,#FF,#FF,#C3,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3C
db #FC,#F3,#F3,#F0,#C3,#FF,#3C,#3C,#C3,#F0,#3F,#FF,#FF,#FF,#FF,#3C
db #FF,#FF,#FF,#FF,#C3,#CF,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#FF,#FF,#C3,#CF,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#0C,#00,#C3,#CF,#3F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#30,#3C,#C3,#CF,#FF,#3C,#C3,#C3,#C3,#F0,#C3,#C3,#3F,#3C
db #FF,#FF,#03,#F0,#C3,#CF,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#30,#F0,#C3,#CF,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#30,#F0,#C3,#CF,#3F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#0C,#00,#C3,#CF,#FF,#3C,#3C,#C3,#C3,#F0,#3C,#C3,#3F,#3C
db #FF,#FF,#FF,#FF,#C3,#CF,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FC,#F3,#F3,#F0,#C3,#CF,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#FF,#FF,#C3,#CF,#3F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #FF,#FF,#FF,#FF,#C3,#CF,#FF,#3C,#3C,#3C,#F0,#3C,#C3,#C3,#3F,#3C
db #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #3C,#3C,#C3,#C3,#F0,#C3,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #3F,#CC,#CC,#FF,#33,#CF,#F0,#3C,#C3,#C3,#C3,#C3,#C3,#C3,#3F,#3C
db #3F,#33,#FF,#33,#FF,#03,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#3C
db #0F,#0F,#0F,#0F,#0F,#0F,#F0,#F0,#3C,#3C,#C3,#0F,#0F,#0F,#3F,#3C
db #3C,#C3,#F0,#C3,#C3,#C3,#0F,#0F,#0F,#0F,#0F,#FF,#FF,#FF,#FF,#3C
db #0F,#0F,#0F,#0F,#0F,#0F,#F0,#C3,#C3,#F0,#C3,#0F,#0F,#0F,#0F,#3C
db #3C,#3C,#C3,#C3,#F0,#C3,#0F,#0F,#0F,#0F,#0F,#CF,#FF,#FF,#FF,#3C
db #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3F,#C3,#C3,#CF,#FC,#C3,#F3,#3C
db #3C,#F0,#3C,#3C,#3C,#C3,#0F,#0F,#3F,#FF,#FF,#CF,#FF,#FF,#FF,#3C
db #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F,#3C
db #3C,#C3,#C3,#F0,#C3,#C3,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #0F,#0F,#0F,#0F,#0F,#0F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3,#F3
db #CF,#CF,#0F,#0F,#3F,#CF,#CF,#0F,#0F,#0F,#0F,#CF,#0F,#0F,#0F,#0F
db #3F,#3C,#C3,#F0,#3F,#3F,#0F,#F0,#3C,#F0,#C3,#CF,#C3,#F0,#3C,#C3
db #CF,#CF,#0F,#0F,#3F,#CF,#CF,#0F,#0F,#0F,#0F,#CF,#0F,#0F,#0F,#0F

sprdspmd1 db 16,64,40
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#08,#37,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #FF,#52,#B3,#FF,#FF,#FF,#FC,#F0,#F0,#F0,#F0,#F0,#F3,#FF,#FF,#FF
db #FF,#34,#B3,#FF,#FF,#FF,#FD,#3F,#FF,#FF,#FF,#EC,#F3,#FF,#FF,#FF
db #FF,#70,#B3,#FF,#FF,#FF,#ED,#AE,#22,#11,#55,#DC,#73,#FF,#FF,#FF
db #FF,#70,#B3,#FF,#FF,#FF,#ED,#7F,#FF,#FF,#FF,#EC,#F3,#FF,#FF,#FF
db #FF,#08,#37,#FF,#FF,#FF,#FC,#F0,#F0,#F0,#F0,#F0,#F3,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#ED,#0F,#0F,#0F,#0F,#0F,#7B,#FF,#FF,#FF
db #F9,#F4,#FA,#F7,#FF,#FF,#ED,#DE,#69,#D3,#FF,#FF,#7B,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#08,#37,#FF,#FF,#FF,#ED,#9F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#52,#B3,#FF,#FF,#FF,#ED,#BF,#69,#A5,#E1,#97,#7B,#FF,#FF,#FF
db #FF,#34,#B3,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#70,#B3,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#70,#B3,#FF,#FF,#FF,#ED,#9F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#08,#37,#FF,#FF,#FF,#ED,#BF,#5A,#A5,#D2,#97,#7B,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #F9,#F4,#FA,#F7,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#ED,#9F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #FF,#FF,#FF,#FF,#FF,#FF,#ED,#BF,#5A,#78,#69,#97,#7B,#FF,#FF,#FF
db #0F,#0F,#0F,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #5A,#A5,#E1,#FF,#FF,#FF,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #0F,#0F,#0F,#0F,#0F,#1F,#ED,#9F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #6E,#BB,#67,#69,#D2,#5B,#ED,#BF,#78,#5A,#A5,#97,#7B,#FF,#FF,#FF
db #5D,#DD,#CD,#0F,#0F,#1F,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #0F,#0F,#0F,#78,#A5,#D3,#ED,#8F,#0F,#0F,#0F,#1F,#7B,#FF,#FF,#FF
db #69,#E1,#A5,#0F,#0F,#1F,#ED,#FF,#FF,#FF,#FF,#FF,#7B,#FF,#FF,#FF
db #0F,#0F,#0F,#78,#5A,#D3,#ED,#0F,#0F,#0F,#0F,#0F,#7B,#FF,#FF,#FF
db #5A,#A5,#E1,#0F,#0F,#1F,#ED,#0F,#1F,#FF,#BF,#FF,#7B,#FF,#FF,#FF
db #0F,#0F,#0F,#FF,#FF,#FF,#ED,#0F,#1F,#A5,#BE,#B5,#7B,#FF,#FF,#FF
db #78,#5A,#69,#FF,#FF,#FF,#ED,#0F,#1F,#FF,#BF,#FF,#7B,#FF,#FF,#FF
db #0F,#0F,#0F,#FF,#FF,#FF,#ED,#0F,#0F,#0F,#0F,#0F,#7B,#FF,#FF,#FF
db #69,#B4,#A5,#FF,#FF,#FF,#FC,#F0,#F0,#F0,#F0,#F0,#F3,#FF,#FF,#FF
db #0F,#0F,#0F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
db #F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5
db #AF,#0F,#6F,#8F,#0F,#0F,#DF,#0F,#0F,#1F,#AF,#0F,#0F,#2F,#0F,#0F
db #5E,#B4,#5F,#3C,#78,#A5,#AF,#5A,#69,#D3,#4F,#B4,#A5,#A7,#B4,#69
db #AF,#0F,#6F,#8F,#0F,#0F,#DF,#0F,#0F,#1F,#AF,#0F,#0F,#2F,#0F,#0F

sprdspmd2 db 16,64,40
db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
db #10,#80,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
db #20,#C0,#00,#00,#00,#00,#00,#00,#70,#F0,#F0,#80,#00,#00,#00,#00
db #20,#C0,#00,#00,#00,#00,#00,#00,#50,#F0,#E0,#80,#00,#00,#00,#00
db #30,#C0,#00,#00,#00,#00,#00,#00,#50,#50,#50,#80,#00,#00,#00,#00
db #30,#C0,#00,#00,#00,#00,#00,#00,#70,#F0,#E0,#80,#00,#00,#00,#00
db #10,#80,#00,#00,#00,#00,#00,#00,#70,#F0,#F0,#80,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#40,#00,#00,#80,#00,#00,#00,#00
db #50,#60,#00,#00,#00,#00,#00,#00,#50,#50,#E0,#80,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#60,#00,#10,#80,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#40,#00,#10,#80,#00,#00,#00,#00
db #10,#80,#00,#00,#00,#00,#00,#00,#60,#80,#00,#80,#00,#00,#00,#00
db #20,#C0,#00,#00,#00,#00,#00,#00,#40,#A0,#D0,#80,#00,#00,#00,#00
db #20,#C0,#00,#00,#00,#00,#00,#00,#60,#00,#00,#80,#00,#00,#00,#00
db #30,#C0,#00,#00,#00,#00,#00,#00,#40,#00,#10,#80,#00,#00,#00,#00
db #30,#C0,#00,#00,#00,#00,#00,#00,#60,#80,#00,#80,#00,#00,#00,#00
db #10,#80,#00,#00,#00,#00,#00,#00,#40,#B0,#50,#80,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#60,#00,#00,#80,#00,#00,#00,#00
db #50,#60,#00,#00,#00,#00,#00,#00,#40,#00,#10,#80,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#60,#80,#00,#80,#00,#00,#00,#00
db #00,#00,#00,#00,#00,#00,#00,#00,#40,#A0,#90,#80,#00,#00,#00,#00
db #F0,#F0,#00,#00,#00,#00,#00,#00,#60,#00,#00,#80,#00,#00,#00,#00
db #00,#10,#F0,#F0,#00,#00,#00,#00,#40,#00,#10,#80,#00,#00,#00,#00
db #50,#D0,#00,#10,#00,#00,#00,#00,#60,#80,#00,#80,#00,#00,#00,#00
db #00,#10,#50,#50,#00,#00,#00,#00,#40,#B0,#50,#80,#00,#00,#00,#00
db #50,#50,#00,#10,#00,#00,#00,#00,#60,#00,#00,#80,#00,#00,#00,#00
db #00,#10,#60,#90,#00,#00,#00,#00,#60,#00,#10,#80,#00,#00,#00,#00
db #60,#D0,#00,#10,#00,#00,#00,#00,#50,#F0,#E0,#80,#00,#00,#00,#00
db #00,#10,#50,#D0,#00,#00,#00,#00,#40,#00,#00,#80,#00,#00,#00,#00
db #50,#90,#00,#10,#00,#00,#00,#00,#40,#30,#60,#80,#00,#00,#00,#00
db #00,#10,#F0,#F0,#00,#00,#00,#00,#40,#20,#40,#80,#00,#00,#00,#00
db #60,#D0,#00,#00,#00,#00,#00,#00,#40,#30,#60,#80,#00,#00,#00,#00
db #00,#10,#00,#00,#00,#00,#00,#00,#40,#00,#00,#80,#00,#00,#00,#00
db #50,#50,#00,#00,#00,#00,#00,#00,#70,#F0,#F0,#80,#00,#00,#00,#00
db #00,#10,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
db #F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #80,#60,#00,#60,#00,#60,#00,#40,#00,#00,#00,#00,#00,#00,#40,#00
db #50,#50,#50,#50,#50,#50,#50,#40,#00,#00,#00,#00,#00,#00,#50,#A0
db #80,#60,#00,#60,#00,#60,#00,#40,#00,#00,#00,#00,#00,#00,#40,#00

sprdspbgr db 16,64,40
db #FD,#33,#AF,#0F,#0A,#00,#00,#00,#00,#00,#07,#4F,#1F,#78,#CD,#06
db #FE,#3B,#6F,#0E,#09,#01,#02,#00,#00,#01,#F8,#C7,#0F,#78,#EF,#06
db #7C,#1A,#6F,#0D,#04,#08,#00,#00,#00,#7D,#8F,#0F,#0F,#FC,#7E,#0F
db #3C,#13,#6F,#0E,#08,#02,#04,#00,#36,#C4,#00,#0F,#1F,#6D,#5E,#8F
db #BE,#99,#6F,#09,#05,#04,#01,#05,#F9,#1B,#EF,#4E,#0F,#E9,#3E,#A7
db #BE,#81,#6B,#0E,#00,#02,#0A,#17,#E3,#F0,#F0,#CE,#07,#EA,#3E,#B7
db #DE,#81,#F4,#F0,#E7,#0D,#04,#0B,#FE,#F0,#F0,#86,#07,#EF,#3E,#FF
db #DA,#C4,#E1,#1F,#F8,#C3,#0D,#07,#7E,#F0,#F0,#0B,#17,#CA,#3D,#7F
db #FB,#84,#E7,#1F,#F8,#E3,#0A,#03,#3D,#74,#E7,#0B,#03,#CE,#6F,#CF
db #FB,#88,#FD,#F8,#F0,#F3,#0D,#03,#75,#EF,#08,#01,#13,#8F,#7F,#CF
db #FB,#04,#FE,#F0,#F0,#FD,#8C,#05,#03,#08,#00,#01,#0B,#CF,#7F,#8F
db #6B,#46,#7E,#F1,#78,#ED,#0E,#01,#00,#02,#0A,#01,#1F,#CF,#7F,#8D
db #CE,#4A,#7F,#F0,#FF,#0D,#0E,#02,#00,#00,#00,#03,#1B,#EF,#FF,#19
db #8F,#CA,#67,#7F,#8E,#03,#0E,#03,#08,#00,#00,#01,#17,#FB,#6D,#13
db #1F,#CB,#2F,#CE,#0A,#09,#0E,#01,#00,#00,#00,#03,#13,#EF,#4E,#13
db #1F,#CB,#27,#0F,#04,#01,#0E,#02,#0C,#00,#00,#02,#17,#EF,#4F,#07
db #3F,#DF,#27,#8E,#00,#05,#0E,#03,#00,#00,#00,#06,#17,#EB,#CF,#0B
db #1F,#6F,#27,#0E,#08,#02,#0F,#02,#08,#00,#00,#04,#07,#CF,#C7,#0D
db #1F,#CF,#73,#8C,#00,#01,#0E,#09,#0F,#00,#00,#08,#1F,#C3,#C7,#4F
db #1F,#CF,#61,#0E,#00,#03,#0E,#02,#0F,#0F,#05,#09,#1F,#CF,#CF,#CF
db #1B,#CF,#79,#0C,#00,#0B,#0E,#01,#0B,#07,#0F,#01,#3F,#CF,#4F,#CE
db #99,#CF,#79,#0E,#08,#07,#0F,#00,#05,#09,#0F,#0B,#1F,#C3,#3F,#CB
db #99,#C7,#79,#8E,#02,#1F,#0E,#00,#07,#0F,#2F,#07,#9F,#CA,#0F,#6A
db #09,#CF,#F8,#0E,#0D,#0F,#0E,#01,#4F,#09,#0F,#0F,#3F,#CF,#0F,#25
db #0D,#E6,#F8,#8F,#07,#4F,#CF,#0F,#8F,#01,#0F,#0F,#1F,#C7,#4D,#3B
db #0D,#EB,#F8,#C7,#0F,#8F,#7F,#3F,#0C,#17,#E9,#0F,#3F,#CF,#0E,#3B
db #0D,#E7,#78,#D3,#1F,#0F,#0F,#0F,#0F,#F8,#E0,#0F,#1F,#EE,#AE,#19
db #0C,#E3,#75,#F3,#7F,#6F,#1F,#1F,#FE,#FB,#EA,#0B,#3F,#EF,#2F,#01
db #0C,#E3,#3A,#E1,#8F,#7C,#F1,#F5,#FB,#8E,#C0,#0F,#3F,#EF,#2F,#00
db #04,#FB,#1B,#F1,#0F,#3C,#F7,#F6,#0A,#12,#84,#0F,#3F,#E7,#1F,#09
db #0E,#FB,#1D,#F0,#8F,#3A,#86,#09,#00,#30,#8C,#07,#7F,#CF,#47,#0B
db #46,#FD,#0C,#F8,#C7,#13,#C2,#00,#00,#F9,#09,#0F,#FF,#E2,#67,#8A
db #4E,#7F,#88,#F8,#D3,#0B,#F8,#0C,#3C,#E3,#08,#0F,#FF,#C6,#6F,#8D
db #2E,#77,#8E,#7C,#E1,#8D,#BE,#F0,#F1,#CB,#0A,#0F,#FE,#C4,#FD,#DD
db #67,#77,#8E,#76,#F1,#8F,#5F,#F3,#BE,#9F,#05,#1F,#FF,#C4,#7B,#4F
db #2F,#37,#8F,#37,#F0,#CF,#7F,#FE,#2F,#2F,#04,#1F,#FE,#81,#EF,#4A
db #6F,#33,#8F,#39,#F0,#AF,#3F,#CF,#0F,#4E,#09,#3F,#FC,#89,#EF,#C9
db #2F,#1B,#CF,#3B,#FC,#33,#1F,#EF,#7F,#8E,#08,#3F,#FE,#0B,#CE,#CD
db #6F,#18,#EF,#1A,#F6,#33,#8F,#FE,#F7,#0D,#02,#7F,#F4,#05,#0F,#8D
db #2F,#19,#FF,#1A,#FA,#3E,#8F,#0F,#0E,#0A,#00,#7E,#FD,#05,#4F,#8B

sprdspsav db 16,64,40
ds 16*40,#F0

prgmsgpth1  db "Path too long.",0
prgmsgpth2  db "The length of the full path",0
prgmsgpth3  db "shouldn't exceed 32 chars.",0

;==============================================================================
;### TRANSFER-TEIL ############################################################
;==============================================================================

prgtrnbeg
;### PRGPRZS -> Stack für Programm-Prozess
        ds 128
prgstk  ds 6*2
        dw prgprz
prgprzn db 0            ;Prozess-Nummer
prgmsgb ds 14


;### PATH TOO LONG ############################################################

prgmsgpth  dw prgmsgpth1,4*1+2,prgmsgpth2,4*1+2,prgmsgpth3,4*1+2

;### DISPLAY ##################################################################

prgwindsp  dw #1501,0,55,8,128,150,0,0,128,150,128,150,128,150, prgicndsp2,prgtitdsp,0,0
prgwindsp0 dw prggrpdspa,0,0:ds 136+14

prggrpdspa db 23,0:dw prgdatdspa,0,0,4*256+3,0,0,2
prggrpdspb db 20,0:dw prgdatdspb,0,0,4*256+3,0,0,2
prggrpdspc db 41,0:dw prgdatdspe,0,0,4*256+3,0,0,2
prggrpdspd db 14,0:dw prgdatdspd,0,0,4*256+3,0,0,2

dsptabdat  db 4,2+4+48+64
dsptabdat0 db 0:dw dsptabtxt1:db -1:dw dsptabtxt2:db -1:dw dsptabtxt3:db -1:dw dsptabtxt4:db -1

;Desktop-Tab
prgdatdspa
dw      0,255*256+0,          2,  0,0,1000,1000,0       ;00=Hintergrund
dw dsptab,255*256+20, dsptabdat,  0,  2,128, 11,0       ;01=Tab-Leiste
dw dspoky,255*256+16,prgbuttxt1,  23,135,32,12,0        ;02="Ok"-Button
dw dspcnc,255*256+16,prgbuttxt2,  58,135,32,12,0        ;03="Cancel"-Button
dw dspapl,255*256+16,prgbuttxt3,  93,135,32,12,0        ;04="Apply"-Button
dw      0,255*256+8,  sprdspmonu, 24, 17,80, 9,0        ;05=Grafik Monitor Up
dw      0,255*256+8,  sprdspmond, 24, 66,80,11,0        ;06=Grafik Monitor Down
dw 0,255*256+8:prgdatdspa1 dw sprdspbgr,32,26,64,40,0   ;07=Grafik Monitor-Inhalt
dw      0,255*256+8,  sprdspmonl, 24, 24, 8,44,0        ;08=Grafik Monitor Left
dw      0,255*256+8,  sprdspmonr, 96, 24, 8,44,0        ;09=Grafik Monitor Right
dw      0,255*256+8,  sprdspmonb, 44, 77,40, 5,0        ;10=Grafik Monitor Base
dw      0,255*256+3, dspobjdate,   0,86,128,48,0        ;11=Rahmen Screenmodes
dw      0,255*256+2, 0*16+1+4+64, 17,109, 14,8,0        ;12=Fläche "Hintergrund 0"
dw      0,255*256+2, 1*16+1+4+64, 45,109, 14,8,0        ;13=Fläche "Hintergrund 1"
dw      0,255*256+2, 2*16+1+4+64, 17,118, 14,8,0        ;14=Fläche "Hintergrund 2"
dw      0,255*256+2, 3*16+1+4+64, 45,118, 14,8,0        ;15=Fläche "Hintergrund 3"
dw dspbgc,255*256+18,dspobjdatf,   9,109, 28,8,0        ;16=Radiobutton "Hintergrund 0"
dw dspbgc,255*256+18,dspobjdatg,  37,109, 28,8,0        ;17=Radiobutton "Hintergrund 1"
dw dspbgc,255*256+18,dspobjdath,   9,118, 28,8,0        ;18=Radiobutton "Hintergrund 2"
dw dspbgc,255*256+18,dspobjdati,  37,118, 28,8,0        ;19=Radiobutton "Hintergrund 3"
dw dspbgc,255*256+18,dspobjdatj,   9, 98,  8,8,0        ;20=Radiobutton "Grafikfile"
dw      0,255*256+32,dspobjdatk,  17, 96,102,12,0       ;21=Textinput   "Grafikfile"
dw dspbrw,255*256+16,dspobjtxtd,  71,109, 48,12,0       ;22=Button "Durchsuchen"

dspobjdate dw dspobjtxtb,2+4
dspobjdatf dw dspobjstab,dspobjtxtc,256*0  +2+4,dspobjkrdb
dspobjdatg dw dspobjstab,dspobjtxtc,256*1  +2+4,dspobjkrdb
dspobjdath dw dspobjstab,dspobjtxtc,256*2  +2+4,dspobjkrdb
dspobjdati dw dspobjstab,dspobjtxtc,256*3  +2+4,dspobjkrdb
dspobjdatj dw dspobjstab,dspobjtxtc,256*255+2+4,dspobjkrdb
dspobjstab db 3
dspobjkrdb dw -1,-1

dspobjdatk  dw dspobjdatkb,0,0,0,0,255,0
dspobjdatka db "sgx",0
dspobjdatkb ds 256

;Colour-Tab
prgdatdspe
dw 0,255*256+0,          2,  0,0,1000,1000,0            ;00=Hintergrund
dw dsptab,255*256+20, dsptabdat,  0,  2,128, 11,0       ;01=Tab-Leiste
dw dspoky,255*256+16,prgbuttxt1,  23,135,32,12,0        ;02="Ok"-Button
dw dspcnc,255*256+16,prgbuttxt2,  58,135,32,12,0        ;03="Cancel"-Button
dw dspapl,255*256+16,prgbuttxt3,  93,135,32,12,0        ;04="Apply"-Button
dw      0,255*256+3, dspobjdat2,   0,14,128,76,0        ;05=Rahmen Colours
dw      0,255*256+3, dspobjdat3,   0,90,128,44,0        ;06=Rahmen Palette

dw colakt,255*256+42,dspobjdats0,    7, 25,54,10,0      ;07=Element-Auswahl
dw collod,255*256+16,prgbuttxt4,     7, 71,26,12,0      ;08=Button "Load"
dw colsav,255*256+16,prgbuttxt5,    35, 71,26,12,0      ;09=Button "Save"

dw      0,255*256+18,dspobjdatr1,   66, 26,43,08,0      ;10=Radio  Farbe 1
dw      0,255*256+18,dspobjdatr2,   66, 38,43,08,0      ;11=Radio  Farbe 2
dw      0,255*256+18,dspobjdatr3,   66, 50,43,08,0      ;12=Radio  Farbe 3
dw      0,255*256+18,dspobjdatr4,   66, 62,43,08,0      ;13=Radio  Farbe 4
dw      0,255*256+18,dspobjdatr5,   66, 74,43,08,0      ;14=Radio  Farbe 5
prgdatdspe1
dw      0,255*256+2, 256*19+00+192,111, 25,10,10,0      ;15=Button Farbe 1
dw      0,255*256+2, 256*19+01+192,111, 37,10,10,0      ;16=Button Farbe 2
dw      0,255*256+2, 256*19+02+192,111, 49,10,10,0      ;17=Button Farbe 3
dw      0,255*256+2, 256*19+03+192,111, 61,10,10,0      ;18=Button Farbe 4
dw      0,255*256+2, 256*19+04+192,111, 73,10,10,0      ;19=Button Farbe 5
prgdatdspe2
dw      0,255*256+2, 256*19+00+192,  9, 41,50,18,0      ;20=Button Example
dw      0,255*256+1 ,dspobjdatr6,   10, 42,48, 8,0      ;21=Text   Example
dw      0,255*256+1 ,dspobjdatr7,   10, 50,48, 8,0      ;22=Text   Example Invers

dw colset0,255*256+2, 256*19+00+192, 08,101,13,12,0     ;23=Pen0
dw colset1,255*256+2, 256*19+01+192, 22,101,13,12,0     ;24=Pen1
dw colset2,255*256+2, 256*19+02+192, 36,101,13,12,0     ;25=Pen2
dw colset3,255*256+2, 256*19+03+192, 50,101,13,12,0     ;26=Pen3
prgdatdspe3
dw coldef,255*256+16,prgbuttxt6,     73,101,47,12,0     ;27=Button "Define"
dw coldtb,255*256+16,prgbuttxt7,     73,115,47,12,0     ;28=Button "Taskbar"

dw colset4,255*256+2, 256*19+04+192, 65,101,13,12,0     ;29=Pen4
dw colset5,255*256+2, 256*19+05+192, 79,101,13,12,0     ;30=Pen5
dw colset6,255*256+2, 256*19+06+192, 93,101,13,12,0     ;31=Pen6
dw colset7,255*256+2, 256*19+07+192,107,101,13,12,0     ;32=Pen7
dw colset8,255*256+2, 256*19+08+192, 08,114,13,12,0     ;33=Pen8
dw colset9,255*256+2, 256*19+09+192, 22,114,13,12,0     ;34=Pen9
dw colseta,255*256+2, 256*19+10+192, 36,114,13,12,0     ;35=Pena
dw colsetb,255*256+2, 256*19+11+192, 50,114,13,12,0     ;36=Penb
dw colsetc,255*256+2, 256*19+12+192, 65,114,13,12,0     ;37=Penc
dw colsetd,255*256+2, 256*19+13+192, 79,114,13,12,0     ;38=Pend
dw colsete,255*256+2, 256*19+14+192, 93,114,13,12,0     ;39=Pene
dw colsetf,255*256+2, 256*19+15+192,107,114,13,12,0     ;40=Penf

dspobjdats0 dw 8,0,dspobjdats1,0,256*0+1,dspobjdats2,0,1
dspobjdats2 dw 0+0,1000,0,0
dspobjdats1 dw 00,dspobjtxts1
            dw 01,dspobjtxts2
            dw 02,dspobjtxts3
            dw 03,dspobjtxts4
            dw 04,dspobjtxts5
            dw 05,dspobjtxts6
            dw 06,dspobjtxts7
            dw 07,dspobjtxts8
            dw 08,dspobjtxts9   ;msx (16c) specific
            dw 09,dspobjtxtsa

dspobjdatr1 dw dspobjradr,dspobjtxtr1,256*0+2+4,dspobjkoor
dspobjdatr2 dw dspobjradr,dspobjtxtr2,256*1+2+4,dspobjkoor
dspobjdatr3 dw dspobjradr,dspobjtxtr3,256*2+2+4,dspobjkoor
dspobjdatr4 dw dspobjradr,dspobjtxtr4,256*3+2+4,dspobjkoor
dspobjdatr5 dw dspobjradr,dspobjtxtr5,256*4+2+4,dspobjkoor

dspobjdatr6 dw dspobjtxtr6,256*192+512
dspobjdatr7 dw dspobjtxtr6,256*192+512

dspobjradr db 0
dspobjkoor dw -1,-1

;Palette-Tab
prgwincol  dw #1501,0,75,24,128,120,0,0,128,120,128,120,128,120, prgicndsp2,prgtitcol,0,0,prggrpcol,0,0:ds 136+14
prggrpcol  db 26,0:dw prgdatdspc,0,0,2*256+2,0,0,2

prgdatdspc
dw 0,255*256+0,          2,  0,0,1000,1000,0            ;00=Hintergrund
dw colcnc,256*255+16,prgbuttxt1,  00,   -12, 32,12,0    ;01=Close(hidden)
dw      0,256*255+64,00,          00,    00, 00,00,0    ;02=*Dummy*
dw      0,256*255+64,00,          00,    00, 00,00,0    ;03=*Dummy*
dw      0,256*255+64,00,          00,    00, 00,00,0    ;04=*Dummy*
dw 0,255*256+3, dspobjdatw,        0, 14-14,128,72,0    ;05=Rahmen Colours
dw 0,255*256+3, dspobjdat3,        0, 86-14,128,48,0    ;06=Rahmen Palette
dw dspcol,255*256+24,dspobjdat4,  15, 27-14, 96, 8,0    ;07=Slider "R"
dw dspcol,255*256+24,dspobjdat5,  15, 39-14, 96, 8,0    ;08=Slider "G"
dw dspcol,255*256+24,dspobjdat6,  15, 51-14, 96, 8,0    ;09=Slider "B"
dw 0,255*256+1 ,dspobjdat7,        8, 27-14,  8, 8,0    ;10=Text   "R"
dw 0,255*256+1 ,dspobjdat8,        8, 39-14,  8, 8,0    ;11=Text   "G"
dw 0,255*256+1 ,dspobjdat9,        8, 51-14,  8, 8,0    ;12=Text   "B"
dw 0,255*256+1 ,dspobjdata,      113, 27-14,  7, 8,0    ;13=Wert für R
dw 0,255*256+1 ,dspobjdatb,      113, 39-14,  7, 8,0    ;14=Wert für G
dw 0,255*256+1 ,dspobjdatc,      113, 51-14,  7, 8,0    ;15=Wert für B
dw dspmov,255*256+16,dspobjtxt7,   7, 67-14, 23,12,0    ;16="Move"   Button
dw dspflp,255*256+16,dspobjtxt8,  33, 67-14, 23,12,0    ;17="Flip"   Button
dw dspbrg,255*256+16,dspobjtxt9,  59, 67-14, 30,12,0    ;18="Bright" Button
dw dspdrk,255*256+16,dspobjtxta,  92, 67-14, 29,12,0    ;19="Dark"   Button
dw dsppn0,255*256+2, 16*0+3+4+64, 11,101-14, 18,20,0    ;20=Pen0
dw dsppn1,255*256+2, 16*1+3+4+64, 33,101-14, 18,20,0    ;21=Pen1
dw dsppn2,255*256+2, 16*2+3+4+64, 55,101-14, 18,20,0    ;22=Pen2
dw dsppn3,255*256+2, 16*3+3+4+64, 77,101-14, 18,20,0    ;23=Pen3
prgdatdspc1
dw dsppn4,255*256+2, 16*2+3+4+64, 99,101-14, 18,20,0    ;24=Pen16
dw 0,255*256+2,      1+4:dsppns1 dw 9,99-14, 22,24,0    ;25=neue Pen-Selektion
dw 0,255*256+2,      2+8:dsppns2 dw 9,99-14, 22,24,0    ;26=alte Pen-Selektion (### muss immer letzter sein! ###)

dspobjdat2 dw dspobjtxt2,2+4
dspobjdatw dw dspobjtxtk,2+4
dspobjdat3 dw dspobjtxt3,2+4
dspobjdat4 dw 1, 3, 15, 256*255+1
dspobjdat5 dw 1, 6, 15, 256*255+1
dspobjdat6 dw 1, 9, 15, 256*255+1
dspobjdat7 dw dspobjtxt4:dw 2+4
dspobjdat8 dw dspobjtxt5:dw 2+4
dspobjdat9 dw dspobjtxt6:dw 2+4
dspobjdata dw dspobjdspr:db 0+4+128,2
dspobjdatb dw dspobjdspg:db 0+4+128,2
dspobjdatc dw dspobjdspb:db 0+4+128,2

dspobjdatd dw dspobjdspb:db 0+4+128,2

;Modi-Tab
prgdatdspd
dw 0,255*256+0,          2,  0,0,1000,1000,0            ;00=Hintergrund
dw dsptab,255*256+20, dsptabdat,  0,  2,128, 11,0       ;01=Tab-Leiste
dw dspoky,255*256+16,prgbuttxt1,  23,135,32,12,0        ;02="Ok"-Button
dw dspcnc,255*256+16,prgbuttxt2,  58,135,32,12,0        ;03="Cancel"-Button
dw dspapl,255*256+16,prgbuttxt3,  93,135,32,12,0        ;04="Apply"-Button
dw      0,255*256+8,  sprdspmonu, 24, 17,80, 9,0        ;05=Grafik Monitor Up
dw      0,255*256+8,  sprdspmond, 24, 66,80,11,0        ;06=Grafik Monitor Down
dw 0,255*256+8:prgdatdsp1 dw sprdspmd1, 32,26,64,40,0   ;07=Grafik Monitor-Inhalt
dw      0,255*256+8,  sprdspmonl, 24, 24, 8,44,0        ;08=Grafik Monitor Left
dw      0,255*256+8,  sprdspmonr, 96, 24, 8,44,0        ;09=Grafik Monitor Right
dw      0,255*256+8,  sprdspmonb, 44, 77,40, 5,0        ;10=Grafik Monitor Base
dw 0,255*256+3, dspobjdat1,   0,86,128,48,0             ;11=Rahmen Screenmodes
prgdatdspd0
dw dspmds,255*256+18, dspmodobj1, 9, 97,110,8,0         ;12=Radiobutton "Mode X"
dw dspmds,255*256+18, dspmodobj2, 9,107,110,8,0         ;13=Radiobutton "Mode Y"
dw dspmds,255*256+18, dspmodobj7, 9,117,110,8,0         ;14=Radiobutton "Mode Z"
prgdatdspd1
dw 00    ,255*256+ 1,dspobjdatr,  9, 97, 18, 8,0        ;12=Text "Low"
dw dspset,255*256+24,dspobjdatu, 27, 97, 74, 8,0        ;13=Slider Mode
dw 00    ,255*256+ 1,dspobjdats,104, 97, 18, 8,0        ;14=Text "High"
dw 00    ,255*256+ 1,dspobjdatt,  9,107,110, 8,0        ;15=Text "Resolution"


dspobjdat1 dw dspobjtxt1,2+4

dspobjdatr dw dspobjtxm8,2+4
dspobjdats dw dspobjtxm9,2+4
dspobjdatt dw dspobjtxma,2+4+128+512
dspobjdatu dw 1, 0, 7, 256*255+1

dspmodobj1 dw dspmodstab,dspobjtxm1,256*1+2+4,dspmodkrdb        ;cpc/ep
dspmodobj2 dw dspmodstab,dspobjtxm2,256*2+2+4,dspmodkrdb

dspmodobj5 dw dspmodstab,dspobjtxm5,256*5+2+4,dspmodkrdb        ;msx
dspmodobj6 dw dspmodstab,dspobjtxm6,256*6+2+4,dspmodkrdb
dspmodobj7 dw dspmodstab,dspobjtxm7,256*7+2+4,dspmodkrdb

dspmodobj0 dw dspmodstab,dspobjtxm0,256*0+2+4,dspmodkrdb        ;pcw

dspmodobj14 dw dspmodstab,dspobjtxm14,256*14+2+4,dspmodkrdb     ;nc
dspmodobj15 dw dspmodstab,dspobjtxm15,256*15+2+4,dspmodkrdb
dspmodobj16 dw dspmodstab,dspobjtxm16,256*16+2+4,dspmodkrdb

dspmodobj20 dw dspmodstab,dspobjtxm20,256*20+2+4,dspmodkrdb     ;nxt
dspmodobj21 dw dspmodstab,dspobjtxm21,256*21+2+4,dspmodkrdb

dspmodstab db 1
dspmodsvir db 0
dspmodkrdb dw -1,-1

;Screensaver-Tab
prgdatdspb
dw 0,255*256+0,          2,  0,0,1000,1000,0            ;00=Hintergrund
dw dsptab,255*256+20, dsptabdat,  0,  2,128, 11,0       ;01=Tab-Leiste
dw dspoky,255*256+16,prgbuttxt1,  23,135,32,12,0        ;02="Ok"-Button
dw dspcnc,255*256+16,prgbuttxt2,  58,135,32,12,0        ;03="Cancel"-Button
dw dspapl,255*256+16,prgbuttxt3,  93,135,32,12,0        ;04="Apply"-Button
dw      0,255*256+8,  sprdspmonu, 24, 17,80, 9,0        ;05=Grafik Monitor Up
dw      0,255*256+8,  sprdspmond, 24, 66,80,11,0        ;06=Grafik Monitor Down
dw 0,255*256+8:prgdatdspb1 dw sprdspsav,32,26,64,40,0   ;07=Grafik Monitor-Inhalt
dw      0,255*256+8,  sprdspmonl, 24, 24, 8,44,0        ;08=Grafik Monitor Left
dw      0,255*256+8,  sprdspmonr, 96, 24, 8,44,0        ;09=Grafik Monitor Right
dw      0,255*256+8,  sprdspmonb, 44, 77,40, 5,0        ;10=Grafik Monitor Base
dw      0,255*256+3, dspobjdatl,   0,86,128,48,0        ;11=Rahmen Screenmodes
dw savchk,255*256+17,dspobjdatq,   8, 99,  8,8,0        ;12=Checkbtn  "Screensaver-File"
dw      0,255*256+32,dspobjdatm,  16, 97, 65,12,0       ;13=Textinput "Screensaver-File"
dw savbrw,255*256+16,dspobjtxte,  83, 97, 36,12,0       ;14=Button    "Durchsuchen"
dw savtst,255*256+16,dspobjtxtj,  61,113, 26,12,0       ;15=Button    "Test"
dw savcfg,255*256+16,dspobjtxtf,  89,113, 30,12,0       ;16=Button    "Setup"
dw      0,255*256+1 ,dspobjdatn,   8,115, 18, 8,0       ;17=Text      "Wait"
dw      0,255*256+32,dspobjdato,  26,113, 16,12,0       ;18=Textinput "Wait"
dw      0,255*256+1 ,dspobjdatp,  44,115,  8,12,0       ;19=Text      "Minutes"

dspobjdatl dw dspobjtxtg,2+4
dspobjdatn dw dspobjtxth,2+4
dspobjdatp dw dspobjtxti,2+4
dspobjdatq dw scrsavflg,dspobjtxtc,2+4

dspobjdatm  dw dspobjdatmb,0,0,0,0,255,0
dspobjdatma db "sav",0
dspobjdatmb ds 256
dspobjdato  dw dspobjdatob,0,0,0,0,2,0
dspobjdatob ds 3


;*** Config ***
cfgsf2flg   db 0    ;Hardware -> Flag, ob SYMBiFACE vorhanden (+1=Maus, +2=RTC, +4=IDE, +8=GFX9000)
cfgdskvir   db 0    ;virtual desktop (0=no virtual desktop, Bit[0-3] -> X-resolution, 1=512, 2=1000, Bit[4-7] -> Y-resolution, not yet defined)
cfgicnanz   db 4    ;Desktop  -> Anzahl Icons
cfgmenanz   db 1    ;Desktop  -> Anzahl Startmenu-Programm-Einträge
cfglstanz   db 0    ;Desktop  -> Anzahl Taskleisten-Shortcuts
cfgcpctyp   db 0    ;Hardware -> Computer-Typ

cfgbgrmem   db 0:ds 32

scrsavflg   db 0    ;Flag, ob Screen-Saver aktiviert
scrsavdly   db 10   ;Anzahl Minuten, nach denen Screen-Saver startet
scrsavfil   ds 33   ;Screen-Saver Application-File
scrsavcfg   ds 64   ;Screen-Saver spezifische Config-Daten

cfgcolbeg
cfgcolwr1   dw 1+16                     ;Rahmen Window Titel/Menu/Toolbar/Inhalt
cfgcolwr2   dw 5+16+32768               ;Rahmen Window Status
cfgcolwt1   db 8*16+5                   ;Text   Window Titel
cfgcolwt2   db 6+16                     ;Text   Window Status
cfgcolwic   db 8,1,4,5                  ;Grafik Window
cfgcolws1   dw 256*6+5+16+32768+16384   ;Scrol1 Window
cfgcolws2   dw 4096*6+3328+5+16         ;Scrol2 Window
cfgcolws3   dw 256*1+6                  ;Scrol3 Window

cfgcolmr1   dw 256*6+9+16+32768+16384   ;Rahmen Menu Fenster
cfgcolmr2   db 16*1+6                   ;Rahmen Menu Leiste
cfgcolmr3   dw 256*1+9+16384            ;Rahmen Menu Linie
cfgcolmt1   dw 6*256+1                  ;Text   Menu aktiviert
cfgcolmt2   dw 6*256+8                  ;Text   Menu deaktiviert
cfgcolmic   db 8,1,4,5                  ;Grafik Menu
cfgcolmiv   db 1                        ;Invert Menu

cfgcolltx   db 6+16                     ;Text   Taskleiste
cfgcollr1   dw 256*6+16+5+32768+16384   ;Rahmen Taskleiste
cfgcollr2   dw 256*6+16+5+32768+16384   ;Button Taskleiste
cfgcollr3   dw 256*6+16+5+32768         ;Rahmen Taskleiste (Windows)
cfgcolliv   db 1                        ;Invert Taskleiste

cfgcolict   db 16*0+1                   ;Text   Icons
cfgcolwcc   db 0,1,2,3                  ;Inhalt Window
cfgcolend

prgtrnend

relocate_table
relocate_end
