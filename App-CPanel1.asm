nolist
computer_mode equ 4     ;0=cpc, 1=msx, 2=pcw, 3=ep, 4=svm, 5=nc, 6=nxt

org #1000

if computer_mode=0
    write "f:\symbos\cp.exe"
elseif computer_mode=1
    write "f:\symbos\msx\cp.exe"
elseif computer_mode=2
    write "f:\symbos\pcw\cp.exe"
elseif computer_mode=3
    write "f:\symbos\ep\cp.exe"
elseif computer_mode=4
    write "f:\symbos\svm\cp.exe"
elseif computer_mode=5
    write "f:\symbos\nc\cp.exe"
elseif computer_mode=6
    write "f:\symbos\nxt\cp.exe"
endif

READ "..\..\..\SRC-Main\SymbOS-Constants.asm"
READ "App-CPanel.asm"
