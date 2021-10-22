# danish-radius

RADIUS authentication server supporting EAP-TLS with DNS-based identities, implemented via <https://balena.io>

## What it does

This is a proof-of-concept implementation of EAP-TLS on RADIUS, using DNS-bound client identities. This allows any device with a DNS-based identity to be allowed network access based on name alone, independent of the private PKI used to sign the certificate.

This project supports, but **does not require**, Valimail's policy engine for managing network access lists.

## Requirements

### Client devices

Client devices must have certificates and trust anchors published according to <https://datatracker.ietf.org/doc/draft-wilson-dane-pkix-cd/>

### Supporting infrastructure

This RADIUS server can be used to support EAP-TLS authentication for wired or wireless networks.

Network hardware must support EAP-TLS. Tested with Ubiquiti APs.

The RADIUS server will accept a static access file (configured at `/var/danish/policy.text` in the `policy_manager` container), or it can be managed via integration with Valimail's policy management system.

## Setup

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/valimail/danish-radius&tarballUrl=https://github.com/ValiMail/danish-radius/archive/refs/heads/main.zip)

1. Configure this project for a Balena fleet.
1. Flash a device with this fleet's firmware.
1. Set the appropriate [environment variables](#environment-variables)
1. Generate the RADIUS server's identity according to [Identity Provisioning](#provisioning-identity)
1. Configure either the Valimail policy server settings or the static policy file [Policy File](#policy-file)
1. Set the SSIDs to be used for authentication in the `ROLES` environment variable. This setting is comma-separated and case-sensitive.

Finally, publish your client device certificates in DNS, following the pattern described here: <https://datatracker.ietf.org/doc/draft-wilson-dane-pkix-cd/>


## policy-file

The policy file from the Valimail policy engine can be found at `/var/danish/policy.json` and is used to create the SSID to DNS name mapping in `/var/danish/policy.txt`, which is periodically checked by the `maintenance` container application and used to compose the `/var/danish/trust_map.json` file. The `/var/danish/trust_map.json` file is used as a part of the authorization process to prevent cross-domain signing with multiple private PKIs (namespace enforcement).

The `/var/danish/policy.json` is structured like this:

```json
{"name": "APPLICATION_NAME",
 "roles": [
     {"name": "ROLE_NAME",
      "members": [
          "some._device.example",
          "someother._device.example"
      ]
     }
 ]
}
```

The `/var/danish/policy.text` file is structured like this:

```bash
my-ssid|some._device.example
my-ssid|other._device.example
another-ssid|some._device.example
```

The string before the pipe character is the SSID name, and the string after the pipe character is the DNS name of the device which should be allowed to access the SSID. If deploying without the Valimail policy server integration, directly manage the `/var/danish/policy.txt` file.

## provisioning-identity

```bash

# Generate the private key and a CSR
./create_id_csr.py

# Print the CSR to stdout. Use this to get a cert and publish it in DNS at ${DANE_ID} (TLSA 4 0 0)
# The CA certificate must be retrievable at https://IDTYPE.DOMAIN/.well-known/ca/AUTHORITYKEYID.pem
# If the device DNS name follows the pattern of "devicename._device.mydomain.example" then 
# IDTYPE is device
# DOMAIN is mydomain.example
# AUTHORITYKEYID is the authorityKeyID from the entity certificate. 
cat /etc/dane_id/${DANE_ID}.csr.pem

# Download and place the CA certificate for the RADIUS server's TLS server config.
mkdir /etc/dane_id/cadir

dane_discovery_get_ca_certificates --output_path /identity/cadir/${DANE_ID}ca.cert.pem --identity_name ${DANE_ID}

```

## environment-variables

| Variable name         | Purpose                                                                                                         |
|-----------------------|-----------------------------------------------------------------------------------------------------------------|
| DANE_ID               | This is the DANE name of this RADIUS server.                                                                    |
| POLICY_NAME           | This is the name of the policy as configured in Valimail's policy system.                                       |
| POLICY_URL            | This is the URL of the policy server.                                                                           |
| RADIUS_ARGS           | Set this to `-xf`.                                                                                              |
| RADIUS_CLIENT_IP      | This is the IP address (or subnet) of network devices which will be passing EAP messages to this RADIUS server. |
| RADIUS_CLIENT_NETMASK | This is the netmask for the `RADIUS_CLIENT_IP`.                                                                 |
| RADIUS_CLIENT_SECRET  | This is the shared secret for RADIUS.                                                                           |
| ROLES                 | This is a comma-separated list of SSIDs that can be found in the policy file, represented as roles.             |


# Licenses

* This repository contains build instructions for, and configuration files adapted from, the FreeRADIUS RADIUS server, which is GPL-licensed. <https://github.com/FreeRADIUS/freeradius-server/blob/master/LICENSE>
