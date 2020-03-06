#!/bin/bash

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat -c "%Y" "${JIRA_INSTALL}/conf/server.xml")" -eq "0" ]; then
  if [ -n "${X_PROXY_NAME}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_PORT}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_SCHEME}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_SECURE}" ]; then
    # Secure requires ca and server certs to be imported into Tomcat keystore 
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "secure" --value "${X_PROXY_SECURE}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PATH}" ]; then
    xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${JIRA_INSTALL}/conf/server.xml"
  fi
fi

if [ -f "${CERTIFICATE}" ]; then
  keytool -noprompt -storepass changeit -keystore ${JAVA_KEYSTORE} -import -file ${CERTIFICATE} -alias CompanyCA
fi

#if [ -f "${CONFLUENCE_CERTIFICATE}" ]; then
#  openssl s_client -connect ${CONFLUENCE_SERVER} -servername ${CONFLUENCE_SERVER} < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${CONFLUENCE_CERTIFICATE}
#  keytool -import -noprompt -storepass changeit -alias ${CONFLUENCE_SERVER_ALIAS} -keystore ${JAVA_KEYSTORE} -file ${CONFLUENCE_CERTIFICATE}
#fi

if [ -n "${MIN_JVM_HEAP_SIZE}" ]; then
  sed --in-place "s/-Xms1024m/-Xms${MIN_JVM_HEAP_SIZE}m/g" "${JIRA_INSTALL}/bin/setenv.sh"
fi

if [ -n "${MAX_JVM_HEAP_SIZE}" ]; then
  sed --in-place "s/-Xmx1024m/-Xmx${MAX_JVM_HEAP_SIZE}m/g" "${JIRA_INSTALL}/bin/setenv.sh"
fi

exec "$@"
