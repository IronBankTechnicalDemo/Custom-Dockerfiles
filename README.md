# Jira

## Vendor Documentation

### Jira Core

Product Page - <https://www.atlassian.com/software/jira/core>
Vendor Documentation - <https://confluence.atlassian.com/jiracoreserver/jira-core-server-8-6-documentation-938846148.html>

### Jira Software

Product Page - <https://www.atlassian.com/software/jira>
Vendor Documentation - <https://confluence.atlassian.com/jirasoftwareserver/jira-software-server-8-6-documentation-938845020.html>

### Jira ServiceDesk

Product Page - <https://www.atlassian.com/software/jira/service-desk>
Vendor Documentation - <https://confluence.atlassian.com/servicedeskserver/jira-service-desk-server-4-6-documentation-939926001.html>

## Installing Other Jira Applications

This specific docker file installs Jira Core. While Jira Core is not a prerequisite for installing other Jira applications, it is included in the license for other Jira applications. Jira Core has a built in mechanism for installing the other Jira applications. This dockerfile assumes that this tool will be used to install the other Jira applications.

Once Jira Core is up and running, and the setup has been complete, click "Applications" in the Jira Administration menu in the top right corner. On the "Versions & Licenses" tab, other licenses Jira Applications are listed. Click "Download" on the application that you wish to download to install it.

## Building the Container

There are no parameters that need to be passed in when building this container.

```bash
docker build -t <your_repo>:<your_version_number> .
```

## Running the Container

This container can be run without passing in any specific parameters.

```bash
docker container run -d --name jira -p 8080:8080 <your_image_tag>
```

### Additional Parameters

While the container can be run without specifying any additional parameters, there are a few parameters that are very useful.

#### JVM Heap Size

To modify the minimum and maximum sizes for the JVM Heap, the following environment variables can be used:

MIN_JVM_HEAP_SIZE = minimum JVM Heap size in MB
MAX_JVM_HEAP_SIZE = maximum JVM Heap size in MB

#### Proxy Settings

When running this container in an orchestrated environment (K8S, OCP, etc.), it will usually be running behind some type of proxy (ingress controller, etc.). In this scenario, the tomcat connector must be updated. The following environment variables can be set to automatically update tomcat's server.xml file

X_PROXY_NAME = The hostname of the proxy.

X_PROXY_PORT = The port of the proxy.

X_PROXY_SCHEME = The url scheme of the proxy. "http" or "https"

CERTIFICATE = Base64 encoded certificate for DNS zone. When defined, the cert will be imported in Jira's keystore.

X_PROXY_SECURE = A true/false value. When true, Jira will check that the certificate for the DNS zone exists in its keystore. When false, Jira does not perform this check. If this value is set to true, and no certifacte is supplied, or an invalid certificate is supplied, then you will not be able to configure Jira due to SSL errors.

If Jira is running behind a proxy, and these parameters are not set. The base url for Jira will be off and you will receive errors during initial setup.

#### Confluence Certificate

If an application link is going to be created from Jira to a Confluence installation, then Confluence's certificate must be imported into Jira's keystore. The following environment variables can be used to aid with this task:

CONFLUENCE_CERTIFICATE = the location and name of the confluence certificate. This is where the certificate will be placed, it is not a reference to a pre-existing file. (Ex. /opt/atlassian/jira/security/confluence.crt)

CONFLUENCE_SERVER = the hostname and port number of the running Confluence instance. (Ex. confluence-host.com:443)

CONFLUENCE_SERVER_ALIAS = the alias of the keystore entry for this certificate.

There is currently no automated mechanism of importing the Confluence cert into Jira's keystore, as it depends on the availability of a running instance of Confluence. The following commands can be used from inside the container/pod to add the certficiate manually:

```bash
openssl s_client -connect ${CONFLUENCE_SERVER} -servername ${CONFLUENCE_SERVER} < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${CONFLUENCE_CERTIFICATE}

keytool -import -noprompt -storepass changeit -alias ${CONFLUENCE_SERVER_ALIAS} -keystore ${JAVA_KEYSTORE} -file ${CONFLUENCE_CERTIFICATE}
```

The first command is why openssl is installed in the container.

If the Confluence certificate is not installed, then you will receive SSL errors when trying to add the application link.

## Pushing the Container

First, ensure you are logged into your docker repository, then run the following command

```bash
docker push <your_image_tag>
```
