ARG IMAGE_BASE_V=2023.5.20241001.1
FROM amazonlinux:${IMAGE_BASE_V} AS nginx-moduler

ARG NGINX_VERSION=1.24.0
ARG TARGETARCH
ARG PSOL=jammy

RUN dnf -y install \
            gcc \
            zlib-devel \
            openssl-devel \
            make \
            pcre-devel \
            libxml2-devel \
            libxslt-devel \
            libgcrypt-devel \
            gd-devel \
            perl-ExtUtils-Embed \
            xz \
            wget \
            git \
            gcc-c++ \
            unzip \
            libuuid-devel \
            tar

RUN mkdir -p /opt/build-stage

WORKDIR /opt/build-stage
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

RUN git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && git reset --hard a71f9312c2deb28875acc7bacfdd5695a111aa53 && \
    cd /opt/build-stage

RUN git clone --recurse-submodules -j8 https://github.com/nginx-modules/ngx_immutable.git && \
    cd ngx_immutable && git reset --hard dab3852a2c8f6782791664b92403dd032e77c1cb && \
    cd /opt/build-stage

RUN git clone --recurse-submodules -j8 https://github.com/nginx-modules/ngx_cache_purge.git && \
    cd ngx_cache_purge && git reset --hard a84b0f3f082025dec737a537a9a443bdd6d6af9d && \
    cd /opt/build-stage

RUN if [ "$TARGETARCH" = "amd64" ]; then \
    wget https://www.tiredofit.nl/psol-${PSOL}.tar.xz && \
    git clone --depth=1 https://github.com/apache/incubator-pagespeed-ngx.git && \
    tar xvf psol-${PSOL}.tar.xz && \
    mv psol incubator-pagespeed-ngx && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz; \
    fi

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    wget https://gitlab.com/gusco/ngx_pagespeed_arm/-/raw/master/psol-1.15.0.0-aarch64.tar.gz && \
    git clone --depth=1 https://github.com/apache/incubator-pagespeed-ngx.git && \
    tar xvf psol-1.15.0.0-aarch64.tar.gz && \
    mv psol incubator-pagespeed-ngx && \
    sed -i 's/x86_64/aarch64/' incubator-pagespeed-ngx/config && \
    sed -i 's/x64/aarch64/' incubator-pagespeed-ngx/config && \
    sed -i 's/-luuid/-l:libuuid.so.1/' incubator-pagespeed-ngx/config && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz; \
    fi

WORKDIR /opt/build-stage/nginx-${NGINX_VERSION}
RUN ./configure --with-compat \
    --add-dynamic-module=../ngx_brotli \
    --add-dynamic-module=../incubator-pagespeed-ngx \
    --add-dynamic-module=../ngx_immutable \
    --add-dynamic-module=../ngx_cache_purge && \
    make modules && \
    mkdir -p /usr/lib/nginx/modules/ && \
    cp /opt/build-stage/nginx-${NGINX_VERSION}/objs/*.so /usr/lib/nginx/modules/

RUN mkdir -p /tmp/standby/nginx_modules && \
    cp /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_http_brotli_static_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_http_immutable_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_http_cache_purge_module.so /tmp/standby/nginx_modules/ && \
    cp /usr/lib/nginx/modules/ngx_pagespeed.so /tmp/standby/nginx_modules/