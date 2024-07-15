#!/bin/bash
echo "Script made by JSBmanD for Ubuntu 24.04. Press ENTER to continue."
read KEY
echo "Enter your domain name and press [ENTER]: "
read DOMAIN
echo "Enter your username for SERVER and press [ENTER]: "
read USERNAME
echo "Enter your password for SERVER and press [ENTER]: "
read PASSWORD
clear
echo "Entered config:"
echo "Domain: $DOMAIN"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "Press ENTER to continue or CTRL+Z to abort"
read KEY
clear
echo "Setup started"
sudo apt update
sudo apt -y install strongswan
sudo apt -y install certbot
sudo apt -y install ufw
clear
sudo ufw enable
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 22
sudo ufw reload
sudo certbot certonly --rsa-key-size 4096 --standalone --agree-tos --no-eff-email --email ceo@$DOMAIN -d $DOMAIN
echo "0 0,12 * * * root python3 -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/ipsec.d/certs/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/ipsec.d/private/
sudo cp /etc/letsencrypt/live/$DOMAIN/chain.pem /etc/ipsec.d/cacerts/
sudo mv /etc/ipsec.conf /etc/ipsec.conf.bak
echo "#global configuration IPsec
#chron logger
config setup
    charondebug=\"ike 1, knl 1, cfg 0\"
    uniqueids=never

#define new ipsec connection
conn jsb-ikev-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    ike=aes128-sha1-modp1024,aes128-sha1-modp1536,aes128-sha1-modp2048,aes128-sha256-ecp256,aes128-sha256-modp1024,aes128-sha256-modp1536,aes128-sha256-modp2048,aes256-aes128-sha256-sha1-modp2048-modp4096-modp1024,aes256-sha1-modp1024,aes256-sha256-modp1024,aes256-sha256-modp1536,aes256-sha256-modp2048,aes256-sha256-modp4096,aes256-sha384-ecp384,aes256-sha384-modp1024,aes256-sha384-modp1536,aes256-sha384-modp2048,aes256-sha384-modp4096,aes256gcm16-aes256gcm12-aes128gcm16-aes128gcm12-sha256-sha1-modp2048-modp4096-modp1024,3des-sha1-modp1024!
    esp=aes128-aes256-sha1-sha256-modp2048-modp4096-modp1024,aes128-sha1,aes128-sha1-modp1024,aes128-sha1-modp1536,aes128-sha1-modp2048,aes128-sha256,aes128-sha256-ecp256,aes128-sha256-modp1024,aes128-sha256-modp1536,aes128-sha256-modp2048,aes128gcm12-aes128gcm16-aes256gcm12-aes256gcm16-modp2048-modp4096-modp1024,aes128gcm16,aes128gcm16-ecp256,aes256-sha1,aes256-sha256,aes256-sha256-modp1024,aes256-sha256-modp1536,aes256-sha256-modp2048,aes256-sha256-modp4096,aes256-sha384,aes256-sha384-ecp384,aes256-sha384-modp1024,aes256-sha384-modp1536,aes256-sha384-modp2048,aes256-sha384-modp4096,aes256gcm16,aes256gcm16-ecp384,3des-sha1!
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@$DOMAIN
    leftcert=fullchain.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.15.1.0/24
    rightdns=1.1.1.1,8.8.8.8
    rightsendcert=never
    eap_identity=%identity" | sudo tee /etc/ipsec.conf
echo "# ipsec.secrets - strongSwan IPsec secrets file
: RSA \"privkey.pem\"
$USERNAME : EAP \"$PASSWORD\"" | sudo tee /etc/ipsec.secrets
echo "duplicheck {
    load = no
}" | sudo tee /etc/strongswan.d/charon/duplicheck.conf
sudo systemctl start strongswan
sudo systemctl enable strongswan
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw allow ipsec
sudo ufw reload
echo "net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
echo "Setup done"
echo "Press ENTER key to show config or CTRL+Z to abort"
read KEY
clear
echo "Config:"
echo "IPsec:"
cat /etc/ipsec.conf
echo "IPsecrets:"
cat /etc/ipsec.secrets
echo "Sysctl:"
cat /etc/sysctl.conf
echo "Done! Press ENTER to finish."
read KEY
