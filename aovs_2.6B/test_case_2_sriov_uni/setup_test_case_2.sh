#!/bin/bash

#Check if VM name is passed
if [ -z "$1" ]; then
   	echo "ERROR: Please pass a VM name that you whish to pin as the first parameter of this script..."
   	exit -1
else
   	VM_NAME=$1
fi

if [ -z "$2" ]; then
	echo "Using default 4 CPU's for VM"
else
   	VM_CPU_COUNT=$2
fi

#ovs-ctl start

script_dir="$(dirname $(readlink -f $0))"

$script_dir/0_configure_hugepages.sh

if [[ "$3" == "AOVS" ]]; then
    $script_dir/1_bind_VFIO-PCI_driver.sh
    $script_dir/2_configure_AOVS.sh
    $script_dir/3_configure_AOVS_rules.sh
    $script_dir/4_guest_xml_configure.sh $VM_NAME $VM_CPU_COUNT

elif [[ "$3" == "OVS_TC" ]]; then
    $script_dir/1_bind_VFIO-PCI_driver_TC.sh $VM_NAME $VM_CPU_COUNT
fi

$script_dir/5_vm_pinning.sh $VM_NAME $VM_CPU_COUNT

echo "DONE($(basename $0))"
exit 0
