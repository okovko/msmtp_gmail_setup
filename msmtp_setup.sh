#!/bin/bash

# Here's how I set up mail on Ubuntu 18.04 and OSX High Sierra (took a while to figure out for Mac)

# https://myaccount.google.com/
# 2 factor authentication needs to be set up
# Click "Signing into Google"
# Click "App passwords"
# Select "Mail" and "other", maybe name it "msmtp"
# Generate the msmtp password and save it somewhere

os=""
if uname -a | grep -iq "darwin"
then
	os="darwin"
elif uname -a | grep -iq "linux"
then
	os="linux"
fi

if [ "$os" == "" ]
then
	echo "This script expects darwin or linux."
	exit 1
elif [ "$os" == "darwin" ] && which brew | grep -c "not found"
then
	echo "Can't find brew installation; make brew command visible or install homebrew and try again"
	exit 1
elif [ "$os" == "linux" ] && ! dpkg -s apt | grep -c "install ok installed"
then
	echo "apt is not installed; install apt and try again"
	exit 1
fi

if [ "$os" == "linux" ]
then
	sudo apt-get install mailutils
	sudo apt-get install msmtp
	sudo apt-get install msmtp-mta
fi

if [ "$os" == "darwin" ]
then
	brew install mailutils
	brew install msmtp
	echo "set sendmail=/usr/local/bin/msmtp" | sudo tee -a /etc/mail.rc
fi

echo "defaults
auth on
tls on" >> ~/.msmtprc

if [ "$os" == "linux" ]
then
	echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> ~/.msmtprc
elif [ "$os" == "darwin" ]
then
	{ echo -n "tls_fingerprint " &
	  msmtp --serverinfo --tls --tls-certcheck=off --host=smtp.gmail.com --port=587 \
	  | egrep -o "([0-9A-Za-z]{2}:){31}[0-9A-Za-z]{2}" ;
	} >> ~/.msmtprc
fi

echo "logfile ~/.msmtp.log
account gmail
host smtp.gmail.com
port 587
from $EMAIL_
user $USERNAME_
password $PASSWORD_
account default: gmail" >> ~/.msmtprc

echo "export MAIL_SERVER = smtp.gmail.com
export MAIL_PORT = 587
export MAIL_USE_TLS = True
export MAIL_USE_SSL = False
export MAIL_USERNAME = $EMAIL_
export MAIL_PASSWORD = $PASSWORD_" >> ~/.$(basename $SHELL)rc
