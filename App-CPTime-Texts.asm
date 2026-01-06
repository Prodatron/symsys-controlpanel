;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                                            @
;@                S y m b O S   -   C o n t r o l   P a n e l                 @
;@                            DATE & TIME SETTINGS                            @
;@                   (default application texts [english])                    @
;@                                                                            @
;@             (c) 2004-2025 by Prodatron / SymbiosiS (Jörn Mika)             @
;@                                                                            @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;### POINTER ##################################################################

prgbuttxt1   db 1:dw prgbuttxt1_eng
prgbuttxt2   db 1:dw prgbuttxt2_eng
prgbuttxt3   db 1:dw prgbuttxt3_eng

prgtittim   db 1:dw prgtittim_eng

timtabtxt1   db 1:dw timtabtxt1_eng
timtabtxt2   db 1:dw timtabtxt2_eng
timtabtxt3   db 1:dw timtabtxt3_eng

timdattxw0   db 1:dw timdattxw0_eng
timdattxw1   db 1:dw timdattxw1_eng
timdattxw2   db 1:dw timdattxw2_eng
timdattxw3   db 1:dw timdattxw3_eng
timdattxw4   db 1:dw timdattxw4_eng
timdattxw5   db 1:dw timdattxw5_eng
timdattxw6   db 1:dw timdattxw6_eng
timdattxw7   db 1:dw timdattxw7_eng

timtxtchr   db 1:dw timtxtchr_eng
timtxtcmn   db 1:dw timtxtcmn_eng
timtxtcsc   db 1:dw timtxtcsc_eng

timdatmt01   db 1:dw timdatmt01_eng
timdatmt02   db 1:dw timdatmt02_eng
timdatmt03   db 1:dw timdatmt03_eng
timdatmt04   db 1:dw timdatmt04_eng
timdatmt05   db 1:dw timdatmt05_eng
timdatmt06   db 1:dw timdatmt06_eng
timdatmt07   db 1:dw timdatmt07_eng
timdatmt08   db 1:dw timdatmt08_eng
timdatmt09   db 1:dw timdatmt09_eng
timdatmt10   db 1:dw timdatmt10_eng
timdatmt11   db 1:dw timdatmt11_eng
timdatmt12   db 1:dw timdatmt12_eng
timdatdt0   db 1:dw timdatdt0_eng
timdatdt1   db 1:dw timdatdt1_eng
timdatdt2   db 1:dw timdatdt2_eng
timdatdt3   db 1:dw timdatdt3_eng
timdatdt4   db 1:dw timdatdt4_eng
timdatdt5   db 1:dw timdatdt5_eng
timdatdt6   db 1:dw timdatdt6_eng

timzontxta   db 1:dw timzontxta_eng
timzontxtb   db 1:dw timzontxtb_eng
timzontxtc   db 1:dw timzontxtc_eng
timzontxtd   db 1:dw timzontxtd_eng
timzontxte   db 1:dw timzontxte_eng
timzontxtf   db 1:dw timzontxtf_eng
timzontxtg   db 1:dw timzontxtg_eng
timzontxth   db 1:dw timzontxth_eng
timzontxti   db 1:dw timzontxti_eng
timzontxtj   db 1:dw timzontxtj_eng
timzontxtk   db 1:dw timzontxtk_eng
timzontxtl   db 1:dw timzontxtl_eng
timzontxtm   db 1:dw timzontxtm_eng
timzontxtn   db 1:dw timzontxtn_eng
timzontxto   db 1:dw timzontxto_eng
timzontxtp   db 1:dw timzontxtp_eng
timzontxtq   db 1:dw timzontxtq_eng
timzontxtr   db 1:dw timzontxtr_eng
timzontxts   db 1:dw timzontxts_eng
timzontxtt   db 1:dw timzontxtt_eng
timzontxtu   db 1:dw timzontxtu_eng
timzontxtv   db 1:dw timzontxtv_eng
timzontxtw   db 1:dw timzontxtw_eng
timzontxtx   db 1:dw timzontxtx_eng
timzontxty   db 1:dw timzontxty_eng
timzontxtz   db 1:dw timzontxtz_eng

;### TEXTS ####################################################################

prgbuttxt1_eng db "Ok",0
prgbuttxt2_eng db "Cancel",0
prgbuttxt3_eng db "Apply",0

prgtittim_eng db "Date and Time",0

timtabtxt1_eng db "Time",0
timtabtxt2_eng db "Date",0
timtabtxt3_eng db "Zone",0

timdattxw0_eng db "W",0
timdattxw1_eng db "M",0
timdattxw2_eng db "T",0
timdattxw3_eng db "W",0
timdattxw4_eng db "T",0
timdattxw5_eng db "F",0
timdattxw6_eng db "S",0
timdattxw7_eng db "S",0

timtxtchr_eng  db "Hour",0
timtxtcmn_eng  db "Min.",0
timtxtcsc_eng  db "Sec.",0

timdatmt01_eng db "January",0
timdatmt02_eng db "February",0
timdatmt03_eng db "March",0
timdatmt04_eng db "April",0
timdatmt05_eng db "May",0
timdatmt06_eng db "June",0
timdatmt07_eng db "July",0
timdatmt08_eng db "August",0
timdatmt09_eng db "September",0
timdatmt10_eng db "October",0
timdatmt11_eng db "November",0
timdatmt12_eng db "December",0
timdatdt0_eng  db "Monday",0
timdatdt1_eng  db "Tuesday",0
timdatdt2_eng  db "Wednesday",0
timdatdt3_eng  db "Thursday",0
timdatdt4_eng  db "Friday",0
timdatdt5_eng  db "Saturday",0
timdatdt6_eng  db "Sunday",0

timzontxta_eng db "-12 Int.Dateline",0
timzontxtb_eng db "-11 Midway Island",0
timzontxtc_eng db "-10 Hawaii",0
timzontxtd_eng db "-09 Alaska",0
timzontxte_eng db "-08 Los Angeles",0
timzontxtf_eng db "-07 Denver, Arizona",0
timzontxtg_eng db "-06 Chicago",0
timzontxth_eng db "-05 New York",0
timzontxti_eng db "-04 Santiago",0
timzontxtj_eng db "-03 Buenos Aires",0
timzontxtk_eng db "-02 Middle Atlantic",0
timzontxtl_eng db "-01 Azores, Cabo Verde",0
timzontxtm_eng db "+00 London, Lissabon",0
timzontxtn_eng db "+01 Amsterdam, Berlin",0
timzontxto_eng db "+02 Kiev, Helsinki",0
timzontxtp_eng db "+03 Constantinople",0
timzontxtq_eng db "+04 Tiflis",0
timzontxtr_eng db "+05 Male",0
timzontxts_eng db "+06 Dhaka",0
timzontxtt_eng db "+07 Bangkok, Hanoi",0
timzontxtu_eng db "+08 Beijing, Perth",0
timzontxtv_eng db "+09 Tokyo, Seoul",0
timzontxtw_eng db "+10 Sydney",0
timzontxtx_eng db "+11 New Caledonia",0
timzontxty_eng db "+12 Auckland",0
timzontxtz_eng db "+13 Nuku'alofa",0

;### RESERVE
ds 32
