#! /bin/bash

set -e
if [ $EUID -ne 0 ]; then 
	echo "Please run the script as root."
	exit 1
fi

MANAGER=""
GROUP="desktop,default"
AgentUrl="https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.2-1_amd64.deb"
AgentInstaller="/tmp/wazuh-agent_4.7.2-1_amd64.deb"
LocalConfigFile=/var/ossec/etc/local_internal_options.conf

if [ -z $MANAGER ]; then
	echo "Error: value for MANAGER is not specified. Please set the value before executing the script"
	exit 1
fi


/bin/wget $AgentUrl -O $AgentInstaller 

WAZUH_MANAGER=$MANAGER WAZUH_AGENT_GROUP=$GROUP dpkg -i $AgentInstaller

echo "sca.remote_commands=1" >> $LocalConfigFile

systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

echo "Wazuh agent installation and configuration successful."
