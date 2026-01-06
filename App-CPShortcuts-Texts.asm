;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                                 SHORTCUTS                                  @
;@                   (default application texts [english])                    @
;@                                                                            @
;@             (c) 2004-2025 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;### POINTER ##################################################################

prgtitlnk   db 1:dw prgtitlnk_eng

prgbuttxt1   db 1:dw prgbuttxt1_eng
prgbuttxt2   db 1:dw prgbuttxt2_eng
prgbuttxt3   db 1:dw prgbuttxt3_eng

prgtxtlnk2a   db 1:dw prgtxtlnk2a_eng
prgtxtlnk2b   db 1:dw prgtxtlnk2b_eng
prgtxtlnk3a   db 1:dw prgtxtlnk3a_eng
prgtxtlnk3b   db 1:dw prgtxtlnk3b_eng
prgtxtlnk3c   db 1:dw prgtxtlnk3c_eng
prgtxtlnk3d   db 1:dw prgtxtlnk3d_eng
prgtxtlnk4   db 1:dw prgtxtlnk4_eng
prgtxtlnk5a   db 1:dw prgtxtlnk5a_eng
prgtxtlnk5c   db 1:dw prgtxtlnk5c_eng
prgtxtlnk6a   db 1:dw prgtxtlnk6a_eng
prgtxtlnk7a   db 1:dw prgtxtlnk7a_eng
prgtxtlnk7b   db 1:dw prgtxtlnk7b_eng
prgtxtlnk7c   db 1:dw prgtxtlnk7c_eng
prgtxtlnk8a   db 1:dw prgtxtlnk8a_eng
prgtxtlnk8b   db 1:dw prgtxtlnk8b_eng

;### TEXTS ####################################################################

prgtitlnk_eng db "Desktop and Startmenu Links",0

prgbuttxt1_eng db "Ok",0
prgbuttxt2_eng db "Cancel",0
prgbuttxt3_eng db "Apply",0

prgtxtlnk2a_eng db "Desktop",0
prgtxtlnk2b_eng db "Startmenu",0
prgtxtlnk3a_eng db "Up",0
prgtxtlnk3b_eng db "Down",0
prgtxtlnk3c_eng db "Del",0
prgtxtlnk3d_eng db "Add",0
prgtxtlnk4_eng  db "Edit entry",0
prgtxtlnk5a_eng db "Path",0
prgtxtlnk5c_eng db "Browse...",0
prgtxtlnk6a_eng db "Name",0
prgtxtlnk7a_eng db "Icon",0
prgtxtlnk7b_eng db "Use file icon",0
prgtxtlnk7c_eng db "Select icon...",0
prgtxtlnk8a_eng db "XPos",0
prgtxtlnk8b_eng db "YPos",0

;### RESERVE
ds 0
