;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                                                                            @
;@             (c) 2004-2021 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

P_DEBOUT    equ #1f
P_VERSION   equ #13

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
prgdatver       equ 88          ;required OS version
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
            db "Control Panel":ds 11:db 0 ;Name
            db 1                    ;flags (+1=16c icon)
            dw prgicn16c-prgcodbeg  ;16 colour icon offset
            ds 5                    ;*reserved*
prgmemtab   db "SymExe10"           ;SymbOS-EXE-Kennung                 POST Tabelle Speicherbereiche
            dw 0                    ;zusätzlicher Code-Speicher
            dw lnklenall+32+extlen+fntlen   ;zusätzlicher Data-Speicher
            dw 0                    ;zusätzlicher Transfer-Speicher
            ds 26                   ;*reserviert*
            db 1,3                  ;required OS version (3.1)
prgicnsml   db 2,8,8:db #44,#22:db #A8,#57:db #60,#AE:db #10,#4C:db #23,#80:db #57,#60:db #AE,#51:db #44,#22
prgicnbig   db 6,24,24
            db #00,#00,#00,#00,#00,#00,#FF,#FF,#FF,#FF,#80,#00,#8F,#0F,#0F,#1F,#80,#00,#8F,#0F,#0F,#1F,#80,#00,#9E,#F0,#87,#1F,#80,#00,#9E,#10,#8F,#1F,#80,#00,#9E,#B0,#9F,#FF,#80,#00,#9E,#E0,#AE,#12,#80,#00
            db #9E,#73,#BF,#FE,#B0,#00,#9F,#CE,#E2,#7E,#C2,#80,#8F,#4D,#66,#7E,#8D,#80,#8F,#6A,#2A,#7E,#1B,#80,#8F,#EA,#62,#7E,#95,#80,#BF,#CE,#A2,#7E,#42,#E0,#AF,#05,#62,#7E,#85,#14,#BD,#EE,#3A,#F1,#1A,#FE
            db #BD,#FD,#05,#05,#36,#FE,#BD,#CA,#79,#3A,#82,#F6,#9E,#E7,#F7,#35,#DD,#E0,#F0,#D6,#FF,#39,#FF,#C0,#00,#56,#F9,#FC,#F7,#80,#00,#56,#91,#EC,#73,#80,#00,#30,#10,#EC,#30,#00,#00,#00,#10,#E0,#00,#00

setkeynum   equ 0   ;Keyboard
setmounum   equ 1   ;Mouse
setdspnum   equ 2   ;Display
settimnum   equ 3   ;Time/Date
setfntnum   equ 4   ;Font
setsysnum   equ 5   ;System
setdevnum   equ 6   ;Devices
setlnknum   equ 7   ;Links

;### PRGPRZ -> Programm-Prozess
prgupdflg   db 0            ;Flag, ob Sleep oder Idle (mit Time-Update)
prgsubnum   db 0            ;Zwischenspeicher für zu öffnendes Subwin

prgwinanz   equ 8
prgwin      db 0            ;Nummer des Haupt-Fensters
prgwinsub   dw prgwinkey,-1
            dw prgwinmou,-1
            dw 0,-1
            dw 0,-1
            dw prgwinfnt,-1
            dw prgwinsys,-1
            dw prgwindev,-1
            dw prgwinlnk,-1
prgwinsub2  dw keycnc, 0
            dw prgsub4,0
            dw 0,0
            dw 0,0
            dw prgsub4,0
            dw prgsub4,0
            dw devcnc, 0
            dw prgsub4,0

windatprz   equ 3   ;Prozeßnummer
windatsup   equ 51  ;Nummer des Superfensters+1 oder 0

bnknumget   db 0
bnknumput   db 0

prgid   db "Control Pane"
extid   db "SymbOS Advan"
extfnd  db 0

prgprz  call prgext
        call prgdbl
        ld a,(prgprzn)
        ld (prgwindat+windatprz),a
        ld (prgwinkey+windatprz),a
        ld (prgwinmou+windatprz),a
        ld (prgwinfnt+windatprz),a
        ld (prgwindev+windatprz),a
        ld (prgwinsys+windatprz),a
        ld (prgwinlnk+windatprz),a

        call sysini     ;muss an erster stelle stehen
        call prgver     ;platform check
        call keyini
        call devini
        call mouini
        call lnkini
        call fntini
        call sysini0
        call SySystem_HLPINI

        ld c,MSC_DSK_WINOPN
        ld a,(prgbnknum)
        ld b,a
        ld de,prgwindat
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
        cp MSC_GEN_FOCUS        ;*** Application soll sich Focus nehmen
        jp z,prgfoc
        cp MSR_SYS_SELOPN       ;*** Browse-Fenster wurde geschlossen
        jp z,prgbrc
        cp MSR_DSK_WCLICK       ;*** Fenster-Aktion wurde geklickt
        jr nz,prgprz0
        ld e,(iy+1)
        ld a,(prgwin)
        cp e
        jp nz,prgsub            ;*** Subwin wurde geklickt
        ld a,(iy+2)
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jp z,prgend1
        cp DSK_ACT_MENU         ;*** Menü wurde geklickt
        jp z,prgmen
        cp DSK_ACT_CONTENT      ;*** Inhalt wurde geklickt
        jr nz,prgprz0
        ld a,(iy+3)
        cp 2
        jr z,prgprz5
        cp 7
        jr nz,prgprz0           ;kein doppelclick/tastenclick -> ignorieren
prgprz5 ld a,(iy+8)
        cp setdspnum*4+4
        jp z,prgrun1            ;Display -> Wird nachgeladen
        cp settimnum*4+4
        jp z,prgrun2            ;Time    -> Wird nachgeladen
        cp setlnknum*4+4
        jr nz,prgprz6
        ld hl,extfnd
        bit 0,(hl)
        jp nz,prgrun3           ;Links & Extended Desktop -> Wird nachgeladen
prgprz6 ld (prgsubnum),a
        ld l,a
        ld h,0
        ld de,prgwinsub+2-4
        add hl,de
        ld a,(hl)
        cp -1
        ld c,a
        ld b,MSC_DSK_WINTOP
;C=Window, B=Command
prgprz4 ld a,(prgprzn)
        db #dd:ld l,a
        db #dd:ld h,PRC_ID_DESKTOP
        ld iy,prgmsgb
        jr z,prgprz2
        ld (iy+0),b                     ;Fenster vorhanden -> nach oben holen
        ld (iy+1),c
        rst #10
        jr prgprz0
prgprz2 ld (iy+0),MSC_DSK_WINOPN        ;Fenster nicht da  -> neu öffnen
        ld a,(prgbnknum)
        ld (prgmsgb+1),a
        dec hl
        ld d,(hl)
        dec hl
        ld e,(hl)
        ld (prgmsgb+2),de
        ld a,1
        ld (de),a
        inc hl
        inc hl
        push hl
        rst #10
prgprz3 call msgget                     ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        pop hl
        cp MSR_DSK_WOPNER
        jp z,prgprz0            ;kein Speicher für Fenster -> egal, dann halt nichts machen
        cp MSR_DSK_WOPNOK
        push hl
        jr nz,prgprz3           ;andere Message als "Fenster geöffnet" -> ignorieren
        pop hl
        ld a,(iy+4)
        ld (hl),a
        ld a,(prgsubnum)
        cp 16
        jp nz,prgprz0
        ld a,1
        ld (prgupdflg),a
        jp prgprz0

;### PRGRUN -> Modul nachladen
prgrunstm   db "%cpstartm.exe",0

prgrun1 ld hl,256*1+MSC_SYS_PRGSET
        jp cfgsav1
prgrun2 ld hl,256*2+MSC_SYS_PRGSET
        jp cfgsav1
prgrun3 ld c,MSC_SYS_PRGRUN
        ld hl,prgrunstm
        ld a,(prgbnknum)
        ld b,l
        ld e,h
        ld d,a
        ld a,PRC_ID_SYSTEM
        call msgsnd1
        jp prgprz0

;### PRGMEN -> Menü angeklickt
prgmen  ld l,(iy+8)
        ld h,(iy+9)
        ld a,h
        or l
        jp z,prgprz0
        jp (hl)

;### PRGINF -> Info-Fenster anzeigen
prginf  ld b,1+128
        ld hl,prgmsginf         ;*** Info-Fenster
        call prginf0
        jp prgprz0
prginf0 ld (prgmsgb+1),hl
        ld a,(prgbnknum)
        ld c,a
        ld (prgmsgb+3),bc
        ld a,MSC_SYS_SYSWRN
prginf1 ld (prgmsgb),a
        jp devact1

;### PRGFOC -> Focus nehmen
prgfoc  ld a,(prgwin)
        ld b,a
        ld c,MSC_DSK_WINMID
        call msgsnd
        jp prgprz0

;### PRGSUB -> Sub-Fenster angeklickt
;### Eingabe    E=Fenster-ID, IY=prgmsgb
prgsub  ld a,e
        ld b,prgwinanz
        ld hl,prgwinsub+2
        ld de,4
prgsub1 cp (hl)
        jr z,prgsub2
        add hl,de
        djnz prgsub1
        jp prgprz0
prgsub2 ld a,prgwinanz
        sub b
        add a
        add a
        ld c,a                  ;C=Sub-Fenster Index * 4
        ld a,(iy+2)
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jp nz,prgsub3
        ld hl,prgwinsub2
        ld b,0
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        jp (hl)
prgsub4 ld b,0
        ld hl,prgwinsub+2
        add hl,bc
        ld c,(hl)
        ld (hl),-1
        ld b,MSC_DSK_WINCLS
        or a
        jp prgprz4
prgsub3 cp DSK_ACT_CONTENT      ;*** Inhalt wurde geklickt
        jp nz,prgprz0
        ld l,(iy+8)
        ld h,(iy+9)
        ld a,h
        or l
        jp z,prgprz0
        ld a,h
        or a
        jr nz,prgsub5
        ld a,l
        cp 100
        jr c,prgsub5
        cp 180
        jp c,keysel     ;100-179 = Taste
prgsub5 jp (hl)

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
        ld (prgmsgb+8),hl
        ld a,(prgbnknum)
        add d
        ld l,a
        ld h,8
        ld (prgmsgb+6),hl
        ld hl,100
        ld (prgmsgb+10),hl
        ld hl,5000
        ld (prgmsgb+12),hl
        ld l,MSC_SYS_SELOPN
        ld (prgmsgb),hl
        ld a,(prgprzn)
        db #dd:ld l,a
        db #dd:ld h,PRC_ID_SYSTEM
        ld iy,prgmsgb
        rst #10
        ret

;### PRGBRC -> Browse-Fenster schließen
;### Eingabe    P1=Typ (0=Ok, 1=Abbruch, 2=FileAuswahl bereits in Benutzung, 3=kein Speicher frei, 4=kein Fenster frei), P2=PfadLänge
prgbrc  ld a,(prgmsgb+1)
        or a
        jr z,prgbrc1
        inc a
        jr z,prgbrc4
        xor a
        ld (prgbron),a
        jp prgprz0
prgbrc4 ld a,(prgmsgb+2)
        ld (prgwinlnk+windatsup),a
        jp prgprz0
prgbrc1 ld hl,prgbron
        ld e,(hl)
        ld (hl),0
        ld a,(prgmsgb+2)           ;A=Pfadlänge
        dec e
        jr z,prgbrc3
        dec e
        jr z,prgbrc5
        dec e
        jr z,prgbrc6
        dec e
        jr z,prgprc7
        dec e
        jp z,keylod0
        dec e
        jp z,keysav0
        jp prgprz0
prgprc7 ld ix,prgobjfnt2a       ;*** Font Pfad
        call strinp
        ld e,16
        call fntbrw0
        jp fntlod
prgbrc6 call syseng3            ;*** Extension Applikation
        ld e,17
        call systab0
        jp prgprz0
prgbrc5 ld hl,lnkicnchs1        ;*** Link Icon
        ld de,0
        jp lnkicf0
prgbrc3 call prgbrc2            ;*** Link Applikation
        ld a,(setlnknum*4+prgwinsub+2)
        cp -1
        jp z,prgprz0
        ld e,18
        call lnklsc0
        jp lnkicf
prgbrc2 ld (prgobjlnk5b+8),a
        ld (prgobjlnk5b+4),a
        xor a
        ld (prgobjlnk5b+2),a
        ld (prgobjlnk5b+6),a
        ret

;### PRGDBL -> Test, ob Programm bereits läuft
prgdbl  xor a
        ld (prgcodbeg+prgdatnam),a
        ld hl,prgid
        call prgdbl0
        ld a,"C"
        ld (prgcodbeg+prgdatnam),a
        ld a,(prgmsgb+1)
        or a
        ret nz
        ld a,(prgmsgb+9)
        ld c,MSC_GEN_FOCUS
        call msgsnd1
        jr prgend
prgdbl0 ld b,l
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
        ret

;### PRGEXT -> search for advanced desktop
prgext  ld hl,extid
        call prgdbl0
        ld a,(prgmsgb+1)
        cp 1
        sbc a
        ld (extfnd),a
        ret z
        ld hl,prgicnlnk8c
        ld (prgicnspr8+2),hl
        ld hl,0
        ld (prgicnspr8+4),hl
        ret

;### PRGVER -> Plattform-Check
prgver  ld a,(cfgcpctyp)
        and #1f
if computer_mode=0          ;CPC -> 0-4 OK
        cp 4+1
elseif computer_mode=1      ;MSX -> 7-10 OK
        cp 7
        jr c,prgver1
        cp 10+1
elseif computer_mode=2      ;PCW -> 12-13 OK
        cp 12
        jr c,prgver1
        cp 13+1
elseif computer_mode=3      ;EP  -> 6 OK
        cp 6
        jr c,prgver1
        cp 6+1
elseif computer_mode=4      ;SVM -> 18 OK
        cp 18
        jr c,prgver1
        cp 18+1
elseif computer_mode=5      ;NC  -> 15-17 OK
        cp 15
        jr c,prgver1
        cp 17+1
elseif computer_mode=6      ;NXT -> 20 OK
        cp 20
        jr c,prgver1
        cp 20+1
endif
        ret c
prgver1 ld b,1
        ld hl,prgmsgwpf
        call prginf0
        jr prgend

;### PRGEND -> Programm beenden
prgend1 ld hl,cfgflags1
        bit 0,(hl)
        jr z,prgend
        ld hl,256*1+MSC_SYS_SYSCFG
        call devact0
prgend  ld a,(prgprzn)
        db #dd:ld l,a
        db #dd:ld h,PRC_ID_SYSTEM
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
        ld a,(prgmsgb)
        or a
        jr z,prgend
        scf
        ret

;### MSGDSK -> Message für Programm von Deskzop-Prozess abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgdsk  call msgget
        jr nc,msgdsk            ;keine Message
        ld a,PRC_ID_DESKTOP
        db #dd:cp h
        jr nz,msgdsk            ;Message von anderem als Desktop-Prozeß -> ignorieren
        ld a,(prgmsgb)
        ret

;### MSGSND -> Message an Desktop-Prozess senden
;### Eingabe    C=Kommando, B/E/D/L/H=Parameter1/2/3/4/5
msgsnd  ld a,PRC_ID_DESKTOP
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
        db #dd:ld h,PRC_ID_SYSTEM
        rst #10                 ;Message senden
syscll1 rst #30
        ld iy,prgmsgb
        ld a,(prgprzn)
        db #dd:ld l,a
        db #dd:ld h,PRC_ID_SYSTEM
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

;### CFGLOD -> Config laden
cfglod  ld hl,256*0+MSC_SYS_SYSCFG
        jr cfgsav1

;### CFGSAV -> Config speichern
cfgsav  ld hl,256*1+MSC_SYS_SYSCFG
cfgsav1 call devact0
        jp prgprz0

;### CFGASV -> Config Autosave ein/aus
cfgasv  ld hl,prgwinmen1a
        ld a,(hl)
        xor 2
        ld (hl),a
        srl a
        ld hl,cfgflags1
        res 0,(hl)
        or (hl)
        ld (hl),a
        ld hl,jmp_sysinf        ;*** Flags speichern
        ld de,256*1+6
        ld ix,cfgmem+1
        ld iy,66+2+6+1
        rst #28
        jp prgprz0

;### CFGBGR -> Hintergrund-Bild reloaden
cfgbgr  ld hl,256*2+MSC_SYS_SYSCFG
        jr cfgsav1

;### HELP-FILE
SySystem_HLPFLG db 0    ;flag, if HLP-path is valid
SySystem_HLPPTH db "%help.exe "
SySystem_HLPPTH1 ds 128
SySHInX db ".HLP",0

SySystem_HLPINI
        ld hl,(prgcodbeg)
        ld de,prgcodbeg
        dec h
        add hl,de                   ;HL = CodeEnd = Command line
        ld de,SySystem_HLPPTH1
        ld bc,0
        db #dd:ld l,128
SySHIn1 ld a,(hl)
        or a
        jr z,SySHIn3
        cp " "
        jr z,SySHIn3
        cp "."
        jr nz,SySHIn2
        ld c,e
        ld b,d
SySHIn2 ld (de),a
        inc hl
        inc de
        db #dd:dec l
        ret z
        jr SySHIn1
SySHIn3 ld a,c
        or b
        ret z
        ld e,c
        ld d,b
        ld hl,SySHInX
        ld bc,5
        ldir
        ld a,1
        ld (SySystem_HLPFLG),a
        ret

hlpopn  ld a,(SySystem_HLPFLG)
        or a
        jp z,prgprz0
        ld a,(prgbnknum)
        ld d,a
        ld a,PRC_ID_SYSTEM
        ld c,MSC_SYS_PRGRUN
        ld hl,SySystem_HLPPTH
        ld b,l
        ld e,h
        call msgsnd1
        jp prgprz0


;==============================================================================
;### MAUS-FENSTER #############################################################
;==============================================================================

;### MOUINI -> Maus-Fenster initialisieren
mouini  ld hl,jmp_sysinf            ;*** Maus-Infos holen
        ld de,256*6+5
        ld ix,mosdsp
        ld iy,66+2
        rst #28
        jr moustl

;### MOUSTL -> Settings laden
moustl  ld a,(mosdsp):dec a:ld (mouobjdatc+2),a:inc a:call clcdez:ld (mouobjtxte),hl
        ld a,(mosrsp):dec a:ld (mouobjdatd+2),a:inc a:call clcdez:ld (mouobjtxtf),hl
        ld a,(mosfac):dec a:ld (mouobjdatg+2),a:inc a:call clcdez:ld (mouobjtxth),hl
        ld a,(mosdcs):sub 3:ld (mouobjdatk+2),a:add 3:call clcdez:ld (mouobjtxtl),hl
        ld a,(moswfc):      ld (mouobjdatn+2),a:      call clcdez:ld (mouobjtxto),hl
        ld a,(mosswp)
        ld (mouobjdatis),a
        ret


;### MOUAPL -> Maus-Fenster APPLY-Button
mouapl  call mouact
        jp prgprz0

;### MOUOKY -> Maus-Fenster OK-Button
mouoky  call mouact
mouoky1 ld c,4*setmounum
        ld a,c
        jp prgsub4

;### MOUCNC -> Maus-Fenster CANCEL/CLOSE-Button
moucnc  call moudis
        call mouini
        jr mouoky1

;### MOUACT -> Maus-Einstellungen übernehmen
mouact  ld a,(mouobjdatis)
        ld (mosswp),a
        ld hl,jmp_sysinf            ;*** Maus-Infos speichern
        ld de,256*6+6
        ld ix,mosdsp
        ld iy,66+2
        rst #28
        ret

;### MOUDIS -> Maus-Einstellungen nicht übernehmen
moudis  ;...
        ret

;### MOUSLD -> Slider angeklickt
mouslda ld a,(mouobjdatc+2)
        ld hl,mosdsp
        ld e,9
        ld ix,mouobjtxte
        jr mousld1
mousldb ld a,(mouobjdatd+2)
        ld hl,mosrsp
        ld e,10
        ld ix,mouobjtxtf
        jr mousld1
mousldc ld a,(mouobjdatg+2)
        ld hl,mosfac
        ld e,16
        ld ix,mouobjtxth
        jr mousld1
mousldd ld a,(mouobjdatk+2)
        add 2
        ld hl,mosdcs
        ld e,22
        ld ix,mouobjtxtl
        jr mousld1
mouslde ld a,(mouobjdatn+2)
        dec a
        ld hl,moswfc
        ld e,17
        ld ix,mouobjtxto
mousld1 inc a
        ld (hl),a
        call clcdez
        ld (ix+0),l
        ld (ix+1),h
        call mousld2
        jp prgprz0
mousld2 ld c,MSC_DSK_WININH
        ld a,(1*4+prgwinsub+2)
        ld b,a
        jp msgsnd


;==============================================================================
;### KEYBOARD-FENSTER #########################################################
;==============================================================================

keynum  db 4*16+3

    if computer_mode=0
keytab  db "                "
        db " [ ]  \ ^-@P;:/."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
elseif computer_mode=1
keytab  db "                "
        db "\] `  ",129," =-[P';/."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
elseif computer_mode=2
keytab  db "                "
        db " [ ]  \ ^-@P;:/."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
elseif computer_mode=3
keytab  db "                "
        db " [ ]  \ ^-@P;:/."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
elseif computer_mode=4
keytab  db "                "
        db " ] \  ` =-[P';/."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
elseif computer_mode=5
keytab  db "                "
        db " ] #  \ =-[P';/."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
elseif computer_mode=6
keytab  db "                "
        db "           P;",34," ."
        db "09OILKM,87UYHJN "
        db "65RTGFBV43EWSDCX"
        db "12 Q A Z        "
endif

keyadr  dw 0

;### KEYINI -> Keyboard-Fenster initialisieren
keyini  ld hl,jmp_sysinf            ;*** Keyboard-Infos holen
        ld de,256*2+5
        ld ix,keydef+320
        ld iy,66
        rst #28
        ld e,7
        ld hl,jmp_sysinf
        rst #28             ;DE=System, IX=Data, IYL=Bank
        push ix
        pop hl
        ld bc,3432+99
        add hl,bc
        ld (keyadr),hl
        ld de,keydef
        ld bc,320
        ld a,(bnknumget)
        rst #20:dw jmp_bnkcop
        ld hl,(keydsp)
        ld (keyold),hl
        call keyspl
        jr keydfl
keyini2 ld a,(hl)
        and %10111111
        or c
        ld (hl),a
        add hl,de
        djnz keyini2
        ret

;### KEYSPL -> Speed-Settings laden
keyspl  ld a,(keydsp)
        dec a
        ld (keyobjdatn+2),a
        inc a
        call clcdez
        ld (keyobjtxtq),hl
        ld a,(keyrsp)
        dec a
        ld (keyobjdato+2),a
        inc a
        call clcdez
        ld (keyobjtxtr),hl
        ret

;### KEYGET -> Tastennummer von CPC nach MSX/PCW/EP/SVM/NC/NXT umwandeln
;### Eingabe    A=Nummer (CPC)
;### Ausgabe    A=Nummer (MSX/PCW/EP/SVM/NC/NXT)
;### Verändert  F,DE,HL
if computer_mode=1
keygett db 69,71,70,66,62,55,52,12
        db 68,79,60,65,57,53,54,79
        db 67,14,52,16,56,79,21,79
        db 11,10,13,37,17,15,20,19
        db 00,09,36,30,33,32,34,18
        db 08,07,42,46,29,31,35,64
        db 06,05,39,41,28,27,23,43
        db 04,03,26,44,40,25,24,45
        db 01,02,58,38,59,22,79,47
        db 79,79,79,79,79,79,58,61
elseif computer_mode=2
keygett db 14,06,78,05,09,72,77,07
        db 15,79,08,13,74,02,00,01
        db 16,17,18,19,76,21,22,23
        db 24,25,26,27,28,29,30,31
        db 32,33,34,35,36,37,38,39
        db 40,41,42,43,44,45,46,47
        db 48,49,50,51,52,53,54,55
        db 56,57,58,59,60,61,62,63
        db 64,65,66,67,68,69,79,71
        db 79,79,79,79,79,79,64,23
elseif computer_mode=3
keygett db 59,58,57,60,35,34,71,87
        db 61,63,37,33,36,39,38,56
        db 65,77,62,54,32,07,01,15
        db 45,43,75,76,51,53,67,68
        db 44,42,74,72,52,50,64,66
        db 40,24,16,18,08,48,00,70
        db 26,28,19,20,10,12,02,04
        db 27,29,21,22,13,11,03,05
        db 25,30,31,17,23,14,09,06
        db 80,81,82,83,84,87,87,46
elseif computer_mode=5
keygett db 59,51,49,07,07,07,60,07  ;0
        db 03,17,07,07,07,07,07,07  ;8
        db 50,66,04,58,07,00,52,09  ;16
        db 56,65,67,75,68,76,53,79  ;24
        db 73,15,78,69,77,63,62,71  ;32
        db 32,33,61,45,54,70,55,11  ;40
        db 22,20,38,44,46,39,42,43  ;48
        db 02,24,28,27,30,31,47,35  ;56
        db 18,25,10,26,19,36,16,34  ;64
        db 07,07,07,07,07,07,07,74  ;72
elseif computer_mode=6
keygett db 75,72,74,07,07,07,66,07  ;0
        db 73,64,07,07,07,07,07,07  ;8
        db 69,07,08,07,07,56,07,01  ;16
        db 07,07,07,16,79,78,07,76  ;24
        db 24,25,17,18,09,10,02,77  ;32
        db 26,27,19,20,12,11,03,00  ;40
        db 28,36,43,44,52,51,04,60  ;48
        db 35,34,42,41,49,50,59,58  ;56
        db 32,33,70,40,67,48,65,57  ;64
        db 07,07,07,07,07,07,07,71  ;72
endif

if computer_mode=0      ;cpc ohne translation
keyget  ret
elseif computer_mode=4  ;svm ohne translation (identisch mit cpc)
keyget  ret
else
keyget  ld hl,keygett
        ld e,a
        ld d,0
        add hl,de
        ld a,(hl)
        ret
endif

;### KEYDFL -> Definition-Settings laden
keydfl  ld a,(keynum)
        ld e,a
        ld d,0
        ld hl,keytab
        add hl,de
        ld a,(hl)
        ld (keyobjtxtf),a
        ld a,e
        call keyget
        ld e,a
        ld hl,80*0+keydef
        ld ix,keyobjdatg
        call keydfl1
        ld hl,80*1+keydef
        ld ix,keyobjdath
        call keydfl1
        ld hl,80*2+keydef
        ld ix,keyobjdati
        call keydfl1
        ld hl,80*3+keydef
        ld ix,keyobjdatj
keydfl1 ld (ix+2),0
        ld (ix+6),0
        add hl,de
        ld a,(hl)
        cp 33
        jr c,keydfl2
        cp 127
        jr nc,keydfl2
        ld (ix+14),a
        ld (ix+15),0
        ld (ix+4),1
        ld (ix+8),1
        ret
keydfl2 ld (ix+17),0
        ld (ix+4),3
        ld (ix+8),3
        ld c,"0"-1
keydfl3 inc c
        sub 100
        jr nc,keydfl3
        add 100
        ld (ix+14),c
        call clcdez
        ld (ix+15),l
        ld (ix+16),h
        ret

;### KEYDFS -> Definition-Settings speichern
keydfs  ld a,(keynum)
        call keyget
        ld d,0
        ld e,a
        ld hl,80*0+keydef
        ld ix,keyobjdatg
        call keydfs1
        ld hl,80*1+keydef
        ld ix,keyobjdath
        call keydfs1
        ld hl,80*2+keydef
        ld ix,keyobjdati
        call keydfs1
        ld hl,80*3+keydef
        ld ix,keyobjdatj
keydfs1 add hl,de
        ld a,(ix+8)
        cp 1
        jr nz,keydfs2
        ld a,(ix+14)
        ld (hl),a
        ret
keydfs2 ld bc,14
        add ix,bc
        ld b,a
        ld c,0
keydfs3 ld a,c
        add a
        ret c
        ld c,a
        add a
        ret c
        add a
        ret c
        add c
        ret c
        ld c,a
        ld a,(ix+0)
        sub "0"
        ret c
        cp 10
        ret nc
        add c
        ret c
        ld c,a
        inc ix
        djnz keydfs3
        ld (hl),a
        ret

;### KEYLOD -> load keyboard definition
keylod  ld a,5
        ld hl,prginpkey2a
        call prgbro
        jp prgprz0
keylod0 ld hl,prginpkey2b
        ld ix,(prgbnknum-1)
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOPN
        jp c,prgprz0
        push af
        ld de,(prgbnknum)
        ld hl,keydef
        ld bc,4*80
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        pop af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        ld de,256*5+256-9
        jp keysel0

;### KEYSAV -> save keyboard definition
keysav  ld a,6
        ld hl,prginpkey2a
        ld d,64
        call prgbro0
        jp prgprz0
keysav0 call keydfs
        ld hl,prginpkey2b
        ld ix,(prgbnknum-1)
        xor a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILNEW
        jp c,prgprz0
        push af
        ld de,(prgbnknum)
        ld hl,keydef
        ld bc,4*80
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOUT
        pop af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        ld de,256*5+256-9
        jp prgprz0

;### KEYAPL -> Keyboard-Fenster APPLY-Button
keyapl  call keyact
        jp prgprz0

;### KEYOKY -> Keyboard-Fenster OK-Button
keyoky  call keyact
keyoky1 ld c,4*setkeynum
        ld a,1
        jp prgsub4

;### KEYCNC -> Keyboard-Fenster CANCEL/CLOSE-Button
keycnc  call keydis
        call keyini
        jr keyoky1

;### KEYACT -> Keyboard-Einstellungen übernehmen
keyact  ld hl,(keydsp)
        ld (keyold),hl
        call keydfs
        ld hl,jmp_sysinf            ;*** Keyboard-Infos sichern
        ld de,256*2+6
        ld ix,keydef+320
        ld iy,66
        rst #28
        ld de,(keyadr)
        ld hl,keydef
        ld bc,320
        ld a,(bnknumput)
        rst #20:dw jmp_bnkcop
        ret

;### KEYDIS -> Keyboard-Einstellungen nicht übernehmen
keydis  ld hl,jmp_sysinf
        ld de,256*2+6
        ld ix,keyold
        ld iy,66
        rst #28
        ret

;### KEYSEL -> Taste auswählen
keysel  sub 100                 ;A=0-79 (Nummer)
        push af
        call keydfs
        pop af
        ld (keynum),a
keysel0 call keydfl
        ld de,prgdatkeyn-14*256+256-5
        call keysel1
        jp prgprz0
keysel1 ld c,MSC_DSK_WININH
        ld a,(0*4+prgwinsub+2)
        ld b,a
        jp msgsnd

;### KEYSPD -> Speed setzen
keyspd  ld a,(keyobjdatn+2)
        inc a
        ld (keydsp),a
        ld a,(keyobjdato+2)
        inc a
        ld (keyrsp),a
        call keyspl
        ld de,prgdatkeyn-3*256+256-2
        call keysel1
        ld hl,jmp_sysinf
        ld de,256*2+6
        ld ix,keydsp
        ld iy,66
        rst #28
        jp prgprz0


;==============================================================================
;### DEVICE-FENSTER ###########################################################
;==============================================================================

if computer_mode=0          ;cpc
stodty  equ #202
elseif computer_mode=1      ;msx
stodty  equ #21c
elseif computer_mode=2      ;pcw
stodty  equ #202
elseif computer_mode=3      ;ep
stodty  equ #20f
elseif computer_mode=4      ;svm
stodty  equ #203
elseif computer_mode=5      ;nc
stodty  equ #203
elseif computer_mode=6      ;nxt
stodty  equ #203
endif

devadr  dw 0
devslt  db 0,0              ;Driver-Typ für Slot 0 und 1 (-1=NUL, 0=FDC, 1=IDE, 2=SD, 3=USB)

;### DEVINI -> Device-Fenster initialisieren
devini  ld hl,stodty
        xor a
        rst #20:dw jmp_bnkrwd
        ld (devslt),bc

devini3 ld a,(devslt+0)
        ld hl,prgobjdev4+2
        ld ix,prgdatdev3+2-16
        call devini5

        ld a,(devslt+1)
        ld hl,prgobjdev5+2
        ld ix,prgdatdev3+2
        call devini5

        ld hl,jmp_sysinf
        ld e,3
        ld ix,cfgdevmem
        rst #28                 ;Device-Config laden
        xor a
devini0 ld (prgobjdev3a),a
        ld a,-1
        ld (devsela),a
        ld ix,cfgdevmem+cfgdevnam
        ld bc,8*256
        ld iy,prgtabdev1
        ld l,0
devini1 ld a,(ix+cfgdevlet-cfgdevnam)
        or a
        jr z,devini2
        inc c
        ld (iy+0),l
        push ix
        pop de
        ld (iy+2),e
        ld (iy+3),d
        ld de,4
        add iy,de
devini2 ld de,cfgdevlen
        add ix,de
        ld a,e
        add l
        ld l,a
        djnz devini1
        ld a,c
        ld (prgobjdev3),a
        jp devlod
devini5 cp 1
        ld de,prgtxtdev6
        jr c,devini6
        ld de,prgtxtdev7
        jr z,devini6
        cp 3
        ld de,prgtxtdeva
        jr c,devini6
        ld de,prgtxtdevb
        jr z,devini6
        set 6,(ix+0)
        ret
devini6 ld (hl),e
        inc hl
        ld (hl),d
        ret

;### DEVLOD -> Lädt Device-Settings des angewählten Devices ins Fenster
;### Verändert  AF,BC,DE,HL,IX
devlod  ld a,-1
        ld (devtypa),a
        ld a,(prgobjdev3a)
        add a:add a
        ld l,a
        ld h,0
        ld de,prgtabdev1+2
        add hl,de
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld hl,-cfgdevnam
        add hl,de               ;HL=Gerätedaten
        ld (devadr),hl
        ld a,(hl)
        sub "A"
        cp "Z"+1
        jr c,devlod0
        add "A"-"a"
devlod0 ld (prgobjdevg+12),a    ;Buchstabe setzen
        inc hl
        xor a
        bit 7,(hl)
        jr z,devlod1
        inc a
devlod1 ld (prgdevrem),a        ;Wechseldatenträger setzen
        ld a,(hl)
        inc hl
        and 15
        ld (prgdevtyp),a        ;Gerätetyp setzen
        ld a,(hl)
        push hl
        call devspc
        pop hl
        inc hl
        inc hl
        ld (prgobjdev8),hl      ;Name setzen
        ld bc,11*256+255
        xor a
devlod2 inc c
        cp (hl)
        inc hl
        jr nz,devlod2
        ld a,c
        ld (prgobjdev8+8),a
        ret

;### DEVSPC -> Setzt Device-Typ spezifische Einstellungen
;### Eingabe    A=SubLaufwerk-Config, ZF=Typ (1=FDC, 0=IDE)
;### Verändert  AF,BC,DE,HL,IX
devspc  ld c,a
        ld hl,devslt
        jr z,devspc6
        inc hl
devspc6 ld a,(hl)
        ld ix,prgdatdev2        ;Geräte-spezifische Controls setzen
        res 7,(ix+2)
        ld hl,prgobjdevx
        ld de,prgobjdeva
        cp 1
        jr c,devspc1            ;FDC
        set 7,(ix+2)
        ld hl,prgobjdevy
        ld de,prgobjdevb
        jr z,devspc1
        ld de,prgobjdevc
        cp 2
        jr z,devspc1
        ld de,prgobjdevd
devspc1 ld (16*0+prgdatdev1+4),de
        ld (16*1+prgdatdev1+4),hl
        jr nc,devspc4
        ld a,c                      ;*** FDC
        and 3
        ld (prgobjdeva+12),a    ;FDC-Laufwerk setzen
        xor a
        bit 2,c
        jr z,devspc2
        inc a
devspc2 ld (prgobjdevx+12),a    ;FDC-Kopf setzen
        xor a
        bit 3,c
        jr z,devspc3
        inc a
devspc3 ld (prgdevstp),a        ;FDC-Doublestep setzen
        ret
devspc4 ld a,c                      ;*** IDE/SD/SCSI
        and 15
        ld (prgobjdevy+12),a    ;IDE/SD/SCSI-Partition setzen
        ld a,c
        rrca:rrca:rrca:rrca
        and 15
        ld hl,12
        add hl,de
        ld (hl),a               ;IDE/SD/SCSI-Kanal setzen
        ret

;### DEVSAV -> Speicher Device-Settings des bisher angewählten Devices
devsav  ld hl,(devadr)
        ld a,(prgobjdevg+12)
        add "A"
        ld (hl),a               ;Buchstabe speichern
        inc hl
        ld a,(prgdevrem)
        rrca
        and 128
        ld c,a
        ld a,(prgdevtyp)
        or c
        ld (hl),a               ;Wechselflag und Typ speichern
        inc hl
        bit 0,a
        ld de,devslt
        jr z,devsav2
        inc de
devsav2 ld a,(de)
        cp 1
        jr nc,devsav4
        ld a,(prgobjdeva+12)    ;*** FDC-Einstellungen speichern
        ld ix,prgobjdevx+12
        bit 0,(ix+0)
        jr z,devsav1
        set 2,a
devsav1 ld ix,prgdevstp
        bit 0,(ix+0)
        jr z,devsav3
        set 3,a
devsav3 ld (hl),a
        ret
devsav4 ld de,prgobjdevb+12     ;*** IDE-Einstellungen speichern
        jr z,devsav5
        ld de,prgobjdevc+12
        cp 3
        jr c,devsav5
        ld de,prgobjdevd+12
devsav5 ld a,(de)
        add a:add a:add a:add a
        ld c,a
        ld a,(prgobjdevy+12)
        or c
        jr devsav3

;### DEVSEL -> Device-Auswahl
devsela db 0
devsel  ld a,(prgobjdev3a)
        ld hl,devsela
        cp (hl)
        jr z,devsel0
        ld (hl),a
        ld a,-1
        call devsav
        call devlod
devsel1 ld a,10
devsel2 push af
        ld e,a
        call devtyp1
        pop af
        inc a
        cp 20+1
        jr c,devsel2
devsel0 jp prgprz0

;### DEVTYP -> Device-Typ setzen
devtypa db 0
devtyp  ld a,(prgdevtyp)
        ld hl,devtypa
        cp (hl)
        jr z,devsel0
        ld (hl),a
        or a
        call devspc
        ld e,16
        call devtyp1
        ld e,17
        call devtyp1
        ld e,18
        call devtyp1
        ld e,19
        call devtyp1
        jp prgprz0
devtyp1 ld c,MSC_DSK_WININH
        ld a,(6*4+prgwinsub+2)
        ld b,a
        jp msgsnd

;### DEVDEL -> Device entfernen
devdel  ld a,(prgobjdev3)
        dec a
        ld c,a
        jp z,prgprz0
        ld a,(prgobjdev3a)
        add a:add a
        ld l,a
        ld h,0
        ld de,prgtabdev1
        add hl,de
        ld e,(hl)
        inc hl
        ld a,(hl)
        and #3f
        ld d,a
        ld hl,cfgdevmem
        add hl,de
        ld (hl),0
        ld a,(prgobjdev3a)
        cp c
        jr c,devdel1
        ld a,c
        dec a
devdel1 call devini0
        jp devsel1

;### DEVADD -> Device hinzufügen
devaddn db "New Device",0,0
devadd  call devsav
        ld hl,cfgdevmem
        ld de,cfgdevlen
        ld b,8
        xor a
devadd1 cp (hl)
        jr z,devadd2
        add hl,de
        djnz devadd1
        jp prgprz0
devadd2 ld a,8
        sub b
        push af
        push hl
        call devfre
        pop hl
        ld (hl),a
        ld a,(devslt+0)
        sub -1
        ld a,129
        sbc 0
        inc hl
        ld (hl),a
        inc hl
        ld (hl),0
        inc hl
        ld (hl),0
        inc hl
        ex de,hl
        ld hl,devaddn
        ld bc,12
        ldir
        pop af
        jr devdel1

;### DEVLET -> Device-Buchstabe setzen
devlet  ld a,(prgobjdev3a)
        ld h,a                      ;H=Device-Slot
        ld a,(prgobjdevg+12)
        add "A"
        ld l,a                      ;L=Buchstabe
        ld ix,cfgdevmem+cfgdevlet
        ld b,8
        ld de,cfgdevlen
devlet1 ld a,(ix+0)                 ;prüfen, ob Buchstabe bereits verwendet ist
        cp l
        jr nz,devlet2               ;Buchstabe stimmt nicht -> ok
        ld a,8
        sub b
        cp h
        jr nz,devlet3               ;Buchstabe stimmt und nicht aktuelles Device -> Buchstabe darf nicht verwendet werden
devlet2 add ix,de
        djnz devlet1
        jp prgprz0                  ;Nein -> alles ok
devlet3 call devfre             ;C=Buchstabe
        ld a,c
        sub "A"
        ld (prgobjdevg+12),a
        ld e,13
        call devtyp1
        jp prgprz0

;### DEVFRE -> Freien Buchstaben suchen
;### Ausgabe    C=Buchstabe
devfre  ld c,"A"
        ld b,8
devfre1 push bc
devfre2 ld ix,cfgdevmem+cfgdevlet
        ld de,cfgdevlen
        ld b,8
        ld a,c
devfre3 cp (ix+0)
        jr z,devfre4
        add ix,de
        djnz devfre3
        pop bc
        ret
devfre4 pop bc
        inc c
        djnz devfre1
        ret

;### DEVAPL -> Device-Fenster APPLY-Button
devapl  call devact
        jp prgprz0

;### DEVOKY -> Device-Fenster OK-Button
devoky  call devact
devoky1 ld c,4*setdevnum
        ld a,c
        jp prgsub4

;### DEVCNC -> Device-Fenster CANCEL/CLOSE-Button
devcnc  call devini
        jr devoky1

;### DEVACT -> Device-Einstellungen übernehmen
devact  call devsav
        call sysini0
        ld hl,jmp_sysinf
        ld e,4
        ld ix,cfgdevmem
        rst #28                 ;Device-Config speichern
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_DEVINI       ;Devices neu einbinden
        ret nc
        ld a,c                  ;Fehler -> Meldung ausgeben
        add "0"
        ld (prgerrdev1a),a
        ld a,e
        add "0"
        ld (prgerrdev2a),a
        ld a,d
        call clcdez
        ld (prgerrdev3a),hl
        ld b,1
        ld hl,prgdeverr
        jp prginf0

devact0 ld (prgmsgb),hl
devact1 ld a,(prgprzn)
        db #dd:ld l,a
        db #dd:ld h,PRC_ID_SYSTEM
        ld iy,prgmsgb
        rst #10                 ;Devices aktualisieren
        ret


;==============================================================================
;### SYSTEM-FENSTER ###########################################################
;==============================================================================

extlen  equ 768

;### SYSINI -> System-Fenster initialisieren
;prgtxtsys2f = "[unknown]"

sysinit
    if computer_mode=0
        dw prgtxtsys2a,prgtxtsys2b,prgtxtsys2c,prgtxtsys2d,prgtxtsys2e  ;0,1,2,3,4  CPC
        dw prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f

elseif computer_mode=1
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2r,prgtxtsys2m,prgtxtsys2n,prgtxtsys2o              ;7,8,9,10   MSX
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f

elseif computer_mode=2
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2p,prgtxtsys2q                                      ;12,13      PCW
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f

elseif computer_mode=3
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2h                                                  ;6          EP
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f

elseif computer_mode=4
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2i  ;18         SVM
        dw prgtxtsys2f,prgtxtsys2f

elseif computer_mode=5
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2j,prgtxtsys2k,prgtxtsys2l,prgtxtsys2f  ;15,16,17   NC
        dw prgtxtsys2f,prgtxtsys2f

elseif computer_mode=6
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f,prgtxtsys2f
        dw prgtxtsys2f,prgtxtsys2s                                      ;20         NXT
endif

if computer_mode=4
sysini5 and #f
        call clcdez
        ld a,l
        cp "0"
        jr z,sysini9
        ld (ix+0),l
        inc ix
sysini9 ld (ix+0),h
        inc ix
        ld (ix+0),c
        ret

sysini  ld ix,prgtxtsys2i1
        in a,(P_VERSION)
        push af
        rrca:rrca:rrca:rrca
        ld c,"."
        call sysini5
        inc ix
        pop af
        ld c,0
        call sysini5 
else
sysini
endif
        ld e,7
        ld hl,jmp_sysinf
        rst #28             ;DE=System, IX=Data, IY=Transfer
        ld a,(prgbnknum)
        add a:add a:add a:add a
        db #fd:add l
        ld (bnknumget),a
        push af
        rlca:rlca:rlca:rlca
        ld (bnknumput),a
        ld e,8                  ;*** Version holen
        ld hl,jmp_sysinf
        rst #28             ;IY=Adr
        push iy
        pop hl
        inc hl:inc hl
        ld de,prgtxtsys1y
        pop af
        ld bc,30
        rst #20:dw jmp_bnkcop
        ld hl,jmp_sysinf        ;*** Systempfad holen
        ld de,256*31+5
        ld ix,syssyspth
        ld iy,0
        rst #28
        ld hl,jmp_sysinf        ;*** Autoexec-Pfad + Flag holen
        ld de,256*33+5
        ld ix,sysautpth
        ld iy,66+2+6+9+32
        rst #28
        ld hl,jmp_sysinf        ;*** Flags holen
        ld de,256*9+5
        ld ix,cfgmem
        ld iy,66+2+6
        rst #28
        ld a,(cfgflags1)
        push af
        and 2
        rrca
        ld (cfgselflg),a
        pop af
        and 1
        add a
        inc a
        ld (prgwinmen1a),a
        ld hl,jmp_memsum        ;*** Speicher-Infos holen
        rst #28                 ;E,IX=freier Speicher insgesamt, D=Anzahl verfügbarer Bänke (jenseits 64K)
        inc d
        ld e,0
        srl d:rr e
        srl d:rr e              ;DE=gesamter Speicher
        push de
        pop ix
        ld iy,prgtxtsys1f
        ld e,4
        ld hl,jmp_clcnum
        rst #28
        push iy
        pop de
        inc de
        ld hl,prgtxtsys1g
        ld bc,8
        ldir
        ld a,(cfgcpctyp)        ;*** Plattform
        ld de,prgtxtsys20
        and #1f
        add a
        ld bc,sysinit
        call sysini3
        ld ix,prgobjsys3c       ;*** Misc
        call strinp
        ld ix,prgobjsys3g
        call strinp
        ld e,7                  ;*** File Extensions holen
        ld hl,jmp_sysinf
        rst #28             ;DE=System, IX=Data, IY=Transfer
        ld hl,lnkcfgdat
        ld bc,lnklenall+32
        add hl,bc
        ld (syslsta),hl
        ex de,hl
        push ix
        pop hl
        ld bc,lnklenall
        add hl,bc
        ld (syslstm),hl
        ld bc,extlen
        ld a,(bnknumget)
        rst #20:dw jmp_bnkcop
        xor a                   ;*** Liste generieren
        ld (prgobjsys5+2),a
        ld (prgobjsys5+12),a
        call syslst
        jp syseng0
sysini3 ld l,a
        ld h,0
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
sysini4 ld a,(hl)
        ldi
        or a
        jr nz,sysini4
        dec de
        ret
sysini0 xor a                   ;*** Boot-Drive Auswahl
        ld (prgobjsys3i+12),a
        ld ix,cfgdevmem
        ld bc,8*256
        ld iy,prgobjsysi1
sysini6 ld a,(ix+cfgdevlet)
        or a
        jr z,sysini8
        ld hl,cfgbotdrv
        cp (hl)
        jr nz,sysini7
        ld (prgobjsys3i+12),bc
sysini7 ld (iy+0),a
        sub "A"
        add a
        ld l,a
        ld h,0
        ld de,prgtabdevga
        add hl,de
        ld (iy+2),l
        ld (iy+3),h
        ld de,4
        add iy,de
        inc c
sysini8 ld de,cfgdevlen
        add ix,de
        djnz sysini6
        xor a
        ld (prgobjsys3i+13),a
        ld a,c
        ld (prgobjsys3i+0),a
        ret

;### SYSLST -> Extension-Liste generieren
syslsta dw 0
syslstm dw 0
syslstp db 0
syslst  ld a,16
        ld (prgobjsys5),a
        ld hl,(syslsta)
        ld ix,sysentlst     ;IX=Liste
        ld de,sysentext     ;DE=Extensions
        db #fd:ld l,16      ;IYL=Zähler
syslst1 db #fd:ld h,5
        push hl
        push de
syslst2 ld a,(hl)
        cp 32
        jr c,syslst3
        ld bc,3
        ldir                ;Extension kopieren
        ld a,","
        ld (de),a
        inc de
        db #fd:dec h
        jr nz,syslst2
syslst3 dec de
        ld a,5
        db #fd:cp h
        jr nz,syslst4
        inc de
        ld a,16
        db #fd:sub l
        ld (prgobjsys5),a
        db #fd:ld l,1
syslst4 xor a               ;Extensionliste abschließen
        ld (de),a
        pop hl
        ld bc,20
        add hl,bc
        ex de,hl
        pop hl
        ld bc,15
        add hl,bc
        ld (ix+4),l         ;Pfadadresse eintragen
        ld (ix+5),h
        ld bc,33
        add hl,bc
        res 7,(ix+1)        ;Eintrag demarkieren
        ld bc,6
        add ix,bc
        db #fd:dec l
        jr nz,syslst1
        ld a,(prgobjsys5+12)    ;Selektierte Zeile markieren
syslst5 ld (syslstp),a
        ld c,a
        add a
        add c
        add a
        ld l,a
        ld h,0
        ld bc,sysentlst+1
        add hl,bc
        set 7,(hl)
        ret

;### SYSENC -> Eintrag wurde angeklickt
sysenc  ld a,(prgobjsys5+12)
        ld hl,syslstp
        cp (hl)
        jp z,prgprz0
        push af
        push hl
        call sysenp
        jr z,sysenc1
        call syslst
        ld e,5
        call systab0
sysenc1 pop hl
        pop af
        ld (hl),a
        call syseng
        jp prgprz0

;### SYSENP -> Eintrag speichern
;### Ausgabe    ZF=1 keine Änderung, ZF=0 Änderung hat stattgefunden
sysenpb ds 48
sysenpa dw 0
sysenp  ld de,sysenpb+1
        ld hl,sysenpb
        push hl
        ld (hl),1
        ld bc,5*3
        ldir
        ld (hl),0
        ld bc,33-1
        ldir
        pop de
        ld ix,prgobjsysaa
        ld iy,prginpsysaa
        ld bc,5*256
sysenp1 ld l,(ix+8)
        inc l
        dec l:jr z,sysenp2
        ld a," "
        inc de:ld (de),a
        inc de:ld (de),a
        push de
        dec de:dec de
        inc c
        ld a,(iy+0):call clclcs:ld (de),a:inc de
        dec l:jr z,sysenp8
        ld a,(iy+1):call clclcs:ld (de),a:inc de
        dec l:jr z,sysenp8
        ld a,(iy+2):call clclcs:ld (de),a
sysenp8 pop de
        inc de
sysenp2 push bc
        ld bc,14
        add ix,bc
        ld bc,4
        add iy,bc
        pop bc
        djnz sysenp1
        inc c:dec c
        ret z                   ;keine Extensions gefunden -> nichts machen
        ld hl,prginpsysba
        ld de,sysenpb+15
sysenp3 ld a,(hl)
        or a
        jr z,sysenp4
        ldi
        jr sysenp3
sysenp4 ld a," "
        dec hl
        cp (hl)
        jr z,sysenp5
        ld (de),a
sysenp5 ld hl,sysenpb
        ld de,sysengb
        ld b,48
sysenp6 ld a,(de)
        cp (hl)
        jr nz,sysenp7
        inc de
        inc hl
        djnz sysenp6
        xor a
        ret                     ;keine Änderung -> fertig
sysenp7 ld de,(sysenpa)
        ld hl,sysenpb
        ld bc,48
        ld a,c
        ldir                    ;Änderung übernehmen
        or a
        ret

;### SYSENG -> Eintrag holen
sysengb ds 48
syseng  call syseng0
        ld de,256*12+250
        jp systab0
syseng0 ld de,prginpsysaa+1
        ld hl,prginpsysaa
        ld (hl),0
        ld bc,5*4-1
        ldir
        ld a,(prgobjsys5+12)
        call sysdel0
        ld hl,(syslsta)
        add hl,bc               ;HL=Adresse
        ld (sysenpa),hl
        push hl
        ld de,sysengb
        ld bc,48
        ldir
        pop hl
        push hl
        db #fd:ld l,5
        ld de,prginpsysaa
syseng1 ld a,(hl)
        cp 32
        jr c,syseng2
        ld bc,3
        ldir
        xor a
        ld (de),a
        inc de
        db #fd:dec l
        jr nz,syseng1
syseng2 ld ix,prgobjsysaa:call strinp
        ld ix,prgobjsysab:call strinp
        ld ix,prgobjsysac:call strinp
        ld ix,prgobjsysad:call strinp
        ld ix,prgobjsysae:call strinp
        pop hl
        ld bc,15
        add hl,bc
        ld de,prginpsysba
        ld bc,33
        ldir
syseng3 ld ix,prgobjsysba:call strinp
        ret

;### SYSTAB -> Tab wechseln
systabo db 0
systab  ld a,(prgobjsys0a)
        ld hl,systabo
        cp (hl)
        jp z,prgprz0
        ld (hl),a
        or a
        ld hl,prggrpsysa
        jr z,systab1
        ld hl,prggrpsysb
systab1 ld (prgwinsys0),hl
        ld e,-1
        call systab0
        jp prgprz0
systab0 ld a,(setsysnum*4+prgwinsub+2)
        ld c,MSC_DSK_WININH
        ld b,a
        jp msgsnd

;### SYSADD -> Filetype-Eintrag hinzufügen
sysadde db "???":ds 15-3
sysaddf ds 33
sysadd  ld a,(prgobjsys5)
        cp 16
        jp z,prgprz0
        push af
        ld hl,syssyspth
        ld de,sysaddf
        ld bc,32
        ldir
        call sysenp
        pop af
        push af
        call sysdel0
        ld hl,(syslsta)
        add hl,bc               ;HL=Adresse
        ex de,hl
        ld hl,sysadde
        ld bc,48
        pop af
        jr sysdel2

;### SYSDEL -> Filetype-Eintrag entfernen
sysdel  ld a,(prgobjsys5)
        dec a
        jp z,prgprz0
        ld hl,(sysenpa)
        ld e,l
        ld d,h
        ld bc,48
        add hl,bc
        ld a,(prgobjsys5+12)
        neg
        add 15
        jr z,sysdel1
        call sysdel0
        ldir
sysdel1 ld l,e
        ld h,d
        inc hl
        ld (hl),1
        ld bc,47
        xor a
sysdel2 ld (prgobjsys5+12),a
        ldir
        call syslst
        ld e,5
        call systab0
        call syseng
        jp prgprz0
sysdel0 ld c,a
        add a
        add c
        add a
        add a
        ld c,a
        ld b,0
        sla c:rl b
        sla c:rl b
        ret

;### SYSBRW -> Browse-Button wurde geklickt
sysbrw  ld a,3
        ld hl,prgobjsysbb
        call prgbro
        jp prgprz0

;### SYSAPL -> System-Fenster APPLY-Button
sysapl  call sysact
        jp prgprz0

;### SYSOKY -> System-Fenster OK-Button
sysoky  call sysact
sysoky1 ld c,4*setsysnum
        ld a,c
        jp prgsub4

;### SYSCNC -> System-Fenster CANCEL/CLOSE-Button
syscnc  call sysini
        call sysini0
        jr sysoky1

;### SYSACT -> System-Einstellungen übernehmen
sysact  call sysenp             ;*** Fileextensions speichern
        call syslst
        ld hl,(syslsta)
        ld de,(syslstm)
        ld bc,extlen
        ld a,(bnknumput)
        rst #20:dw jmp_bnkcop
        ld hl,jmp_sysinf        ;*** Systempfad speichern
        ld de,256*31+6
        ld ix,syssyspth
        ld iy,0
        rst #28
        ld hl,jmp_sysinf        ;*** Autoexec-Pfad + Flag speichern
        ld de,256*33+6
        ld ix,sysautpth
        ld iy,66+2+6+9+32
        rst #28
        ld a,(prgobjsys3i+12)   ;*** Boot-Drive übernehmen
        add a:add a
        ld l,a
        ld h,0
        ld de,prgobjsysi1
        add hl,de
        ld a,(hl)
        ld (cfgbotdrv),a
        ld a,(cfgselflg)        ;*** Flags speichern
        add a
        ld hl,cfgflags1
        ld e,(hl)
        res 1,e
        or e
        ld (hl),a
        ld hl,jmp_sysinf
        ld de,256*5+6
        ld ix,cfgmem
        ld iy,66+2+6
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

lnklstnum   db 0    ;0=Desktop, 1=Startmenu, 2=Taskbar
lnkentnum   db 0    ;ausgewählter Eintrag

;### LNKINI -> Link-Fenster initialisieren
lnkini  ld e,9                  ;*** Icons updaten
        rst #20:dw jmp_sysinf
        ld e,7                  ;*** Namen, Pfade und Icons holen
        ld hl,jmp_sysinf
        rst #28             ;DE=System, IX=Data, IY=Transfer
        push ix
        pop hl
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
        cp 1
        jr c,lnklsi3
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
lnklsc0 ld c,MSC_DSK_WININH
        ld a,(setlnknum*4+prgwinsub+2)
        ld b,a
        jp msgsnd

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
        ld a,(prgbnknum)
        db #dd:ld h,a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOPN
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
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILPOI
        jp c,lnkicfe
lnkicf1 ld a,(prgbnknum)
        ld e,a
        ld a,(lnkicfh)
        ld hl,lnkeswb
        ld bc,147
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
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
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
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
lnkoky1 ld c,4*setlnknum
        ld a,c
        jp prgsub4

;### LNKCNC -> Link-Fenster CANCEL/CLOSE-Button
lnkcnc  call lnkini
        jr lnkoky1

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
        ld bc,256*8+MSC_DSK_DSKSRV   ;*** Hintergrund neu aufbauen
        jp msgsnd


;==============================================================================
;### FONT-FENSTER #############################################################
;==============================================================================

fntlen  equ 96*16+2

;### FNTINI -> Font-Fenster initialisieren
fntinia dw 0    ;Font-Herkunft
fntinib dw 0    ;Font-Buffer

fntini  ld e,8                      ;*** Font holen
        ld hl,jmp_sysinf
        rst #28             ;DE=Adr, IX=Len
        push de
        ld bc,lnklenall+32+extlen
        ld hl,lnkcfgdat
        add hl,bc           ;HL=Ziel
        ld (fntinib),hl
        ld ix,prgobjfnt1a
        ld de,6
        ld b,8
fntini1 ld (ix+4),l
        ld (ix+5),h
        add ix,de
        djnz fntini1
        ex de,hl
        pop hl
        ld (fntinia),hl
        ld a,(prgbnknum)
        add a:add a:add a:add a
        ld bc,fntlen
        rst #20:dw jmp_bnkcop   ;kopieren
        ret

;### FNTLOD -> Lade-Button wurde geklickt
fntlod  ld hl,prginpfnt2b
        ld a,(prgbnknum)
        db #dd:ld h,a
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILOPN
        jp c,prgprz0
        push af
        ld de,(prgbnknum)
        ld hl,(fntinib)
        ld bc,fntlen
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILINP
        pop af
        call syscll
        db MSC_SYS_SYSFIL
        db FNC_FIL_FILCLO
        ld de,256*5+256-9
        call fntbrw0
        jp prgprz0

;### FNTBRW -> Browse-Button wurde geklickt
fntbrw  ld a,4
        ld hl,prginpfnt2a
        call prgbro
        jp prgprz0
fntbrw0 ld a,(setfntnum*4+prgwinsub+2)
        ld c,MSC_DSK_WININH
        ld b,a
        jp msgsnd

;### FNTAPL -> Font-Fenster APPLY-Button
fntapl  call fntact
        jp prgprz0

;### FNTOKY -> Font-Fenster OK-Button
fntoky  call fntact
fntoky1 ld c,4*setfntnum
        ld a,c
        jp prgsub4

;### FNTCNC -> Font-Fenster CANCEL/CLOSE-Button
fntcnc  call fntini
        jr fntoky1

;### FNTACT -> Font-Einstellungen übernehmen
fntact  ld hl,(fntinib)
        ld de,(fntinia)
        ld bc,fntlen
        ld a,(prgbnknum)
        rst #20:dw jmp_bnkcop   ;kopieren
        ld bc,256*9+MSC_DSK_DSKSRV
        jp msgsnd


;==============================================================================
;### SUB-ROUTINEN #############################################################
;==============================================================================

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

;### CLCLCS -> Wandelt Groß- in Kleinbuchstaben um
;### Eingabe    A=Zeichen
;### Ausgabe    A=lcase(Zeichen)
;### Verändert  F
clclcs  cp "A"
        ret c
        cp "Z"+1
        ret nc
        add "a"-"A"
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


;==============================================================================
;### DATEN-TEIL ###############################################################
;==============================================================================

prgdatbeg

prgicn16c db 12,24,24:dw $+7:dw $+4,12*24:db 5
db #88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#11,#11,#11,#11,#11,#11,#11,#11,#38,#88,#88,#88,#1A,#9A,#9A,#9A,#9A,#9A,#9A,#91,#38,#88,#88,#88,#19,#A9,#A9,#A9,#A9,#A9,#A9,#A1,#38,#88,#88,#88
db #1A,#9E,#EE,#33,#3A,#9A,#9A,#91,#38,#88,#88,#88,#19,#AE,#FF,#F3,#19,#A9,#A9,#A1,#38,#88,#88,#88,#1A,#9E,#3F,#33,#1A,#91,#11,#11,#38,#88,#88,#88,#19,#A3,#33,#32,#19,#5F,#FF,#03,#38,#88,#88,#88
db #1A,#93,#23,#11,#1A,#55,#55,#53,#38,#77,#88,#88,#19,#A1,#11,#46,#77,#5F,#45,#53,#37,#46,#78,#88,#1A,#9A,#91,#64,#67,#5F,#45,#53,#14,#64,#78,#88,#19,#A9,#A7,#56,#46,#5F,#45,#53,#46,#41,#78,#88
db #1A,#9A,#57,#56,#67,#5F,#45,#53,#74,#61,#78,#88,#19,#55,#55,#46,#76,#5F,#45,#53,#67,#46,#77,#78,#1A,#54,#64,#64,#67,#5F,#45,#53,#74,#64,#64,#67,#19,#75,#55,#56,#46,#57,#77,#75,#46,#47,#55,#57
db #1A,#75,#55,#77,#64,#64,#64,#64,#64,#57,#55,#57,#19,#75,#57,#46,#47,#75,#46,#57,#76,#46,#75,#57,#1A,#97,#75,#54,#75,#55,#64,#75,#55,#65,#77,#78,#33,#37,#75,#47,#55,#55,#46,#75,#55,#55,#77,#88
db #88,#88,#85,#47,#57,#75,#55,#77,#75,#55,#78,#88,#88,#88,#85,#47,#78,#85,#55,#78,#87,#55,#78,#88,#88,#88,#88,#77,#88,#87,#55,#78,#88,#77,#88,#88,#88,#88,#88,#88,#88,#87,#77,#78,#88,#88,#88,#88

icndatslf       db 2,8,8,#FF,#FF,#88,#90,#98,#90,#B8,#F0,#B8,#F0,#98,#90,#88,#90,#F0,#F0        ;Links
icndatsrg       db 2,8,8,#FF,#FF,#88,#90,#88,#D0,#B8,#F0,#B8,#F0,#88,#D0,#88,#90,#F0,#F0        ;Rechts

prgmsginf1 db "SymbOS CONTROL PANEL",0
prgmsginf2 db " Version 2.2 (Build 240125pdt)",0
prgmsginf3 db " Copyright <c> 2024 SymbiosiS",0

prgmsgwpf1 db "Wrong platform! This Control Panel",0
prgmsgwpf2 db "is for the "
if computer_mode=0
                       db "AMSTRAD CPC.",0
elseif computer_mode=1
                       db "MSX1/2(+)/TURBOR.",0
elseif computer_mode=2
                       db "AMSTRAD PCW JOYCE.",0
elseif computer_mode=3
                       db "ENTERPRISE 64/128.",0
elseif computer_mode=4
                       db "SYMBOS VM.",0
elseif computer_mode=5
                       db "AMSTRAD NC1x0/200.",0
elseif computer_mode=6
                       db "ZX SPECTRUM NEXT.",0
endif
prgmsgwpf3 db "Please replace CP.EXE .",0

prgerrdev1  db "Error while adding "
prgerrdev1a db "# device(s)",0
prgerrdev2  db "Device number: "
prgerrdev2a db "#",0
prgerrdev3  db "Error code: "
prgerrdev3a db "##",0

prgwintit db "Control Panel",0
prgwinsta db "8 Object(s)",0
prgwinmentx1 db "File",0
prgwinmentx2 db "?",0
prgwinmen1tx1 db "Load settings",0
prgwinmen1tx2 db "Save settings",0
prgwinmen1tx3 db "Autosave",0
prgwinmen1tx4 db "Close",0
prgwinmen2tx1 db "Helptopics",0
prgwinmen2tx2 db "Info",0

prgicnkey1a db "Keyboard",0
prgicnmou2a db "Mouse",0
prgicndsp3a db "Display",0
prgicntim4a db "Date and",0:prgicntim4b db "Time",0
prgicnfnt5a db "Font",0
prgicnsys6a db "System",0
prgicndev7a db "Mass",0:prgicndev7b db "Storage",0

prgicnlnk8a db "Desktop",0:prgicnlnk8b db "Links",0
prgicnlnk8c db "Startmenu",0



if computer_mode=2      ;PCW -> 4farb icons

prgicntim1 db 6,24,24       ;Datum/Uhrzeit
db #77,#FF,#DD,#FF,#FF,#80,#46,#0A,#3D,#0A,#0A,#C8,#C5,#05,#35,#05,#05,#AC,#C6,#68,#3D,#1A,#C2,#BE,#C5,#E1,#41,#B4,#E1,#BE,#C6,#E0,#78,#B0,#68,#BE,#C5,#61,#35,#05,#61,#BE,#C6,#68,#7F,#CE,#C2,#BE
db #C5,#71,#8F,#3E,#C1,#BE,#C6,#6B,#3D,#8F,#82,#BE,#C5,#47,#C0,#67,#49,#BE,#C6,#9E,#10,#11,#2C,#BE,#C5,#AC,#00,#00,#AD,#BE,#D7,#2C,#10,#00,#9E,#BE,#D5,#48,#10,#88,#56,#BE,#F7,#58,#10,#D0,#56,#BE
db #F3,#48,#22,#00,#56,#3E,#F3,#2C,#44,#00,#9E,#FE,#F0,#AC,#00,#00,#BC,#F0,#70,#9E,#10,#11,#3C,#E0,#00,#47,#C4,#67,#48,#00,#00,#23,#3F,#8F,#80,#00,#00,#11,#8F,#3C,#00,#00,#00,#00,#70,#C0,#00,#00
prgicndsp1 db 6,24,24       ;Anzeige
db #00,#77,#FF,#FF,#FF,#CC,#00,#8F,#0F,#1F,#87,#64,#11,#0F,#0F,#1F,#86,#EC,#22,#00,#00,#33,#D9,#EC,#45,#0F,#0F,#3F,#DB,#EC,#45,#FF,#FF,#DE,#97,#EC,#45,#F0,#F0,#F3,#FB,#EC,#45,#C0,#F0,#E2,#5E,#EC
db #45,#B0,#F0,#E3,#9F,#E4,#45,#F0,#F0,#F3,#4F,#E8,#45,#B0,#F0,#E3,#3D,#E4,#45,#F0,#F0,#D7,#3E,#EC,#45,#F0,#F0,#8F,#F5,#EC,#45,#F0,#F1,#4F,#DB,#EC,#45,#F0,#E3,#3D,#D3,#EC,#45,#00,#57,#3E,#5B,#EC
db #45,#0F,#8F,#E4,#5B,#C8,#77,#FF,#4F,#EB,#7B,#80,#30,#E3,#3D,#E2,#78,#00,#00,#DF,#3E,#6B,#48,#00,#11,#0A,#E5,#2E,#68,#00,#11,#05,#4B,#1E,#E4,#00,#00,#C2,#04,#3F,#C0,#00,#00,#30,#F0,#F0,#00,#00
prgicnfnt1 db 6,24,24       ;Schriftarten
db #00,#00,#F0,#00,#C0,#00,#00,#10,#0F,#90,#2C,#00,#00,#21,#0F,#78,#1E,#C0,#00,#21,#C3,#7B,#87,#6A,#00,#30,#ED,#6A,#43,#E6,#00,#31,#A9,#6A,#30,#CC,#00,#31,#21,#6A,#70,#80,#00,#10,#21,#6A,#87,#48
db #00,#21,#A1,#7A,#C3,#2C,#00,#21,#E5,#E6,#ED,#3D,#00,#43,#78,#C0,#10,#3D,#00,#43,#6B,#2C,#10,#7B,#00,#A5,#2D,#1E,#90,#E6,#00,#A5,#3D,#0F,#78,#CC,#10,#7A,#1E,#87,#3D,#88,#10,#7A,#1E,#F8,#F3,#00
db #21,#E6,#87,#B3,#CC,#00,#21,#F0,#87,#C4,#00,#00,#43,#0F,#0F,#48,#00,#00,#52,#F0,#C3,#6A,#00,#00,#B5,#FF,#ED,#2C,#00,#00,#B5,#00,#21,#3D,#00,#00,#F3,#00,#10,#F1,#00,#00,#66,#00,#00,#FF,#00,#00
prgicnlnk1 db 6,24,24       ;Desktop und Menu Links
db #87,#0F,#0F,#0F,#0F,#0F,#F7,#FF,#FF,#FF,#FF,#EF,#F7,#F9,#FF,#EF,#00,#6F,#F7,#DA,#FF,#EE,#B4,#67,#F7,#CB,#F7,#EE,#78,#67,#F7,#CB,#7B,#EE,#F0,#67,#F7,#CB,#3D,#EE,#F0,#67,#F7,#CB,#7B,#EF,#00,#6F
db #F7,#DA,#3D,#FF,#FF,#EF,#F7,#F9,#B5,#F9,#F4,#E9,#0F,#0F,#FB,#FF,#FF,#EF,#5A,#A5,#FF,#FF,#FF,#EF,#0F,#0F,#0F,#2F,#00,#6F,#6E,#9A,#A5,#A6,#B4,#67,#5D,#CF,#0F,#2E,#78,#67,#0F,#1E,#D2,#A6,#F0,#67
db #69,#C3,#0F,#2E,#F0,#67,#0F,#1E,#B4,#A7,#00,#6F,#5A,#C3,#0F,#3F,#FF,#EF,#0F,#0F,#FF,#F9,#F4,#E9,#78,#69,#FF,#FF,#FF,#EF,#0F,#0F,#FF,#FF,#FF,#EF,#69,#A5,#FF,#FF,#FF,#EF,#0F,#0F,#F0,#F0,#F0,#E1
prgicnkey1 db 6,24,24       ;Tastatur
db #00,#00,#00,#00,#10,#00,#00,#00,#00,#00,#21,#80,#00,#00,#00,#00,#10,#40,#00,#00,#00,#00,#00,#20,#00,#60,#D0,#B0,#60,#20,#10,#B0,#60,#D0,#B0,#E0,#20,#00,#00,#00,#00,#00,#70,#F0,#F0,#F0,#F0,#E0
db #84,#00,#00,#00,#00,#32,#B3,#FF,#FF,#FF,#FF,#FE,#A2,#49,#92,#24,#48,#7A,#A3,#4B,#96,#2D,#4B,#7A,#B2,#F0,#F0,#F0,#F0,#F2,#A2,#12,#24,#49,#80,#7A,#A3,#1E,#2D,#4B,#87,#7A,#B2,#F0,#F0,#F0,#F0,#F2
db #A2,#41,#92,#24,#48,#7A,#A3,#4B,#96,#2D,#4B,#7A,#B2,#F0,#F0,#F0,#F0,#F2,#A2,#12,#24,#00,#24,#7A,#A3,#1E,#2D,#0F,#2D,#7A,#B2,#F0,#F0,#F0,#F0,#F2,#D7,#FF,#FF,#FF,#FF,#FE,#70,#F0,#F0,#F0,#F0,#E0
prgicnmou1 db 6,24,24       ;Maus
db #C4,#00,#00,#00,#00,#00,#C4,#00,#00,#00,#00,#00,#73,#11,#FF,#EE,#00,#00,#30,#EE,#8F,#3E,#80,#00,#11,#88,#67,#0F,#C8,#00,#11,#00,#11,#F0,#E0,#00,#22,#00,#66,#07,#3E,#00,#44,#00,#88,#01,#17,#80
db #88,#11,#22,#00,#0B,#C8,#8C,#22,#44,#00,#07,#6C,#8E,#44,#88,#00,#0B,#6C,#8F,#88,#00,#00,#07,#3E,#8B,#0E,#00,#00,#0B,#3E,#45,#0F,#00,#00,#07,#3E,#22,#0F,#00,#00,#0F,#3E,#11,#07,#08,#01,#07,#3E
db #00,#89,#08,#00,#0F,#7E,#00,#45,#08,#01,#0F,#7E,#00,#22,#0C,#02,#0F,#EC,#00,#11,#04,#05,#1F,#EC,#00,#11,#07,#0F,#7F,#C8,#00,#00,#89,#1F,#FF,#80,#00,#00,#77,#FF,#FC,#00,#00,#00,#30,#F0,#C0,#00
prgicndev1 db 6,24,24       ;Mass Storage Devices
db #00,#10,#C0,#11,#AD,#3F,#00,#30,#E0,#11,#AD,#3F,#00,#61,#3C,#11,#FF,#FF,#00,#87,#0F,#91,#FE,#FF,#10,#0F,#0F,#59,#ED,#F7,#21,#0F,#0F,#3D,#FE,#FF,#61,#0F,#0F,#3D,#8F,#3F,#C3,#0F,#8D,#17,#8C,#37
db #C3,#1F,#C7,#1F,#8F,#3F,#C3,#0E,#8A,#1A,#F0,#F0,#E9,#0F,#0F,#3C,#D2,#00,#E5,#0D,#FF,#FC,#A7,#80,#72,#0F,#3F,#FF,#DF,#48,#31,#82,#0A,#FF,#EF,#EA,#10,#E9,#3C,#F0,#DF,#6A,#00,#F4,#F0,#F0,#AF,#E4
db #00,#72,#F1,#F2,#D6,#C8,#00,#31,#E3,#F9,#B5,#80,#00,#10,#F9,#7C,#F2,#00,#00,#00,#F4,#BE,#E4,#00,#00,#00,#72,#F4,#C8,#00,#00,#00,#31,#F1,#80,#00,#00,#00,#10,#FE,#00,#00,#00,#00,#00,#E0,#00,#00
prgicnsys1 db 6,24,24       ;System
db #00,#30,#F0,#F0,#E2,#00,#00,#70,#F0,#F0,#F4,#00,#00,#F0,#F0,#F0,#F8,#00,#10,#7F,#FF,#FF,#F0,#00,#10,#FC,#F0,#E3,#F0,#00,#10,#DA,#BD,#69,#F0,#00,#10,#F8,#F0,#E1,#F0,#00,#10,#DB,#78,#E1,#F0,#00
db #10,#FA,#F0,#E1,#F0,#00,#10,#F8,#F0,#E1,#F1,#00,#10,#FC,#F0,#E3,#F2,#00,#10,#8F,#0F,#0F,#E4,#00,#10,#FF,#FF,#FF,#D9,#88,#00,#F0,#F9,#F0,#80,#66,#00,#11,#22,#00,#00,#11,#31,#F6,#FC,#D2,#F0,#C0
db #30,#F0,#F0,#F0,#F2,#C8,#73,#FF,#FF,#FF,#F5,#E4,#63,#05,#05,#05,#F2,#E8,#C6,#0A,#0A,#0A,#F9,#F4,#C5,#04,#01,#05,#FA,#FA,#F7,#FF,#FF,#FF,#F8,#F0,#F0,#F0,#F0,#F0,#D3,#5E,#F0,#F0,#F0,#F0,#F0,#F0

else        ;sonstige -> 16farb icons

prgicntim1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Datum/Uhrzeit
db #83,#33,#33,#33,#33,#83,#33,#33,#33,#33,#18,#88,#83,#E8,#E8,#E8,#EE,#13,#E8,#E8,#E8,#E8,#31,#88,#13,#8E,#8E,#8E,#8E,#13,#8E,#8E,#8E,#8E,#32,#18,#13,#E8,#E1,#18,#EE,#13,#E8,#E1,#11,#E8,#32,#31
db #13,#8E,#11,#1E,#81,#8E,#1E,#11,#11,#1E,#32,#31,#13,#E8,#11,#18,#E1,#11,#18,#11,#E1,#18,#32,#31,#13,#8E,#81,#1E,#8E,#13,#8E,#8E,#81,#1E,#32,#31,#13,#E8,#E1,#18,#E3,#33,#33,#E8,#11,#E8,#32,#31
db #13,#8E,#81,#13,#32,#22,#22,#31,#11,#8E,#32,#31,#13,#E8,#E1,#32,#22,#13,#32,#22,#18,#E8,#32,#31,#13,#8E,#83,#22,#11,#CC,#C3,#32,#21,#8E,#32,#31,#13,#E8,#32,#21,#CC,#C1,#CC,#C3,#22,#18,#32,#31
db #13,#8E,#32,#1C,#CC,#CC,#CC,#CC,#32,#1E,#32,#31,#13,#E3,#22,#1C,#CC,#C1,#CC,#CC,#32,#21,#32,#31,#13,#83,#21,#CC,#CC,#C1,#3C,#CC,#C3,#21,#32,#31,#13,#33,#21,#C1,#CC,#C1,#11,#C1,#C3,#21,#32,#31
db #11,#33,#21,#CC,#CC,#3C,#CC,#CC,#C3,#21,#22,#31,#11,#33,#22,#1C,#C3,#CC,#CC,#CC,#32,#21,#33,#31,#11,#11,#32,#1C,#CC,#CC,#CC,#CC,#32,#11,#11,#11,#81,#11,#32,#21,#CC,#C1,#CC,#C3,#22,#11,#11,#18
db #88,#88,#83,#22,#13,#CC,#C3,#32,#21,#88,#88,#88,#88,#88,#88,#32,#22,#33,#32,#22,#18,#88,#88,#88,#88,#88,#88,#83,#32,#22,#22,#11,#88,#88,#88,#88,#88,#88,#88,#88,#81,#11,#11,#88,#88,#88,#88,#88
prgicndsp1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Anzeige
db #88,#88,#83,#33,#33,#33,#33,#33,#33,#33,#33,#88,#88,#88,#32,#22,#22,#22,#22,#2F,#12,#22,#03,#18,#88,#83,#22,#22,#22,#22,#22,#2F,#12,#20,#33,#18,#88,#30,#00,#00,#00,#00,#00,#FF,#F1,#03,#33,#18
db #83,#02,#22,#22,#22,#22,#22,#FF,#F1,#23,#33,#18,#83,#02,#33,#33,#33,#33,#33,#21,#12,#23,#33,#18,#83,#02,#11,#11,#11,#11,#11,#FF,#F1,#73,#33,#18,#83,#02,#11,#88,#11,#11,#11,#F8,#E7,#61,#33,#18
db #83,#02,#18,#11,#11,#11,#11,#FE,#76,#67,#13,#18,#83,#02,#11,#11,#11,#11,#11,#F7,#67,#66,#71,#18,#83,#02,#18,#11,#11,#11,#11,#76,#66,#17,#13,#18,#83,#02,#11,#11,#11,#11,#17,#67,#66,#71,#33,#18
db #83,#02,#11,#11,#11,#11,#76,#66,#17,#13,#33,#18,#83,#02,#11,#11,#11,#17,#67,#66,#71,#23,#33,#18,#83,#02,#11,#11,#11,#76,#66,#17,#11,#23,#33,#18,#83,#02,#00,#00,#07,#67,#66,#71,#E1,#23,#33,#18
db #83,#02,#22,#22,#76,#66,#17,#18,#E1,#23,#31,#88,#83,#33,#33,#37,#67,#66,#71,#FE,#E1,#33,#18,#88,#88,#11,#11,#76,#66,#17,#11,#F8,#E1,#11,#88,#88,#88,#88,#33,#27,#66,#71,#21,#FE,#E1,#88,#88,#88
db #88,#83,#20,#20,#17,#12,#22,#F8,#E1,#18,#88,#88,#88,#83,#02,#02,#21,#22,#22,#21,#13,#18,#88,#88,#88,#88,#11,#20,#02,#00,#22,#33,#11,#88,#88,#88,#88,#88,#88,#11,#11,#11,#11,#11,#88,#88,#88,#88
prgicnfnt1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Schriftarten
db #88,#88,#88,#88,#11,#11,#88,#88,#11,#88,#88,#88,#88,#88,#88,#81,#AA,#AA,#18,#81,#AA,#18,#88,#88,#88,#88,#88,#1A,#AA,#AA,#A1,#11,#AA,#A1,#11,#88,#88,#88,#88,#1A,#11,#AA,#A1,#FF,#1A,#AA,#A1,#F8
db #88,#88,#88,#11,#FF,#1A,#A1,#F8,#81,#AA,#1F,#F8,#88,#88,#88,#1F,#F8,#1A,#A1,#F8,#88,#11,#FF,#88,#88,#88,#88,#1F,#88,#1A,#A1,#F8,#81,#11,#18,#88,#88,#88,#88,#81,#88,#1A,#A1,#F8,#1A,#AA,#A1,#88
db #88,#88,#88,#1A,#18,#1A,#A1,#F1,#11,#AA,#AA,#18,#88,#88,#88,#1A,#1F,#1A,#1F,#F8,#FF,#1A,#AA,#1F,#88,#88,#81,#AA,#A1,#11,#11,#88,#88,#81,#AA,#1F,#88,#88,#81,#AA,#A1,#FA,#AA,#18,#88,#81,#A1,#FF
db #88,#88,#1A,#1A,#AA,#1A,#AA,#A1,#18,#81,#1F,#F8,#88,#88,#1A,#1A,#AA,#1F,#AA,#AA,#A1,#11,#FF,#88,#88,#81,#A1,#81,#AA,#A1,#1A,#AA,#AA,#1F,#F8,#88,#88,#81,#A1,#81,#AA,#A1,#F1,#11,#11,#FF,#88,#88
db #88,#1A,#18,#80,#1A,#AA,#18,#FF,#FF,#88,#88,#88,#88,#1A,#11,#11,#1A,#AA,#1F,#88,#88,#88,#88,#88,#81,#AA,#AA,#AA,#AA,#AA,#A1,#88,#88,#88,#88,#88,#81,#A1,#11,#11,#11,#AA,#A1,#F8,#88,#88,#88,#88
db #1A,#1F,#FF,#FF,#FF,#1A,#AA,#18,#88,#88,#88,#88,#1A,#1F,#88,#88,#88,#1A,#AA,#1F,#88,#88,#88,#88,#11,#FF,#88,#88,#88,#81,#11,#1F,#88,#88,#88,#88,#8F,#F8,#88,#88,#88,#88,#FF,#FF,#88,#88,#88,#88
prgicnlnk1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Desktop und Menu Links
db #12,#22,#22,#22,#22,#22,#22,#22,#22,#22,#22,#22,#1F,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#1F,#FF,#F1,#1F,#FF,#FF,#FF,#F2,#00,#00,#2F,#F2,#1F,#FF,#F1,#81,#FF,#FF,#FF,#F0,#12,#11,#0F,#F2
db #1F,#FF,#F1,#88,#1F,#FF,#FF,#F0,#21,#11,#0F,#F2,#1F,#FF,#F1,#88,#81,#FF,#FF,#F0,#11,#11,#0F,#F2,#1F,#FF,#F1,#88,#88,#1F,#FF,#F0,#11,#11,#0F,#F2,#1F,#FF,#F1,#88,#81,#FF,#FF,#F2,#00,#00,#2F,#F2
db #1F,#FF,#F1,#81,#88,#1F,#FF,#FF,#FF,#FF,#FF,#F2,#1F,#FF,#F1,#1F,#18,#1F,#F1,#1F,#1F,#11,#F1,#12,#66,#66,#66,#66,#F1,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#61,#61,#16,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2
db #66,#66,#66,#66,#66,#66,#66,#F2,#00,#00,#2F,#F2,#6F,#F0,#F0,#61,#16,#16,#16,#F0,#12,#11,#0F,#F2,#6F,#0F,#FF,#66,#66,#66,#66,#F0,#21,#11,#0F,#F2,#66,#66,#66,#61,#11,#61,#16,#F0,#11,#11,#0F,#F2
db #61,#16,#11,#66,#66,#66,#66,#F0,#11,#11,#0F,#F2,#66,#66,#66,#61,#16,#11,#16,#F2,#00,#00,#2F,#F2,#61,#61,#11,#66,#66,#66,#66,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#FF,#FF,#F1,#1F,#1F,#11,#F1,#12
db #61,#11,#61,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#61,#16,#16,#16,#FF,#FF,#FF,#FF,#FF,#FF,#FF,#F2,#66,#66,#66,#66,#11,#11,#11,#11,#11,#11,#11,#12
prgicnkey1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Tastatur
db #88,#88,#88,#88,#88,#88,#88,#88,#88,#81,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#16,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#81,#81,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#18
db #88,#88,#81,#18,#11,#81,#18,#11,#81,#18,#88,#18,#88,#81,#18,#11,#81,#18,#11,#81,#18,#11,#11,#18,#88,#18,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#81,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#18
db #16,#44,#44,#44,#44,#44,#44,#44,#44,#44,#44,#71,#14,#77,#77,#77,#77,#77,#77,#77,#77,#77,#77,#71,#14,#74,#61,#46,#14,#61,#46,#14,#61,#44,#61,#71,#14,#76,#61,#66,#16,#61,#66,#16,#61,#66,#61,#71
db #14,#71,#11,#11,#11,#11,#11,#11,#11,#11,#11,#71,#14,#74,#44,#61,#46,#14,#61,#46,#14,#44,#61,#71,#14,#76,#66,#61,#66,#16,#61,#66,#16,#66,#61,#71,#14,#71,#11,#11,#11,#11,#11,#11,#11,#11,#11,#71
db #14,#74,#41,#46,#14,#61,#46,#14,#61,#44,#61,#71,#14,#76,#61,#66,#16,#61,#66,#16,#61,#66,#61,#71,#14,#71,#11,#11,#11,#11,#11,#11,#11,#11,#11,#71,#14,#74,#44,#61,#46,#14,#44,#44,#46,#14,#61,#71
db #14,#76,#66,#61,#66,#16,#66,#66,#66,#16,#61,#71,#14,#71,#11,#11,#11,#11,#11,#11,#11,#11,#11,#71,#17,#67,#77,#77,#77,#77,#77,#77,#77,#77,#77,#71,#81,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#18
prgicnmou1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Maus
db #15,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#15,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#81,#55,#88,#85,#55,#55,#55,#58,#88,#88,#88,#88,#88,#11,#55,#58,#56,#66,#66,#51,#18,#88,#88,#88
db #88,#85,#58,#88,#85,#56,#66,#66,#51,#88,#88,#88,#88,#85,#88,#88,#88,#85,#11,#11,#11,#18,#88,#88,#88,#58,#88,#88,#85,#58,#86,#66,#66,#51,#88,#88,#85,#88,#88,#88,#58,#88,#88,#86,#86,#65,#18,#88
db #58,#88,#88,#85,#88,#58,#88,#88,#68,#66,#51,#88,#56,#88,#88,#58,#85,#88,#88,#88,#86,#66,#65,#18,#56,#68,#85,#88,#58,#88,#88,#88,#68,#66,#65,#18,#56,#66,#58,#88,#88,#88,#88,#88,#86,#66,#66,#51
db #58,#66,#66,#68,#88,#88,#88,#88,#68,#66,#66,#51,#85,#86,#66,#66,#88,#88,#88,#88,#86,#66,#66,#51,#88,#58,#66,#66,#88,#88,#88,#88,#66,#66,#66,#51,#88,#85,#86,#66,#68,#88,#88,#86,#86,#66,#66,#51
db #88,#88,#58,#86,#68,#88,#88,#88,#66,#66,#65,#51,#88,#88,#85,#86,#68,#88,#88,#86,#66,#66,#65,#51,#88,#88,#88,#58,#66,#88,#88,#68,#66,#66,#55,#18,#88,#88,#88,#85,#86,#88,#86,#86,#66,#65,#55,#18
db #88,#88,#88,#85,#86,#66,#66,#66,#65,#55,#51,#88,#88,#88,#88,#88,#58,#86,#66,#65,#55,#55,#18,#88,#88,#88,#88,#88,#85,#55,#55,#55,#55,#11,#88,#88,#88,#88,#88,#88,#88,#11,#11,#11,#11,#88,#88,#88
prgicndev1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Mass Storage Devices
db #88,#88,#88,#81,#11,#88,#88,#87,#76,#16,#66,#77,#88,#88,#88,#11,#11,#18,#88,#87,#76,#16,#66,#77,#88,#88,#81,#1E,#EE,#11,#88,#87,#77,#77,#77,#77,#88,#88,#1E,#EE,#EE,#EE,#18,#87,#77,#71,#77,#77
db #88,#81,#EE,#EE,#EE,#EE,#E1,#87,#77,#16,#17,#77,#88,#1E,#EE,#EE,#EE,#EE,#EE,#17,#77,#71,#77,#77,#81,#1E,#EE,#EE,#EE,#EE,#EE,#17,#7A,#AA,#AA,#77,#11,#EE,#EE,#EE,#3E,#8E,#8E,#E7,#7A,#88,#8A,#77
db #11,#EE,#EE,#E3,#13,#EE,#EE,#E7,#7A,#AA,#AA,#77,#11,#EE,#EE,#E8,#38,#E8,#E8,#E1,#11,#11,#11,#11,#31,#1E,#EE,#EE,#EE,#EE,#EE,#11,#11,#21,#88,#88,#13,#1E,#EE,#8E,#33,#33,#33,#11,#12,#32,#18,#88
db #81,#31,#EE,#EE,#EE,#33,#33,#33,#33,#23,#21,#88,#88,#13,#18,#E8,#E8,#E8,#33,#33,#33,#32,#31,#38,#88,#81,#31,#1E,#EE,#11,#11,#11,#33,#23,#21,#38,#88,#88,#13,#11,#11,#11,#11,#11,#32,#32,#13,#18
db #88,#88,#81,#31,#11,#13,#11,#31,#13,#21,#31,#88,#88,#88,#88,#13,#11,#32,#31,#13,#12,#13,#18,#88,#88,#88,#88,#81,#31,#13,#23,#11,#11,#31,#88,#88,#88,#88,#88,#88,#13,#11,#32,#31,#13,#18,#88,#88
db #88,#88,#88,#88,#81,#31,#13,#11,#31,#88,#88,#88,#88,#88,#88,#88,#88,#13,#11,#13,#18,#88,#88,#88,#88,#88,#88,#88,#88,#81,#33,#31,#88,#88,#88,#88,#88,#88,#88,#88,#88,#88,#11,#18,#88,#88,#88,#88
prgicnsys1 db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;System
db #88,#88,#88,#11,#11,#11,#11,#11,#11,#78,#88,#88,#88,#88,#81,#11,#11,#11,#11,#11,#17,#11,#88,#88,#88,#88,#11,#11,#11,#11,#11,#11,#71,#11,#88,#88,#88,#81,#67,#77,#77,#77,#77,#77,#11,#11,#88,#88
db #88,#81,#77,#11,#11,#11,#11,#76,#11,#11,#88,#88,#88,#81,#71,#21,#F2,#1F,#21,#16,#11,#11,#88,#88,#88,#81,#71,#11,#11,#11,#11,#16,#11,#11,#88,#88,#88,#81,#71,#2F,#21,#11,#11,#16,#11,#11,#88,#88
db #88,#81,#71,#F1,#11,#11,#11,#16,#11,#11,#88,#88,#88,#81,#71,#11,#11,#11,#11,#16,#11,#17,#88,#88,#88,#81,#77,#11,#11,#11,#11,#76,#11,#71,#88,#88,#88,#81,#76,#66,#66,#66,#66,#66,#17,#18,#88,#88
db #88,#81,#77,#77,#77,#77,#77,#77,#71,#87,#78,#88,#88,#88,#11,#11,#71,#17,#11,#11,#18,#88,#87,#78,#88,#88,#88,#87,#88,#78,#88,#88,#88,#88,#88,#87,#88,#13,#13,#31,#33,#11,#11,#21,#11,#11,#11,#88
db #88,#11,#11,#11,#11,#11,#11,#11,#11,#31,#31,#88,#81,#33,#33,#33,#33,#33,#33,#33,#13,#13,#13,#18,#81,#32,#82,#82,#82,#82,#82,#82,#11,#31,#31,#18,#13,#28,#28,#28,#28,#28,#28,#28,#31,#13,#13,#11
db #13,#82,#82,#88,#88,#82,#82,#82,#31,#31,#31,#31,#13,#33,#33,#33,#33,#33,#33,#33,#31,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#23,#23,#21,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11,#11

endif

prgicntim2 db 2,8,8,#33,#CC,#47,#A6,#8F,#97,#CB,#B5,#9E,#1F,#AD,#1F,#47,#A6,#33,#CC     ;Datum/Uhrzeit
prgicndsp2 db 2,8,8,#77,#EE,#BC,#D3,#E8,#F1,#D8,#F1,#F8,#F1,#F8,#F1,#BC,#D3,#77,#EE     ;Anzeige
prgicnfnt2 db 2,8,8,#30,#80,#43,#48,#96,#2C,#B4,#B5,#87,#3D,#B4,#B5,#F1,#F1,#77,#77     ;Schriftarten
prgicnlnk2 db 2,8,8,#F9,#FF,#DA,#FF,#CB,#F7,#CB,#7B,#CB,#3D,#CB,#7B,#DA,#3D,#F9,#F3     ;Desktop und Menu Links
prgicnkey2 db 2,8,8,#26,#4D,#2B,#46,#FF,#FF,#4D,#9B,#46,#9D,#FF,#FF,#26,#4D,#2B,#46     ;Tastatur
prgicnmou2 db 2,8,8,#10,#C0,#20,#20,#77,#10,#AF,#98,#AF,#88,#FF,#88,#FF,#88,#77,#00     ;Maus
prgicndev2 db 2,8,8,#AD,#3E,#AD,#3E,#FF,#FE,#FE,#FE,#ED,#F6,#FE,#FE,#8F,#3E,#8C,#36     ;Mass Storage Devices
prgicnsys2 db 2,8,8,#F0,#FE,#F0,#FE,#2D,#4F,#69,#5E,#6B,#DA,#2F,#CB,#F7,#F0,#F7,#F0     ;System

prgtitkey db "Keyboard",0
prgtitmou db "Mouse",0
prgtitfnt db "Font",0
prgtitprt db "Printer",0
prgtitsys db "System",0
prgtitlnk db "Desktop and Startmenu Links",0

prgbuttxt1 db "Ok",0
prgbuttxt2 db "Cancel",0
prgbuttxt3 db "Apply",0
prgbuttxt4 db "Load",0
prgbuttxt5 db "Save",0


;### MASS STORAGE DEVICES ######################################################

prgtitdev   db "Mass Storage Devices",0
prgtxtdev1  db "Drives",0
prgtxtdev2  db "Settings",0
prgtxtdev3  db "Del",0
prgtxtdev4  db "Add",0
prgtxtdev5  db "Name",0

prgtxtdev6  db "Floppy disk",0
prgtxtdev7  db "IDE device",0
prgtxtdeva  db "SD/MMC card reader",0
prgtxtdevb  db "SCSI/USB device",0

prgtxtdev8  db "Removeable medium",0
prgtxtdev9  db "Specifics",0
prgtxtdeve  db "Drive letter",0
prgtxtdevf  db "Double step",0
prgtabdevga db "A",0,"B",0,"C",0,"D",0,"E",0,"F",0,"G",0,"H",0,"I",0,"J",0,"K",0,"L",0,"M",0
            db "N",0,"O",0,"P",0,"Q",0,"R",0,"S",0,"T",0,"U",0,"V",0,"W",0,"X",0,"Y",0,"Z",0

prgtabdevaa db "Drive A",0              ;Geräteauswahl FDC
prgtabdevab db "Drive B",0
if computer_mode=0
prgtabdevac db "HxC SD Card at A",0
prgtabdevad db "HxC SD Card at B",0
elseif computer_mode=1
prgtabdevac db "Drive C",0
prgtabdevad db "Drive D",0
elseif computer_mode=2
prgtabdevac db "HxC SD Card at A",0
prgtabdevad db "HxC SD Card at B",0
elseif computer_mode=3
prgtabdevac db "Drive C",0
prgtabdevad db "Drive D",0
elseif computer_mode=4
prgtabdevac db "?C",0
prgtabdevad db "?D",0
elseif computer_mode=5
prgtabdevac db "?C",0
prgtabdevad db "?D",0
elseif computer_mode=6
prgtabdevac db "?C",0
prgtabdevad db "?D",0
endif

prgtabdevba db "Master",0               ;Geräteauswahl IDE
prgtabdevbb db "Slave",0

prgtabdevca db "Slot 1",0               ;Geräteauswahl SD
prgtabdevcb db "Slot 2",0

prgtabdevda db "Device 0",0             ;Geräteauswahl USB/SCSI
prgtabdevdb db "Device 1",0
prgtabdevdc db "Device 2",0
prgtabdevdd db "Device 3",0
prgtabdevde db "Device 4",0
prgtabdevdf db "Device 5",0
prgtabdevdg db "Device 6",0
prgtabdevdh db "Device 7",0

prgtabdevxa db "Head 0",0               ;Sub-Auswahl FDC
prgtabdevxb db "Head 1",0

prgtabdevya db "Not partitioned",0      ;Sub-Auswahl IDE/USB/SCSI/SD
prgtabdevyb db "Primary partition 1",0
prgtabdevyc db "Primary partition 2",0
prgtabdevyd db "Primary partition 3",0
prgtabdevye db "Primary partition 4",0


;### KEYBOARD #################################################################

prgk_1txt db "1",0
prgk_2txt db "2",0
prgk_3txt db "3",0
prgk_4txt db "4",0
prgk_5txt db "5",0
prgk_6txt db "6",0
prgk_7txt db "7",0
prgk_8txt db "8",0
prgk_9txt db "9",0
prgk_0txt db "0",0
prgk_qtxt db "Q",0
prgk_wtxt db "W",0
prgk_etxt db "E",0
prgk_rtxt db "R",0
prgk_ttxt db "T",0
prgk_ytxt db "Y",0
prgk_utxt db "U",0
prgk_itxt db "I",0
prgk_otxt db "O",0
prgk_ptxt db "P",0
prgk_atxt db "A",0
prgk_stxt db "S",0
prgk_dtxt db "D",0
prgk_ftxt db "F",0
prgk_gtxt db "G",0
prgk_htxt db "H",0
prgk_jtxt db "J",0
prgk_ktxt db "K",0
prgk_ltxt db "L",0
prgk_ztxt db "Z",0
prgk_xtxt db "X",0
prgk_ctxt db "C",0
prgk_vtxt db "V",0
prgk_btxt db "B",0
prgk_ntxt db "N",0
prgk_mtxt db "M",0
prgksptxt db 0
prgkf7txt db "f7",0
prgkf8txt db "f8",0
prgkf9txt db "f9",0
prgkf4txt db "f4",0
prgkf5txt db "f5",0
prgkf6txt db "f6",0
prgkf1txt db "f1",0
prgkf2txt db "f2",0
prgkf3txt db "f3",0
prgkf0txt db "f0",0
prgkfdtxt db "f.",0
prgkm1txt db "f1",0
prgkm2txt db "f2",0
prgkm3txt db "f3",0
prgkm4txt db "f4",0
prgkm5txt db "f5",0
prgkm6txt db "Sel",0
prgkm7txt db "Stp",0
prgkm8txt db "Hom",0
prgkm9txt db "Ins",0
prgkmatxt db "Hld",0
prgkkotxt db ",",0
prgkputxt db ".",0
prgksltxt db "/",0
prgksttxt db "-",0

if computer_mode=0
keyobjtxty  equ 4
keyobjtxts  db "CPC",0
prgkdatxt   db "^",0
prgkattxt   db "@",0
prgkoptxt   db "[",0
prgkdotxt   db ":",0
prgksetxt   db ";",0
prgkcotxt   db "]",0
prgkbstxt   db "\",0
elseif computer_mode=1
keyobjtxty  equ 4
keyobjtxts  db "MSX",0
prgkdatxt   db "=",0
prgkattxt   db "[",0
prgkoptxt   db "]",0
prgkdotxt   db ";",0
prgksetxt   db "'",0
prgkcotxt   db "`",0
prgkbstxt   db 129,0
prgkbstxt1  db "\",0
elseif computer_mode=2
keyobjtxty  equ 4
keyobjtxts  db "PCW",0
prgkdatxt   db "=",0
prgkattxt   db "[",0
prgkoptxt   db "]",0
prgkdotxt   db ";",0
prgksetxt   db "|",0
prgkcotxt   db "#",0
prgkbstxt   db "\",0
elseif computer_mode=3
keyobjtxty  equ 4
keyobjtxts db " EP",0
prgkdatxt   db "^",0
prgkattxt   db "@",0
prgkoptxt   db "[",0
prgkdotxt   db ":",0
prgksetxt   db ";",0
prgkcotxt   db "]",0
prgkbstxt   db "\",0
elseif computer_mode=4
keyobjtxty  equ 48
keyobjtxts  db "SVM",0
prgkeqtxt   db "=",0
prgkaptxt   db "'",0
prgkoptxt   db "[",0
prgkcotxt   db "]",0
prgksetxt   db ";",0
prgkgatxt   db "`",0
prgkbstxt   db "\",0
elseif computer_mode=5
keyobjtxty  equ 4
keyobjtxts  db "NC",0
prgkeqtxt   db "=",0
prgkoptxt   db "[",0
prgkcotxt   db "]",0
prgksetxt   db ";",0
prgkaptxt   db "'",0
prgknstxt   db "#",0
prgkbstxt   db "\",0
elseif computer_mode=6
keyobjtxty  equ 4
keyobjtxts  db "NXT",0
prgksetxt   db ";",0
prgkqutxt   db 34,0
endif

keyobjtxt1 db "Definitions",0
keyobjtxt2 db "Speed",0
keyobjtxt3 db "Buttons",0
keyobjtxta db "Key",0
keyobjtxtb db "Normal",0
keyobjtxtc db "Shift",0
keyobjtxtd db "Control",0
keyobjtxte db "Alt",0
keyobjtxtf db "   ",0

keyobjtxtk db "Delay",0
keyobjtxtl db "Repeat",0
keyobjtxtm db "Test",0
keyobjtxtq db "00",0
keyobjtxtr db "99",0

;### MAUS #####################################################################

mouobjtxt1 db "Joystick Settings",0
mouobjtxt2 db "Mouse Settings",0
mouobjtxt3 db "Button Settings",0

mouobjtxta db "Accel.",0
mouobjtxtb db "Speed",0
mouobjtxte db "00",0
mouobjtxtf db "00",0
mouobjtxth db "00",0
mouobjtxti db "Swap left/right button",0
mouobjtxtj db "DblClk",0
mouobjtxtl db "00",0
mouobjtxtm db "Wheel",0
mouobjtxto db "00",0

;### SYSTEM ###################################################################

prgtxtsys0a db "General",0
prgtxtsys0b db "File types",0

prgtxtsys1  db "System info",0
prgtxtsys1a db "Platform",0
prgtxtsys1b db "Memory",0
prgtxtsys1d db "Version",0

if computer_mode=0
prgtxtsys2a db "CPC 464",0
prgtxtsys2b db "CPC 664",0
prgtxtsys2c db "CPC 6128",0
prgtxtsys2d db "CPC 464+",0
prgtxtsys2e db "CPC 6128+",0

elseif computer_mode=1
prgtxtsys2r db "MSX1",0
prgtxtsys2m db "MSX2",0
prgtxtsys2n db "MSX2+",0
prgtxtsys2o db "MSX turboR",0

elseif computer_mode=2
prgtxtsys2p db "PCW 8xxx",0
prgtxtsys2q db "PCW 9xxx",0

elseif computer_mode=3
prgtxtsys2h db "Enterprise",0

elseif computer_mode=4
prgtxtsys2i  db "SymbOS VM "
prgtxtsys2i1 db "xx.xx",0

elseif computer_mode=5
prgtxtsys2j db "NC 100",0
prgtxtsys2k db "NC 150",0
prgtxtsys2l db "NC 200",0

elseif computer_mode=6
prgtxtsys2s db "Spectrum Next",0

endif
prgtxtsys2f db "[Unknown]",0

prgtxtsys1y ds 30
prgtxtsys20 ds 22


prgtxtsys2g db 0

prgtxtsys3  db "Miscellaneous",0
prgtxtsys3a db "System path",0

prgtxtsys3b db "SymbOS Extended Desktop",0
prgtxtsys3d db "(requires a reboot)",0

prgtxtsys3j db "Use maximum memory for",0
prgtxtsys3k db "file selection dialogues",0

prgtxtsys3e db "Autoexec",0
prgtxtsys3h db "Boot drive",0

prgtxtlnk9a db "Extension(s)",0
prgtxtlnk9b db "Application path",0

sysentext   ds 20*16

;### LINK #####################################################################

prgtxtlnk2a db "Desktop",0
prgtxtlnk2b db "Startmenu",0
prgtxtlnk2c db "Taskbar",0
prgtxtlnk3a db "Up",0
prgtxtlnk3b db "Down",0
prgtxtlnk3c db "Del",0
prgtxtlnk3d db "Add",0
prgtxtlnk4  db "Edit entry",0
prgtxtlnk5a db "Path",0
prgtxtlnk5c db "Browse...",0
prgtxtlnk6a db "Name",0
prgtxtlnk7a db "Icon",0
prgtxtlnk7b db "Use file icon",0
prgtxtlnk7c db "Select icon...",0
prgtxtlnk8a db "XPos",0
prgtxtlnk8b db "YPos",0

;### FONT #####################################################################

prgtxtfnt0a db "Font appearance",0
prgtxtfnt0b db "Load new font",0

prgtxtfnt1a db " !",34,"#$%&'()*+,-./",0
prgtxtfnt1b db "0123456789:;<=>?",0
prgtxtfnt1c db "@ABCDEFGHIJKLMNO",0
prgtxtfnt1d db "PQRSTUVWXYZ[\]^_",0
prgtxtfnt1e db "`abcdefghijklmno",0
prgtxtfnt1f db "pqrstuvwxyz{|}~",0
prgtxtfnt1g db "Little Peter is playing",0
prgtxtfnt1h db "with the ball outside",0

;### EXTENDED!!! ##############################################################

lnkcfgdat   db 0        ;ab hier Texte, Pfade, Icons und Font im verlängerten Speicherbereich

;==============================================================================
;### TRANSFER-TEIL ############################################################
;==============================================================================

prgtrnbeg
;### PRGPRZS -> Stack für Programm-Prozess
        ds 128
prgstk  ds 6*2
        dw prgprz
prgprzn db 0            ;Nummer des Taschenrechner-Prozesses
prgmsgb ds 14

;### HAUPT-FENSTER ############################################################

prgwindat dw #7701,0,20,20,192,90,0,0,192,90,32,24,10000,10000,prgicnsml,prgwintit,prgwinsta,prgwinmen,prgwingrp,0,0:ds 136+14

prgwinmen dw 2, 1+4,prgwinmentx1,prgwinmen1,0, 1+4,prgwinmentx2,prgwinmen2,0
prgwinmen1 dw 5, 1,prgwinmen1tx1,cfglod,0,            1,prgwinmen1tx2,cfgsav,0
prgwinmen1a dw   1,prgwinmen1tx3,cfgasv,0, 1+8,0,0,0, 1,prgwinmen1tx4,prgend,0
prgwinmen2 dw 3, 1,prgwinmen2tx1,hlpopn,0, 1+8,0,0,0, 1,prgwinmen2tx2,prginf,0

prgwingrp db 9,0:dw prgicnobj,0,0,0,0,0,0
prgicnobj
dw 00,        0,0+64      ,0,0,10000,10000,0
dw 16,255*256+9,prgicnspr4,000,001,48,40,0  ;Date and Time
dw 12,255*256+9,prgicnspr3,048,001,48,40,0  ;Display
dw 20,255*256+9,prgicnspr5,096,001,48,40,0  ;Fonts
dw 32,255*256+9,prgicnspr8,144,001,48,40,0  ;Desktop & Menu Links
dw 04,255*256+9,prgicnspr1,000,049,48,40,0  ;Keyboard
dw 08,255*256+9,prgicnspr2,048,049,48,40,0  ;Mouse
dw 28,255*256+9,prgicnspr7,096,049,48,40,0  ;Mass Storage
dw 24,255*256+9,prgicnspr6,144,049,48,40,0  ;System

if computer_mode=2      ;PCW -> 4farb icons
prgicnspr1 dw prgicnkey1,prgicnkey1a,0,          128+4
prgicnspr2 dw prgicnmou1,prgicnmou2a,0,          128+4
prgicnspr3 dw prgicndsp1,prgicndsp3a,0,          128+4
prgicnspr4 dw prgicntim1,prgicntim4a,prgicntim4b,128+4
prgicnspr5 dw prgicnfnt1,prgicnfnt5a,0,          128+4
prgicnspr6 dw prgicnsys1,prgicnsys6a,0,          128+4
prgicnspr7 dw prgicndev1,prgicndev7a,prgicndev7b,128+4
prgicnspr8 dw prgicnlnk1,prgicnlnk8a,prgicnlnk8b,128+4
else        ;sonstige -> 16farb icons
prgicnspr1 dw prgicnkey1,prgicnkey1a,0,          128+4+16
prgicnspr2 dw prgicnmou1,prgicnmou2a,0,          128+4+16
prgicnspr3 dw prgicndsp1,prgicndsp3a,0,          128+4+16
prgicnspr4 dw prgicntim1,prgicntim4a,prgicntim4b,128+4+16
prgicnspr5 dw prgicnfnt1,prgicnfnt5a,0,          128+4+16
prgicnspr6 dw prgicnsys1,prgicnsys6a,0,          128+4+16
prgicnspr7 dw prgicndev1,prgicndev7a,prgicndev7b,128+4+16
prgicnspr8 dw prgicnlnk1,prgicnlnk8a,prgicnlnk8b,128+4+16
endif

;### MOUSE ####################################################################

prgwinmou  dw #1501,0,80,10,128,131,0,0,128,131,128,131,128,131, prgicnmou2,prgtitmou,0,0,prggrpmou,0,0:ds 136+14
prggrpmou db 23,0:dw prgdatmou,0,0,3*256+2,0,0,0
prgdatmou
dw 00,     255*256+0,2, 0,0,1000,1000,0                 ;00=Hintergrund
dw mouoky, 255*256+16,prgbuttxt1,  23,116,32,12,0       ;01="Ok"-Button
dw moucnc, 255*256+16,prgbuttxt2,  58,116,32,12,0       ;02="Cancel"-Button
dw mouapl, 255*256+16,prgbuttxt3,  93,116,32,12,0       ;03="Apply"-Button
dw 00,     255*256+3, mouobjdat1,  0, 1,128,38,0        ;04=Rahmen Joystick-Maus
dw 00,     255*256+1, mouobjdata,  8, 12,30,8,0         ;05=Speed  "Accel" Text
dw 00,     255*256+1, mouobjdatb,  8, 23,30,8,0         ;06=Speed  "Speed" Text
dw mouslda,255*256+24,mouobjdatc, 36, 12,70,8,0         ;07=Speed  "Accel" Slider
dw mousldb,255*256+24,mouobjdatd, 36, 23,70,8,0         ;08=Speed  "Speed" Slider
dw 00,     255*256+1, mouobjdate,108, 12,12,8,0         ;09=Speed  "Accel" Wert
dw 00,     255*256+1, mouobjdatf,108, 23,12,8,0         ;10=Speed  "Speed" Wert
dw 00,     255*256+3, mouobjdat2, 0,39,128,38,0         ;11=Rahmen Proportional-Maus
dw 00,     255*256+1, mouobjdatb,  8, 50,30,8,0         ;12=Propor "Speed" Text
dw 00,     255*256+1, mouobjdatm,  8, 61,30,8,0         ;13=Propor "Wheel" Text
dw mousldc,255*256+24,mouobjdatg, 36, 50,70,8,0         ;14=Propor "Speed" Slider
dw mouslde,255*256+24,mouobjdatn, 36, 61,70,8,0         ;15=Propor "Wheel" Slider
dw 00,     255*256+1, mouobjdath,108, 50,12,8,0         ;16=Propor "Speed" Wert
dw 00,     255*256+1, mouobjdato,108, 61,12,8,0         ;17=Propor "Wheel" Wert
dw 00,     255*256+3, mouobjdat3,  0,77,128,38,0        ;18=Rahmen Button
dw 00,     255*256+17,mouobjdati,  8, 88,112,8,0        ;19=Button "Swap" Checkbox
dw 00,     255*256+1, mouobjdatj,  8, 99,30,8,0         ;20=Button "Dclk" Text
dw mousldd,255*256+24,mouobjdatk, 36, 99,70,8,0         ;21=Button "Dclk" Slider
dw 00,     255*256+1, mouobjdatl,108, 99,12,8,0         ;22=Button "Dclk" Wert

mouobjdat1 dw mouobjtxt1,2+4
mouobjdat2 dw mouobjtxt2,2+4
mouobjdat3 dw mouobjtxt3,2+4
mouobjdata dw mouobjtxta,2+4
mouobjdatb dw mouobjtxtb,2+4
mouobjdatc dw 1,0,98,256*255+1
mouobjdatd dw 1,0,98,256*255+1
mouobjdate dw mouobjtxte:db 0+4+128,2
mouobjdatf dw mouobjtxtf:db 0+4+128,2
mouobjdatg dw 1,0,98,256*255+1
mouobjdath dw mouobjtxth:db 0+4+128,2
mouobjdati dw mouobjdatis,mouobjtxti,2+4
mouobjdatis db 0
mouobjdatj dw mouobjtxtj,2+4
mouobjdatk dw 1,0,47,256*255+1
mouobjdatl dw mouobjtxtl:db 0+4+128,2
mouobjdatm dw mouobjtxtm,2+4
mouobjdatn dw 1,0,9,256*255+1
mouobjdato dw mouobjtxto:db 0+4+128,2

;### KEYBOARD #################################################################

prgwinkey  dw #1501,0,40,16,252,152,0,0,252,152,252,152,252,152,prgicnkey2,prgtitkey,0,0,prggrpkey,0,0:ds 136+14
prggrpkey db prgdatkeyn,0:dw prgdatkey,0,0,3*256+2,0,0,0

prgdatkey
dw 00,255*256+0,2, 0,0,1000,1000,0              ;00=Hintergrund
dw keyoky,255*256+16,prgbuttxt1,149,137,32,12,0 ;01="Ok"-Button
dw keycnc,255*256+16,prgbuttxt2,183,137,32,12,0 ;02="Cancel"-Button
dw keyapl,255*256+16,prgbuttxt3,217,137,32,12,0 ;03="Apply"-Button
dw keylod,255*256+16,prgbuttxt4,  4,137,32,12,0 ;04="Load"-Button
dw keysav,255*256+16,prgbuttxt5, 38,137,32,12,0 ;05="Save"-Button

if computer_mode=0                                                                  ;***CPC***

dw 0  ,255*256+2 ,3+4+64+48,  3,16,12,12,0      ;"ESC"      * Reihe 1
dw 164,255*256+16,prgk_1txt, 16,16,12,12,0      ;"1"
dw 165,255*256+16,prgk_2txt, 29,16,12,12,0      ;"2"
dw 157,255*256+16,prgk_3txt, 42,16,12,12,0      ;"3"
dw 156,255*256+16,prgk_4txt, 55,16,12,12,0      ;"4"
dw 149,255*256+16,prgk_5txt, 68,16,12,12,0      ;"5"
dw 148,255*256+16,prgk_6txt, 81,16,12,12,0      ;"6"
dw 141,255*256+16,prgk_7txt, 94,16,12,12,0      ;"7"
dw 140,255*256+16,prgk_8txt,107,16,12,12,0      ;"8"
dw 133,255*256+16,prgk_9txt,120,16,12,12,0      ;"9"
dw 132,255*256+16,prgk_0txt,133,16,12,12,0      ;"0"
dw 125,255*256+16,prgksttxt,146,16,12,12,0      ;"-"
dw 124,255*256+16,prgkdatxt,159,16,12,12,0      ;"^"
dw 0  ,255*256+2 ,3+4+64+48,172,16,12,12,0      ;"CLR"
dw 0  ,255*256+2 ,3+4+64+48,185,16,12,12,0      ;"DEL"
dw 110,255*256+16,prgkf7txt,198,16,12,12,0      ;"f7"
dw 111,255*256+16,prgkf8txt,211,16,12,12,0      ;"f8"
dw 103,255*256+16,prgkf9txt,224,16,12,12,0      ;"f9"

dw 0  ,255*256+2 ,3+4+64+48,  3,29,19,12,0      ;"TAB"      * Reihe 2
dw 167,255*256+16,prgk_qtxt, 23,29,12,12,0      ;"Q"
dw 159,255*256+16,prgk_wtxt, 36,29,12,12,0      ;"W"
dw 158,255*256+16,prgk_etxt, 49,29,12,12,0      ;"E"
dw 150,255*256+16,prgk_rtxt, 62,29,12,12,0      ;"R"
dw 151,255*256+16,prgk_ttxt, 75,29,12,12,0      ;"T"
dw 143,255*256+16,prgk_ytxt, 88,29,12,12,0      ;"Y"
dw 142,255*256+16,prgk_utxt,101,29,12,12,0      ;"U"
dw 135,255*256+16,prgk_itxt,114,29,12,12,0      ;"I"
dw 134,255*256+16,prgk_otxt,127,29,12,12,0      ;"O"
dw 127,255*256+16,prgk_ptxt,140,29,12,12,0      ;"P"
dw 126,255*256+16,prgkattxt,153,29,12,12,0      ;"@"
dw 117,255*256+16,prgkoptxt,166,29,12,12,0      ;"["
dw 0  ,255*256+2 ,3+4+64+48,182,29,15,25,0      ;"RET"
dw 120,255*256+16,prgkf4txt,198,29,12,12,0      ;"f4"
dw 112,255*256+16,prgkf5txt,211,29,12,12,0      ;"f5"
dw 104,255*256+16,prgkf6txt,224,29,12,12,0      ;"f6"

dw 0  ,255*256+2 ,3+4+64+48,  3,42,22,12,0      ;"CAPS"     * Reihe 3
dw 169,255*256+16,prgk_atxt, 26,42,12,12,0      ;"A"
dw 160,255*256+16,prgk_stxt, 39,42,12,12,0      ;"S"
dw 161,255*256+16,prgk_dtxt, 52,42,12,12,0      ;"D"
dw 153,255*256+16,prgk_ftxt, 65,42,12,12,0      ;"F"
dw 152,255*256+16,prgk_gtxt, 78,42,12,12,0      ;"G"
dw 144,255*256+16,prgk_htxt, 91,42,12,12,0      ;"H"
dw 145,255*256+16,prgk_jtxt,104,42,12,12,0      ;"J"
dw 137,255*256+16,prgk_ktxt,117,42,12,12,0      ;"K"
dw 136,255*256+16,prgk_ltxt,130,42,12,12,0      ;"L"
dw 129,255*256+16,prgkdotxt,143,42,12,12,0      ;"doppelpunkt"
dw 128,255*256+16,prgksetxt,156,42,12,12,0      ;";"
dw 119,255*256+16,prgkcotxt,169,42,12,12,0      ;"]"
dw 113,255*256+16,prgkf1txt,198,42,12,12,0      ;"f1"
dw 114,255*256+16,prgkf2txt,211,42,12,12,0      ;"f2"
dw 105,255*256+16,prgkf3txt,224,42,12,12,0      ;"f3"

dw 0  ,255*256+2 ,3+4+64+48,  3,55,25,12,0      ;"SHIFT"    * Reihe 4
dw 171,255*256+16,prgk_ztxt, 29,55,12,12,0      ;"Z"
dw 163,255*256+16,prgk_xtxt, 42,55,12,12,0      ;"X"
dw 162,255*256+16,prgk_ctxt, 55,55,12,12,0      ;"C"
dw 155,255*256+16,prgk_vtxt, 68,55,12,12,0      ;"V"
dw 154,255*256+16,prgk_btxt, 81,55,12,12,0      ;"B"
dw 146,255*256+16,prgk_ntxt, 94,55,12,12,0      ;"N"
dw 138,255*256+16,prgk_mtxt,107,55,12,12,0      ;"M"
dw 139,255*256+16,prgkkotxt,120,55,12,12,0      ;","
dw 131,255*256+16,prgkputxt,133,55,12,12,0      ;"."
dw 130,255*256+16,prgksltxt,146,55,12,12,0      ;"/"
dw 122,255*256+16,prgkbstxt,159,55,12,12,0      ;"\"
dw 0  ,255*256+2 ,3+4+64+48,172,55,25,12,0      ;"SHIFT"
dw 115,255*256+16,prgkf0txt,198,55,12,12,0      ;"f0"
dw 0  ,255*256+2 ,3+4+64+48,211,55,12,12,0      ;"rauf"
dw 107,255*256+16,prgkfdtxt,224,55,12,12,0      ;"f."

dw 0  ,255*256+2 ,3+4+64+48, 3,68, 25,12,0      ;"CTRL"     * Reihe 5
dw 0  ,255*256+2 ,3+4+64+48,29,68, 20,12,0      ;"ALT"
dw 0  ,255*256+2 ,3+4+64+48,50,68,103,12,0      ;"SPACE"
dw 0  ,255*256+2 ,3+4+64+48,154,68,43,12,0      ;"ENTER"
dw 0  ,255*256+2 ,3+4+64+48,198,68,12,12,0      ;"links" 
dw 0  ,255*256+2 ,3+4+64+48,211,68,12,12,0      ;"runter"
dw 0  ,255*256+2 ,3+4+64+48,224,68,12,12,0      ;"rechts"

elseif computer_mode=1                                                              ;***MSX***

dw 113,255*256+16,prgkm1txt,  3, 3,15,12,0      ;"f1"       * Reihe 0
dw 114,255*256+16,prgkm2txt, 19, 3,15,12,0      ;"f2"
dw 105,255*256+16,prgkm3txt, 35, 3,15,12,0      ;"f3"
dw 120,255*256+16,prgkm4txt, 51, 3,15,12,0      ;"f4"
dw 112,255*256+16,prgkm5txt, 67, 3,15,12,0      ;"f5"
dw 104,255*256+16,prgkm6txt, 88, 3,21,12,0      ;"sel/f6"
dw 110,255*256+16,prgkm7txt,110, 3,21,12,0      ;"stp/f7"
dw 111,255*256+16,prgkm8txt,132, 3,21,12,0      ;"hom/f8"
dw 103,255*256+16,prgkm9txt,154, 3,21,12,0      ;"ins/f9"
dw 0  ,255*256+2 ,3+4+64+48,176, 3,21,12,0      ;"del"

dw 0  ,255*256+2 ,3+4+64+48,  3,16,12,12,0      ;"ESC"      * Reihe 1
dw 164,255*256+16,prgk_1txt, 16,16,12,12,0      ;"1"
dw 165,255*256+16,prgk_2txt, 29,16,12,12,0      ;"2"
dw 157,255*256+16,prgk_3txt, 42,16,12,12,0      ;"3"
dw 156,255*256+16,prgk_4txt, 55,16,12,12,0      ;"4"
dw 149,255*256+16,prgk_5txt, 68,16,12,12,0      ;"5"
dw 148,255*256+16,prgk_6txt, 81,16,12,12,0      ;"6"
dw 141,255*256+16,prgk_7txt, 94,16,12,12,0      ;"7"
dw 140,255*256+16,prgk_8txt,107,16,12,12,0      ;"8"
dw 133,255*256+16,prgk_9txt,120,16,12,12,0      ;"9"
dw 132,255*256+16,prgk_0txt,133,16,12,12,0      ;"0"
dw 125,255*256+16,prgksttxt,146,16,12,12,0      ;"-"
dw 124,255*256+16,prgkdatxt,159,16,12,12,0      ;"^"
dw 107,255*256+16,prgkbstxt1,172,16,12,12,0     ;"CLR"
dw 0  ,255*256+2 ,3+4+64+48,185,16,12,12,0      ;"DEL"

dw 0  ,255*256+2 ,3+4+64+48,  3,29,19,12,0      ;"TAB"      * Reihe 2
dw 167,255*256+16,prgk_qtxt, 23,29,12,12,0      ;"Q"
dw 159,255*256+16,prgk_wtxt, 36,29,12,12,0      ;"W"
dw 158,255*256+16,prgk_etxt, 49,29,12,12,0      ;"E"
dw 150,255*256+16,prgk_rtxt, 62,29,12,12,0      ;"R"
dw 151,255*256+16,prgk_ttxt, 75,29,12,12,0      ;"T"
dw 143,255*256+16,prgk_ytxt, 88,29,12,12,0      ;"Y"
dw 142,255*256+16,prgk_utxt,101,29,12,12,0      ;"U"
dw 135,255*256+16,prgk_itxt,114,29,12,12,0      ;"I"
dw 134,255*256+16,prgk_otxt,127,29,12,12,0      ;"O"
dw 127,255*256+16,prgk_ptxt,140,29,12,12,0      ;"P"
dw 126,255*256+16,prgkattxt,153,29,12,12,0      ;"@"
dw 117,255*256+16,prgkoptxt,166,29,12,12,0      ;"["
dw 0  ,255*256+2 ,3+4+64+48,182,29,15,25,0      ;"RET"

dw 0  ,255*256+2 ,3+4+64+48,  3,42,22,12,0      ;"CAPS"     * Reihe 3
dw 169,255*256+16,prgk_atxt, 26,42,12,12,0      ;"A"
dw 160,255*256+16,prgk_stxt, 39,42,12,12,0      ;"S"
dw 161,255*256+16,prgk_dtxt, 52,42,12,12,0      ;"D"
dw 153,255*256+16,prgk_ftxt, 65,42,12,12,0      ;"F"
dw 152,255*256+16,prgk_gtxt, 78,42,12,12,0      ;"G"
dw 144,255*256+16,prgk_htxt, 91,42,12,12,0      ;"H"
dw 145,255*256+16,prgk_jtxt,104,42,12,12,0      ;"J"
dw 137,255*256+16,prgk_ktxt,117,42,12,12,0      ;"K"
dw 136,255*256+16,prgk_ltxt,130,42,12,12,0      ;"L"
dw 129,255*256+16,prgkdotxt,143,42,12,12,0      ;"doppelpunkt"
dw 128,255*256+16,prgksetxt,156,42,12,12,0      ;";"
dw 119,255*256+16,prgkcotxt,169,42,12,12,0      ;"]"

dw 0  ,255*256+2 ,3+4+64+48,  3,55,25,12,0      ;"SHIFT"    * Reihe 4
dw 171,255*256+16,prgk_ztxt, 29,55,12,12,0      ;"Z"
dw 163,255*256+16,prgk_xtxt, 42,55,12,12,0      ;"X"
dw 162,255*256+16,prgk_ctxt, 55,55,12,12,0      ;"C"
dw 155,255*256+16,prgk_vtxt, 68,55,12,12,0      ;"V"
dw 154,255*256+16,prgk_btxt, 81,55,12,12,0      ;"B"
dw 146,255*256+16,prgk_ntxt, 94,55,12,12,0      ;"N"
dw 138,255*256+16,prgk_mtxt,107,55,12,12,0      ;"M"
dw 139,255*256+16,prgkkotxt,120,55,12,12,0      ;","
dw 131,255*256+16,prgkputxt,133,55,12,12,0      ;"."
dw 130,255*256+16,prgksltxt,146,55,12,12,0      ;"/"
dw 122,255*256+16,prgkbstxt,159,55,12,12,0      ;"\"
dw 0  ,255*256+2 ,3+4+64+48,172,55,25,12,0      ;"SHIFT"
dw 0  ,255*256+2 ,3+4+64+48,198,55,12,25,0      ;"links"
dw 0  ,255*256+2 ,3+4+64+48,211,55,12,12,0      ;"rauf"
dw 0  ,255*256+2 ,3+4+64+48,224,55,12,25,0      ;"rechts"

dw 0  ,255*256+2 ,3+4+64+48,  3,68, 25,12,0     ;"CONTROL"  * Reihe 5
dw 0  ,255*256+2 ,3+4+64+48, 29,68, 20,12,0     ;"ALT"
dw 0  ,255*256+2 ,3+4+64+48, 50,68,103,12,0     ;"SPACE"
dw 0  ,255*256+2 ,3+4+64+48,154,68, 43,12,0     ;"ENTER"
dw 0  ,255*256+2 ,3+4+64+48,211,68, 12,12,0     ;"runter"

elseif computer_mode=2                                                              ;***PCW***

dw 0  ,255*256+2 ,3+4+64+48,  3,16,12,12,0      ;"ESC"      * Reihe 1
dw 164,255*256+16,prgk_1txt, 16,16,12,12,0      ;"1"
dw 165,255*256+16,prgk_2txt, 29,16,12,12,0      ;"2"
dw 157,255*256+16,prgk_3txt, 42,16,12,12,0      ;"3"
dw 156,255*256+16,prgk_4txt, 55,16,12,12,0      ;"4"
dw 149,255*256+16,prgk_5txt, 68,16,12,12,0      ;"5"
dw 148,255*256+16,prgk_6txt, 81,16,12,12,0      ;"6"
dw 141,255*256+16,prgk_7txt, 94,16,12,12,0      ;"7"
dw 140,255*256+16,prgk_8txt,107,16,12,12,0      ;"8"
dw 133,255*256+16,prgk_9txt,120,16,12,12,0      ;"9"
dw 132,255*256+16,prgk_0txt,133,16,12,12,0      ;"0"
dw 125,255*256+16,prgksttxt,146,16,12,12,0      ;"-"
dw 124,255*256+16,prgkdatxt,159,16,12,12,0      ;"^"
dw 0  ,255*256+2 ,3+4+64+48,172,16,12,12,0      ;"CLR"
dw 0  ,255*256+2 ,3+4+64+48,185,16,12,12,0      ;"DEL"
dw 112,255*256+16,prgkf5txt,198,16,12,12,0      ;"f5"
dw 0  ,255*256+2 ,3+4+64+48,211,16,12,12,0      ;
dw 0  ,255*256+2 ,3+4+64+48,224,16,12,12,0      ;
dw 0  ,255*256+2 ,3+4+64+48,237,16,12,12,0      ;

dw 0  ,255*256+2 ,3+4+64+48,  3,29,19,12,0      ;"TAB"      * Reihe 2
dw 167,255*256+16,prgk_qtxt, 23,29,12,12,0      ;"Q"
dw 159,255*256+16,prgk_wtxt, 36,29,12,12,0      ;"W"
dw 158,255*256+16,prgk_etxt, 49,29,12,12,0      ;"E"
dw 150,255*256+16,prgk_rtxt, 62,29,12,12,0      ;"R"
dw 151,255*256+16,prgk_ttxt, 75,29,12,12,0      ;"T"
dw 143,255*256+16,prgk_ytxt, 88,29,12,12,0      ;"Y"
dw 142,255*256+16,prgk_utxt,101,29,12,12,0      ;"U"
dw 135,255*256+16,prgk_itxt,114,29,12,12,0      ;"I"
dw 134,255*256+16,prgk_otxt,127,29,12,12,0      ;"O"
dw 127,255*256+16,prgk_ptxt,140,29,12,12,0      ;"P"
dw 126,255*256+16,prgkattxt,153,29,12,12,0      ;"@"
dw 117,255*256+16,prgkoptxt,166,29,12,12,0      ;"["
dw 0  ,255*256+2 ,3+4+64+48,182,29,15,25,0      ;"RET"
dw 120,255*256+16,prgkf4txt,198,29,12,12,0      ;"f4"
dw 0  ,255*256+2 ,3+4+64+48,211,29,12,12,0      ;
dw 0  ,255*256+2 ,3+4+64+48,224,29,12,12,0      ;
dw 0  ,255*256+2 ,3+4+64+48,237,29,12,12,0      ;

dw 0  ,255*256+2 ,3+4+64+48,  3,42,22,12,0      ;"CAPS"     * Reihe 3
dw 169,255*256+16,prgk_atxt, 26,42,12,12,0      ;"A"
dw 160,255*256+16,prgk_stxt, 39,42,12,12,0      ;"S"
dw 161,255*256+16,prgk_dtxt, 52,42,12,12,0      ;"D"
dw 153,255*256+16,prgk_ftxt, 65,42,12,12,0      ;"F"
dw 152,255*256+16,prgk_gtxt, 78,42,12,12,0      ;"G"
dw 144,255*256+16,prgk_htxt, 91,42,12,12,0      ;"H"
dw 145,255*256+16,prgk_jtxt,104,42,12,12,0      ;"J"
dw 137,255*256+16,prgk_ktxt,117,42,12,12,0      ;"K"
dw 136,255*256+16,prgk_ltxt,130,42,12,12,0      ;"L"
dw 129,255*256+16,prgkdotxt,143,42,12,12,0      ;"doppelpunkt"
dw 128,255*256+16,prgksetxt,156,42,12,12,0      ;";"
dw 119,255*256+16,prgkcotxt,169,42,12,12,0      ;"]"
dw 105,255*256+16,prgkf3txt,198,42,12,12,0      ;"f3"
dw 111,255*256+16,prgkf8txt,211,42,12,12,0      ;"f8"
dw 0  ,255*256+2 ,3+4+64+48,224,42,12,12,0      ;
dw 103,255*256+16,prgkf9txt,237,42,12,12,0      ;"f9"

dw 0  ,255*256+2 ,3+4+64+48,  3,55,25,12,0      ;"SHIFT"    * Reihe 4
dw 171,255*256+16,prgk_ztxt, 29,55,12,12,0      ;"Z"
dw 163,255*256+16,prgk_xtxt, 42,55,12,12,0      ;"X"
dw 162,255*256+16,prgk_ctxt, 55,55,12,12,0      ;"C"
dw 155,255*256+16,prgk_vtxt, 68,55,12,12,0      ;"V"
dw 154,255*256+16,prgk_btxt, 81,55,12,12,0      ;"B"
dw 146,255*256+16,prgk_ntxt, 94,55,12,12,0      ;"N"
dw 138,255*256+16,prgk_mtxt,107,55,12,12,0      ;"M"
dw 139,255*256+16,prgkkotxt,120,55,12,12,0      ;","
dw 131,255*256+16,prgkputxt,133,55,12,12,0      ;"."
dw 130,255*256+16,prgksltxt,146,55,12,12,0      ;"/"
dw 122,255*256+16,prgkbstxt,159,55,12,12,0      ;"\"
dw 0  ,255*256+2 ,3+4+64+48,172,55,25,12,0      ;"SHIFT"
dw 114,255*256+16,prgkf2txt,198,55,12,12,0      ;"f2"
dw 0  ,255*256+2 ,3+4+64+48,211,55,12,12,0      ;
dw 107,255*256+16,prgkfdtxt,224,55,12,12,0      ;"f."
dw 0  ,255*256+2 ,3+4+64+48,237,55,12,12,0      ;

dw 0  ,255*256+2 ,3+4+64+48,  3,68,25,12,0      ;"CONTROL"  * Reihe 5
dw 0  ,255*256+2 ,3+4+64+48, 29,68,20,12,0      ;"ALT"
dw 0  ,255*256+2 ,3+4+64+48,50,68,103,12,0      ;"SPACE"
dw 0  ,255*256+2 ,3+4+64+48,154,68,43,12,0      ;"ENTER"
dw 113,255*256+16,prgkf1txt,198,68,12,12,0      ;"f1" 
dw 115,255*256+16,prgkf0txt,211,68,12,12,0      ;"f0"
dw 0  ,255*256+2 ,3+4+64+48,224,68,12,12,0      ;
dw 0  ,255*256+2 ,3+4+64+48,237,68,12,12,0      ;

elseif computer_mode=3                                                              ;***EP ***

dw 113,255*256+16,prgkf1txt,  9, 3,22,12,0      ;"f1"       * Reihe 0
dw 114,255*256+16,prgkf2txt, 32, 3,22,12,0      ;"f2"
dw 105,255*256+16,prgkf3txt, 55, 3,22,12,0      ;"f3"
dw 120,255*256+16,prgkf4txt, 78, 3,22,12,0      ;"f4"
dw 112,255*256+16,prgkf5txt,101, 3,22,12,0      ;"f5"
dw 104,255*256+16,prgkf6txt,124, 3,22,12,0      ;"f6"
dw 110,255*256+16,prgkf7txt,147, 3,22,12,0      ;"f7"
dw 111,255*256+16,prgkf8txt,170, 3,22,12,0      ;"f8"
dw 103,255*256+16,prgkmatxt,193, 3,18,12,0      ;"hold/f9"
dw 0  ,255*256+2 ,3+4+64+48,212, 3,23,12,0      ;"stop"

dw 0  ,255*256+2 ,3+4+64+48,  6,16,12,12,0      ;"ESC"      * Reihe 1
dw 164,255*256+16,prgk_1txt, 19,16,12,12,0      ;"1"
dw 165,255*256+16,prgk_2txt, 32,16,12,12,0      ;"2"
dw 157,255*256+16,prgk_3txt, 45,16,12,12,0      ;"3"
dw 156,255*256+16,prgk_4txt, 58,16,12,12,0      ;"4"
dw 149,255*256+16,prgk_5txt, 71,16,12,12,0      ;"5"
dw 148,255*256+16,prgk_6txt, 84,16,12,12,0      ;"6"
dw 141,255*256+16,prgk_7txt, 97,16,12,12,0      ;"7"
dw 140,255*256+16,prgk_8txt,110,16,12,12,0      ;"8"
dw 133,255*256+16,prgk_9txt,123,16,12,12,0      ;"9"
dw 132,255*256+16,prgk_0txt,136,16,12,12,0      ;"0"
dw 125,255*256+16,prgksttxt,149,16,12,12,0      ;"-"
dw 124,255*256+16,prgkdatxt,162,16,12,12,0      ;"^"
dw 0  ,255*256+2 ,3+4+64+48,175,16,23,12,0      ;"ERASE"
dw 0  ,255*256+2 ,3+4+64+48,199,16,23,12,0      ;"DEL"
dw 0  ,255*256+2 ,3+4+64+48,223,16,12,12,0      ;"INS"

dw 0  ,255*256+2 ,3+4+64+48,  6,29,19,12,0      ;"TAB"      * Reihe 2
dw 167,255*256+16,prgk_qtxt, 26,29,12,12,0      ;"Q"
dw 159,255*256+16,prgk_wtxt, 39,29,12,12,0      ;"W"
dw 158,255*256+16,prgk_etxt, 52,29,12,12,0      ;"E"
dw 150,255*256+16,prgk_rtxt, 65,29,12,12,0      ;"R"
dw 151,255*256+16,prgk_ttxt, 78,29,12,12,0      ;"T"
dw 143,255*256+16,prgk_ytxt, 91,29,12,12,0      ;"Y"
dw 142,255*256+16,prgk_utxt,104,29,12,12,0      ;"U"
dw 135,255*256+16,prgk_itxt,117,29,12,12,0      ;"I"
dw 134,255*256+16,prgk_otxt,130,29,12,12,0      ;"O"
dw 127,255*256+16,prgk_ptxt,143,29,12,12,0      ;"P"
dw 126,255*256+16,prgkattxt,156,29,12,12,0      ;"@"
dw 117,255*256+16,prgkoptxt,169,29,12,12,0      ;"["
dw 0  ,255*256+2 ,3+4+64+48,185,29,15,25,0      ;"RET"
dw 0  ,255*256+2 ,3+4+64+48,206,48,12,12,0      ;links
dw 0  ,255*256+2 ,3+4+64+48,217,37,12,12,0      ;rauf
dw 0  ,255*256+2 ,3+4+64+48,217,59,12,12,0      ;runter
dw 0  ,255*256+2 ,3+4+64+48,228,48,12,12,0      ;rechts

dw 0  ,255*256+2 ,3+4+64+48,  3,42,12,12,0      ;"CTRL"     * Reihe 3
dw 0  ,255*256+2 ,3+4+64+48, 16,42,12,12,0      ;"LOCK"
dw 169,255*256+16,prgk_atxt, 29,42,12,12,0      ;"A"
dw 160,255*256+16,prgk_stxt, 42,42,12,12,0      ;"S"
dw 161,255*256+16,prgk_dtxt, 55,42,12,12,0      ;"D"
dw 153,255*256+16,prgk_ftxt, 68,42,12,12,0      ;"F"
dw 152,255*256+16,prgk_gtxt, 81,42,12,12,0      ;"G"
dw 144,255*256+16,prgk_htxt, 94,42,12,12,0      ;"H"
dw 145,255*256+16,prgk_jtxt,107,42,12,12,0      ;"J"
dw 137,255*256+16,prgk_ktxt,120,42,12,12,0      ;"K"
dw 136,255*256+16,prgk_ltxt,133,42,12,12,0      ;"L"
dw 129,255*256+16,prgkdotxt,146,42,12,12,0      ;"doppelpunkt"
dw 128,255*256+16,prgksetxt,159,42,12,12,0      ;";"
dw 119,255*256+16,prgkcotxt,172,42,12,12,0      ;"]"

dw 0  ,255*256+2 ,3+4+64+48,  3,55,19,12,0      ;"SHIFT"    * Reihe 4
dw 122,255*256+16,prgkbstxt, 23,55,12,12,0      ;"\"
dw 171,255*256+16,prgk_ztxt, 36,55,12,12,0      ;"Z"
dw 163,255*256+16,prgk_xtxt, 49,55,12,12,0      ;"X"
dw 162,255*256+16,prgk_ctxt, 62,55,12,12,0      ;"C"
dw 155,255*256+16,prgk_vtxt, 75,55,12,12,0      ;"V"
dw 154,255*256+16,prgk_btxt, 88,55,12,12,0      ;"B"
dw 146,255*256+16,prgk_ntxt,101,55,12,12,0      ;"N"
dw 138,255*256+16,prgk_mtxt,114,55,12,12,0      ;"M"
dw 139,255*256+16,prgkkotxt,127,55,12,12,0      ;","
dw 131,255*256+16,prgkputxt,140,55,12,12,0      ;"."
dw 130,255*256+16,prgksltxt,153,55,12,12,0      ;"/"
dw 0  ,255*256+2 ,3+4+64+48,166,55,21,12,0      ;"SHIFT"
dw 0  ,255*256+2 ,3+4+64+48,188,55,12,12,0      ;"ALT"

dw 0  ,255*256+2 ,3+4+64+48,53,68,104,12,0      ;"SPACE"    * Reihe 5

elseif computer_mode=4                                                              ;***SVM***

dw 0  ,255*256+2 ,3+4+64+48,  3, 3,12,12,0      ;"ESC"      * Reihe 0
dw 113,255*256+16,prgkf1txt, 24, 3,12,12,0      ;"f1"
dw 114,255*256+16,prgkf2txt, 37, 3,12,12,0      ;"f2"
dw 105,255*256+16,prgkf3txt, 50, 3,12,12,0      ;"f3"
dw 120,255*256+16,prgkf4txt, 63, 3,12,12,0      ;"f4"
dw 112,255*256+16,prgkf5txt, 85, 3,12,12,0      ;"f5"
dw 104,255*256+16,prgkf6txt, 98, 3,12,12,0      ;"f6"
dw 110,255*256+16,prgkf7txt,111, 3,12,12,0      ;"f7"
dw 111,255*256+16,prgkf8txt,124, 3,12,12,0      ;"f8"
dw 103,255*256+16,prgkf9txt,146, 3,12,12,0      ;"f9"
dw 115,255*256+16,prgkf0txt,159, 3,12,12,0      ;"f10"
dw 107,255*256+16,prgkfdtxt,172, 3,12,12,0      ;"f11"
dw 0  ,255*256+2 ,3+4+64+48,185, 3,12,12,0      ;"f12"
dw 111,255*256+2 ,3+4+64+48,200, 3,12,12,0      ;"PRT"
dw 111,255*256+2 ,3+4+64+48,213, 3,12,12,0      ;"SCL"
dw 111,255*256+2 ,3+4+64+48,226, 3,12,12,0      ;"PAU"

dw 122,255*256+16,prgkgatxt,  3,16,12,12,0      ;"~"        * Reihe 1
dw 164,255*256+16,prgk_1txt, 16,16,12,12,0      ;"1"
dw 165,255*256+16,prgk_2txt, 29,16,12,12,0      ;"2"
dw 157,255*256+16,prgk_3txt, 42,16,12,12,0      ;"3"
dw 156,255*256+16,prgk_4txt, 55,16,12,12,0      ;"4"
dw 149,255*256+16,prgk_5txt, 68,16,12,12,0      ;"5"
dw 148,255*256+16,prgk_6txt, 81,16,12,12,0      ;"6"
dw 141,255*256+16,prgk_7txt, 94,16,12,12,0      ;"7"
dw 140,255*256+16,prgk_8txt,107,16,12,12,0      ;"8"
dw 133,255*256+16,prgk_9txt,120,16,12,12,0      ;"9"
dw 132,255*256+16,prgk_0txt,133,16,12,12,0      ;"0"
dw 125,255*256+16,prgksttxt,146,16,12,12,0      ;"-"
dw 124,255*256+16,prgkeqtxt,159,16,12,12,0      ;"="
dw 0  ,255*256+2 ,3+4+64+48,172,16,25,12,0      ;"DEL"
dw 0  ,255*256+2 ,3+4+64+48,200,16,12,12,0      ;"INS"
dw 0  ,255*256+2 ,3+4+64+48,213,16,12,12,0      ;"HOM"
dw 0  ,255*256+2 ,3+4+64+48,226,16,12,12,0      ;"PUP"

dw 0  ,255*256+2 ,3+4+64+48,  3,29,19,12,0      ;"TAB"      * Reihe 2
dw 167,255*256+16,prgk_qtxt, 23,29,12,12,0      ;"Q"
dw 159,255*256+16,prgk_wtxt, 36,29,12,12,0      ;"W"
dw 158,255*256+16,prgk_etxt, 49,29,12,12,0      ;"E"
dw 150,255*256+16,prgk_rtxt, 62,29,12,12,0      ;"R"
dw 151,255*256+16,prgk_ttxt, 75,29,12,12,0      ;"T"
dw 143,255*256+16,prgk_ytxt, 88,29,12,12,0      ;"Y"
dw 142,255*256+16,prgk_utxt,101,29,12,12,0      ;"U"
dw 135,255*256+16,prgk_itxt,114,29,12,12,0      ;"I"
dw 134,255*256+16,prgk_otxt,127,29,12,12,0      ;"O"
dw 127,255*256+16,prgk_ptxt,140,29,12,12,0      ;"P"
dw 126,255*256+16,prgkoptxt,153,29,12,12,0      ;"["
dw 117,255*256+16,prgkcotxt,166,29,12,12,0      ;"]"
dw 0  ,255*256+2 ,3+4+64+48,182,29,15,25,0      ;"RET"
dw 120,255*256+2 ,3+4+64+48,200,29,12,12,0      ;"f4"
dw 112,255*256+2 ,3+4+64+48,213,29,12,12,0      ;"f5"
dw 104,255*256+2 ,3+4+64+48,226,29,12,12,0      ;"f6"

dw 0  ,255*256+2 ,3+4+64+48,  3,42,22,12,0      ;"CAPS"     * Reihe 3
dw 169,255*256+16,prgk_atxt, 26,42,12,12,0      ;"A"
dw 160,255*256+16,prgk_stxt, 39,42,12,12,0      ;"S"
dw 161,255*256+16,prgk_dtxt, 52,42,12,12,0      ;"D"
dw 153,255*256+16,prgk_ftxt, 65,42,12,12,0      ;"F"
dw 152,255*256+16,prgk_gtxt, 78,42,12,12,0      ;"G"
dw 144,255*256+16,prgk_htxt, 91,42,12,12,0      ;"H"
dw 145,255*256+16,prgk_jtxt,104,42,12,12,0      ;"J"
dw 137,255*256+16,prgk_ktxt,117,42,12,12,0      ;"K"
dw 136,255*256+16,prgk_ltxt,130,42,12,12,0      ;"L"
dw 129,255*256+16,prgksetxt,143,42,12,12,0      ;";"
dw 128,255*256+16,prgkaptxt,156,42,12,12,0      ;"'"
dw 119,255*256+16,prgkbstxt,169,42,12,12,0      ;"\"

dw 0  ,255*256+2 ,3+4+64+48,  3,55,25,12,0      ;"SHIFT"    * Reihe 4
dw 171,255*256+16,prgk_ztxt, 29,55,12,12,0      ;"Z"
dw 163,255*256+16,prgk_xtxt, 42,55,12,12,0      ;"X"
dw 162,255*256+16,prgk_ctxt, 55,55,12,12,0      ;"C"
dw 155,255*256+16,prgk_vtxt, 68,55,12,12,0      ;"V"
dw 154,255*256+16,prgk_btxt, 81,55,12,12,0      ;"B"
dw 146,255*256+16,prgk_ntxt, 94,55,12,12,0      ;"N"
dw 138,255*256+16,prgk_mtxt,107,55,12,12,0      ;"M"
dw 139,255*256+16,prgkkotxt,120,55,12,12,0      ;","
dw 131,255*256+16,prgkputxt,133,55,12,12,0      ;"."
dw 130,255*256+16,prgksltxt,146,55,12,12,0      ;"/"
dw 0  ,255*256+2 ,3+4+64+48,159,55,38,12,0      ;"SHIFT"
dw 0  ,255*256+2 ,3+4+64+48,213,55,12,12,0      ;"rauf"

dw 0  ,255*256+2 ,3+4+64+48, 3,68, 25,12,0      ;"CTRL"     * Reihe 5
dw 0  ,255*256+2 ,3+4+64+48,29,68, 20,12,0      ;"ALT"
dw 0  ,255*256+2 ,3+4+64+48,50,68,100,12,0      ;"SPACE"
dw 0  ,255*256+2 ,3+4+64+48,151,68,20,12,0      ;"ALT"
dw 0  ,255*256+2 ,3+4+64+48,172,68,25,12,0      ;"CTRL"
dw 0  ,255*256+2 ,3+4+64+48,200,68,12,12,0      ;"links" 
dw 0  ,255*256+2 ,3+4+64+48,213,68,12,12,0      ;"runter"
dw 0  ,255*256+2 ,3+4+64+48,226,68,12,12,0      ;"rechts"

elseif computer_mode=5                                                                  ;***NC***

dw 0  ,255*256+2 ,3+4+64+48,  3,16,12,12,0      ;"ESC"      * Reihe 1
dw 164,255*256+16,prgk_1txt, 16,16,12,12,0      ;"1"
dw 165,255*256+16,prgk_2txt, 29,16,12,12,0      ;"2"
dw 157,255*256+16,prgk_3txt, 42,16,12,12,0      ;"3"
dw 156,255*256+16,prgk_4txt, 55,16,12,12,0      ;"4"
dw 149,255*256+16,prgk_5txt, 68,16,12,12,0      ;"5"
dw 148,255*256+16,prgk_6txt, 81,16,12,12,0      ;"6"
dw 141,255*256+16,prgk_7txt, 94,16,12,12,0      ;"7"
dw 140,255*256+16,prgk_8txt,107,16,12,12,0      ;"8"
dw 133,255*256+16,prgk_9txt,120,16,12,12,0      ;"9"
dw 132,255*256+16,prgk_0txt,133,16,12,12,0      ;"0"
dw 125,255*256+16,prgksttxt,146,16,12,12,0      ;"-"
dw 124,255*256+16,prgkeqtxt,159,16,12,12,0      ;"="
dw 0  ,255*256+2 ,3+4+64+48,172,16,12,12,0      ;"CLR"
dw 0  ,255*256+2 ,3+4+64+48,185,16,12,12,0      ;"DEL"

dw 0  ,255*256+2 ,3+4+64+48,  3,29,19,12,0      ;"TAB"      * Reihe 2
dw 167,255*256+16,prgk_qtxt, 23,29,12,12,0      ;"Q"
dw 159,255*256+16,prgk_wtxt, 36,29,12,12,0      ;"W"
dw 158,255*256+16,prgk_etxt, 49,29,12,12,0      ;"E"
dw 150,255*256+16,prgk_rtxt, 62,29,12,12,0      ;"R"
dw 151,255*256+16,prgk_ttxt, 75,29,12,12,0      ;"T"
dw 143,255*256+16,prgk_ytxt, 88,29,12,12,0      ;"Y"
dw 142,255*256+16,prgk_utxt,101,29,12,12,0      ;"U"
dw 135,255*256+16,prgk_itxt,114,29,12,12,0      ;"I"
dw 134,255*256+16,prgk_otxt,127,29,12,12,0      ;"O"
dw 127,255*256+16,prgk_ptxt,140,29,12,12,0      ;"P"
dw 126,255*256+16,prgkoptxt,153,29,12,12,0      ;"["
dw 117,255*256+16,prgkcotxt,166,29,12,12,0      ;"]"
dw 0  ,255*256+2 ,3+4+64+48,182,29,15,25,0      ;"RET"

dw 0  ,255*256+2 ,3+4+64+48,  3,42,22,12,0      ;"CAPS"     * Reihe 3
dw 169,255*256+16,prgk_atxt, 26,42,12,12,0      ;"A"
dw 160,255*256+16,prgk_stxt, 39,42,12,12,0      ;"S"
dw 161,255*256+16,prgk_dtxt, 52,42,12,12,0      ;"D"
dw 153,255*256+16,prgk_ftxt, 65,42,12,12,0      ;"F"
dw 152,255*256+16,prgk_gtxt, 78,42,12,12,0      ;"G"
dw 144,255*256+16,prgk_htxt, 91,42,12,12,0      ;"H"
dw 145,255*256+16,prgk_jtxt,104,42,12,12,0      ;"J"
dw 137,255*256+16,prgk_ktxt,117,42,12,12,0      ;"K"
dw 136,255*256+16,prgk_ltxt,130,42,12,12,0      ;"L"
dw 129,255*256+16,prgksetxt,143,42,12,12,0      ;";"
dw 128,255*256+16,prgkaptxt,156,42,12,12,0      ;"'"
dw 119,255*256+16,prgknstxt,169,42,12,12,0      ;"#"

dw 0  ,255*256+2 ,3+4+64+48,  3,55,25,12,0      ;"SHIFT"    * Reihe 4
dw 171,255*256+16,prgk_ztxt, 29,55,12,12,0      ;"Z"
dw 163,255*256+16,prgk_xtxt, 42,55,12,12,0      ;"X"
dw 162,255*256+16,prgk_ctxt, 55,55,12,12,0      ;"C"
dw 155,255*256+16,prgk_vtxt, 68,55,12,12,0      ;"V"
dw 154,255*256+16,prgk_btxt, 81,55,12,12,0      ;"B"
dw 146,255*256+16,prgk_ntxt, 94,55,12,12,0      ;"N"
dw 138,255*256+16,prgk_mtxt,107,55,12,12,0      ;"M"
dw 139,255*256+16,prgkkotxt,120,55,12,12,0      ;","
dw 131,255*256+16,prgkputxt,133,55,12,12,0      ;"."
dw 130,255*256+16,prgksltxt,146,55,12,12,0      ;"/"
dw 0  ,255*256+2 ,3+4+64+48,159,55,25,12,0      ;"SHIFT"
dw 0  ,255*256+2 ,3+4+64+48,185,55,12,12,0      ;"rauf"

dw 0  ,255*256+2 ,3+4+64+48,  3,68,22,12,0      ;"FUNCTION" * Reihe 5
dw 0  ,255*256+2 ,3+4+64+48, 26,68,12,12,0      ;"CTRL"
dw 0  ,255*256+2 ,3+4+64+48, 39,68,12,12,0      ;"ALT"
dw 0  ,255*256+2 ,3+4+64+48, 52,68,80,12,0      ;"SPACE"
dw 122,255*256+16,prgkbstxt,133,68,12,12,0      ;"\"
dw 0  ,255*256+2 ,3+4+64+48,146,68,12,12,0      ;"secret menu" (=ENTER)
dw 0  ,255*256+2 ,3+4+64+48,159,68,12,12,0      ;"links"
dw 0  ,255*256+2 ,3+4+64+48,172,68,12,12,0      ;"rechts"
dw 0  ,255*256+2 ,3+4+64+48,185,68,12,12,0      ;"runter"

elseif computer_mode=6                                                                  ;***NXT***

dw 0  ,255*256+2 ,3+4+64+48,36+  3,16,12,12,0   ;"ESC"      * Reihe 1
dw 0  ,255*256+2 ,3+4+64+48,36+ 16,16,12,12,0   ;"EDIT"
dw 164,255*256+16,prgk_1txt,36+ 29,16,12,12,0   ;"1"
dw 165,255*256+16,prgk_2txt,36+ 42,16,12,12,0   ;"2"
dw 157,255*256+16,prgk_3txt,36+ 55,16,12,12,0   ;"3"
dw 156,255*256+16,prgk_4txt,36+ 68,16,12,12,0   ;"4"
dw 149,255*256+16,prgk_5txt,36+ 81,16,12,12,0   ;"5"
dw 148,255*256+16,prgk_6txt,36+ 94,16,12,12,0   ;"6"
dw 141,255*256+16,prgk_7txt,36+107,16,12,12,0   ;"7"
dw 140,255*256+16,prgk_8txt,36+120,16,12,12,0   ;"8"
dw 133,255*256+16,prgk_9txt,36+133,16,12,12,0   ;"9"
dw 132,255*256+16,prgk_0txt,36+146,16,12,12,0   ;"0"
dw 0  ,255*256+2 ,3+4+64+48,36+159,16,18,12,0   ;"DEL"

dw 0  ,255*256+2 ,3+4+64+48,36+  3,29,15,12,0   ;"TRUEVID"  * Reihe 2
dw 0  ,255*256+2 ,3+4+64+48,36+ 19,29,15,12,0   ;"INVVID"
dw 167,255*256+16,prgk_qtxt,36+ 35,29,12,12,0   ;"Q"
dw 159,255*256+16,prgk_wtxt,36+ 48,29,12,12,0   ;"W"
dw 158,255*256+16,prgk_etxt,36+ 61,29,12,12,0   ;"E"
dw 150,255*256+16,prgk_rtxt,36+ 74,29,12,12,0   ;"R"
dw 151,255*256+16,prgk_ttxt,36+ 87,29,12,12,0   ;"T"
dw 143,255*256+16,prgk_ytxt,36+100,29,12,12,0   ;"Y"
dw 142,255*256+16,prgk_utxt,36+113,29,12,12,0   ;"U"
dw 135,255*256+16,prgk_itxt,36+126,29,12,12,0   ;"I"
dw 134,255*256+16,prgk_otxt,36+139,29,12,12,0   ;"O"
dw 127,255*256+16,prgk_ptxt,36+152,29,12,12,0   ;"P"
dw 0  ,255*256+2 ,3+4+64+48,36+165,29,12,25,0   ;"RET"

dw 0  ,255*256+2 ,3+4+64+48,36+  3,42,18,12,0   ;"CAPS"     * Reihe 3
dw 0  ,255*256+2 ,3+4+64+48,36+ 22,42,18,12,0   ;"GRAPH"
dw 169,255*256+16,prgk_atxt,36+ 41,42,12,12,0   ;"A"
dw 160,255*256+16,prgk_stxt,36+ 54,42,12,12,0   ;"S"
dw 161,255*256+16,prgk_dtxt,36+ 67,42,12,12,0   ;"D"
dw 153,255*256+16,prgk_ftxt,36+ 80,42,12,12,0   ;"F"
dw 152,255*256+16,prgk_gtxt,36+ 93,42,12,12,0   ;"G"
dw 144,255*256+16,prgk_htxt,36+106,42,12,12,0   ;"H"
dw 145,255*256+16,prgk_jtxt,36+119,42,12,12,0   ;"J"
dw 137,255*256+16,prgk_ktxt,36+132,42,12,12,0   ;"K"
dw 136,255*256+16,prgk_ltxt,36+145,42,12,12,0   ;"L"

dw 0  ,255*256+2 ,3+4+64+48,36+  3,55,25,12,0   ;"SHIFT"    * Reihe 4
dw 0  ,255*256+2 ,3+4+64+48,36+ 29,55,18,12,0   ;"EXTEND"
dw 171,255*256+16,prgk_ztxt,36+ 48,55,12,12,0   ;"Z"
dw 163,255*256+16,prgk_xtxt,36+ 61,55,12,12,0   ;"X"
dw 162,255*256+16,prgk_ctxt,36+ 74,55,12,12,0   ;"C"
dw 155,255*256+16,prgk_vtxt,36+ 87,55,12,12,0   ;"V"
dw 154,255*256+16,prgk_btxt,36+100,55,12,12,0   ;"B"
dw 146,255*256+16,prgk_ntxt,36+113,55,12,12,0   ;"N"
dw 138,255*256+16,prgk_mtxt,36+126,55,12,12,0   ;"M"
dw 0  ,255*256+2 ,3+4+64+48,36+139,55,12,12,0   ;"rauf"
dw 0  ,255*256+2 ,3+4+64+48,36+152,55,25,12,0   ;"SHIFT"

dw 0  ,255*256+2 ,3+4+64+48,36+  3,68,12,12,0   ;"SYMB"     * Reihe 5
dw 128,255*256+16,prgksetxt,36+ 16,68,12,12,0   ;";"
dw 129,255*256+16,prgkqutxt,36+ 29,68,12,12,0   ;"""
dw 139,255*256+16,prgkkotxt,36+ 42,68,12,12,0   ;","
dw 131,255*256+16,prgkputxt,36+ 55,68,12,12,0   ;"."
dw 0  ,255*256+2 ,3+4+64+48,36+ 68,68,57,12,0   ;"SPACE"
dw 0  ,255*256+2 ,3+4+64+48,36+126,68,12,12,0   ;"links"
dw 0  ,255*256+2 ,3+4+64+48,36+139,68,12,12,0   ;"runter"
dw 0  ,255*256+2 ,3+4+64+48,36+152,68,12,12,0   ;"rechts"
dw 0  ,255*256+2 ,3+4+64+48,36+165,68,12,12,0   ;"SYMB"

endif

dw 00,255*256+3,keyobjdat1,  0,83,112,53,0      ;78=Definition-Rahmen     *** Settings
dw 00,255*256+3,keyobjdat2,109,83,143,53,0      ;79=Geschwindigkeits-Rahmen
dw 00,255*256+1,keyobjdata,  8, 93,30,8,0       ;80=Definition "Key"    Text
dw 00,255*256+1,keyobjdatb,  8,106,30,8,0       ;81=Definition "Normal" Text
dw 00,255*256+1,keyobjdatc, 66,106,30,8,0       ;82=Definition "Shift"  Text
dw 00,255*256+1,keyobjdatd,  8,119,30,8,0       ;83=Definition "Ctrl"   Text
dw 00,255*256+1,keyobjdate, 66,119,30,8,0       ;84=Definition "Alt"    Text
dw 00,255*256+1 ,keyobjdatf,39, 93,20, 8,0      ;85=Definition "Key"    Name
dw 00,255*256+32,keyobjdatg,39,104,20,12,0      ;86=Definition "Normal" Input
dw 00,255*256+32,keyobjdath,85,104,20,12,0      ;87=Definition "Shift"  Input
dw 00,255*256+32,keyobjdati,39,117,20,12,0      ;88=Definition "Ctrl"   Input
dw 00,255*256+32,keyobjdatj,85,117,20,12,0      ;89=Definition "Alt"    Input
dw 00,255*256+1,keyobjdatk,117, 93,30,8,0       ;90=Speed "Delay"  Text
dw 00,255*256+1,keyobjdatl,117,106,30,8,0       ;91=Speed "Repeat" Text
dw 00,255*256+1,keyobjdatm,117,119,30,8,0       ;92=Speed "Test"   Text
dw keyspd,255*256+24,keyobjdatn,149,93,81,8,0   ;93=Speed "Delay"  Slider
dw keyspd,255*256+24,keyobjdato,149,106,81,8,0  ;94=Speed "Repeat" Slider
dw 00,255*256+32,keyobjdatp,149,117,96,12,0     ;95=Speed "Test"   Input
dw 00,255*256+1,keyobjdatq,232, 93,12,8,0       ;96=Speed "Delay"  Wert
dw 00,255*256+1,keyobjdatr,232,106,12,8,0       ;97=Speed "Repeat" Wert
dw 00,255*256+1,keyobjdats,233,keyobjtxty,16,8,0    ;98=Computertyp  Text

prgdatkeyn equ $-prgdatkey/16

keyobjdat1 dw keyobjtxt1,2+4
keyobjdat2 dw keyobjtxt2,2+4
keyobjdata dw keyobjtxta,2+4
keyobjdatb dw keyobjtxtb,2+4
keyobjdatc dw keyobjtxtc,2+4
keyobjdatd dw keyobjtxtd,2+4
keyobjdate dw keyobjtxte,2+4
keyobjdatf dw keyobjtxtf,2+4
keyobjdatg dw keyobjdatgb,0,0,0,0,3,0:keyobjdatgb ds 4
keyobjdath dw keyobjdathb,0,0,0,0,3,0:keyobjdathb ds 4
keyobjdati dw keyobjdatib,0,0,0,0,3,0:keyobjdatib ds 4
keyobjdatj dw keyobjdatjb,0,0,0,0,3,0:keyobjdatjb ds 4
keyobjdatk dw keyobjtxtk,2+4
keyobjdatl dw keyobjtxtl,2+4
keyobjdatm dw keyobjtxtm,2+4
keyobjdatn dw 1,0,98,256*255+1
keyobjdato dw 1,0,98,256*255+1
keyobjdatp dw keyobjdatpb,0,0,0,0,29,0:keyobjdatpb ds 30
keyobjdatq dw keyobjtxtq:db 0+4+128,2
keyobjdatr dw keyobjtxtr:db 0+4+128,2
keyobjdats dw keyobjtxts:db 2+4,1

prgobjkey2a dw prginpfnt2b,0,0,0,0,255,0
prginpkey2a db "kyb",0
prginpkey2b ds 256


;### MASS STORAGE DEVICES #####################################################

prgwindev   dw #1501,0,50,8,128,152,0,0,128,152,128,152,128,152,prgicndev2,prgtitdev,0,0,prggrpdev,0,0:ds 136+14
prggrpdev   db 20,0:dw prgdatdev,0,0,3*256+2,0,0,0
prgdatdev
dw      0,255*256+ 0,         2,  0,0,1000,1000,0       ;00=Hintergrund
dw devoky,255*256+16,prgbuttxt1,  23,137,32, 12,0       ;01="Ok"-Button
dw devcnc,255*256+16,prgbuttxt2,  58,137,32, 12,0       ;02="Cancel"-Button
dw devapl,255*256+16,prgbuttxt3,  93,137,32, 12,0       ;03="Apply"-Button
dw      0,255*256+ 3,prgobjdev1,   0,01,128, 30,0       ;04=Rahmen Drives
dw      0,255*256+ 3,prgobjdev2,   0,31,128,105,0       ;05=Rahmen Settings
dw devdel,255*256+16,prgtxtdev3,  78,10, 20, 12,0       ;06="Del"-Button
dw devadd,255*256+16,prgtxtdev4, 101,10, 20, 12,0       ;07="Add"-Button
dw      0,255*256+ 1,prgobjdev7,   7,43, 24,  8,0       ;08=Name Text
dw      0,255*256+ 1,prgobjdevh,   7,65, 50,  8,0       ;09=DriveLetter Text

dw devsel,255*256+42,prgobjdev3,   7,11, 68, 10,0       ;10=Laufwerksauswahl
dw      0,255*256+32,prgobjdev8,  32,41, 74, 12,0       ;11=Name Input
dw      0,255*256+17,prgobjdev6,   7,55,114,  8,0       ;12=Wechseldatenträger Check
dw devlet,255*256+42,prgobjdevg,  57,64, 18, 10,0       ;13=DriveLetter Auswahl
dw devtyp,255*256+18,prgobjdev4,   7,78,114,  8,0       ;14=Typ Slot 1 Radio
prgdatdev3
dw devtyp,255*256+18,prgobjdev5,   7,88,114,  8,0       ;15=Typ Slot 2 Radio
prgdatdev1
dw      0,255*256+42,prgobjdevb,  14,98,90, 10,0        ;16=Geräte-Auswahl (Laufwerks, Master/Slave, Device)
dw      0,255*256+42,prgobjdevx,  14,110,90,  8,0       ;17=Kopf/Partitions-Auswahl
dw      0,255*256+ 0,         2,  14,122,70,  8,0       ;18=Lösch-Fläche für Doublestep check
prgdatdev2
dw      0,255*256+17,prgobjdevi,  14,122,70,  8,0       ;19=Doublestep Check

prgobjdev1  dw prgtxtdev1,2+4
prgobjdev2  dw prgtxtdev2,2+4
prgobjdev4  dw prgdevtyp,prgtxtdev6,2+4+0  ,prgbufdev1
prgobjdev5  dw prgdevtyp,prgtxtdev7,2+4+256,prgbufdev1
prgobjdev6  dw prgdevrem,prgtxtdev8,2+4
prgobjdev7  dw prgtxtdev5,2+4
prgobjdev8  dw 0,0,0,0,0,11,0
prgobjdev9  dw prgtxtdev9,2+4
prgobjdevh  dw prgtxtdeve,2+4
prgobjdevi  dw prgdevstp,prgtxtdevf,2+4

prgbufdev1  dw -1,-1

prgdevtyp   db 0
prgdevrem   db 0
prgdevstp   db 0

prgobjdev3  dw 0,0,prgtabdev1,0,256*0+1,prgtabdev2
prgobjdev3a dw 0,1
prgtabdev2  dw 0+0,1000,0,0
prgtabdev1  ds 4*8

prgobjdeva  dw 4,0,prgobjdeva1,0,256*0+1,prgobjdeva2,0,1        ;FDC
prgobjdeva2 dw 0+0,1000,0,0
prgobjdeva1 dw 00,prgtabdevaa,01,prgtabdevab,02,prgtabdevac,03,prgtabdevad

prgobjdevb  dw 2,0,prgobjdevb1,0,256*0+1,prgobjdevb2,0,1        ;IDE
prgobjdevb2 dw 0+0,1000,0,0
prgobjdevb1 dw 00,prgtabdevba,01,prgtabdevbb

prgobjdevc  dw 2,0,prgobjdevc1,0,256*0+1,prgobjdevc2,0,1        ;SD
prgobjdevc2 dw 0+0,1000,0,0
prgobjdevc1 dw 00,prgtabdevca,01,prgtabdevcb

prgobjdevd  dw 8,0,prgobjdevd1,0,256*0+1,prgobjdevd2,0,1        ;SCSI/USB
prgobjdevd2 dw 0+0,1000,0,0
prgobjdevd1 dw 00,prgtabdevda,01,prgtabdevdb,02,prgtabdevdc,03,prgtabdevdd,04,prgtabdevde,05,prgtabdevdf,06,prgtabdevdg,07,prgtabdevdh

prgobjdevx  dw 2,0,prgobjdevx1,0,256*0+1,prgobjdevx2,0,1        ;FDC Head
prgobjdevx2 dw 0+0,1000,0,0
prgobjdevx1 dw 00,prgtabdevxa,01,prgtabdevxb

prgobjdevy  dw 5,0,prgobjdevy1,0,256*0+1,prgobjdevy2,0,1        ;IDE/SD/SCSI Partition
prgobjdevy2 dw 0+0,1000,0,0
prgobjdevy1 dw 00,prgtabdevya,01,prgtabdevyb,02,prgtabdevyc,03,prgtabdevyd,04,prgtabdevye


prgobjdevg  dw 26,0,prgobjdevg1,0,256*0+1,prgobjdevg2,0,1
prgobjdevg2 dw 0+0,1000,0,0
prgobjdevg1 dw 00,00*2+prgtabdevga,01,01*2+prgtabdevga,02,02*2+prgtabdevga,03,03*2+prgtabdevga,04,04*2+prgtabdevga,05,05*2+prgtabdevga
            dw 06,06*2+prgtabdevga,07,07*2+prgtabdevga,08,08*2+prgtabdevga,09,09*2+prgtabdevga,10,10*2+prgtabdevga,11,11*2+prgtabdevga
            dw 12,12*2+prgtabdevga,13,13*2+prgtabdevga,14,14*2+prgtabdevga,15,15*2+prgtabdevga,16,16*2+prgtabdevga,17,17*2+prgtabdevga
            dw 18,18*2+prgtabdevga,19,19*2+prgtabdevga,20,20*2+prgtabdevga,21,21*2+prgtabdevga,22,22*2+prgtabdevga,23,23*2+prgtabdevga
            dw 24,24*2+prgtabdevga,25,25*2+prgtabdevga

;### LINKS ####################################################################

prgwinlnk   dw #1501,0,50,5,160,167,0,0,160,167,160,167,160,167,prgicnlnk2,prgtitlnk,0,0,prggrplnk,0,0:ds 136+14
prggrplnk   db 30,0:dw prgdatlnk,0,0,3*256+2,0,0,0
prgdatlnk
dw 00,     255*256+0, 2,           0,0,1000,1000,0      ;00=Hintergrund
dw lnkoky, 255*256+16,prgbuttxt1,  55,152,32,12,0       ;01="Ok"-Button
dw lnkcnc, 255*256+16,prgbuttxt2,  90,152,32,12,0       ;02="Cancel"-Button
dw lnkapl, 255*256+16,prgbuttxt3, 125,152,32,12,0       ;03="Apply"-Button
dw lnkenc, 255*256+41,prgobjlnk1, 4,   4, 92, 58,0      ;04=Liste Einträge
dw lnklsc, 255*256+18,prgobjlnk2a,100, 4, 52,  8,0      ;05=Radio Desktop
dw lnklsc, 255*256+18,prgobjlnk2b,100,14, 52,  8,0      ;06=Radio Startmenu
dw lnklsc, 255*256+64,prgobjlnk2c,100,24, 52,  8,0      ;07=Radio Taskbar ##vorerst deaktiviert##
dw lnkeup, 255*256+16,prgtxtlnk3a,100,36, 27, 12,0      ;08=Button "Up"
dw lnkedw, 255*256+16,prgtxtlnk3b,129,36, 27, 12,0      ;09=Button "Down"
dw lnkdel, 255*256+16,prgtxtlnk3c,100,50, 27, 12,0      ;10=Button "Del"
dw lnkadd, 255*256+16,prgtxtlnk3d,129,50, 27, 12,0      ;11=Button "Add"
dw 00,     255*256+3, prgobjlnk4,   0,65,160, 86,0      ;12=Rahmen Edit
dw 00,     255*256+1, prgobjlnk6a,  8,77, 22,  8,0      ;13=Beschreibung  Name
prgdatlnk1
dw 00,     255*256+32,prgobjlnk6b, 32,75,120, 12,0      ;14=Input Lang    Name
dw 00,     255*256+32,prgobjlnk6c, 32,75, 60, 12,0      ;15=Input Teil1   Name
dw 00,     255*256+32,prgobjlnk6d, 92,75, 60, 12,0      ;16=Input Teil2   Name
dw 00,     255*256+1, prgobjlnk5a,  8,91, 22,  8,0      ;17=Beschreibung  Pfad
dw 00,     255*256+32,prgobjlnk5b, 32,89, 78, 12,0      ;18=Input         Pfad
dw lnkbrw, 255*256+16,prgtxtlnk5c,112,89, 40, 12,0      ;19=Button Browse Pfad
prgdatlnk2
dw 00,     255*256+0, 2,           08,103,144,40,0      ;20=Fläche        Icon
dw 00,     255*256+1, prgobjlnk7a,  8,105,22,  8,0      ;21=Beschreibung  Icon
dw 00,     255*256+2, 0,           32,103,26, 26,0      ;22=Rahmen        Icon
prgdatlnk3
dw 00,     255*256+8, prgicnbig,   33,104,24, 24,0      ;23=Grafik        Icon
dw lnkicf, 255*256+16,prgtxtlnk7b, 62,103,64, 12,0      ;24=Button File   Icon
dw lnkicc, 255*256+16,prgtxtlnk7c, 62,117,64, 12,0      ;25=Button Choose Icon
dw 00,     255*256+1, prgobjlnk8a, 32,133,22,  8,0      ;26=Beschreibung  X
dw 00,     255*256+32,prgobjlnk8c, 54,131,32, 12,0      ;27=Input         X
dw 00,     255*256+1, prgobjlnk8b, 90,133,22,  8,0      ;28=Beschreibung  Y
dw 00,     255*256+32,prgobjlnk8d,112,131,32, 12,0      ;29=Input         Y

lnklsttyp   db 0
prgobjlnk2k ds 4
prgobjlnk2a dw lnklsttyp,prgtxtlnk2a,2+4+000,prgobjlnk2k
prgobjlnk2b dw lnklsttyp,prgtxtlnk2b,2+4+256,prgobjlnk2k
prgobjlnk2c dw lnklsttyp,prgtxtlnk2c,2+4+512,prgobjlnk2k
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

prgobjlnk8a dw prgtxtlnk8a,2+4
prgobjlnk8b dw prgtxtlnk8b,2+4
prgobjlnk8c dw prginplnk8c,0,0,0,0,5,0
prginplnk8c ds 6
prgobjlnk8d dw prginplnk8d,0,0,0,0,5,0
prginplnk8d ds 6

prgobjlnk1  dw 0,0,lnkentlst,0,256*0+1,lnkentrow,0,1
lnkentrow   dw 0,92,00,0
lnkentlst   dw 00,0,01,0,02,0,03,0,04,0,05,0,06,0,07,0,08,0,09,0
            dw 10,0,11,0,12,0,13,0,14,0,15,0,16,0,17,0,18,0,19,0

;### SYSTEM ###################################################################

prgwinsys   dw #1501,0,80,03,128,168,0,0,128,168,128,168,128,168, prgicnsys2,prgtitsys,0,0
prgwinsys0  dw prggrpsysa,0,0:ds 136+14

prggrpsysa  db 24,0:dw prgdatsysa,0,0,4*256+3,0,0,2
prggrpsysb  db 18,0:dw prgdatsysb,0,0,4*256+3,0,0,2

prgobjsys0  db 2,2+4+48+64
prgobjsys0a db 0:dw prgtxtsys0a:db -1:dw prgtxtsys0b:db -1

prgdatsysa
dw 00,     255*256+0,2, 0,0,1000,1000,0                 ;00=Hintergrund
dw systab, 255*256+20,prgobjsys0,   0, 1,128,11,0       ;01=Tab-Leiste
dw sysoky, 255*256+16,prgbuttxt1,  23,153,32,12,0       ;02="Ok"-Button
dw syscnc, 255*256+16,prgbuttxt2,  58,153,32,12,0       ;03="Cancel"-Button
dw sysapl, 255*256+16,prgbuttxt3,  93,153,32,12,0       ;04="Apply"-Button
dw 00,     255*256+3, prgobjsys1,  0, 14,128,42,0       ;05=Rahmen Info
dw 00,     255*256+1, prgobjsys1a, 8, 25,70, 8,0        ;06=Beschreibung Type
dw 00,     255*256+1, prgobjsys1b, 8, 33,70, 8,0        ;07=Beschreibung Memory
dw 00,     255*256+1, prgobjsys1d, 8, 41,70, 8,0        ;09=Beschreibung Version
dw 00,     255*256+1, prgobjsys1e,40, 25,80, 8,0        ;10=Anzeige Type
dw 00,     255*256+1, prgobjsys1f,40, 33,80, 8,0        ;11=Anzeige Memory
dw 00,     255*256+1, prgobjsys1h,40, 41,80, 8,0        ;13=Anzeige Version
dw 00,     255*256+3, prgobjsys3,  0,56,128,96,0        ;14=Rahmen Misc
dw 00,     255*256+1, prgobjsys3h,8, 67, 50, 8,0        ;15=Beschreibung Boot drive
dw 00,     255*256+42,prgobjsys3i,60,66, 18,10,0        ;16=Auswahl Boot drive
dw 00,     255*256+1, prgobjsys3a,8, 80, 50, 8,0        ;17=Beschreibung Systempfad
dw 00,     255*256+32,prgobjsys3c,60,78, 60,12,0        ;18=Input Systempfad
dw 00,     255*256+1, prgobjsys3e,8,  94,42, 8,0        ;19=Beschreibung Autoexec
dw 00,     255*256+17,prgobjsys3f,52, 94,112,8,0        ;20=Check Autoexec
dw 00,     255*256+32,prgobjsys3g,60, 92,60,12,0        ;21=Input Autoexec
dw 00,     255*256+17,prgobjsys3b,8, 107,111,8,0        ;22=Check SymbOS Extensions
dw 00,     255*256+1, prgobjsys3d,16,117,111,8,0        ;23=Beschreibung SymbOS Extensions
dw 00,     255*256+17,prgobjsys3j,8, 127,111,8,0        ;24=Check File Selector maximum
dw 00,     255*256+1, prgobjsys3k,16,137,111,8,0        ;25=Beschreibung File Selector maximum

prgobjsys1  dw prgtxtsys1,2+4
prgobjsys1a dw prgtxtsys1a,2+4
prgobjsys1b dw prgtxtsys1b,2+4
prgobjsys1d dw prgtxtsys1d,2+4
prgobjsys1e dw prgtxtsys20,2+4+256
prgobjsys1f dw prgtxtsys1f,2+4+256
prgobjsys1h dw prgtxtsys1y,2+4+256
prgobjsys3  dw prgtxtsys3,2+4
prgobjsys3a dw prgtxtsys3a,2+4
prgobjsys3b dw cfgextflg,prgtxtsys3b,2+4
prgobjsys3c dw syssyspth,0,0,0,0,31,0
prgobjsys3d dw prgtxtsys3d,2+4
prgobjsys3e dw prgtxtsys3e,2+4

prgobjsys3j dw cfgselflg,prgtxtsys3j,2+4
prgobjsys3k dw prgtxtsys3k,2+4

prgobjsys3f dw sysautflg,prgtxtsys2g,2+4
prgobjsys3g dw sysautpth,0,0,0,0,31,0
prgobjsys3h dw prgtxtsys3h,2+4
prgobjsys3i dw 8,0,prgobjsysi1,0,256*0+1,prgobjsysi2,0,1
prgobjsysi2 dw 0+0,1000,0,0
prgobjsysi1 ds 8*4

syssyspth   ds 32
sysautpth   ds 32
sysautflg   db 0

prgtxtsys1f db "#### "
prgtxtsys1g db " KB Ram",0


prgdatsysb
dw 00,     255*256+0,2, 0,0,1000,1000,0                 ;00=Hintergrund
dw systab, 255*256+20,prgobjsys0,   0, 1,128,11,0       ;01=Tab-Leiste
dw sysoky, 255*256+16,prgbuttxt1,  23,153,32,12,0       ;02="Ok"-Button
dw syscnc, 255*256+16,prgbuttxt2,  58,153,32,12,0       ;03="Cancel"-Button
dw sysapl, 255*256+16,prgbuttxt3,  93,153,32,12,0       ;04="Apply"-Button
dw sysenc, 255*256+41,prgobjsys5,   4,17,120,51,0       ;05=Liste Einträge
dw sysdel, 255*256+16,prgtxtlnk3c, 68,70, 27,12,0       ;06=Button "Del"
dw sysadd, 255*256+16,prgtxtlnk3d, 97,70, 27,12,0       ;07=Button "Add"
dw 00,     255*256+3, prgobjlnk4,   0,83,128,69,0       ;08=Rahmen Edit
dw 00,     255*256+1, prgobjlnk9a,  8,93, 70, 8,0       ;09=Beschreibung Extension(s)
dw 00,     255*256+1, prgobjlnk9b, 8,122, 62, 8,0       ;10=Beschreibung Application
dw sysbrw, 255*256+16,prgtxtlnk5c,78,119, 42,12,0       ;11=Button "Browse..."
dw 00,     255*256+32,prgobjsysaa,  8,103,20,12,0       ;12=Input Extension 1
dw 00,     255*256+32,prgobjsysab, 31,103,20,12,0       ;13=Input Extension 2
dw 00,     255*256+32,prgobjsysac, 54,103,20,12,0       ;14=Input Extension 3
dw 00,     255*256+32,prgobjsysad, 77,103,20,12,0       ;15=Input Extension 4
dw 00,     255*256+32,prgobjsysae,100,103,20,12,0       ;16=Input Extension 5
dw 00,     255*256+32,prgobjsysba, 8,132,112,12,0       ;17=Input Application

prgobjlnk9a dw prgtxtlnk9a,2+4
prgobjlnk9b dw prgtxtlnk9b,2+4

prgobjsysaa dw prginpsysaa,0,0,0,0,3,0
prgobjsysab dw prginpsysab,0,0,0,0,3,0
prgobjsysac dw prginpsysac,0,0,0,0,3,0
prgobjsysad dw prginpsysad,0,0,0,0,3,0
prgobjsysae dw prginpsysae,0,0,0,0,3,0
prginpsysaa ds 4
prginpsysab ds 4
prginpsysac ds 4
prginpsysad ds 4
prginpsysae ds 4

prgobjsysba dw prginpsysba,0,0,0,0,31,0
prgobjsysbb db "exe",0
prginpsysba ds 256

prgobjsys5  dw 0,0,sysentlst,0,256*0+2,sysentrow,0,1
sysentrow   dw 0,40,00,0, 0,80,00,0
sysentlst   dw 00,20*00+sysentext,0, 01,20*01+sysentext,0, 02,20*02+sysentext,0, 03,20*03+sysentext,0
            dw 04,20*04+sysentext,0, 05,20*05+sysentext,0, 06,20*06+sysentext,0, 07,20*07+sysentext,0
            dw 08,20*08+sysentext,0, 09,20*09+sysentext,0, 10,20*10+sysentext,0, 11,20*11+sysentext,0
            dw 12,20*12+sysentext,0, 13,20*13+sysentext,0, 14,20*14+sysentext,0, 15,20*15+sysentext,0

;### FONTS ####################################################################

prgwinfnt   dw #1501,0,50,5,128,159,0,0,128,159,128,159,128,159,prgicnfnt2,prgtitfnt,0,0,prggrpfnt,0,0:ds 136+14
prggrpfnt   db 20,0:dw prgdatfnt,0,0,3*256+2,0,0,0
prgdatfnt   
dw 00,     255*256+0, 2,           0,0,1000,1000,0      ;00=Hintergrund
dw fntoky, 255*256+16,prgbuttxt1,  22,144,32, 12,0      ;01="Ok"-Button
dw fntcnc, 255*256+16,prgbuttxt2,  57,144,32, 12,0      ;02="Cancel"-Button
dw fntapl, 255*256+16,prgbuttxt3,  92,144,32, 12,0      ;03="Apply"-Button
dw 00,     255*256+1, prgobjlnk0a,  5, 3, 112, 8,0      ;04=Beschreibung Font-Erscheinung
dw 00,     255*256+2, 3+4+0+64   ,  4,12 ,120,85,0      ;05=Box Fontanzeige
dw 00,     255*256+5, prgobjfnt1a,  8,15, 112, 8,0      ;06=Beschreibung Font-Zeile 1
dw 00,     255*256+5, prgobjfnt1b,  8,24, 112, 8,0      ;07=Beschreibung Font-Zeile 2
dw 00,     255*256+5, prgobjfnt1c,  8,33, 112, 8,0      ;08=Beschreibung Font-Zeile 3
dw 00,     255*256+5, prgobjfnt1d,  8,42, 112, 8,0      ;09=Beschreibung Font-Zeile 4
dw 00,     255*256+5, prgobjfnt1e,  8,51, 112, 8,0      ;10=Beschreibung Font-Zeile 5
dw 00,     255*256+5, prgobjfnt1f,  8,60, 112, 8,0      ;11=Beschreibung Font-Zeile 6
dw 00,     255*256+5, prgobjfnt1g,  8,76, 112, 8,0      ;12=Beschreibung Font-Zeile 7
dw 00,     255*256+5, prgobjfnt1h,  8,86, 112, 8,0      ;13=Beschreibung Font-Zeile 8
dw 00,     255*256+0, 1,            8,72, 112, 1,0      ;14=Trennlinie
dw 00,     255*256+1, prgobjfnt0b,  5,101,112, 8,0      ;15=Beschreibung Laden
dw 00,     255*256+32,prgobjfnt2a,  4,111,120,12,0      ;16=Input Fontpfad
dw fntbrw, 255*256+16,prgtxtlnk5c,  4,125, 45,12,0      ;17="Browse..."-Button
dw fntlod, 255*256+16,prgbuttxt4,   51,125, 45,12,0     ;18="Load"-Button
dw 00,     255*256+0, 1,            4,139,120, 1,0      ;19=Trennlinie

prgobjlnk0a dw prgtxtfnt0a,2+4
prgobjfnt0b dw prgtxtfnt0b,2+4

prgobjfnt1a dw prgtxtfnt1a,0+4,0
prgobjfnt1b dw prgtxtfnt1b,0+4,0
prgobjfnt1c dw prgtxtfnt1c,0+4,0
prgobjfnt1d dw prgtxtfnt1d,0+4,0
prgobjfnt1e dw prgtxtfnt1e,0+4,0
prgobjfnt1f dw prgtxtfnt1f,0+4,0
prgobjfnt1g dw prgtxtfnt1g,0+4,0
prgobjfnt1h dw prgtxtfnt1h,0+4,0

prgobjfnt2a dw prginpfnt2b,0,0,0,0,255,0
prginpfnt2a db "fnt",0
prginpfnt2b ds 256

;### CONFIG ###################################################################
cfgdevlet   equ 0       ;Buchstabe
cfgdevflg   equ 1       ;[Bit0-3]=Typ (0=FDC, 1=IDE), [Bit7]=Wechseldatenträger
cfgdevsub   equ 2       ;Sublaufwerk (Laufwerk/Kopf bzw. Partition/Kanal)
cfgdevres   equ 3       ;*reserviert (1 Byte)*
cfgdevnam   equ 4       ;Name
cfgdevlen   equ 16
cfgdevmem   db "A",0+128,0,0,"Floppy A",0,0,0,0
            db "B",0+128,1,0,"Floppy B",0,0,0,0
            ds 6*cfgdevlen
cfgbgrmem   db 0:ds 32

keyold  ds 2
keydef  ds 4*80
keydsp  db 20   ;Tastatur-Delay-Speed
keyrsp  db 1    ;Tastatur-Repeat-Speed
mosdsp  db 16   ;Maus-Verzögerung
mosrsp  db 4    ;Maus-Geschwindigkeit
mosfac  db 20   ;Maus-PS2-Geschwindigkeits-Faktor
mosdcs  db 10   ;Maus-Doppelclick-Verzögerung
mosswp  db 0    ;Flag, ob Maustasten vertauschen
moswfc  db 0    ;Rad-Geschwindigkeit

prgmsginf  dw prgmsginf1,4*1+2,prgmsginf2,4*1+2,prgmsginf3,4*1+2,prgicnbig
prgmsgwpf  dw prgmsgwpf1,4*1+2,prgmsgwpf2,4*1+2,prgmsgwpf3,4*1+2
prgdeverr  dw prgerrdev1,4*1+2,prgerrdev2,4*1+2,prgerrdev3,4*1+2

cfgselflg   db 0

cfgmem
cfgbotdrv   db "A"  ;SYMBOS.INI Laufwerk
cfgflags1   db 0    ;Flags -> [b0]=Autosave Config, [b1]=use maximum memory for file selection
cfgextflg   db 0    ;Flags, ob SymbOS Extension geladen wird
cfghrdflg   db 0    ;Hardware flags (+1=Proportional Mouse, +2=Real Time clock, +4=Mass Storage Device, +8=GFX9000)
cfgfdctry   db 6    ;Device   -> Anzahl Wiederholungs-Versuche bei FDC-Sector-Fehler
cfgicnanz   db 4    ;Desktop  -> Anzahl Icons
cfgmenanz   db 6    ;Desktop  -> Anzahl Startmenu-Programm-Einträge
cfglstanz   db 0    ;Desktop  -> Anzahl Taskleisten-Shortcuts
cfgcpctyp   db 0    ;Hardware -> Computer-Typ
cfgicnpos   dw 000,000
            dw 000,044
            dw 000,088
            dw 000,132
            dw 052,000
            dw 052,044
            dw 052,088
            dw 052,132

prgtrnend

relocate_table
relocate_end
