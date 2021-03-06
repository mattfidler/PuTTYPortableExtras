SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
Icon "..\..\App\AppInfo\pageant.ico"
OutFile "..\..\PageantPortable.exe"

Var cmdLineParams
!include "FileFunc.nsh"

CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

Section
  ${GetParameters} $cmdLineParams
  Exec '"$EXEDIR\PuTTYPortable.exe" /A $cmdLineParams'
SectionEnd
