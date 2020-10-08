#!/usr/bin/env bash

WGET_URL="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.6&product=universalforwarder&filename=splunkforwarder-8.0.6-152fb4b2bb96-Linux-x86_64.tgz&wget=true"
FILENAME="splunkforwarder-8.0.6-152fb4b2bb96-Linux-x86_64.tgz"
DL_PATH="/tmp/$FILENAME"
INSTALL_DIR="/opt"
SPLUNK_HOME="$INSTALL_DIR/splunkforwarder"
SPLUNK_USER="splunk"
SPLUNK_USER_HOME="/home/$SPLUNK_USER"
SYSTEMD_MANAGED=0
BOOT_START="$SPLUNK_HOME/bin/splunk enable boot-start -systemd-managed $SYSTEMD_MANAGED -user $SPLUNK_USER"

if ! [[ -e $SPLUNK_USER_HOME ]]; then
	echo "A user '$SPLUNK_USER' needs to exist on the system!!!"
	return 0
fi


# In case splunk is already installed and running, shut it down before removing it (if it's installed and not running nbd)
if [[ -e $SPLUNK_HOME ]]; then
	echo "Stopping Splunk Forwarder..."
	$SPLUNK_HOME/bin/splunk stop
fi

# Remove everything in and including SPLUNK_HOME if it exists
if [[ -e $SPLUNK_HOME ]]; then
	echo "Removing existing $SPLUNK_HOME directory..."
	rm -rf $SPLUNK_HOME
fi

# Download splunkforwarder and extract it into SPLUNK_HOME then delete the install file
echo "Installing Splunk Forwarder..."
wget -O $DL_PATH $WGET_URL

cd $INSTALL_DIR && tar -zxvf $DL_PATH

chown -R $SPLUNK_USER:$SPLUNK_USER $SPLUNK_HOME

rm -rf $DL_PATH

# start splunk and accept the license. It will prompt you for the admin name and password
echo "Starting Splunk..."

su $SPLUNK_USER -c "$SPLUNK_HOME/bin/splunk start --accept-license"

echo "Stopping Splunk To Enable Boot Start..."

$SPLUNK_HOME/bin/splunk stop

echo "Setting enable boot-start..."

$BOOT_START

echo "Starting Splunk..."

su $SPLUNK_USER -c "$SPLUNK_HOME/bin/splunk start"

#get back to our home dir
cd ~

echo "All Done!!!"