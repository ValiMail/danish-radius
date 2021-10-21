#!/bin/bash

# Start the RADIUS server
mkdir -p /tmp/radiusd
sudo chown freerad:freerad /tmp/radiusd 
cd /etc/freeradius/3.0/sites-enabled/ && ls | xargs -n 1 unlink
cd /etc/freeradius/3.0/mods-enabled/ && ls | xargs -n 1 unlink 
cat /etc/freeradius-conf-cache/eap-tls | envsubst '${DANE_ID}' > /etc/freeradius/3.0/mods-enabled/eap-tls
cat /etc/freeradius-conf-cache/clients.conf | envsubst > /etc/freeradius/3.0/clients.conf
cp /etc/freeradius-conf-cache/default /etc/freeradius/3.0/sites-enabled
cp /etc/freeradius-conf-cache/default /etc/freeradius/3.0/sites-enabled
cp /etc/freeradius-conf-cache/attr_filter /etc/freeradius/3.0/mods-enabled
chown freerad:freerad /etc/dane_id/${DANE_ID}.crt.pem
chown freerad:freerad /etc/dane_id/${DANE_ID}.key.pem
ln -s /etc/freeradius/3.0/mods-available/always /etc/freeradius/3.0/mods-enabled/always
ln -s /etc/freeradius/3.0/mods-available/preprocess /etc/freeradius/3.0/mods-enabled/preprocess
ln -s /etc/freeradius/3.0/mods-available/expiration /etc/freeradius/3.0/mods-enabled/expiration
# ln -s /etc/freeradius/3.0/sites-available/check-eap-tls /etc/freeradius/3.0/sites-enabled/check-eap-tls
ln -s /etc/freeradius/3.0/mods-available/logintime /etc/freeradius/3.0/mods-enabled/logintime
ln -s /etc/freeradius/3.0/mods-available/detail /etc/freeradius/3.0/mods-enabled/detail
ln -s /etc/freeradius/3.0/mods-available/exec /etc/freeradius/3.0/mods-enabled/exec
ln -s /etc/freeradius/3.0/mods-available/expr /etc/freeradius/3.0/mods-enabled/expr
sudo freeradius -f -l stdout ${RADIUS_ARGS} | tee /var/log/radout
sleep 5
