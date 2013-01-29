#
# This makefile creates the (signed) Windows installer for jpm4j. Before running this
# makefile ensure that the following tools are in the command path:
#
#  signtool  	"/c/Program Files/Microsoft SDKs/Windows/v7.1/Bin"
#  keytool   	"/c/Program Files/Java/jdk1.7.0_07/bin"
#  iccs      	"/c/Program Files (x86)\Inno Setup 5"
#  mingw32-gcc	"/c/MinGW/bin"
# 
# This makefile is assumed to run on a windows PC and assumes a cygwin kind of
# environment.
#
# This makefile signs the artifacts. To not hardcode the password, a macro $(PASSWORD)
# is used. This macro should be set as an environment variable before the makefile is
# run.
#
# The jar is by default retrieved from the ci server. 
#

all: jpm-setup.exe
 	
 
# 
# Sign the installer
#

jpm-setup.exe : setup.exe aqute.pfx
	cp setup.exe jpm-setup.exe
	signtool sign -f aqute.pfx -d "Installer for jpm4j" -du "https://www.jpm4j.org/#/md/jpmcmd" -a -p $(PASSWORD) jpm-setup.exe 

#
# Build the installer
#

setup.exe : inno.iss runner.exe sjpm.exe readme.txt jpm.jar
	iscc  inno.iss         

#
# Fetch the jar file from the CI server
#

jpm.jar : 
	curl -o jpm.jar https://bndtools.ci.cloudbees.com/job/bnd.next/lastSuccessfulBuild/artifact/dist/bundles/biz.aQute.jpm.run/biz.aQute.jpm.run-latest.jar 

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
	
