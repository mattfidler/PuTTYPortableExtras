CRCCheck On
RequestExecutionLevel user
; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

!include "MUI2.nsh"

!include "FileFunc.nsh"

Name "PuttyPortable Extras"
OutFile "..\..\PageantDefaultKeys.exe"
BrandingText "PuTTY Portable Extras"

InstallDir "$EXEDIR"

!define MUI_ICON "..\..\App\AppInfo\pageant.ico"
#!define MUI_UNICON
!define MUI_HEADERIMAGEs

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING
!define MUI_PAGE_HEADER_TEXT "PuTTY Portable Key Options"
!define MUI_PAGE_HEADER_SUBTEXT "Select and remove default keys for Pageant"

!define MUI_COMPONENTSPAGE_SMALLDESC

Var usb
Var usbs
!define TEMP1 $R0 ;Temp variable

;Order of pages
Page custom SetCustom ValidateCustom ": Select Default Keys" ;Custom page. InstallOptions gets called in SetCustom.
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Function GetDriveVars
  StrCmp $9 "c:\" spa
  StrCmp $8 "HDD" gpa
  StrCmp $9 "a:\" spa
  StrCmp $9 "b:\" spa
  
  gpa:
    IfFileExists "$9PotableApps" set_usb
    Goto spa
    
  set_usb:
    StrCpy $usb "$9"
    StrCpy $usbs "$9" -1
  spa:    
    Push $0
    
FunctionEnd

Function .onInit
  SetOutPath "$EXEDIR\Data\ini"
  CopyFiles /SILENT "$EXEDIR\App\ini\io-keys.ini" "$EXEDIR\Data\ini\io-keys.ini"
  ${GetDrives} "FDD+HDD" "GetDriveVars"
  SetOutPath "$EXEDIR\Data"
  end_init:
    ClearErrors
FunctionEnd

Function .onGUIEnd
  Delete "$EXEDIR\Data\ini\io-keys.ini"
FunctionEnd


Function SetCustom
  
  ;Display the InstallOptions dialog
  
  Push ${TEMP1}
  
    InstallOptions::dialog "$EXEDIR\Data\ini\io-keys.ini"
    Pop ${TEMP1}
    
  Pop ${TEMP1}
  
FunctionEnd

!define add_btn "Field 4"
!define rm_btn  "Field 5"
Function ValidateCustom
  ReadIniStr $R0 "$EXEDIR\Data\ini\io-keys.ini" "${add_btn}" "State"
  MessageBox MB_OK "Add Btn: $R0"
FunctionEnd

Section "Components" 
  ;Get Install Options dialog user input
  
  
SectionEnd
