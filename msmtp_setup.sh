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
elif uname -a | grep -iq "ubuntu"
then
	os="ubuntu"
fi

if [ "$os" == "" ]
then
	exit 1
fi

if [ "$os" == "ubuntu" ]
then
	sudo apt-get install mailutils
	sudo apt-get install msmtp
	sudo apt-get install msmtp-mta
fi

if [ "$os" == "darwin" ]
then
	sudo brew install mailutils
	sudo brew install msmtp
	echo "set sendmail=/usr/bin/msmtp" | sudo tee -a /etc/mail.rc
fi

echo "defaults
auth on
tls on" >> ~/.msmtprc

if [ "$os" == "ubuntu" ]
then
	echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> ~/.msmtprc
elif [ "$os" == "darwin" ]
then
	{ echo -n "tls_fingerprint" &
	  msmtp --serverinfo --tls --tls-certcheck=off --host=smtp.gmail.com --port=587 \
	  | grep -e "SHA256" | tr -s ' ' | cut -c10- ;
	} >> ~/.msmtprc
fi

echo "logfile ~/.msmtp.log
account gmail
host smtp.gmail.com
port 587
from $EMAIL
user $USERNAME 
password $PASSWORD
account default: gmail" >> ~/.msmtprc

echo "export MAIL_SERVER = smtp.gmail.com
export MAIL_PORT = 587
export MAIL_USE_TLS = True
export MAIL_USE_SSL = False
export MAIL_USERNAME = $EMAIL
export MAIL_PASSWORD = $PASSWORD" >> ~/.$(basename $SHELL)rc
