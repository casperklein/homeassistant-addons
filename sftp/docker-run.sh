#!/bin/bash

PASSWORD=$(jq --raw-output '.password' /data/options.json)

[ -z "$PASSWORD" ] && {
	echo "Error: No password set."
	exit 1
}

echo "root:$PASSWORD" | chpasswd || exit

cd /etc/ssh || exit

#rm -f ssh_host_ecdsa_key ssh_host_rsa_key ssh_host_ed25519_key

#echo "Creating SSH2 ECDSA key; this may take some time.."
#ssh-keygen -q -f ssh_host_ecdsa_key   -N '' -t ecdsa   -b 521  # Max key size for ecdsa is 521

#echo "Creating SSH2 RSA key; this may take some time.."
#ssh-keygen -q -f ssh_host_rsa_key     -N '' -t rsa     -b 2048 # 2048 bits is considered sufficient.

#echo "Creating SSH2 ED25519 key; this may take some time.."
#ssh-keygen -q -f ssh_host_ed25519_key -N '' -t ed25519         # Ed25519 keys have a fixed length and the -b flag will be ignored.
#echo

echo "Fingerprints:"
echo
echo "ECDSA:   $(ssh-keygen -lf ssh_host_ecdsa_key -E md5)"
echo "ECDSA:   $(ssh-keygen -lf ssh_host_ecdsa_key)"
echo
echo "RSA:     $(ssh-keygen -lf ssh_host_rsa_key -E md5)"
echo "RSA:     $(ssh-keygen -lf ssh_host_rsa_key)"
echo
echo "ED25519: $(ssh-keygen -lf ssh_host_ed25519_key -E md5)"
echo "ED25519: $(ssh-keygen -lf ssh_host_ed25519_key)"
echo

while :; do
	/usr/sbin/sshd -D -e
done
