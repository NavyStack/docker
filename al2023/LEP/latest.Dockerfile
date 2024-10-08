ARG NGINX_VERSION=1.25.3
ARG PHP_VERSION=8.2
ARG TARGETARCH
ARG IMAGE_BASE_V=2023.5.20241001.1
FROM navystack/nginx_mod:al2023-${NGINX_VERSION} AS mod

FROM amazonlinux:${IMAGE_BASE_V} AS final

LABEL maintainer="NavyStack <webmaster@navystack.com>" \
      image_base="amazonlinux:${IMAGE_BASE_V}" \
      arch="${TARGETARCH}" \
      php_version="${PHP_VERSION}" \
      nginx_version="${NGINX_VERSION}" \
      nginx_dy_modules="pagespeed, brotli, cache_purge, immutable"

RUN dnf -y install dnf-utils && \
    { \
		echo '[nginx-mainline]'; \
		echo 'name=nginx mainline repo'; \
		echo 'baseurl=http://nginx.org/packages/mainline/amzn/2023/$basearch/'; \
		echo 'gpgcheck=1'; \
		echo 'enabled=1'; \
		echo 'gpgkey=https://nginx.org/keys/nginx_signing.key'; \
		echo 'module_hotfixes=true'; \
		echo 'priority=9'; \        
	} > /etc/yum.repos.d/nginx.repo && \
    dnf config-manager --set-enabled nginx-mainline && \
    dnf -y install \
            gcc \
            nginx \
            php \
            php-bcmath \
            php-cli \
            php-common \
            php-exif \
            php-fpm \
            php-gd \
            php-intl \
            php-mbstring \
            php-mysqlnd \
            php-opcache \
            php-pdo \
            php-pear \
            php-pgsql \
            php-soap \
            php-xml \
            php-zip \
            tar \
    && \
    dnf clean all && \
    dnf install -y \
        php-devel \
        ImageMagick \
        ImageMagick-devel \
    && \
        pear update-channels && \
        pecl update-channels && \
    pecl install -f --configureoptions 'with-imagick="autodetect"' imagick && \
    pecl install -n \
            redis \
            apcu \
    && \
        echo "extension=imagick.so" >> /etc/php.d/20-imagick.ini && \
        echo "extension=apcu.so" >> /etc/php.d/10-apcu.ini && \
        echo "extension=redis.so" >> /etc/php.d/10-redis.ini \
    && \
    dnf -y remove \
        php-devel \
        gcc \
        ImageMagick-devel \
    && \
    dnf clean all \
    && \
        sed -i 's+^post_max_size = 8M+post_max_size = 120M+g;s+^upload_max_filesize = 2M+upload_max_filesize = 100M+g;s+^short_open_tag = Off+short_open_tag = On+g;s+;mysqli.allow_local_infile = On+mysqli.allow_local_infile = On+g' /etc/php.ini && \
        sed -i 's+pid = /run/php-fpm/php-fpm.pid+pid = /var/run/nginx.pid+g' /etc/php-fpm.conf && \
        sed -i 's+listen = /run/php-fpm/www.sock+listen = 9000+g' /etc/php-fpm.d/www.conf && \
        sed -i 's+user = apache+user = nginx+g' /etc/php-fpm.d/www.conf && \
    mkdir -p /var/cache/nginx/pagespeed_temp && \
        chown -R nginx:nginx /var/cache/nginx/pagespeed_temp && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    chown -R nginx:nginx /var/www/html/ /var/lib/php/ /var/log/php-fpm/ && \
    rm -rf /etc/nginx/conf.d/*

COPY --from=mod /tmp/standby/nginx_modules/*.so /etc/nginx/modules/
WORKDIR /var/www/html
VOLUME /var/www/html
EXPOSE 80

CMD ["php-fpm", "nginx", "-g", "daemon off;"]
