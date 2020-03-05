#!/bin/bash
if [[ -z "${DEFAULT_PASSWORD}" ]]; then
  DEFAULT_PASSWORD="CpS!^246"
fi

SSH_CMD="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
SCP_CMD="scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "

if [[ -z "${OVF_TOOL}" ]]; then
  OVF_TOOL="VMware-ovftool-4.1.0-2459827-lin.x86_64.bundle"
fi

HOST_OS_TYPE="vmware"
if [[ -d $WORKING_DIR/yaml ]]; then
  HOST_OS_TYPE="openstack"
fi

#   
# Prints the value for a key in a config.properties file.
# Arguments:
#    1 - CONFIGFILE - full path to the config.properties file
#    2 - KEY - key for the configuration to be checked
# Returns the value for the key
#
get_config_property()
{
    # Check for arguments
    [[ $# -ne 2 ]] && echo "Not enough arguments:  ${#}" && exit 1
    CONFIGFILE=${1}
    KEY=${2}
  
    sed -n -e "s/^${KEY}=\(.*\)/\1/p" ${CONFIGFILE}
}   

LOG_FILE_NAME="$WORKING_DIR/target/logfile"
mkdir -p $WORKING_DIR/target
exec &> >(tee -a ${LOG_FILE_NAME} )
