#!/bin/bash
echo "Maintenance process will wait for 60 seconds, then update the trust map."
sleep 60
# Run the trust mapper script
echo "Update trust mapper..."
mkdir -p /etc/dane_id/cadir
pkix_cd_manage_trust  --infile ${TRUST_INFILE_PATH} --cacerts /etc/dane_id/cadir/cabundle.pem --trustmap /var/danish/trust_map.json
echo "Reindex CA certs..."
cd /etc/dane_id/cadir/
c_rehash ./