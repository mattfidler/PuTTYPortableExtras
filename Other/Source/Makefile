all: ../../PageantPortable.exe ../../App/putty/PUTTY.exe ../../PageantPuTTYPortable.exe

install:
	makensis PuttyExtrasInstaller.nsi

../../PageantPortable.exe: PageantPortable.nsi
	makensis PageantPortable.nsi

../../App/putty/PUTTY.exe: fakeputty.nsi
	makensis fakeputty.nsi
../../PageantPuTTYPortable.exe: PageantPuTTYPortable.nsi
	makensis PageantPuTTYPortable.nsi
clean:
	rm ../../PageantPortable.exe
	rm ../../App/putty/PUTTY.exe
	rm ../../PageantPuTTYPortable.exe

