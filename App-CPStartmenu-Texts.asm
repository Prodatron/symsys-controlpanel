;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                              STARTMENU EDITOR                              @
;@                   (default application texts [english])                    @
;@                                                                            @
;@             (c) 2015-2015 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;### POINTER ##################################################################

stmtxttit   db 1:dw stmtxttit_eng
stmtxtcls   db 1:dw stmtxtcls_eng
stmtxtlcd   db 1:dw stmtxtlcd_eng

stmtxtltr   db 1:dw stmtxtltr_eng
stmtxtasc   db 1:dw stmtxtasc_eng
stmtxtasm   db 1:dw stmtxtasm_eng
stmtxtdel   db 1:dw stmtxtdel_eng
stmtxtmup   db 1:dw stmtxtmup_eng
stmtxtmdw   db 1:dw stmtxtmdw_eng
stmtxtedi   db 1:dw stmtxtedi_eng
stmtxtnms   db 1:dw stmtxtnms_eng
stmtxtnmd   db 1:dw stmtxtnmd_eng
stmtxtptd   db 1:dw stmtxtptd_eng
stmtxtbrw   db 1:dw stmtxtbrw_eng
stmtxtstd   db 1:dw stmtxtstd_eng
stmtxtrnd   db 1:dw stmtxtrnd_eng
stmtxtrfs   db 1:dw stmtxtrfs_eng

stmtxtrun0   db 1:dw stmtxtrun0_eng
stmtxtrun1   db 1:dw stmtxtrun1_eng
stmtxtrun2   db 1:dw stmtxtrun2_eng
stmtxtrun3   db 1:dw stmtxtrun3_eng

errmemtxt1   db 1:dw errmemtxt1_eng
errmemtxt2   db 1:dw errmemtxt2_eng
errmemtxt3   db 1:dw errmemtxt3_eng

errnumtxt1   db 1:dw errnumtxt1_eng
errnumtxt2   db 1:dw errnumtxt2_eng
errnumtxt3   db 1:dw errnumtxt3_eng

errsubtxt1   db 1:dw errsubtxt1_eng
errsubtxt2   db 1:dw errsubtxt2_eng
errsubtxt3   db 1:dw errsubtxt3_eng

;### TEXTS ####################################################################

stmtxttit_eng   db "Startmenu Editor",0
stmtxtcls_eng   db "Close",0
stmtxtlcd_eng   db "Current location:",0

stmtxtltr_eng   db "Tree",0
stmtxtasc_eng   db "Add shortcut",0
stmtxtasm_eng   db "Add submenu",0
stmtxtdel_eng   db "Delete",0
stmtxtmup_eng   db "Entry up",0
stmtxtmdw_eng   db "Entry down",0
stmtxtedi_eng   db "Edit entry",0
stmtxtnms_eng   db "[entry is read only]",0
stmtxtnmd_eng   db "Name",0
stmtxtptd_eng   db "Target",0
stmtxtbrw_eng   db "Browse",0
stmtxtstd_eng   db "Start in",0
stmtxtrnd_eng   db "Run",0
stmtxtrfs_eng   db "Refresh",0

stmtxtrun0_eng  db "Default",0
stmtxtrun1_eng  db "Normal window",0
stmtxtrun2_eng  db "Minimized",0
stmtxtrun3_eng  db "Maximized",0

errmemtxt1_eng  db "Memory full!",0
errmemtxt2_eng  db "There is no memory left for",0
errmemtxt3_eng  db "completing this operation.",0

errnumtxt1_eng  db "Too many entries! The maximum",0
errnumtxt2_eng  db "amount of entries (24) for this",0
errnumtxt3_eng  db "submenu has been reached.",0

errsubtxt1_eng  db "Too many nested submenus!",0
errsubtxt2_eng  db "The deepest level for a",0
errsubtxt3_eng  db "submenu is 5.",0

;### RESERVE
ds 0
