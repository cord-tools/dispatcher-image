FROM amazonlinux:2

ARG DISPATCHER_VERSION=4.3.5

ENV HTTPD_PREFIX=/etc/httpd
ENV PUBLISH_DOMAIN=localhost
ENV PUBLISH_PORT=4503
ENV AUTO_RELOAD=true
ENV DISPATCHER_URL="https://download.macromedia.com/dispatcher/download/dispatcher-apache2.4-linux-x86_64-${DISPATCHER_VERSION}.tar.gz"

RUN amazon-linux-extras install -y epel && yum -y --setopt=tsflags=nodocs update && \
    yum --enablerepo=epel -y --setopt=tsflags=nodocs install inotify-tools httpd openssl tar less strace lsof psmisc file && \
    yum clean all && rm -rf /var/cache/yum && chown -R apache:apache /var/www/html && \
    echo "Installing dispatcher version ${DISPATCHER_VERSION}" && \
    curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    curl -L "${DISPATCHER_URL}" -O && \
    mkdir -p dispatcher && tar -C dispatcher -zxvf dispatcher-apache2.*.tar.gz && \
    rm dispatcher-apache2.*.tar.gz && \
    cp dispatcher/dispatcher-apache2.*.so $HTTPD_PREFIX/modules/mod_dispatcher.so && \
    rm -rf dispatcher/ && \
    echo "LoadModule dispatcher_module modules/mod_dispatcher.so" >> $HTTPD_PREFIX/conf.modules.d/00-base.conf && \
    sed -ri \
      -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
      -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
      -e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
      -e '/^IncludeOptional\s+conf\.d\/\S+/a \
<IfModule status_module>\n \
  ExtendedStatus On\n \
  <Location "/server-status">\n \
    SetHandler server-status\n \
    Require local\n \
  </Location>\n \
</IfModule>\n' \
    "$HTTPD_PREFIX/conf/httpd.conf" && \
    sed -ri \
      -e '/^<Directory\s+\/>/a \
  <IfModule disp_apache2.c>\n \
    ModMimeUsePathInfo On\n \
    SetHandler dispatcher-handler\n \
  <\/IfModule>\n' \
      "$HTTPD_PREFIX/conf/httpd.conf"

# Copy Dispatcher configs
COPY conf/* $HTTPD_PREFIX/conf.d/

COPY httpd-foreground /usr/local/bin/

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["bash", "-c", "httpd-foreground"]
