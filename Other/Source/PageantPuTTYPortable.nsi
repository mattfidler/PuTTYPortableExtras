SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
Icon "..\..\App\AppInfo\appicon.ico"
OutFile "..\..\PageantPuTTYPortable.exe"

Var cmdLineParams
!include "FileFunc.nsh"

CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

Section
  ${GetParameters} $cmdLineParams
  Exec '"$EXEDIR\PuTTYPortable.exe" /B $cmdLineParams'
SectionEnd
