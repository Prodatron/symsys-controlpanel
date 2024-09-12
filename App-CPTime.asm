;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                           DATE AND TIME SETTINGS                           @
;@                                                                            @
;@             (c) 2004-2007 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;Todo
;+ Wochennummern bei manchen Jahren falsch

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
            db "CP:Time and Date":ds 8:db 0   ;Name
            db 1                    ;flags (+1=16c icon)
            dw prgicn16c-prgcodbeg  ;16 colour icon offset
            ds 5                    ;*reserved*
prgmemtab   db "SymExe10"           ;SymbOS-EXE-Kennung                 POST Tabelle Speicherbereiche
            dw 0                    ;zusätzlicher Code-Speicher
            dw 0                    ;zusätzlicher Data-Speicher
            dw 0                    ;zusätzlicher Transfer-Speicher
            ds 26                   ;*reserviert*
            db 0,3                  ;required OS version (3.0)
prgicntim2  db 2,8,8,#33,#CC,#47,#A6,#8F,#97,#CB,#B5,#9E,#1F,#AD,#1F,#47,#A6,#33,#CC
prgicntim1  db 6,24,24,#77,#FF,#DD,#FF,#FF,#80,#46,#0A,#3D,#0A,#0A,#C8,#C5,#05,#35,#05,#05,#AC,#C6,#68,#3D,#1A,#C2,#BE,#C5,#E1,#41,#B4,#E1,#BE,#C6,#E0,#78,#B0,#68,#BE,#C5,#61,#35,#05,#61,#BE,#C6,#68,#7F,#CE,#C2,#BE
            db #C5,#71,#8F,#3E,#C1,#BE,#C6,#6B,#3D,#8F,#82,#BE,#C5,#47,#C0,#67,#49,#BE,#C6,#9E,#10,#11,#2C,#BE,#C5,#AC,#00,#00,#AD,#BE,#D7,#2C,#10,#00,#9E,#BE,#D5,#48,#10,#88,#56,#BE,#F7,#58,#10,#D0,#56,#BE
            db #F3,#48,#22,#00,#56,#3E,#F3,#2C,#44,#00,#9E,#FE,#F0,#AC,#00,#00,#BC,#F0,#70,#9E,#10,#11,#3C,#E0,#00,#47,#C4,#67,#48,#00,#00,#23,#3F,#8F,#80,#00,#00,#11,#8F,#3C,#00,#00,#00,#00,#70,#C0,#00,#00


;### PRGPRZ -> Programm-Prozess
prgwinanz   equ 7
prgwin      db 0            ;Nummer des Haupt-Fensters

dskprzn     db 2
sysprzn     db 3
windatprz   equ 3           ;Prozeßnummer

prgid   db "CP:Time and "

prgprz  call prgdbl
        ld a,(prgprzn)
        ld (prgwintim+windatprz),a
        call timini

        ld bc,256*DSK_SRV_SCRCNV+MSC_DSK_DSKSRV
        ld de,gfxcnvtab
        ld hl,(prgbnknum)
        call msgsnd
        rst #30

        ld c,MSC_DSK_WINOPN
        ld a,(prgbnknum)
        ld b,a
        ld de,prgwintim
        call msgsnd
prgprz1 call msgdsk             ;Message holen -> IXL=Status, IXH=Absender-Prozeß
        cp MSR_DSK_WOPNER
        jp z,prgend             ;kein Speicher für Fenster -> Prozeß beenden
        cp MSR_DSK_WOPNOK
        jr nz,prgprz1           ;andere Message als "Fenster geöffnet" -> ignorieren
        ld a,(prgmsgb+4)
        ld (prgwin),a           ;Fenster wurde geöffnet -> Nummer merken

        ld c,MSC_KRL_TMADDT     ;Timer (1/Sekunde) hinzufügen
        ld hl,timupdc
        ld a,(prgbnknum)
        ld e,a
        ld a,(prgprzn)
        ld d,a
        ld a,50
        call msgkrl

prgprz0 call msgget
        jr nc,prgprz0
        cp MSC_GEN_FOCUS        ;*** Application soll sich Focus nehmen
        jp z,prgfoc
        cp MSR_DSK_WCLICK       ;*** Fenster-Aktion wurde geklickt
        jr nz,prgprz0
        ld a,(iy+2)
        cp DSK_ACT_CLOSE        ;*** Close wurde geklickt
        jp z,timcnc
        cp DSK_ACT_CONTENT      ;*** Inhalt wurde geklickt
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
        cp 43
        jp c,timday     ;000-042 = Kalender
prgsub5 jp (hl)

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

;### MSGKRL -> Message an Kernel senden
;### Eingabe    C=Commando, HL,DE,A=Parameter
;### Ausgabe    HL=Rückgabe
;### Veraendert AF,BC,DE,IX,IY
msgkrl  ld iy,prgmsgb
        ld (iy+0),c
        ld (iy+1),l
        ld (iy+2),h
        ld (iy+3),e
        ld (iy+4),d
        ld (iy+5),a
        ld a,c
        add 128
        ld (msgkrln),a
        db #dd:ld h,1       ;1 is the number of the kernel process
        ld a,(prgprzn)
        db #dd:ld l,a
        rst #10
msgkrl1 db #dd:ld h,1       ;1 is the number of the kernel process
        ld a,(prgprzn)
        db #dd:ld l,a
        rst #08             ;wait for a kernel message
        db #dd:dec l
        jr nz,msgkrl1
        ld a,(msgkrln)
        cp (iy+0)
        jr nz,msgkrl1
        ld l,(iy+1)
        ld h,(iy+2)
        ret
msgkrln db 0

;### MSGGET -> Message für Programm abholen
;### Ausgabe    CF=0 -> keine Message vorhanden, CF=1 -> IXH=Absender, (recmsgb)=Message, A=(recmsgb+0), IY=recmsgb
;### Veraendert 
msgget  db #dd:ld h,-1
msgget1 push ix
        call timupd0
        rst #30
        pop ix
        ld a,(prgprzn)
        db #dd:ld l,a           ;IXL=Rechner-Prozeß-Nummer
        ld iy,prgmsgb           ;IY=Messagebuffer
        rst #18
        or a
        db #dd:dec l
        ret nz
        ld iy,prgmsgb
        ld a,(iy+0)
        or a
        jp z,prgend
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
        ld (iy+0),c
        ld (iy+1),b
        ld (iy+2),e
        ld (iy+3),d
        ld (iy+4),l
        ld (iy+5),h
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


;==============================================================================
;### TIME AND DATE-FENSTER ####################################################
;==============================================================================

timdchg db 0    ;Flag, ob Uhrzeit geändert wurde (-> kein Refresh mehr über System-Uhr)
timdhou db 0    ;ausgewählte Stunde
timdmin db 0    ;ausgewählte Minute
timdsec db 0    ;ausgewählte Sekunde
timdzon db 0    ;ausgewählte Zeitzone
timdmon db 0    ;ausgewählter Monat
timdday db 0    ;ausgewählter Tag
timdold db 0    ;alter Tag
timdyea dw 0    ;ausgewähltes Jahr
timdmax db 0    ;Anzahl Tage des Monats
timdbeg db 0    ;Wochentag vom 1. des Monats


;### TIMINI -> TimeDate-Fenster initialisieren
timini  rst #20:dw jmp_timget   ;A=Sekunden, B=Minuten, C=Stunden, D=Tag (ab 1), E=Monat (ab 1), HL=Jahr, IXL=Timezone (-12 bis +13)
        ld (timdsec),a
        ld (timdhou),bc
        xor a
        ld (timdchg),a
        push ix
        call timcal
        pop ix
        call timini0
        db #dd:ld a,l
        add 12                  ;A=Zeitzone ab +00 statt ab -12
        ld c,a
        ld (timzonobj+12),a
        ld a,c
        sub 2
        jr nc,timini1
        xor a
timini1 ld (timzonobj+2),a
        ld de,4
        inc c
        ld hl,timzonlst+1
        ld b,26
timini2 ld a,(hl)
        and #3f
        ld (hl),a
        dec c
        jr nz,timini3
        or 128
        ld (hl),a
timini3 add hl,de
        djnz timini2
        jp timclk
timini0 db #dd:ld a,l
        ld (timdzon),a
        dec a
        jp p,timini4
        add 24                  ;A immer 0-23
timini4 cp 24
        jr c,timini6
        xor a
timini6 ld l,a
        ld h,0
        ld bc,sprtimmap
        add hl,bc
        ld (sprtimmap1+3),hl    ;Zeitzone ist Offset für erste Graphic
        neg
        add 24
        ld c,a
        add a:add a
        ld (sprtimmap1+1),a     ;Breite = (24-Zeitzone)*4
        ld a,c
        add a:add a
        add 5
        ld (prgdattimc1),a      ;Position von zweiter Grafik = 6+Breite erste Grafik
        neg
        add 103                 ;Breite von zweiter Grafik = 98-Position
        ld (sprtimmap2+1),a
        ld a,10
        jr nz,timini5
        ld a,64                 ;falls 0, deaktivieren
timini5 ld (prgdattimc1-4),a
        ret

;### TIMANZ -> Anzahl Tage des Monats holen
;### Eingabe    HL=Jahr, E=Monat (ab 1)
;### Ausgabe    A=Anzahl Tage
;### Veraendert F,DE,HL
timanzm db 31,0,31,30,31,30,31,31,30,31,30,31
timanz  ld a,l
        and 3
        ld a,28
        jr nz,timanz1
        inc a
timanz1 ld (timanzm+1),a
        ld hl,timanzm-1
        ld d,0
        add hl,de
        ld a,(hl)
        ret

;### TIMCLK -> Uhr intern aufbauen
;### Verändert  AF,BC,DE,HL,IX,IY
timclkf dw 0*45+sprtimfntspr,1*45+sprtimfntspr,2*45+sprtimfntspr,3*45+sprtimfntspr,4*45+sprtimfntspr
        dw 5*45+sprtimfntspr,6*45+sprtimfntspr,7*45+sprtimfntspr,8*45+sprtimfntspr,9*45+sprtimfntspr
timclkb ds 6*2              ;wert+1, adresse, flag ob änderung

timclk  ld bc,-48*256-48
        ld ix,timclkb-2
        ld iy,prgdattima1-16
        ld a,(timdhou):cp 24:call timclk0
        ld a,(timdmin):cp 60:call timclk0
        ld a,(timdsec):cp 60
timclk0 jr c,timclk2
        xor a
timclk2 call clcdez
        add hl,bc
        ld a,l
        call timclk1
        ld a,h
timclk1 inc ix
        inc ix
        ld de,16
        add iy,de
        inc a
        cp (ix+0)
        ld (ix+1),0
        ret z
        ld (ix+0),a
        ld (ix+1),1
        add a
        ld de,timclkf-2
        add e
        ld e,a
        ld a,0
        adc d
        ld d,a
        ld a,(de)
        ld (iy+4),a
        inc de
        ld a,(de)
        ld (iy+5),a
        ret

;### TIMCAL -> Kalender intern aufbauen
;### Eingabe    D=Tag (ab 1), E=Monat (ab 1), HL=Jahr
;### Veraendert AF,BC,DE,HL,IX,IY
timdatmtab  dw timdatmt01,timdatmt02,timdatmt03,timdatmt04,timdatmt05,timdatmt06
            dw timdatmt07,timdatmt08,timdatmt09,timdatmt10,timdatmt11,timdatmt12
timdatdtab  dw timdatdt0, timdatdt1, timdatdt2, timdatdt3, timdatdt4, timdatdt5, timdatdt6

timcal  ld a,d:dec a:cp 31:jr c,timcal6:ld d,1
timcal6 ld a,e:dec a:cp 12:jr c,timcal7:ld e,1
timcal7 ld (timdmon),de
        push de
        ex de,hl
        ld hl,1980-1
        or a
        sbc hl,de
        ld hl,1980
        jr nc,timcal8       ;1979>=year -> set year to 1980
        ld hl,2100
        or a
        sbc hl,de
        ex de,hl
        jr nc,timcal8
        add hl,de           ;2100<year  -> set year to 2100
timcal8 ld (timdyea),hl
        push hl
        ld hl,prgdattimb1+4         ;*** Kalenderblatt löschen
        ld a,6*7
        ld de,0*4+timdatnum
        ld bc,16-1
timcal1 ld (hl),e
        inc hl
        ld (hl),d
        add hl,bc
        dec a
        jr nz,timcal1
        pop hl
        pop de
        push hl
        push de
        ld d,1
        call timgdy
        ld (timdbeg),a
        add a:add a:add a:add a
        ld l,a
        ld h,0
        ld de,prgdattimb1+4
        add hl,de
        ld c,l
        ld b,h                      ;BC=Zeiger auf ersten Tag
        pop de
        pop hl
        push hl
        push de
        call timanz                 ;A=Anzahl Tage
        ld (timdmax),a
        ld hl,(timdday)
        cp l
        jr nc,timcal4
        ld (timdday),a
timcal4 ld de,1*4+timdatnum         ;DE=Zeiger auf Nummern-Datensaetze
        ld l,c
        ld h,b                      ;HL=Zeiger auf ersten Tag
        ld bc,16-1
timcal2 ld (hl),e                   ;*** Kalenderblatt füllen
        inc hl
        ld (hl),d
        add hl,bc
        inc de:inc de:inc de:inc de
        dec a
        jr nz,timcal2
        pop de
        pop hl
        push de                     ;*** Wochenspalte füllen
        call timgwk                 ;C=erste Wochennummer
        ld b,6
        ld iy,timwektxt             ;IY=Text
        ld de,3
timcal5 ld a,c
        inc c
        call clcdez
        ld (iy+0),l
        ld (iy+1),h
        add iy,de
        djnz timcal5
        pop de
        ld d,0
        ld hl,timdatmtab-2
        add hl,de
        add hl,de
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld (timdatmdt),hl
timcal0 ld de,(timdmon)             ;*** volles Datum anzeigen
        ld hl,(timdyea)
        call timgdy
        add a
        ld l,a
        ld h,0
        ld de,timdatdtab
        add hl,de                   ;HL=Zeiger auf Wochentag-Name
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld de,timdatftx
timcal3 ld a,(hl)
        ldi
        or a
        jr nz,timcal3
        db #fd:ld l,e
        db #fd:ld h,d
        ld (iy-1),","
        ld (iy+0)," "
        ld (iy+3),"."
        ld (iy+6),"."
        ld a,(timdold)
        ld de,timdatnum+2
        add a
        add a
        ld l,a
        ld h,0
        add hl,de
        ld (hl),4+128
        ld a,(timdday)
        ld (timdold),a
        ld l,a
        ld h,0
        add hl,hl:add hl,hl
        add hl,de
        ld (hl),1+8+128
        call clcdez
        ld (iy+1),l
        ld (iy+2),h
        ld a,(timdmon)
        call clcdez
        ld (iy+4),l
        ld (iy+5),h
        ld bc,7
        add iy,bc
        push iy
        ld ix,(timdyea)
        ld e,4
        ld hl,jmp_clcnum
        rst #28
        pop hl
        ld de,timdatytx
        ld bc,4
        ldir
        ret

;### TIMGDY -> Wochen-Tag errechnen
;### Eingabe    D=Tag (ab 1), E=Monat (ab 1), HL=Jahr
;### Ausgabe    A=Wochentag (0-6; 0=Montag)
;### Veraendert F,BC,DE,HL
timgdyn db 0,3,3,6,1,4,6,2,5,0,3,5
timgdys db 0,3,4,0,2,5,0,3,6,1,4,6
timgdy  ld bc,1980
        or a
        sbc hl,bc
        ld b,l          ;B=Jahre seit 1980
        ld c,3          ;A=Schaltjahr-Checker
        ld a,1          ;A=Wochentag (01.01.1980 war Dienstag)
        inc b
timgdy1 dec b
        jr z,timgdy3
        inc a           ;neues Jahr -> Wochentag+1
        inc c
        bit 2,c
        jr z,timgdy2
        ld c,0          ;Schaltjahr -> Wochentag+2
        inc a
timgdy2 cp 7
        jr c,timgdy1
        sub 7
        jr timgdy1
timgdy3 ld b,a          ;B=Wochentag vom 1.1. des Jahres
        ld a,c
        cp 3
        ld hl,timgdyn
        jr nz,timgdy4
        ld hl,timgdys
timgdy4 ld a,d
        dec a
        ld d,0
        dec e
        add hl,de
        add (hl)
        add b
timgdy5 sub 7
        jr nc,timgdy5
        add 7
        ret

;### TIMGWK -> Wochen-Nummer errechnen
;### Eingabe    E=Monat (ab 1), HL=Jahr
;### Ausgabe    C=Wochennummer (ab 1)
;### Verändert  F,BC,DE,HL
timgwk  push de
        push hl
        ld de,#101
        call timgdy
        add 1-7
        pop hl
        pop de              ;E=Monatszaehler, HL=Jahr
        ld b,1              ;B=Monatsnummer
        ld c,b              ;C=Wochennummer
timgwk1 ld d,a              ;D=Wochentag 1.1.
        dec e
        ret z
        inc e
        push de
        push hl
        ld e,b
        inc b
        call timanz
        pop hl
        pop de
        dec e
        add d
timgwk2 inc c
        sub 7
        jr z,timgwk1
        jr c,timgwk1
        jr timgwk2

;### TIMACT -> Time-Settings übernehmen
timact  ld a,(timdzon)
        db #dd:ld l,a
        ld a,(timdsec)
        ld bc,(timdhou)
        ld de,(timdmon)
        ld hl,(timdyea)
        rst #20:dw jmp_timset
        xor a
        ld (timdchg),a
        ret

;### TIMAPL -> Time-Fenster APPLY-Button
timapl  call timact
        jp prgprz0

;### TIMOKY -> Time-Fenster OK-Button
timoky  call timact
timoky1 jp prgend

;### TIMCNC -> Time-Fenster CANCEL/CLOSE-Button
timcnc  jr timoky1

;### TIMTAB -> Tab wurde geklickt
timacttab db 0                  ;aktueller Tab

timtab  ld a,(timtabdat0)       ;*** Tab angeklickt
        ld hl,timacttab
        cp (hl)
        jp z,prgprz0            ;gleicher wie aktueller -> nichts machen
        ld (hl),a
        cp 1
        ld hl,prggrptima
        jr c,timtab1
        ld hl,prggrptimc
        jr nz,timtab1        ;##!!## datum update
        rst #20:dw jmp_timget
        call timcal
        ld hl,prggrptimb
timtab1 ld (prgwintim0),hl      ;Tab wechseln
        ld e,-1
timtab3 call timtab2
        jp prgprz0
;E=Objekt/-1 -> ein/alle Objekt(e) des Display-Fensters neu aufbauen
timtab2 ld c,MSC_DSK_WININH
timtab4 ld a,(prgwin)
        or a
        ret z
        ld b,a
        jp msgsnd

;### TIMDAY -> Tag in Kalender wurde geklickt
;### Eingabe    A=Day-Nummer (1-42)
timday  dec a
        ld c,a
        ld a,(timdbeg)
        neg
        add c
        jp m,prgprz0
        ld c,a
        ld a,(timdmax)
        inc c
        cp c
        jp c,prgprz0
        ld a,(timdold)
        ld b,a              ;b=old
        ld a,c              ;c=new
        ld (timdday),a
        push bc
        call timcal0        ;Anzeige intern refreshen
        pop bc
        push bc
        ld a,(timdbeg)
        add b
        add 26
        ld e,a
        call timtab2
        pop bc
        ld a,(timdbeg)
        add c
        add 26
        ld e,a
        call timtab2
        ld e,20
        jr timtab3

;### TIMZON -> Zeitzone wurde geklickt
timzon  ld hl,(timzonobj+12)
        ld a,l
        sub 12
        ld l,a
        ld a,(timdzon)
        cp l
        jp z,prgprz0            ;keine Änderung -> fertig
        ld a,l
        db #dd:ld l,a
        call timini0
        ld de,256*5+256-2
        call timtab2
        jp prgprz0

;### TIMxyy -> Stunde/Minute/Sekunde erhöhen/erniedrigen
timhde  ld c,-1
timhde1 ld b,24
        ld hl,timdhou
        jr timsin2
timhin  ld c,1
        jr timhde1
timnde  ld c,-1
timnde1 ld b,60
        ld hl,timdmin
        jr timsin2
timnin  ld c,1
        jr timnde1
timsde  ld c,-1
        jr timsin1
timsin  ld c,1
timsin1 ld b,60
        ld hl,timdsec
timsin2 ld a,1
        ld (timdchg),a
        ld a,(hl)
        add c
        cp b
        jr c,timsin3
        dec b
        ld a,c
        cp -1
        ld a,b
        jr z,timsin3
        xor a
timsin3 ld (hl),a
        call timupd
        jp prgprz0

;### TIMUPD0 -> Updated die Uhrzeit-Anzeige 1x pro Sekunde
timupdc db 1
timupd0 ld a,(timacttab)
        or a
        ret nz
        ld a,(timdchg)
        or a
        ret nz
        ld hl,timupdc
        xor a
        cp (hl)
        ret z
        ld (hl),a
        rst #20:dw jmp_timget
        ld (timdsec),a
        ld (timdhou),bc
;### TIMUPD -> Update die Uhrzeit-Anzeige
timupd  call timclk
        ld b,6              ;B=Zähler
        ld c,b              ;C=Objektnummer
        ld hl,timclkb+1     ;(HL)=Flag, ob Änderung
timupd1 xor a
        cp (hl)
        jr z,timupd2
        push bc
        push hl
        ld e,c
        ld c,MSC_DSK_WINDIN
        call timtab4
        pop hl
        pop bc
timupd2 inc hl
        inc hl
        inc c
        djnz timupd1
        ret

;### TIMMDE -> ein Monat weniger
timmde  ld a,(timdmon)
        sub 1
        jr nz,timmde1
        call timyde0
        ld a,12
timmde1 ld (timdmon),a
timref  ld hl,(timdyea)
        ld de,(timdmon)
        call timcal
        ld e,-16
        ld d,18
        call timtab2
        ld e,-16
        ld d,18+16
        call timtab2
        ld e,-16
        ld d,18+32
        call timtab2
        ld e,-3
        ld d,18+48
        jp timtab3

;### TIMMIN -> ein Monat mehr
timmin  ld a,(timdmon)
        inc a
        cp 13
        jr c,timmde1
        call timyin0
        ld a,1
        jr timmde1

;### TIMYDE -> ein Jahr weniger
timyde  call timyde0
        jr timref
timyde0 ld hl,(timdyea)
        dec hl
        ld de,1980
        or a
        sbc hl,de
        jr nc,timyde1
        ld hl,2099-1980
timyde1 add hl,de
        ld (timdyea),hl
        ret

;### TIMYIN -> ein Jahr mehr
timyin  call timyin0
        jr timref
timyin0 ld hl,(timdyea)
        inc hl
        ld de,2100
        or a
        sbc hl,de
        jr c,timyin1
        ld hl,1980-2100
timyin1 add hl,de
        ld (timdyea),hl
        ret


;==============================================================================
;### DATEN-TEIL ###############################################################
;==============================================================================

prgdatbeg

prgicn16c db 12,24,24:dw $+7:dw $+4,12*24:db 5     ;Datum/Uhrzeit
db #83,#33,#33,#33,#33,#83,#33,#33,#33,#33,#18,#88,#83,#E8,#E8,#E8,#EE,#13,#E8,#E8,#E8,#E8,#31,#88,#13,#8E,#8E,#8E,#8E,#13,#8E,#8E,#8E,#8E,#32,#18,#13,#E8,#E1,#18,#EE,#13,#E8,#E1,#11,#E8,#32,#31
db #13,#8E,#11,#1E,#81,#8E,#1E,#11,#11,#1E,#32,#31,#13,#E8,#11,#18,#E1,#11,#18,#11,#E1,#18,#32,#31,#13,#8E,#81,#1E,#8E,#13,#8E,#8E,#81,#1E,#32,#31,#13,#E8,#E1,#18,#E3,#33,#33,#E8,#11,#E8,#32,#31
db #13,#8E,#81,#13,#32,#22,#22,#31,#11,#8E,#32,#31,#13,#E8,#E1,#32,#22,#13,#32,#22,#18,#E8,#32,#31,#13,#8E,#83,#22,#11,#CC,#C3,#32,#21,#8E,#32,#31,#13,#E8,#32,#21,#CC,#C1,#CC,#C3,#22,#18,#32,#31
db #13,#8E,#32,#1C,#CC,#CC,#CC,#CC,#32,#1E,#32,#31,#13,#E3,#22,#1C,#CC,#C1,#CC,#CC,#32,#21,#32,#31,#13,#83,#21,#CC,#CC,#C1,#3C,#CC,#C3,#21,#32,#31,#13,#33,#21,#C1,#CC,#C1,#11,#C1,#C3,#21,#32,#31
db #11,#33,#21,#CC,#CC,#3C,#CC,#CC,#C3,#21,#22,#31,#11,#33,#22,#1C,#C3,#CC,#CC,#CC,#32,#21,#33,#31,#11,#11,#32,#1C,#CC,#CC,#CC,#CC,#32,#11,#11,#11,#81,#11,#32,#21,#CC,#C1,#CC,#C3,#22,#11,#11,#18
db #88,#88,#83,#22,#13,#CC,#C3,#32,#21,#88,#88,#88,#88,#88,#88,#32,#22,#33,#32,#22,#18,#88,#88,#88,#88,#88,#88,#83,#32,#22,#22,#11,#88,#88,#88,#88,#88,#88,#88,#88,#81,#11,#11,#88,#88,#88,#88,#88

prgbuttxt1 db "Ok",0
prgbuttxt2 db "Cancel",0
prgbuttxt3 db "Apply",0

prgtittim db "Date and Time",0

;### TIME AND DATE #############################################################

timtabtxt1 db "Time",0
timtabtxt2 db "Date",0
timtabtxt3 db "Zone",0

timwektxt  db "01",0,"02",0,"03",0,"04",0,"05",0,"06",0
timdattxt
db  " ",0,0,"1",0,0,"2",0,0,"3",0,0,"4",0,0,"5",0,0,"6",0,0,"7",0,0,"8",0,0,"9",0,0
db "10",0, "11",0, "12",0, "13",0, "14",0, "15",0, "16",0, "17",0, "18",0, "19",0
db "20",0, "21",0, "22",0, "23",0, "24",0, "25",0, "26",0, "27",0, "28",0, "29",0
db "30",0, "31",0
timdattxw db "W",0,"M",0,"T",0,"W",0,"T",0,"F",0,"S",0,"S",0
timdatytx db "    ",0

timtxtchr  db "Hour",0
timtxtcmn  db "Min.",0
timtxtcsc  db "Sec.",0

timdatmt01 db "January",0:  timdatmt02 db "February",0: timdatmt03 db "March",0
timdatmt04 db "April",0:    timdatmt05 db "May",0:      timdatmt06 db "June",0
timdatmt07 db "July",0:     timdatmt08 db "August",0:   timdatmt09 db "September",0
timdatmt10 db "October",0:  timdatmt11 db "November",0: timdatmt12 db "December",0
timdatdt0  db "Monday",0:   timdatdt1  db "Tuesday",0:  timdatdt2  db "Wednesday",0:timdatdt3  db "Thursday",0
timdatdt4  db "Friday",0:   timdatdt5  db "Saturday",0: timdatdt6  db "Sunday",0

timzontxta db "-12 Int.Dateline",0
timzontxtb db "-11 Midway Island",0
timzontxtc db "-10 Hawaii",0
timzontxtd db "-09 Alaska",0
timzontxte db "-08 Los Angeles",0
timzontxtf db "-07 Denver, Arizona",0
timzontxtg db "-06 Chicago",0
timzontxth db "-05 New York",0
timzontxti db "-04 Santiago",0
timzontxtj db "-03 Buenos Aires",0
timzontxtk db "-02 Middle Atlantic",0
timzontxtl db "-01 Azores, Cabo Verde",0
timzontxtm db "+00 London, Lissabon",0
timzontxtn db "+01 Amsterdam, Berlin",0
timzontxto db "+02 Kiev, Helsinki",0
timzontxtp db "+03 Constantinople",0
timzontxtq db "+04 Tiflis",0
timzontxtr db "+05 Maldives",0
timzontxts db "+06 Astana",0
timzontxtt db "+07 Bangkok, Hanoi",0
timzontxtu db "+08 Beijing, Perth",0
timzontxtv db "+09 Tokyo, Seoul",0
timzontxtw db "+10 Sydney",0
timzontxtx db "+11 New Caledonia",0
timzontxty db "+12 Auckland",0
timzontxtz db "+13 Nuku'alofa",0

gfxcnvtab
dw icndatslf0,icndatslf+9:db 4,8,8,8*2
dw icndatsrg0,icndatsrg+9:db 4,8,8,8*2
dw 0

icndatslf   db 2,8,8:dw icndatslf+10,icndatslf+9,2*8:db 0:ds 2*8
icndatslf0  db #FF,#FF,#88,#90,#98,#90,#B8,#F0,#B8,#F0,#98,#90,#88,#90,#F0,#F0        ;Links
icndatsrg   db 2,8,8:dw icndatsrg+10,icndatsrg+9,2*8:db 0:ds 2*8
icndatsrg0  db #FF,#FF,#88,#90,#88,#D0,#B8,#F0,#B8,#F0,#88,#D0,#88,#90,#F0,#F0        ;Rechts

sprtimfntspr
db 3,12,14,#11,#E1,#00,#30,#F0,#88,#61,#10,#84,#6A,#00,#C0,#C8,#00,#C0,#C0,#00,#CA,#C0,#00,#CA,#C0,#00,#CA,#C0,#00,#CA,#C8,#00,#C0,#6A,#00,#C0,#61,#10,#84,#30,#F0,#88,#11,#E1,#00
db 3,12,14,#00,#6C,#00,#34,#E0,#00,#70,#E0,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#00,#60,#00,#74,#F0,#C2,#74,#F0,#E2
db 3,12,14,#11,#F1,#00,#34,#F0,#80,#60,#01,#C0,#C2,#00,#C0,#C8,#00,#C8,#00,#00,#C0,#00,#12,#C4,#00,#74,#08,#00,#E8,#00,#10,#84,#00,#34,#00,#00,#CA,#00,#00,#F0,#F0,#C0,#F0,#F0,#C0
db 3,12,14,#32,#F1,#00,#78,#F0,#84,#E8,#01,#C0,#00,#00,#CA,#00,#00,#C2,#00,#17,#C0,#11,#F0,#80,#00,#F8,#C4,#00,#00,#C2,#00,#00,#60,#00,#00,#60,#0C,#00,#EA,#F0,#F0,#C0,#74,#F1,#08
db 3,12,14,#00,#30,#80,#00,#74,#80,#00,#7A,#80,#00,#D0,#80,#11,#90,#80,#10,#98,#80,#30,#10,#80,#24,#10,#80,#60,#10,#80,#78,#F0,#C0,#78,#F0,#C0,#00,#10,#80,#00,#74,#C0,#00,#70,#C0
db 3,12,14,#70,#F0,#84,#70,#F0,#84,#60,#00,#00,#60,#00,#00,#60,#4E,#00,#70,#F0,#08,#70,#9E,#84,#00,#00,#C0,#00,#00,#CA,#00,#00,#CA,#00,#00,#C0,#C0,#01,#C0,#F0,#F0,#80,#74,#F1,#00
db 3,12,14,#00,#34,#C2,#00,#F0,#E0,#10,#C4,#00,#30,#08,#00,#65,#00,#00,#60,#79,#00,#70,#F0,#C4,#70,#88,#C0,#61,#00,#60,#60,#00,#60,#64,#00,#60,#30,#00,#EA,#32,#F0,#C0,#01,#F0,#88
db 3,12,14,#70,#F0,#E0,#70,#F0,#E0,#60,#00,#60,#00,#00,#62,#00,#00,#C8,#00,#00,#C0,#00,#01,#84,#00,#10,#80,#00,#10,#88,#00,#32,#00,#00,#30,#00,#00,#25,#00,#00,#60,#00,#00,#62,#00
db 3,12,14,#12,#F1,#00,#74,#F0,#84,#68,#01,#C0,#C0,#00,#CA,#C0,#00,#C2,#71,#1F,#C0,#74,#F0,#80,#70,#F0,#C4,#68,#01,#C0,#C0,#00,#CA,#C0,#00,#CA,#68,#01,#C0,#74,#F0,#84,#12,#F1,#00
db 3,12,14,#11,#F1,#00,#30,#F0,#80,#75,#01,#C0,#60,#00,#4A,#60,#00,#60,#60,#00,#60,#60,#00,#E0,#30,#BE,#E0,#10,#F0,#E8,#00,#4E,#6A,#00,#00,#C0,#06,#32,#84,#70,#F0,#00,#34,#C6,#00

sprtimmap1 db 24,96,50:dw sprtimmap,sprtimmap0,24*50
sprtimmap2 db 24,96,50:dw sprtimmap,sprtimmap0,24*50

sprtimmap0 db 0
sprtimmap
db #F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F1,#1E,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#E3,#00,#6B,#08,#00,#FC,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#87,#09,#08,#00,#00,#30,#F0,#F1,#F0,#D2,#FE,#F0,#D3,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#D3,#8F,#31,#00,#00,#00,#78,#F0,#97,#F0,#F0,#F0,#F0,#F1,#F4,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F7,#FB,#EF,#69,#00,#00,#00,#78,#F0,#F2,#F0,#F0,#F1,#F0,#F0,#BC,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F5,#2F,#AF,#F8,#C2,#00,#00,#F8,#F0,#F0,#F0,#F0,#96,#F0,#84,#01,#F0,#D1,#F0,#F0,#F0
db #F0,#F0,#F0,#93,#EB,#FF,#7C,#E0,#00,#00,#F8,#F0,#F0,#F0,#F0,#78,#F1,#08,#03,#FA,#F0,#F0,#F0,#F0
db #F0,#FC,#F0,#C6,#13,#DF,#12,#F1,#00,#00,#F0,#F0,#F0,#F8,#F0,#F9,#0C,#00,#00,#00,#6E,#7C,#F0,#F0
db #E2,#00,#EF,#EF,#17,#35,#8C,#F0,#00,#10,#F0,#F0,#C2,#32,#F0,#97,#44,#00,#00,#00,#00,#00,#7F,#F8
db #C0,#00,#00,#00,#0C,#01,#C0,#79,#00,#74,#F0,#F0,#84,#01,#EE,#00,#04,#00,#00,#00,#00,#00,#00,#11
db #C8,#00,#00,#06,#00,#01,#C6,#78,#19,#F0,#30,#F0,#89,#19,#08,#00,#00,#00,#00,#00,#00,#00,#00,#07
db #C0,#00,#00,#00,#00,#35,#FF,#F0,#92,#F0,#F0,#E1,#33,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#70
db #C2,#23,#08,#00,#08,#70,#95,#F0,#F6,#F0,#F0,#E0,#33,#0C,#00,#00,#00,#00,#00,#00,#00,#11,#3E,#F0
db #E1,#78,#C4,#00,#00,#36,#84,#74,#F0,#F0,#F0,#78,#39,#00,#00,#00,#00,#00,#00,#00,#11,#F1,#70,#F0
db #F2,#F0,#E0,#00,#00,#01,#80,#32,#F0,#F0,#F1,#7D,#69,#00,#00,#00,#00,#00,#00,#00,#34,#E0,#F8,#F0
db #F0,#F0,#F1,#00,#00,#00,#88,#10,#F0,#F0,#E1,#AF,#75,#00,#00,#00,#00,#00,#00,#00,#13,#F1,#F0,#F0
db #F0,#F0,#F0,#08,#00,#02,#00,#7E,#F0,#F0,#F0,#84,#00,#00,#00,#00,#00,#00,#00,#00,#01,#F0,#F0,#F0
db #F0,#F0,#F0,#80,#00,#13,#09,#C1,#F0,#F0,#F0,#84,#00,#02,#00,#00,#00,#00,#00,#00,#32,#B4,#F0,#F0
db #F0,#F0,#F0,#80,#00,#03,#1D,#F0,#F0,#F0,#F0,#1F,#8C,#72,#09,#02,#00,#00,#00,#00,#75,#F0,#F0,#F0
db #F0,#F0,#F0,#80,#00,#00,#32,#F0,#F0,#F0,#F1,#30,#E7,#04,#11,#08,#00,#00,#00,#06,#F1,#F0,#F0,#F0
db #F0,#F0,#F0,#C4,#00,#00,#30,#F0,#F0,#F0,#F0,#CF,#F8,#8E,#01,#08,#00,#00,#00,#25,#D4,#F0,#F0,#F0
db #F0,#F0,#F0,#C2,#00,#00,#74,#F0,#F0,#F0,#F0,#08,#70,#EB,#00,#00,#00,#00,#00,#34,#3E,#F0,#F0,#F0
db #F0,#F0,#F0,#E1,#00,#27,#78,#F0,#F0,#F0,#E1,#00,#02,#02,#00,#00,#00,#00,#00,#30,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#08,#F0,#FC,#F0,#F0,#F0,#C2,#00,#00,#11,#01,#8C,#00,#00,#00,#34,#F1,#F0,#F0,#F0
db #F4,#F0,#F0,#F0,#C4,#F0,#FC,#F0,#F0,#F0,#C0,#00,#00,#11,#09,#78,#00,#42,#00,#7C,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#E2,#5A,#F7,#F0,#F0,#F0,#C4,#00,#00,#00,#08,#70,#88,#CA,#12,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#9B,#F0,#F0,#F0,#F0,#C0,#00,#00,#00,#9B,#F0,#91,#E1,#32,#F4,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#C3,#F1,#F0,#F0,#F0,#C0,#00,#00,#00,#34,#F0,#D4,#F3,#3A,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#8C,#30,#F0,#F0,#C2,#00,#00,#00,#11,#F0,#F2,#F1,#F8,#F2,#F4,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#84,#03,#F0,#F0,#F1,#ED,#00,#00,#12,#F0,#F0,#E1,#78,#78,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#80,#00,#F8,#F0,#F0,#F0,#00,#00,#74,#F0,#F0,#F1,#6C,#74,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#88,#00,#32,#F0,#F0,#F0,#88,#00,#78,#F0,#F0,#F0,#AD,#3C,#9E,#F0,#F0,#F0
db #78,#F0,#F0,#F0,#F0,#F0,#80,#00,#00,#F0,#F0,#F0,#84,#00,#F0,#F0,#F0,#F0,#F7,#F4,#C6,#7A,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#84,#00,#00,#F0,#F0,#F0,#84,#00,#F8,#F0,#F0,#F0,#F1,#FC,#F0,#F9,#F8,#F0
db #F8,#F0,#F0,#F0,#F0,#F0,#C0,#00,#01,#F0,#F0,#F0,#84,#00,#7A,#F0,#F0,#F0,#F0,#F0,#3D,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E1,#00,#11,#F0,#F0,#F0,#84,#00,#D4,#F0,#F0,#F0,#F0,#C2,#02,#F8,#F0,#F4
db #F0,#F0,#F6,#F0,#F0,#F0,#F1,#00,#11,#F0,#F0,#F0,#C4,#11,#94,#F0,#F0,#F0,#F0,#80,#00,#70,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E1,#00,#34,#F0,#F0,#F0,#C0,#10,#F6,#F0,#F0,#F0,#F0,#00,#00,#30,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E0,#00,#70,#F0,#F0,#F0,#C0,#32,#F0,#F0,#F0,#F0,#F0,#08,#00,#12,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E0,#00,#F0,#F0,#F0,#F0,#C2,#30,#F0,#F0,#F0,#F0,#F0,#89,#08,#30,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E0,#11,#F0,#F0,#F0,#F0,#E1,#F8,#F0,#F0,#F0,#F0,#F0,#FE,#C2,#30,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E2,#32,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F1,#78,#F0,#78
db #F0,#F0,#F0,#F0,#F0,#F0,#E2,#70,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F8,#F1,#F8
db #F0,#F0,#F0,#F0,#F0,#F0,#E2,#78,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#E3,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#C2,#F8,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F2,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#C2,#F2,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#E0,#F8,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#F1,#F8,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
db #F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0


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

;### TIME AND DATE ############################################################

prgwintim  dw #1501,0,32,32,108,125,0,0,108,125,108,125,108,125, prgicntim2,prgtittim,0,0
prgwintim0 dw prggrptima,0,0:ds 136+14

prggrptima db 21,0:dw prgdattima,0,0,4*256+3,0,0,2
prggrptimb db 69,0:dw prgdattimb,0,0,4*256+3,0,0,2
prggrptimc db  8,0:dw prgdattimc,0,0,4*256+3,0,0,2

timtabdat  db 3,2+4+48+64
timtabdat0 db 0:dw timtabtxt1:db -1:dw timtabtxt2:db -1:dw timtabtxt3:db -1

;Time-Tab
prgdattima
dw 00,255*256+0,         2, 0,0,1000,1000,0             ;00=Hintergrund
dw timtab,255*256+20,timtabdat,0,2,108,11,0             ;01=Tab-Leiste
dw timoky,255*256+16,prgbuttxt1, 2,111,33,12,0          ;02="Ok"-Button
dw timcnc,255*256+16,prgbuttxt2,37,111,34,12,0          ;03="Cancel"-Button
dw timapl,255*256+16,prgbuttxt3,73,111,33,12,0          ;04="Apply"-Button
dw 0,255*256+2,49*256+64+128,    2,35,104,46,0          ;05=Uhr Fläche
prgdattima1
dw 0,255*256+8,0*45+sprtimfntspr,08,51,12,14,0          ;06=Uhr Stunde  Ziffer 1
dw 0,255*256+8,1*45+sprtimfntspr,20,51,12,14,0          ;07=Uhr Stunde  Ziffer 2
dw 0,255*256+8,2*45+sprtimfntspr,42,51,12,14,0          ;08=Uhr Minute  Ziffer 1
dw 0,255*256+8,3*45+sprtimfntspr,54,51,12,14,0          ;09=Uhr Minute  Ziffer 2
dw 0,255*256+8,4*45+sprtimfntspr,76,51,12,14,0          ;10=Uhr Sekunde Ziffer 1
dw 0,255*256+8,5*45+sprtimfntspr,88,51,12,14,0          ;11=Uhr Sekunde Ziffer 2
dw timhde,255*256+10,icndatslf,  11,83, 8, 8,0          ;12=Stunde  weniger
dw timhin,255*256+10,icndatsrg,  20,83, 8, 8,0          ;13=Stunde  mehr
dw timnde,255*256+10,icndatslf,  45,83, 8, 8,0          ;14=Minute  weniger
dw timnin,255*256+10,icndatsrg,  54,83, 8, 8,0          ;15=Minute  mehr
dw timsde,255*256+10,icndatslf,  79,83, 8, 8,0          ;16=Sekunde weniger
dw timsin,255*256+10,icndatsrg,  88,83, 8, 8,0          ;17=Sekunde mehr
dw 0,255*256+1,timdatchr,08,26,24,8,0                   ;18=Stunde  Beschreibung
dw 0,255*256+1,timdatcmn,40,26,24,8,0                   ;19=Minute  Beschreibung
dw 0,255*256+1,timdatcsc,76,26,24,8,0                   ;20=Sekunde Beschreibung

timdatchr dw timtxtchr,2+4+512
timdatcmn dw timtxtcmn,2+4+512
timdatcsc dw timtxtcsc,2+4+512

;Date-Tab
prgdattimb
dw 00,255*256+0,         2, 0,0,1000,1000,0             ;00=Hintergrund
dw timtab,255*256+20,timtabdat,0,2,108,11,0             ;01=Tab-Leiste
dw timoky,255*256+16,prgbuttxt1, 2,111,33,12,0          ;02="Ok"-Button
dw timcnc,255*256+16,prgbuttxt2,37,111,34,12,0          ;03="Cancel"-Button
dw timapl,255*256+16,prgbuttxt3,73,111,33,12,0          ;04="Apply"-Button
dw 00,255*256+0,       3, 2,27,104,64,0                 ;05=Kalender-Hintergrund
dw 0,255*256+1,timdatdwn, 3,28,11,8,0                   ;06=Kalender-Wochenspalte
dw 0,255*256+1,timdatdw1,15,28,12,8,0                   ;07=Kalender-Montag
dw 0,255*256+1,timdatdw2,28,28,12,8,0                   ;08=Kalender-Dienstag
dw 0,255*256+1,timdatdw3,41,28,12,8,0                   ;09=Kalender-Mittwoch
dw 0,255*256+1,timdatdw4,54,28,12,8,0                   ;10=Kalender-Donnerstag
dw 0,255*256+1,timdatdw5,67,28,12,8,0                   ;11=Kalender-Freitag
dw 0,255*256+1,timdatdw6,80,28,12,8,0                   ;12=Kalender-Samstag
dw 0,255*256+1,timdatdw7,93,28,12,8,0                   ;13=Kalender-Sonntag
dw timmde,255*256+10,icndatslf,48,16,8,8,0              ;14=Monat weniger
dw timmin,255*256+10,icndatsrg,56,16,8,8,0              ;15=Monat mehr
dw timyde,255*256+10,icndatslf,90,16,8,8,0              ;16=Jahr weniger
dw timyin,255*256+10,icndatsrg,98,16,8,8,0              ;17=Jahr mehr
dw 0,     255*256+1,timdatmdt, 2,16,46,8,0              ;18=Monat
dw 0,     255*256+1,timdatydt,66,16,24,8,0              ;19=Jahr
dw 0,255*256+1,timdatfdt,4,93,100,8,0                   ;20=volles Datum
prgdattimb2                                             ;21=Wochennummern
dw 0, 255*256+1,0*4+timweknum, 4,37,11,8,0
dw 0, 255*256+1,1*4+timweknum, 4,46,11,8,0
dw 0, 255*256+1,2*4+timweknum, 4,55,11,8,0
dw 0, 255*256+1,3*4+timweknum, 4,64,11,8,0
dw 0, 255*256+1,4*4+timweknum, 4,73,11,8,0
dw 0, 255*256+1,5*4+timweknum, 4,82,11,8,0
prgdattimb1                                             ;27=Tagesnummern
dw  1,255*256+1,0*4+timdatnum,15,37,12,8,0:dw  2,255*256+1,0*4+timdatnum,28,37,12,8,0:dw  3,255*256+1,0*4+timdatnum,41,37,12,8,0
dw  4,255*256+1,0*4+timdatnum,54,37,12,8,0:dw  5,255*256+1,0*4+timdatnum,67,37,12,8,0:dw  6,255*256+1,0*4+timdatnum,80,37,12,8,0
dw  7,255*256+1,0*4+timdatnum,93,37,12,8,0
dw  8,255*256+1,0*4+timdatnum,15,46,12,8,0:dw  9,255*256+1,0*4+timdatnum,28,46,12,8,0:dw 10,255*256+1,0*4+timdatnum,41,46,12,8,0
dw 11,255*256+1,0*4+timdatnum,54,46,12,8,0:dw 12,255*256+1,0*4+timdatnum,67,46,12,8,0:dw 13,255*256+1,0*4+timdatnum,80,46,12,8,0
dw 14,255*256+1,0*4+timdatnum,93,46,12,8,0
dw 15,255*256+1,0*4+timdatnum,15,55,12,8,0:dw 16,255*256+1,0*4+timdatnum,28,55,12,8,0:dw 17,255*256+1,0*4+timdatnum,41,55,12,8,0
dw 18,255*256+1,0*4+timdatnum,54,55,12,8,0:dw 19,255*256+1,0*4+timdatnum,67,55,12,8,0:dw 20,255*256+1,0*4+timdatnum,80,55,12,8,0
dw 21,255*256+1,0*4+timdatnum,93,55,12,8,0
dw 22,255*256+1,0*4+timdatnum,15,64,12,8,0:dw 23,255*256+1,0*4+timdatnum,28,64,12,8,0:dw 24,255*256+1,0*4+timdatnum,41,64,12,8,0
dw 25,255*256+1,0*4+timdatnum,54,64,12,8,0:dw 26,255*256+1,0*4+timdatnum,67,64,12,8,0:dw 27,255*256+1,0*4+timdatnum,80,64,12,8,0
dw 28,255*256+1,0*4+timdatnum,93,64,12,8,0
dw 29,255*256+1,0*4+timdatnum,15,73,12,8,0:dw 30,255*256+1,0*4+timdatnum,28,73,12,8,0:dw 31,255*256+1,0*4+timdatnum,41,73,12,8,0
dw 32,255*256+1,0*4+timdatnum,54,73,12,8,0:dw 33,255*256+1,0*4+timdatnum,67,73,12,8,0:dw 34,255*256+1,0*4+timdatnum,80,73,12,8,0
dw 35,255*256+1,0*4+timdatnum,93,73,12,8,0
dw 36,255*256+1,0*4+timdatnum,15,82,12,8,0:dw 37,255*256+1,0*4+timdatnum,28,82,12,8,0:dw 38,255*256+1,0*4+timdatnum,41,82,12,8,0
dw 39,255*256+1,0*4+timdatnum,54,82,12,8,0:dw 40,255*256+1,0*4+timdatnum,67,82,12,8,0:dw 41,255*256+1,0*4+timdatnum,80,82,12,8,0
dw 42,255*256+1,0*4+timdatnum,93,82,12,8,0

timweknum
dw 3*0+timwektxt,3+0+128
dw 3*1+timwektxt,3+0+128
dw 3*2+timwektxt,3+0+128
dw 3*3+timwektxt,3+0+128
dw 3*4+timwektxt,3+0+128
dw 3*5+timwektxt,3+0+128

timdatnum
dw 3*00+timdattxt,4+128+256,3*01+timdattxt,4+128+256,3*02+timdattxt,4+128+256,3*03+timdattxt,4+128+256,3*04+timdattxt,4+128+256
dw 3*05+timdattxt,4+128+256,3*06+timdattxt,4+128+256,3*07+timdattxt,4+128+256,3*08+timdattxt,4+128+256,3*09+timdattxt,4+128+256
dw 3*10+timdattxt,4+128+256,3*11+timdattxt,4+128+256,3*12+timdattxt,4+128+256,3*13+timdattxt,4+128+256,3*14+timdattxt,4+128+256
dw 3*15+timdattxt,4+128+256,3*16+timdattxt,4+128+256,3*17+timdattxt,4+128+256,3*18+timdattxt,4+128+256,3*19+timdattxt,4+128+256
dw 3*20+timdattxt,4+128+256,3*21+timdattxt,4+128+256,3*22+timdattxt,4+128+256,3*23+timdattxt,4+128+256,3*24+timdattxt,4+128+256
dw 3*25+timdattxt,4+128+256,3*26+timdattxt,4+128+256,3*27+timdattxt,4+128+256,3*28+timdattxt,4+128+256,3*29+timdattxt,4+128+256
dw 3*30+timdattxt,4+128+256,3*31+timdattxt,4+128+256

timdatfdt dw     timdatftx,2+4+128+512
timdatmdt dw     0,        0+4+128+512
timdatydt dw     timdatytx,0+4+128+512
timdatdwn dw 0*2+timdattxw,1+128+256
timdatdw1 dw 1*2+timdattxw,1+128+256
timdatdw2 dw 2*2+timdattxw,1+128+256
timdatdw3 dw 3*2+timdattxw,1+128+256
timdatdw4 dw 4*2+timdattxw,1+128+256
timdatdw5 dw 5*2+timdattxw,1+128+256
timdatdw6 dw 6*2+timdattxw,1+128+256
timdatdw7 dw 7*2+timdattxw,1+128+256

timdatftx  ds 32

;Zone-Tab
prgdattimc
dw 00,255*256+0,         2, 0,0,1000,1000,0             ;00=Hintergrund
dw timtab,255*256+20,timtabdat,0,2,108,11,0             ;01=Tab-Leiste
dw timoky,255*256+16,prgbuttxt1, 2,111,33,12,0          ;02="Ok"-Button
dw timcnc,255*256+16,prgbuttxt2,37,111,34,12,0          ;03="Cancel"-Button
dw timapl,255*256+16,prgbuttxt3,73,111,33,12,0          ;04="Apply"-Button
dw      0,255*256+10,sprtimmap1, 5,15,96,50,0           ;05=Grafik Worldmap links
dw      0,255*256+10,sprtimmap2
prgdattimc1                   dw 5,15,96,50,0           ;06=Grafik Worldmap rechts
dw timzon,255*256+41,timzonobj,2,67,104,42,0            ;07=Zeitzonen-Liste

timzonobj   dw 26,11,timzonlst,0,1,timzonrow,13,1
timzonrow   dw 0,96,0,0
timzonlst
dw  0,timzontxta, 1,timzontxtb, 2,timzontxtc, 3,timzontxtd, 4,timzontxte, 5,timzontxtf, 6,timzontxtg
dw  7,timzontxth, 8,timzontxti, 9,timzontxtj,10,timzontxtk,11,timzontxtl,12,timzontxtm,32768+13,timzontxtn
dw 14,timzontxto,15,timzontxtp,16,timzontxtq,17,timzontxtr,18,timzontxts,19,timzontxtt,20,timzontxtu
dw 21,timzontxtv,22,timzontxtw,23,timzontxtx,24,timzontxty,25,timzontxtz

prgtrnend

relocate_table
relocate_end
