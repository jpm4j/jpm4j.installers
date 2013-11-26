# This makefile creates a setup.exe for jpm.
#
# The setup.exe is signed. However, windows needs a PKCS#12 file so we have to
# format this from the default keystore. The keystore is in ../shared. The password
# is for obvious reasons not given. The PASSWORD environment variable should be set for the
# Makefile is ran.
# 
# The installer is using inno, an amazing relieve after trying many others. Very powerful
# and easy to script. Kudos. Installed from:
# 
# 	http://www.jrsoftware.org/isinfo.php
# 
# To sign the files , the Windows SDK for Windows 7
# is required:
# 
# 	http://www.microsoft.com/en-us/download/details.aspx?id=3138
# 
# This makefile creates the (signed) Windows installer for jpm4j. Before running this
# makefile ensure that the following tools are in the command path:
# 
# export PATH=$PATH:/c/inno5.5.3
# export PATH=$PATH:/c/wsdk7.1/Bin
# 
#

all: ../dist/jpm-setup.exe
 
# 
# Sign the installer
#

../dist/jpm-setup.exe : setup.exe aqute.pfx
	cp setup.exe $@
	signtool sign -f aqute.pfx -d "Installer for jpm4j" -du "https://www.jpm4j.org/#!/md/jpmcmd" -a -p $(PASSWORD) $@ 

#
# Build the installer
#

setup.exe : inno.iss ../dist/biz.aQute.jpm.run.jar
	iscc  inno.iss         

#
# Create a signed version from the runner so we can use it in 
# jpm to elevate. This does not work yet since the mt.exe 
# seems to correctly add a manifest but at the same time
# kills the exe. So no elevation yet.
#

sjpm.exe : runner.exe aqute.pfx xmanifest
	cp runner.exe sjpm.exe
	mt "-manifest" xmanifest "-outputresource:sjpm.exe;1"
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
# And clean
#
clean :
	-rm setup.exe aqute.pfx
	
