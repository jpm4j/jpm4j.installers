# Scripts (bat) files do not work very well in Windows, their process rules are different 
# than exes.  So we do it in another way. There is a small exe file that finds out its
# own name from arg[0] (standard guaranteed C). This name is then looked up in 
# 
# 	{dir}/commands/{name}.jpm
# 
# It then takes this file and uses it directly as input to the system command. It is the task
# of jpm to make sure the content is therefore correct. When a new command is installed, jpm
# copies the exe to the appropriate bin directory and creates a "script" in the commands
# directory.
# 
# The setup.exe is signed. However, windows needs a PKCS#12 file so we have to
# format this from the default keystore. The keystore is in ../shared. The password
# is for obvious reasons not given. The PASSWORD environment variable should be set for the
# Makefile is ran.
# 
# The environment is trying to limit itself to MinGW, especially its msys option. This
# includes a limited (but highly portable) shell environment. It can be download from
# 
# 	http://www.mingw.org/
# 
# The installer is using inno, an amazing relieve after trying many others. Very powerful
# and easy to script. Kudos. Installed from:
# 
# 	http://www.jrsoftware.org/isinfo.php
# 
# To sign the files (and maybe one day add a manifest), the Windows SDK for Windows 7
# is required:
# 
# 	http://www.microsoft.com/en-us/download/details.aspx?id=3138
# 
# This makefile creates the (signed) Windows installer for jpm4j. Before running this
# makefile ensure that the following tools are in the command path:
# 
#  msys.bat    "/c/MinGW/msys/1.0"
#  signtool  	"/c/Program Files/Microsoft SDKs/Windows/v7.1/Bin"
#  keytool   	"/c/Program Files/Java/jdk1.7.0_07/bin"
#  iccs      	"/c/Program Files (x86)\Inno Setup 5"
#  mingw32-gcc	"/c/MinGW/bin"
# 
# The jar is by default retrieved from the ci server. 
#
# 64/32 bit misery ...

all: ../dist/jpm-setup.exe
 
# 
# Sign the installer
#

../dist/jpm-setup.exe : setup.exe aqute.pfx
	cp setup.exe $@
	signtool sign -f aqute.pfx -d "Installer for jpm4j" -du "https://www.jpm4j.org/#/md/jpmcmd" -a -p $(PASSWORD) $@ 

#
# Build the installer
#

setup.exe : inno.iss runner.exe sjpm.exe readme.txt ../dist/biz.aQute.jpm.run.jar
	iscc  inno.iss         

#
# Create a signed version from the runner so we can use it in 
# jpm to elevate. This does not work yet since the mt.exe 
# seems to correctly add a manifest but at the same time
# kills the exe. So no elevation yet.
#

sjpm.exe : runner.exe aqute.pfx sjpm.exe.manifest 
	cp runner.exe sjpm.exe
#	mt.exe -manifest sjpm.exe.manifest "-outputresource:sjpm.exe;#1"
	signtool sign -f aqute.pfx -a -p $(PASSWORD) sjpm.exe

#	
# Convert the Java Keystore to 
# PKCS12 file. See:
# http://stackoverflow.com/questions/527610/how-can-i-create-a-pfx-file-from-a-java-keystore
#
# There is a small problem that the current aqute.ks contains two keys (mykey as well) and
# that key can not be exportd. Ignore the warning and tell the program to continue. The
# program also asks for the password 3x :-(
#
aqute.pfx : ../shared/aqute.ks
	keytool -importkeystore \
		-srckeystore $? \
		-destkeystore aqute.pfx \
		-deststoretype PKCS12
 
# 
# Compile the runner program
#           
runner.exe : runner.c
	mingw32-gcc -o runner.exe runner.c

#
# And clean
#
clean :
	-rm runner.exe setup.exe aqute.pfx sjpm.exe jpm.jar jpm-setup.exe
	

getjpm:
	curl https://bndtools.ci.cloudbees.com/job/bnd.next/lastSuccessfulBuild/artifact/dist/bundles/biz.aQute.jpm.run/biz.aQute.jpm.run-latest.jar >jpm.jar
