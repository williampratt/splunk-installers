#!/usr/bin/env bash

WGET_URL="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.6&product=splunk&filename=splunk-8.0.6-152fb4b2bb96-Linux-x86_64.tgz&wget=true"
FILENAME="splunk-8.0.6-152fb4b2bb96-Linux-x86_64.tgz"
DL_PATH="/tmp/$FILENAME"
INSTALL_DIR="/opt"
INSTALLED_PATH="$INSTALL_DIR/splunk"
SPLUNK_USER="splunk"

if ! [[ -e "/home/$SPLUNK_USER" ]]; then
	echo "A user '$SPLUNK_USER' needs to exist on the system!!!"
	return 0
fi

# In case splunk is already installed and running, shut it down before removing it (if it's installed and not running nbd)
if [[ -e $INSTALLED_PATH ]]; then
	echo "Stopping Splunk..."
	$INSTALLED_PATH/bin/splunk stop
fi

# Remove everything in and including INSTALLED_PATH if it exists
if [[ -e $INSTALLED_PATH ]]; then
	echo "Removing existing $INSTALLED_PATH directory..."
	rm -rf $INSTALLED_PATH
fi

# Download splunk and extract it into INSTALLED_PATH then delete the install file
echo "Installing Splunk..."
wget -O $DL_PATH $WGET_URL

cd $INSTALL_DIR && tar -zxvf $DL_PATH

chown -R $SPLUNK_USER:$SPLUNK_USER $INSTALLED_PATH

rm -rf $DL_PATH

# start splunk and accept the license. It will prompt you for the admin name and password
echo "Starting Splunk..."

su $SPLUNK_USER -c "$INSTALLED_PATH/bin/splunk start --accept-license"

echo "All Done!!!"