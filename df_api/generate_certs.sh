#!/usr/bin/env sh

# https://scoutapm.com/blog/securing-ruby-applications-with-mtls

openssl req -new   -x509  -nodes  -days 365  -subj '/CN=my-ca'  -keyout ca.key  -out ca.crt -sha256



# Create the server private key
openssl genrsa -out server.key 2048

# Create the server certificate signing request (CSR)
openssl req -new -key server.key -subj '/CN=localhost' -out server.csr -sha256

# Use the CA key to sign the server CSR and get back the signed certificate. Localhost
# looks like a legit identity!
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256



# Create the client private key
openssl genpkey -algorithm RSA -out client.key

# Create the client certificate signing request (CSR)
openssl req -new -key client.key -subj '/CN=client' -out client.csr -sha256

# Use the CA key to sign the client CSR and get back the signed certificate
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365 -sha256



