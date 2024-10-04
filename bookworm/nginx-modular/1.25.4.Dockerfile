ARG NGINX_VERSION=1.27.2
FROM nginx:${NGINX_VERSION} as builder

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    build-essential \
    xz-utils \
    git \
    zlib1g-dev \
    libpcre3 \
    libpcre3-dev \
    unzip \
    uuid-dev \
    openssl \
    libssl-dev \
    libbrotli-dev && \
    mkdir -p /opt/build-stage

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

RUN tar zxvf nginx-${NGINX_VERSION}.tar.gz

WORKDIR /opt/build-stage/nginx-${NGINX_VERSION}

RUN ./configure --with-compat \
    --add-dynamic-module=../ngx_brotli \
    --add-dynamic-module=../ngx_immutable \
    --add-dynamic-module=../ngx_cache_purge && \
    make modules && \
    cp /opt/build-stage/nginx-${NGINX_VERSION}/objs/*.so /usr/lib/nginx/modules/

FROM nginx:${NGINX_VERSION} as final
COPY --from=builder /opt/build-stage/nginx-${NGINX_VERSION}/objs/*.so /usr/lib/nginx/modules/
RUN { \
        sed -i '1iload_module modules/ngx_http_immutable_module.so;' /etc/nginx/nginx.conf; \
        sed -i '1iload_module modules/ngx_http_cache_purge_module.so;' /etc/nginx/nginx.conf; \
        sed -i '1iload_module modules/ngx_http_brotli_static_module.so;' /etc/nginx/nginx.conf; \
        sed -i '1iload_module modules/ngx_http_brotli_filter_module.so;' /etc/nginx/nginx.conf; \
    } \
    && sed -i 's+include /etc/nginx/conf.d/\*.conf;+&\n    server_tokens off;+' /etc/nginx/nginx.conf
