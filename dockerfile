FROM docker-prod.cloudfitonline.com/ubi/ubi7-golden:7.7

LABEL author="Brian Miller" email="brianmiller@cloudfitsoftware.com" ring="3" application="jira"

# Configuration variables.
ENV JIRA_HOME     /var/atlassian/jira
ENV JIRA_INSTALL  /opt/atlassian/jira
ENV JIRA_VERSION  8.6.1
# Installing openjdk creates a symlink at this location
# Using this symlink, the jdk version no longer has to be used in paths
ENV JAVA_HOME /etc/alternatives/jre
ENV JAVA_KEYSTORE  ${JAVA_HOME}/lib/security/cacerts

COPY "bin/docker-entrypoint.sh" "${JIRA_INSTALL}/docker-entrypoint.sh"

RUN yum install --nogpgcheck -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum install --nogpgcheck -y java-1.8.0-openjdk curl xmlstarlet bash ttf-dejavu libc-compact openssl \
    && groupadd -g 1000 jira \
    && adduser -u 1000 -g 1000 -d /usr/share/jira jira \
    && set -x \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && mkdir -p                "${JIRA_HOME}/certificate" \
    && mkdir -p                "${JIRA_INSTALL}/security" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && rm -f                   "${JIRA_INSTALL}/lib/postgresql-9.1-903.jdbc4-atlassian-hosted.jar" \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-42.2.1.jar" -o "${JIRA_INSTALL}/lib/postgresql-42.2.1.jar" \
    && sed --in-place          "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml" \
    && chmod 700               "${JAVA_KEYSTORE}" \
    && chown jira:jira         "${JAVA_KEYSTORE}" \
    && chmod -R 700 "${JIRA_HOME}" \
    && chmod -R 700 "${JIRA_INSTALL}" \
    && chown -R jira:jira  "${JIRA_HOME}" \
    && chown -R jira:jira  "${JIRA_INSTALL}" \
    && yum --nogpgcheck -y update \
    && yum clean all --nogpgcheck \
    # Disable Ctrl+Alt+Del burst action
    && echo CtrlAltDelBurstAction=none >> /etc/systemd/system.conf \
    && sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth \ 
    && sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/password-auth

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER jira:jira

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]

# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/jira

ENTRYPOINT ["/opt/atlassian/jira/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]