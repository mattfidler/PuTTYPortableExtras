;Copyrignt (C) 2012 Matthew Fidler
; Modifications: 
;  - Changed PuTTYPortable to PageantPortable
;  - Dropped Splash Screen
;  - Made Pageant pretend its PuTTYPortable so that the registry 
;    doesn't have to change when running PuTTYPortable.
;  - Changed Icon

;Copyright (C) 2004-2008 John T. Haller of PortableApps.com

;Website: 

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!define NAME "PageantPortable"
!define PORTABLEAPPNAME "Pageant Portable"
!define APPNAME "Paegent"
!define VER "1.5.7.0"
!define WEBSITE ""
!define DEFAULTEXE "pageant.exe"
!define DEFAULTAPPDIR "putty"
!define DEFAULTSETTINGSDIR "settings"

;=== Program Details
Name "${PORTABLEAPPNAME}"
OutFile "..\..\${NAME}.exe"
Caption "${PORTABLEAPPNAME} | PortableApps.com"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey Comments "Allows ${APPNAME} to be run from a removable drive.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "John T. Haller"
VIAddVersionKey FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${NAME}.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Include
!include "GetParameters.nsh"
!include "Registry.nsh"
!include "ReplaceInFile.nsh"
!include "StrRep.nsh"
!include "MUI.nsh"

;=== Program Icon
Icon "..\..\App\AppInfo\pageant.ico"

;=== Icon & Stye ===
!define MUI_ICON "..\..\App\AppInfo\pageant.ico"

;=== Languages
!insertmacro MUI_LANGUAGE "English"

LangString LauncherFileNotFound ${LANG_ENGLISH} "${PORTABLEAPPNAME} cannot be started. You may wish to re-install to fix this issue. (ERROR: $MISSINGFILEORPATH could not be found)"
LangString LauncherAlreadyRunning ${LANG_ENGLISH} "Another instance of ${APPNAME} is already running. Please close other instances of ${APPNAME} before launching ${PORTABLEAPPNAME}."
LangString LauncherAskCopyLocal ${LANG_ENGLISH} "${PORTABLEAPPNAME} appears to be running from a location that is read-only. Would you like to temporarily copy it to the local hard drive and run it from there?$\n$\nPrivacy Note: If you say Yes, your personal data within ${PORTABLEAPPNAME} will be temporarily copied to a local drive. Although this copy of your data will be deleted when you close ${PORTABLEAPPNAME}, it may be possible for someone else to access your data later."
LangString LauncherNoReadOnly ${LANG_ENGLISH} "${PORTABLEAPPNAME} can not run directly from a read-only location and will now close."


Var PROGRAMDIRECTORY
Var SETTINGSDIRECTORY
Var ADDITIONALPARAMETERS
Var EXECSTRING
Var PROGRAMEXECUTABLE
Var INIPATH
Var SECONDARYLAUNCH
Var FAILEDTORESTOREKEY
Var MISSINGFILEORPATH


Section "Main"
	;=== Check if already running
       ;=== Pretend this is PuTTY portable so that registry settings are not relcated for both...
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "PuTTYPortable") i .r1 ?e'
	Pop $0
	StrCmp $0 0 CheckINI
		StrCpy $SECONDARYLAUNCH "true"

	CheckINI:
		;=== Find the INI file, if there is one
		IfFileExists "$EXEDIR\${NAME}.ini" "" NoINI
			StrCpy "$INIPATH" "$EXEDIR"
			Goto ReadINI

	ReadINI:
		;=== Read the parameters from the INI file
		ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "${APPNAME}Directory"
		StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\$0"
		ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "SettingsDirectory"
		StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\$0"
	

		;=== Check that the above required parameters are present
		IfErrors NoINI
		ReadINIStr $ADDITIONALPARAMETERS "$INIPATH\${NAME}.ini" "${NAME}" "AdditionalParameters"

	;CleanUpAnyErrors:
		;=== Any missing unrequired INI entries will be an empty string, ignore associated errors
		ClearErrors

		;=== Correct PROGRAMEXECUTABLE if blank
		StrCmp $PROGRAMEXECUTABLE "" "" EndINI
			StrCpy "$PROGRAMEXECUTABLE" "${DEFAULTEXE}"
			Goto EndINI

	NoINI:
		;=== No INI file, so we'll use the defaults
		StrCpy "$ADDITIONALPARAMETERS" ""
		StrCpy "$PROGRAMEXECUTABLE" "${DEFAULTEXE}"

		IfFileExists "$EXEDIR\App\${DEFAULTAPPDIR}\${DEFAULTEXE}" "" NoProgramEXE
			StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\App\${DEFAULTAPPDIR}"
			StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\Data\${DEFAULTSETTINGSDIR}"
			GoTo EndINI

	EndINI:
		IfFileExists "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" FoundProgramEXE

	NoProgramEXE:
		;=== Program executable not where expected
		StrCpy $MISSINGFILEORPATH $PROGRAMEXECUTABLE
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
		Abort
		
	FoundProgramEXE:
		;=== Check if running
		StrCmp $SECONDARYLAUNCH "true" GetPassedParameters
		FindProcDLL::FindProc "putty.exe"
		StrCmp $R0 "1" WarnAnotherInstance DisplaySplash

	WarnAnotherInstance:
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherAlreadyRunning)`
		Abort
	
	DisplaySplash:
			InitPluginsDir
	
	GetPassedParameters:
		;=== Get any passed parameters
		Call GetParameters
		Pop $0
		StrCmp "'$0'" "''" "" LaunchProgramParameters

		;=== No parameters
		StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"`
		Goto AdditionalParameters

	LaunchProgramParameters:
		StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" $0`

	AdditionalParameters:
		StrCmp $ADDITIONALPARAMETERS "" SettingsDirectory

		;=== Additional Parameters
		StrCpy $EXECSTRING `$EXECSTRING $ADDITIONALPARAMETERS`
	
	SettingsDirectory:
		;=== Set the settings directory if we have a path
		IfFileExists "$SETTINGSDIRECTORY\*.*" "" RegistryBackup
			CreateDirectory $SETTINGSDIRECTORY
	
	RegistryBackup:
		StrCmp $SECONDARYLAUNCH "true" LaunchAndExit
		;=== Backup the registry
		${registry::KeyExists} "HKEY_CURRENT_USER\Software\SimonTatham-BackupByPuTTYPortable" $R0
		StrCmp $R0 "0" RestoreSettings
		${registry::KeyExists} "HKEY_CURRENT_USER\Software\SimonTatham" $R0
		StrCmp $R0 "-1" RestoreSettings
		${registry::MoveKey} "HKEY_CURRENT_USER\Software\SimonTatham" "HKEY_CURRENT_USER\Software\SimonTatham-BackupByPuTTYPortable" $R0
		Sleep 100

	RestoreSettings:
		IfFileExists "$SETTINGSDIRECTORY\putty.reg" "" SetRandomSeedPath
		
		;=== Get last drive letter
		ReadINIStr $0 "$SETTINGSDIRECTORY\putty.reg" "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY" `"RandSeedFile"`
		StrCpy $1 $0 1 ;last drive letter
		StrCpy $2 $EXEDIR 1 ;current drive letter
		StrCmp $2 $1 RestoreTheKey
		StrCpy $3 `"PublicKeyFile"="$1:\\`
		StrCpy $4 `"PublicKeyFile"="$2:\\`
		;MessageBox MB_OK|MB_ICONINFORMATION `$3 *** $4`
		${ReplaceInFile} "$SETTINGSDIRECTORY\putty.reg" $3 $4
		
	RestoreTheKey:
		IfFileExists "$WINDIR\system32\reg.exe" "" RestoreTheKey9x
			nsExec::ExecToStack `"$WINDIR\system32\reg.exe" import "$SETTINGSDIRECTORY\putty.reg"`
			Pop $R0
			StrCmp $R0 '0' SetRandomSeedPath ;successfully restored key
	RestoreTheKey9x:
		${registry::RestoreKey} "$SETTINGSDIRECTORY\putty.reg" $R0
		Sleep 2000
		StrCmp $R0 '0' SetRandomSeedPath ;successfully restored key
		StrCpy $FAILEDTORESTOREKEY "true"
		MessageBox MB_OK|MB_ICONINFORMATION `${PORTABLEAPPNAME}'s settings could not be loaded into the registry.  The account you are logged in with most likely does not have the ability to alter the registry.  ${PORTABLEAPPNAME} should still run correctly, but the default settings will be used.`

	
	SetRandomSeedPath:
		Sleep 100
		${registry::Write} "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY" "RandSeedFile" "$SETTINGSDIRECTORY\PUTTY.RND" "REG_SZ" $0
		;Sleep 1000
		Sleep 100
		ExecWait $EXECSTRING
		
	CheckRunning:
		Sleep 1000
		FindProcDLL::FindProc "${DEFAULTEXE}"                  
		StrCmp $R0 "1" CheckRunning
		
		StrCmp $FAILEDTORESTOREKEY "true" SetOriginalKeyBack
		CreateDirectory $SETTINGSDIRECTORY
		${registry::SaveKey} "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY" "$SETTINGSDIRECTORY\putty.reg" "" $0
		Sleep 100
	
	SetOriginalKeyBack:
		${registry::DeleteKey} "HKEY_CURRENT_USER\Software\SimonTatham" $R0
		Sleep 100
		${registry::KeyExists} "HKEY_CURRENT_USER\Software\SimonTatham-BackupByPuTTYPortable" $R0
		StrCmp $R0 "-1" TheEnd
		${registry::MoveKey} "HKEY_CURRENT_USER\Software\SimonTatham-BackupByPuTTYPortable" "HKEY_CURRENT_USER\Software\SimonTatham" $R0
		Sleep 100
		Goto TheEnd
		
	LaunchAndExit:
		Exec $EXECSTRING
		
	TheEnd:
		${registry::Unload}
SectionEnd