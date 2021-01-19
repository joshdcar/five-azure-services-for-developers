#!/bin/bash

# CREDIT: https://github.com/BorisWilhelms/create-dotnet-devcert
# FOR LOCAL DOTNET DEV ON LINUX SUBSYSTEM FOR WINDOWS TO FIX dotnet "dev-certs https --trust" not working on linux
# POST SCRIPT IF YOU WANT TO LAUNCH BROWSER IN WINDOWS AND HAVE IT TRUST CERT
# USE SAME DEV CERT FOR WINDOWS
# COPY PFX found at /var/tmp/localhost-dev-cert To Windows C:\users\[profile]\.aspnet\.ssl then run at a windows prompt:  dotnet dev-certs https -ep "C:\users\[profile]\.aspnet\.ssl\dotnet-devcert.pfx" -p "pass:" 
# ADD TO TRUSTED ROOT (FOR NO BROWSER PROMPT)

TMP_PATH=/var/tmp/localhost-dev-cert
if [ ! -d $TMP_PATH ]; then
    mkdir $TMP_PATH
fi

KEYFILE=$TMP_PATH/dotnet-devcert.key
CRTFILE=$TMP_PATH/dotnet-devcert.crt
PFXFILE=$TMP_PATH/dotnet-devcert.pfx

NSSDB_PATHS=(
    "$HOME/.pki/nssdb"
    "$HOME/snap/chromium/current/.pki/nssdb"
    "$HOME/snap/postman/current/.pki/nssdb"
)

CONF_PATH=$TMP_PATH/localhost.conf
cat >> $CONF_PATH <<EOF
[req]
prompt                  = no
default_bits            = 2048
distinguished_name      = subject
req_extensions          = req_ext
x509_extensions         = x509_ext

[ subject ]
commonName              = localhost

[req_ext]
basicConstraints        = critical, CA:true
subjectAltName          = @alt_names

[x509_ext]
basicConstraints        = critical, CA:true
keyUsage                = critical, keyCertSign, cRLSign, digitalSignature,keyEncipherment
extendedKeyUsage        = critical, serverAuth
subjectAltName          = critical, @alt_names
1.3.6.1.4.1.311.84.1.1  = ASN1:UTF8String:ASP.NET Core HTTPS development certificate # Needed to get it imported by dotnet dev-certs

[alt_names]
DNS.1                   = localhost
EOF

function configure_nssdb() {
    echo "Configuring nssdb for $1"
    certutil -d sql:$1 -D -n dotnet-devcert
    certutil -d sql:$1 -A -t "CP,," -n dotnet-devcert -i $CRTFILE
}

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $KEYFILE -out $CRTFILE -config $CONF_PATH --passout pass:
openssl pkcs12 -export -out $PFXFILE -inkey $KEYFILE -in $CRTFILE --passout pass:

for NSSDB in ${NSSDB_PATHS[@]}; do
    if [ -d "$NSSDB" ]; then
        configure_nssdb $NSSDB
    fi
done

sudo rm /etc/ssl/certs/dotnet-devcert.pem
sudo cp $CRTFILE "/usr/local/share/ca-certificates"
sudo update-ca-certificates

dotnet dev-certs https --clean --import $PFXFILE -p ""

echo "TMPPATH $TMP_PATH"
#rm -R $TMP_PATH