nolist

org #1000

READ "..\..\..\SRC-Main\SymbOS-Constants.asm"

write "f:\symbos\cpshcuts.exe"

relocate_start

App_BegCode

;### APPLICATION HEADER #######################################################

;header structure
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

            dw App_BegData-App_BegCode  ;length of code area
            dw App_BegTrns-App_BegData  ;length of data area
            dw App_EndTrns-App_BegTrns  ;length of transfer area
prgdatadr   dw #1000                ;original origin                    POST address data area
prgtrnadr   dw relocate_count       ;number of relocator table entries  POST address transfer area
prgprztab   dw prgstk-App_BegTrns   ;stack length                       POST table processes
            dw 0                    ;*reserved*
App_BnkNum  db 0                    ;*reserved*                         POST bank number
            db "CP:Shortcuts":ds 12:db 0 ;Name
            db 1                    ;flags (+1=16c icon)
            dw prgicn16c-App_BegCode ;16 colour icon offset
            ds 5                    ;*reserved*
prgmemtab   db "SymExe10"           ;SymbOS-EXE-Kennung                 POST Tabelle Speicherbereiche
            dw 0                    ;zusätzlicher Code-Speicher
            dw lnklenall            ;zusätzlicher Data-Speicher
            dw 0                    ;zusätzlicher Transfer-Speicher
            ds 26                   ;*reserviert*
            db 1,4                  ;required OS version (4.1)
prgicnsml   db 2,8,8,#F9,#FF,#DA,#FF,#CB,#F7,#CB,#7B,#CB,#3D,#CB,#7B,#DA,#3D,#F9,#F3
prgicnbig   db 6,24,24
            db #00,#00,#00,#00,#00,#00,#FF,#FF,#FF,#FF,#80,#00,#8F,#0F,#0F,#1F,#80,#00,#8F,#0F,#0F,#1F,#80,#00,#9E,#F0,#87,#1F,#80,#00,#9E,#10,#8F,#1F,#80,#00,#9E,#B0,#9F,#FF,#80,#00,#9E,#E0,#AE,#12,#80,#00
            db #9E,#73,#BF,#FE,#B0,#00,#9F,#CE,#E2,#7E,#C2,#80,#8F,#4D,#66,#7E,#8D,#80,#8F,#6A,#2A,#7E,#1B,#80,#8F,#EA,#62,#7E,#95,#80,#BF,#CE,#A2,#7E,#42,#E0,#AF,#05,#62,#7E,#85,#14,#BD,#EE,#3A,#F1,#1A,#FE
            db #BD,#FD,#05,#05,#36,#FE,#BD,#CA,#79,#3A,#82,#F6,#9E,#E7,#F7,#35,#DD,#E0,#F0,#D6,#FF,#39,#FF,#C0,#00,#56,#F9,#FC,#F7,#80,#00,#56,#91,#EC,#73,#80,#00,#30,#10,#EC,#30,#00,#00,#00,#10,#E0,#00,#00

;*** SYSTEM MANAGER LIBRARY USAGE
use_SySystem_PRGRUN     equ 0   ;Starts an application or opens a document
use_SySystem_PRGEND     equ 1   ;Stops an application and frees its resources
use_SySystem_PRGSRV     equ 1   ;Manages shared services or finds applications
use_SySystem_SYSWRN     equ 1   ;Opens an info, warning or confirm box
use_SySystem_SELOPN     equ 0   ;Opens the file selection dialogue
use_SySystem_HLPOPN     equ 0   ;HLP file handling
use_SySystem_LNGLOD     equ 1   ;Loads a text pack from a language file

;*** DESKTOP MANAGER LIBRARY USAGE
use_SyDesktop_WINOPN    equ 1   ;Opens a new window
use_SyDesktop_WINMEN    equ 0   ;Redraws the menu bar of a window
use_SyDesktop_WININH    equ 1   ;Redraws the content of a window
use_SyDesktop_WINTOL    equ 0   ;Redraws the content of the window toolbar
use_SyDesktop_WINTIT    equ 0   ;Redraws the title bar of a window
use_SyDesktop_WINSTA    equ 0   ;Redraws the status bar of a window
use_SyDesktop_WINMVX    equ 0   ;Sets the X offset of a window content
use_SyDesktop_WINMVY    equ 0   ;Sets the Y offset of a window content
use_SyDesktop_WINTOP    equ 1   ;Takes a window to the front position
use_SyDesktop_WINMAX    equ 0   ;Maximizes a window
use_SyDesktop_WINMIN    equ 0   ;Minimizes a window
use_SyDesktop_WINMID    equ 0   ;Restores a window or the size of a window
use_SyDesktop_WINMOV    equ 0   ;Moves a window to another position
use_SyDesktop_WINSIZ    equ 0   ;Resizes a window
use_SyDesktop_WINCLS    equ 1   ;Closes a window
use_SyDesktop_WINDIN    equ 0   ;Redraws the content of a window (always)
use_SyDesktop_WINSLD    equ 0   ;Redraws the two slider of a window
use_SyDesktop_WINPIN    equ 0   ;Redraws the content of a window (clipped)
use_SyDesktop_WINSIN    equ 0   ;Redraws the content of a control collection
use_SyDesktop_MENCTX    equ 0   ;Opens a context menu
use_SyDesktop_STIADD    equ 0   ;Adds an icon to the systray
use_SyDesktop_STIREM    equ 0   ;Removes an icon from the systray
use_SyDesktop_Service   equ 1   ;[REQUIRED FOR THE FOLLOWING FUNCTIONS]
use_SyDesktop_MODGET    equ 0   ;Returns the current screen mode
use_SyDesktop_MODSET    equ 0   ;Sets the current screen 
use_SyDesktop_COLGET    equ 0   ;Returns the definition of a colours
use_SyDesktop_COLSET    equ 0   ;Defines one colours
use_SyDesktop_DSKBGR    equ 1   ;Redraws the desktop background
use_SyDesktop_DSKPLT    equ 0   ;Redraws the complete screen
use_SyDesktop_DSKALL    equ 1   ;Redraws the complete screen

;*** FILEMANAGER LIBRARY USAGE
use_SyFile_STOTRN       equ 0   ;Reads or writes a number of sectors
use_SyFile_FILNEW       equ 0   ;Creates a new file and opens it
use_SyFile_FILOPN       equ 1   ;Opens an existing file
use_SyFile_FILCLO       equ 1   ;Closes an opened file
use_SyFile_FILINP       equ 1   ;Reads an amount of bytes out of an opened file
use_SyFile_FILOUT       equ 0   ;Writes an amount of bytes into an opened file
use_SyFile_FILPOI       equ 1   ;Moves the file pointer to another position
use_SyFile_FILF2T       equ 0   ;Decodes the file timestamp
use_SyFile_FILT2F       equ 0   ;Encodes the file timestamp
use_SyFile_FILLIN       equ 0   ;Reads one text line out of an opened file
use_SyFile_DIRDEV       equ 0   ;Sets the current drive
use_SyFile_DIRPTH       equ 0   ;Sets the current path
use_SyFile_DIRPRS       equ 0   ;Changes a property of a file or a directory
use_SyFile_DIRPRR       equ 0   ;Reads a property of a file or a directory
use_SyFile_DIRREN       equ 0   ;Renames a file or a directory
use_SyFile_DIRNEW       equ 0   ;Creates a new directory
use_SyFile_DIRINP       equ 0   ;Reads the content of a directory
use_SyFile_DIRDEL       equ 0   ;Deletes one or more files
use_SyFile_DIRRMD       equ 0   ;Deletes a sub directory
use_SyFile_DIRMOV       equ 0   ;Moves a file or sub directory
use_SyFile_DIRINF       equ 0   ;Returns information about one drive
use_SyFile_DEVDIR       equ 0   ;Reads the content of a directory (extended)

READ "..\..\..\SRC-Main\Docs-Developer\symbos_lib-SystemManager.asm"
READ "..\..\..\SRC-Main\Docs-Developer\symbos_lib-DesktopManager.asm"
READ "..\..\..\SRC-Main\Docs-Developer\symbos_lib-FileManager.asm"

READ "App-CPShortcuts.asm"
