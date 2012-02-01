CRCCheck On
RequestExecutionLevel user

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
;SetCompress off
;automatically close the installer when done.
AutoCloseWindow true

Var pa

; MUI2
!define VER "0.62-3"
!define mirror $PLUGINSDIR\mirrors.ini
!include "MUI2.nsh"
!include "FileFunc.nsh"

Name "PuttyPortable Extras"
BrandingText "PuttyPortable Extras"

OutFile "..\..\PuttyPortableExtrasInstaller-${VER}.exe"

!define MUI_HEADERIMAGE

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING
!define MUI_PAGE_HEADER_TEXT "PuTTY Portable Extras"
!define MUI_PAGE_HEADER_SUBTEXT "PuTTY Portable Extras"

!define MUI_COMPONENTSPAGE_SMALLDESC

;Installer pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "License.txt"
!insertmacro MUI_PAGE_COMPONENTS

;MUI_PAGE_STARTMENU pageid variable
!insertmacro MUI_PAGE_INSTFILES


!insertmacro MUI_LANGUAGE "English"


Section "Required Executable" sec_required_executable ; Checked
  ; Description:
  ; This Required executable allows Putty and Pageant to run with the same launcher by replacing putty.exe by a NSIS launcher.
  SetOutPath "$INSTDIR\App\putty"
  IfFileExists "$INSTDIR\App\putty\putty-real.exe" +2
  Rename "$INSTDIR\App\putty\PUTTY.exe" "$INSTDIR\App\putty\putty-real.exe"
  File "..\..\App\putty\putty.exe"
  SetOutPath "$INSTDIR"
  File "..\..\README.html"
SectionEnd ; sec_required_executable

Section "Use PuTTY tray" sec_replace_putty_with_putty_tray ; 
  ; Description:
  ; Replace PuTTY with PuTTY tray
  SetOutPath "$INSTDIR\App\putty"
  File "..\..\App\putty\putty-tray.exe"
SectionEnd ; sec_replace_putty_with_putty_tray


Section "Pageant Portable" sec_pageant_portable ; Checked
  ; Description:
  ; Portable Pageant -- Will relocate PuTTY portable settings before running
  SetOutPath "$INSTDIR\App\putty"
  File "..\..\App\putty\pageant.exe"
  SetOutPath "$INSTDIR"
  File "..\..\PageantPortable.exe"
  File "..\..\PageantPuTTYPortable.exe"
SectionEnd ; sec_pageant_portable

Section "Plink" sec_plink ; Checked
  ; Description:
  ; Plink -- Should be run after either PuTTY Portable is run OR Pageant Portable is run.
  SetOutPath "$INSTDIR\App\putty"
  File "..\..\App\putty\plink.exe"
SectionEnd ; sec_plink

Section "Pscp" sec_pscp ; Checked
  ; Description:
  ; Putty Secure Copy
  SetOutPath "$INSTDIR\App\putty"
  File "..\..\App\putty\pscp.exe"
  File "..\..\App\putty\scp.bat"
SectionEnd ; sec_pscp

Section "Psftp" sec_psftp ; Checked
  ; Description:
  ; Putty Sftp
  SetOutPath "$INSTDIR\App\putty"
  File "..\..\App\putty\psftp.exe"
  File "..\..\App\putty\sftp.bat"
SectionEnd ; sec_psftp

Section "Puttygen" sec_puttygen ; Checked
  ; Description:
  ; Puttygen -- its already portable.  A compressed verion is placed in the portableapps root directory
  SetOutPath "$INSTDIR"
  File "..\..\puttygen.exe"
SectionEnd ; sec_puttygen

Section /o "Sources" sec_sources ; Unchecked (/o)
  ; Description:
  ; Sources
  SetOutPath "$INSTDIR\Other\Source"
  File "*.nsi"
SectionEnd ; sec_sources
;--------------------------------
;Description(s)
LangString DESC_sec_replace_putty_with_putty_tray ${LANG_ENGLISH} "Replace PuTTY with PuTTY tray"
LangString DESC_sec_required_executable ${LANG_ENGLISH} "This Required executable allows Putty and Pageant to run with the same launcher by replacing putty.exe by a NSIS launcher."
LangString DESC_sec_sources ${LANG_ENGLISH} "Sources"
LangString DESC_sec_puttygen ${LANG_ENGLISH} "Puttygen -- its already portable.  A compressed verion is placed in the portableapps root directory"
LangString DESC_sec_psftp ${LANG_ENGLISH} "Putty Sftp"
LangString DESC_sec_pscp ${LANG_ENGLISH} "Putty Secure Copy"
LangString DESC_sec_plink ${LANG_ENGLISH} "Plink -- Should be run after either PuTTY Portable is run OR Pageant Portable is run."
LangString DESC_sec_pageant_portable ${LANG_ENGLISH} "Portable Pageant -- Will relocate PuTTY portable settings before running"
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_required_executable} $(DESC_sec_required_executable)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_sources} $(DESC_sec_sources)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_puttygen} $(DESC_sec_puttygen)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_psftp} $(DESC_sec_psftp)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_pscp} $(DESC_sec_pscp)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_plink} $(DESC_sec_plink)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_pageant_portable} $(DESC_sec_pageant_portable)
  !insertmacro MUI_DESCRIPTION_TEXT ${sec_replace_putty_with_putty_tray} $(DESC_sec_replace_putty_with_putty_tray)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function GetDriveVars
  StrCmp $9 "c:\" spa
  StrCmp $8 "HDD" gpa
  StrCmp $9 "a:\" spa
  StrCmp $9 "b:\" spa
  
  gpa:
    IfFileExists "$9PortableApps" 0 spa
    StrCpy $PA "$9PortableApps"
  spa:
    Push $0
    
FunctionEnd

Function .onInit
  SectionSetFlags ${sec_required_executable} 17
  ${GetDrives} "FDD+HDD" "GetDriveVars"
  IfFileExists "$PA\PuTTYPortable" +3 0
  MessageBox MB_OK "The installer could not find PuTTY Portable! Pleas install PuTTY Portable First."
  Abort
  StrCpy "$INSTDIR" "$PA\PuTTYPortable"
FunctionEnd
