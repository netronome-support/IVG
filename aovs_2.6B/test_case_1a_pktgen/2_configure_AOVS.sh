#!/bin/bash

if [ ! -f /etc/netronome.conf ]; then
    echo "ERROR: Could not find netronome.conf. Is Agilio-OVS installed?"
    exit -1
fi

cat << 'EOF' > /etc/netronome.conf
SDN_VIRTIORELAY_ENABLE=n
SDN_FIREWALL=n
EOF

echo "NEW configuration"
cat /etc/netronome.conf

ovs-ctl stop
ovs-ctl start
ovs-ctl status

exit 0
