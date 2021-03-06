SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
Icon "..\..\App\AppInfo\appicon.ico"
OutFile "..\..\App\putty\PUTTY.exe"

!include "FileFunc.nsh"

CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

Var cmdLineParams
Var pg
Var PA
Var USB


#This came from http://nsis.sourceforge.net/Another_String_Replace_%28and_Slash/BackSlash_Converter%29

!macro _StrReplaceConstructor ORIGINAL_STRING TO_REPLACE REPLACE_BY
  Push "${ORIGINAL_STRING}"
  Push "${TO_REPLACE}"
  Push "${REPLACE_BY}"
  Call StrRep
  Pop $0
!macroend


Function StrRep
  Exch $R4 ; $R4 = Replacement String
  Exch
  Exch $R3 ; $R3 = String to replace (needle)
  Exch 2
  Exch $R1 ; $R1 = String to do replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R5 ; Len (needle)
  Push $R6 ; len (haystack)
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R5 $R3
  StrLen $R6 $R1
  loop:
    StrCpy $R7 $R1 $R5
    StrCmp $R7 $R3 found
    StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
    StrCpy $R2 "$R2$R7"
    StrCpy $R1 $R1 $R6 1
    StrCmp $R1 "" done loop
  found:
    StrCpy $R2 "$R2$R4"
    StrCpy $R1 $R1 $R6 $R5
    StrCmp $R1 "" done loop
  done:
    StrCpy $R3 $R2
    Pop $R7
    Pop $R6
    Pop $R5
    Pop $R2
    Pop $R1
    Pop $R4
    Exch $R3
FunctionEnd

!define StrReplace '!insertmacro "_StrReplaceConstructor"'


!define GetCmdOptions "!insertmacro GetCmdOptions"

!macro GetCmdOptions
  Call GetCmdOptions
!macroend
Function GetCmdOptions
  ## Gets Command Line Functions
  Push $R0
  
  ${GetParameters} $cmdLineParams
  ClearErrors

  ${GetOptions} $cmdLineParams '/A' $R0
  IfErrors +2 0
  StrCpy $pg "1"
  ClearErrors
  
  ${GetOptions} $cmdLineParams '/B' $R0
  IfErrors +2 0
  StrCpy $pg "2"
  ClearErrors
  
  ${StrReplace} $cmdLineParams "/A" ""
  StrCpy $cmdLineParams $0
  
  ${StrReplace} $cmdLineParams "/B" ""
  StrCpy $cmdLineParams $0
  
  Pop $R0
FunctionEnd

Function addkey

  ${StrReplace} $cmdLineParams "$R9" ""
  StrCpy $cmdLineParams $0
  
  StrCpy $cmdLineParams '$cmdLineParams "$R9"'
  StrCpy $0 1
  Push $0
FunctionEnd

Function GetDriveVars
  StrCmp $9 "c:\" spa
  StrCmp $8 "HDD" gpa
  StrCmp $9 "a:\" spa
  StrCmp $9 "b:\" spa
  
  gpa:
    IfFileExists "$9PortableApps" 0 spa
    StrCpy $PA "$9PortableApps"
    StrCpy $USB "$9" -1
  spa:
    Push $0
    
FunctionEnd

Function AddPutty
  IfFileExists "$EXEDIR\putty-tray.exe" putty_tray
  IfFileExists "$EXEDIR\putty-real.exe" putty_real not_found
  putty_tray:
    StrCpy $cmdLineParams "$cmdLineParams -c $EXEDIR\putty-tray.exe"
    Goto end
  putty_real:
    StrCpy $cmdLineParams "$cmdLineParams -c $EXEDIR\putty-real.exe"
    Goto end
  not_found:
    MessageBox MB_OK "Could not find putty executables.  Corrupt?  Starting paegant alone."
  end:
    ClearErrors
FunctionEnd
Var secondaryCall
Section
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "putty.exe") i .r1 ?e'
  Pop $secondaryCall
  StrCmp "$pg" "1" pg
  StrCmp "$pg" "2" pg tty
  pg:
    FindProcDLL::FindProc "pageant.exe"
    StrCmp $R0 "1" found_pageant 0
    IfFileExists "$EXEDIR\pageant.exe" +3 0
    MessageBox MB_OK "Could not find pageant!  Corrupt?"
    Goto exit
    ${Locate} "$EXEDIR\..\..\Data\keys\" "/L=F /M=*.ppk /S= /G=0" "addkey"
    ${Locate} "$USB\Documents\keys\" "/L=F /M=*.ppk /S= /G=0" "addkey"
    StrCmp $pg "2" 0 +2
    Call AddPutty
    Exec "$EXEDIR\pageant.exe $cmdLineParams"
    Sleep 1000
    FindProcDLL::FindProc "pageant.exe"
    StrCmp $R0 "1" 0 -2
    Goto end
  found_pageant:
    StrCmp "$pg" "2" tty
    MessageBox MB_OK "Pageant is already running, please close it first."
    Goto exit
  tty:
    IfFileExists "$EXEDIR\putty-tray.exe" 0 putty_real
    Exec "$EXEDIR\putty-tray.exe $cmdLineParams"
    Sleep 1000
    FindProcDLL::FindProc "putty-tray.exe"
    StrCmp $R0 "1" 0 -2
    Goto end
  putty_real:
    IfFileExists "$EXEDIR\putty-real.exe" 0 no_putty
    Exec "$EXEDIR\putty-real.exe $cmdLineParams"
    Sleep 1000
    FindProcDLL::FindProc "putty-real.exe"
    StrCmp $R0 "1" 0 -2
    Goto end
  no_putty:
    MessageBox MB_OK "Could not find putty executables.  Corrupt?"
    Goto exit
  end:
    ClearErrors
    ## Only one process will hang around for PuTTY Portable Launcher
    StrCmp $secondaryCall 0 0 exit
    StrCpy $R1 "pageant.exe"
  loop:    
    ## Make sure putty.exe is running when either pageant, putty-real
    ## and putty-tray are running.  I'm not sure how the laucher waits
    ## for putty to exit.  There could be some waiting for putty.exe
    ## to terminate before saving registry settings.
    FindProcDLL::FindProc "$R1"
    StrCmp $R0 "1" wait 0
    StrCmp $R1 "pageant.exe" +4
    FindProcDLL::FindProc "pageant.exe"
    StrCpy $R2 "pageant.exe"
    StrCmp $R0 "1" wait 0
    StrCmp $R1 "putty-tray.exe" +4
    FindProcDLL::FindProc "putty-tray.exe"
    StrCpy $R2 "putty-tray.exe"
    StrCmp $R0 "1" wait 0
    StrCmp $R1 "putty-real.exe" +4
    FindProcDLL::FindProc "putty-real.exe"
    StrCpy $R2 "putty-real.exe"
    StrCmp $R0 "1" wait 0
    Goto exit
  wait:
    StrCpy $R1 $R2
    Sleep 1000
    Goto loop
  exit:
    ClearErrors
SectionEnd
Function .onInit
  ${GetCmdOptions}
  ${GetDrives} "FDD+HDD" "GetDriveVars"
FunctionEnd
