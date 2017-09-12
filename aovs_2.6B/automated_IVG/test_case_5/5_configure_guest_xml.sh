#!/bin/bash
#5_configure_guest_xml.sh

VM_NAME=$1
VM_CPU=4
max_memory=$(virsh dominfo $VM_NAME | grep 'Max memory:' | awk '{print $3}')


# Remove vhostuser interface
EDITOR='sed -i "/<interface type=.vhostuser.>/,/<\/interface>/d"' virsh edit $VM_NAME
EDITOR='sed -i "/<hostdev mode=.subsystem. type=.pci./,/<\/hostdev>/d"' virsh edit $VM_NAME

# Add vhostuser interfaces
# nfp_v0.40 --> 0000:81:0d.0
# nfp_v0.41 --> 0000:81:0d.1


bus=$(ethtool -i nfp_v0.20 | grep bus-info | awk '{print $5}' | awk -F ':' '{print $2}')
# Add vhostuser interfaces
EDITOR='sed -i "/<devices/a \<interface type=\"vhostuser\">  <source type=\"unix\" path=\"/tmp/virtiorelay20.sock\" mode=\"client\"\/>  <model type=\"virtio\"/>  <driver name=\"vhost\" queues=\"1\"\/>  <address type=\"pci\" domain=\"0x0000\" bus=\"0x01\" slot=\"0x06\" function=\"0x0\"\/><\/interface>"' virsh edit $VM_NAME
EDITOR='sed -i "/<devices/a \<interface type=\"vhostuser\">  <source type=\"unix\" path=\"/tmp/virtiorelay21.sock\" mode=\"client\"\/>  <model type=\"virtio\"/>  <driver name=\"vhost\" queues=\"1\"\/>  <address type=\"pci\" domain=\"0x0000\" bus=\"0x01\" slot=\"0x07\" function=\"0x0\"\/><\/interface>"' virsh edit $VM_NAME


EDITOR='sed -i "/<numa>/,/<\/numa>/d"' virsh edit $VM_NAME
EDITOR='sed -i "/vcpu/d"' virsh edit $VM_NAME
EDITOR='sed -i "/<cpu/,/<\/cpu>/d"' virsh edit $VM_NAME
EDITOR='sed -i "/<memoryBacking>/,/<\/memoryBacking>/d"' virsh edit $VM_NAME

virsh setvcpus $VM_NAME $VM_CPU --config --maximum
virsh setvcpus $VM_NAME $VM_CPU --config
# MemoryBacking
EDITOR='sed -i "/<domain/a \<memoryBacking><hugepages><page size=\"2048\" unit=\"KiB\" nodeset=\"0\"\/><\/hugepages><\/memoryBacking>"' virsh edit $VM_NAME
# CPU
echo max_memory: $max_memory
echo VM_CPU: $VM_CPU
EDITOR='sed -i "/<domain/a \<cpu mode=\"host-model\"><model fallback=\"allow\"\/><numa><cell id=\"0\" cpus=\"0-'$((VM_CPU-1))'\" memory=\"'${max_memory}'\" unit=\"KiB\" memAccess=\"shared\"\/><\/numa><\/cpu>"' virsh edit $VM_NAME
