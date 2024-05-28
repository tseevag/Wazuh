#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Please run the script as root."
    exit 1
fi

MANAGER=""
GROUP="desktop,default"
WAZUH_AGENT_URL="https://packages.wazuh.com/4.x/macos/wazuh-agent-4.7.2-1.arm64.pkg"
WAZUH_AGENT_PKG="/tmp/wazuh-agent.pkg"
WAZUH_CONFIG_FILE="/Library/Ossec/etc/local_internal_options.conf"

if [ !$MANAGER ]; then
	echo "Error: value for MANAGER is not specified. Please set the value before executing the script"
	exit 1
fi

curl -so "$WAZUH_AGENT_PKG" "$WAZUH_AGENT_URL"

echo "WAZUH_MANAGER=$MANAGER && WAZUH_AGENT_GROUP=$GROUP"  > /tmp/wazuh_envs && installer -pkg "$WAZUH_AGENT_PKG" -target /

echo "sca.remote_commands=1" >> $WAZUH_CONFIG_FILE

launchctl load /Library/LaunchDaemons/com.wazuh.agent.plist
launchctl start com.wazuh.agent

echo "Wazuh agent installation and configuration completed successfully."
