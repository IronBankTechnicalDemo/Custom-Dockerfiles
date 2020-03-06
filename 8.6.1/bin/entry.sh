#!/bin/bash

# Import SSL Certificates
# ------------------------
echo
echo "\${SSL_CERTS_DIR} is set to: ${SSL_CERTS_DIR}"
echo "\${ENABLE_CERT_IMPORT} is set to: ${ENABLE_CERT_IMPORT}"

if [ -z "${JAVA_KEYSTORE_PASSWORD}" ]; then
  echo 'The ENV variable JAVA_KEYSTORE_PASSWORD is empty.'
  echo 'Please provide JAVA_KEYSTORE_PASSWORD as an ENV variable. Using the default value for now.'
  JAVA_KEYSTORE_PASSWORD='changeit'
fi

# If SSL_CERTS_DIR exists, then we can import certificates.
# Whitelisted certificates: *.crt, *.pem
# It does not matter if the directory is empty.
#   In that case, no certificates will be imported.
# By default the keystore is stored in a file named '.keystore' in the
#   user's home directory.

if [ "${ENABLE_CERT_IMPORT}" == "true" ] && [ ! -z "${SSL_CERTS_DIR}" ]; then
  JAVA_KEYSTORE_FILE=${JAVA_KEYSTORE}
  # Loop through all certificates in this directory and import them.
  for CERT in ${SSL_CERTS_DIR}/*.crt ${SSL_CERTS_DIR}/*.pem; do
    echo "Importing certificate: ${CERT} ..."
    ${JAVA_HOME}/bin/keytool \
      -noprompt \
      -storepass ${JAVA_KEYSTORE_PASSWORD} \
      -keystore ${JAVA_KEYSTORE_FILE} \
      -import \
      -file ${CERT} \
      -alias $(basename ${CERT})
  done
  echo "The following certificates were imported:"
  ${JAVA_HOME}/bin/keytool \
    -list -keystore ${JAVA_KEYSTORE_FILE} \
    -storepass ${JAVA_KEYSTORE_PASSWORD} \
    -v \
    | egrep "crt|pem"
fi