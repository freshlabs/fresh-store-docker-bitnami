FROM docker.io/bitnami/minideb:buster
LABEL maintainer "Fresh Labs <team@freshlabs.group>"

ENV PATH="/opt/bitnami/apache/bin:/opt/bitnami/python/bin:/opt/bitnami/php/bin:/opt/bitnami/php/sbin:/opt/bitnami/node/bin:/opt/bitnami/common/bin:/opt/bitnami/nami/bin:$PATH"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages git ca-certificates curl gzip libbsd0 libbz2-1.0 libc6 libcom-err2 libcurl4 libexpat1 libffi6 libfftw3-double3 libfontconfig1 libfreetype6 libgcc1 libgcrypt20 libglib2.0-0 libgmp10 libgnutls30 libgomp1 libgpg-error0 libgssapi-krb5-2 libhogweed4 libicu63 libidn2-0 libjpeg62-turbo libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 liblcms2-2 libldap-2.4-2 liblqr-1-0 libltdl7 liblzma5 libmagickcore-6.q16-6 libmagickwand-6.q16-6 libmcrypt4 libmemcached11 libmemcachedutil2 libncurses6 libncursesw6 libnettle6 libnghttp2-14 libonig5 libp11-kit0 libpcre3 libpng16-16 libpq5 libpsl5 libreadline7 librtmp1 libsasl2-2 libsodium23 libsqlite3-0 libssh2-1 libssl1.1 libstdc++6 libsybdb5 libtasn1-6 libtidy5deb1 libtinfo6 libunistring2 libuuid1 libwebp6 libx11-6 libxau6 libxcb1 libxdmcp6 libxext6 libxml2 libxslt1.1 libzip4 netcat procps sudo tar zlib1g
RUN /build/bitnami-user.sh
RUN /build/install-nami.sh
RUN bitnami-pkg unpack apache-2.4.48-1 --checksum 0296bc7dd5f621eba6f948433a6c7fc04a45876f42f6395cea5888b707f1ad11
RUN bitnami-pkg install python-3.8.11-0 --checksum 28b91ef5db9ad93e704881400703e4085bd82f016be15e3cf8760df044da9490
RUN bitnami-pkg unpack php-8.0.9-1 --checksum e75bd6d2a11128706243bdb1fecda7e9200372ff6b9f579d4fe6e7022b634b0b
RUN bitnami-pkg install node-14.17.4-0 --checksum b8d99ebde08907038f649460bf89253fe88c34aa1ca934f8598a8ebdb6a87e1c
RUN bitnami-pkg install tini-0.19.0-1 --checksum 9b1f1c095944bac88a62c1b63f3bff1bb123aa7ccd371c908c0e5b41cec2528d
#RUN bitnami-pkg install laravel-8.5.23-0 --checksum dd63bcd8f8725b3acc048ac5632fab2f83c8c4e1afd6f1b9e01b028a72536f4b
RUN bitnami-pkg install gosu-1.13.0-0 --checksum fd7257c2736164d02832dbf72e2c1ed9d875bf3e32f0988520796bc503330129
RUN mkdir /app && chown bitnami:bitnami /app

# Install Fresh Store specific packages and dependencies
RUN install_packages unzip rsync

COPY rootfs /
ENV BITNAMI_APP_NAME="fresh-store" \
    BITNAMI_IMAGE_VERSION="8.5.23-debian-10-r6" \
    NODE_PATH="/opt/bitnami/node/lib/node_modules" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

EXPOSE 80 443

WORKDIR /app
USER bitnami
ENTRYPOINT [ "/app-entrypoint.sh" ]
CMD [ "nami", "start", "--foreground", "apache" ]