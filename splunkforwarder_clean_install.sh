#!/usr/bin/env bash

WGET_URL="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.6&product=universalforwarder&filename=splunkforwarder-8.0.6-152fb4b2bb96-Linux-x86_64.tgz&wget=true"
FILENAME="splunkforwarder-8.0.6-152fb4b2bb96-Linux-x86_64.tgz"
DL_PATH="/tmp/$FILENAME"
INSTALL_DIR="/opt"
INSTALLED_PATH="$INSTALL_DIR/splunkforwarder"
SPLUNK_USER="splunk"
SPLUNK_USER_HOME="/home/$SPLUNK_USER"

if ! [[ -e $SPLUNK_USER_HOME ]]; then
	echo "A user '$SPLUNK_USER' needs to exist on the system!!!"
	return 0
fi


# In case splunk is already installed and running, shut it down before removing it (if it's installed and not running nbd)
if [[ -e $INSTALLED_PATH ]]; then
	echo "Stopping Splunk Forwarder..."
	$INSTALLED_PATH/bin/splunk stop
fi

# Remove everything in and including INSTALLED_PATH if it exists
if [[ -e $INSTALLED_PATH ]]; then
	echo "Removing existing $INSTALLED_PATH directory..."
	rm -rf $INSTALLED_PATH
fi

# Download splunkforwarder and extract it into INSTALLED_PATH then delete the install file
echo "Installing Splunk Forwarder..."
wget -O $DL_PATH $WGET_URL

cd $INSTALL_DIR && tar -zxvf $DL_PATH

chown -R $SPLUNK_USER:$SPLUNK_USER $INSTALLED_PATH

rm -rf $DL_PATH

# start splunk and accept the license. It will prompt you for the admin name and password
echo "Starting Splunk Forwarder..."
su $SPLUNK_USER -c "$INSTALLED_PATH/bin/splunk start --accept-license"

echo "All Done!!!"