# Dockerfile
# docker build -f 7.3.33.Dockerfile . -t php:7.3.33

# 使用 7.3.33-fpm-alpine3.15 作为基础镜像
FROM php:7.3.33-fpm-alpine3.15 as builder
LABEL MAINTAINER="0xAiKang <aikangtongxue@gmail.com>"
LABEL description="PHP 镜像，版本为 7.3，支持 CLI、CGI、FPM 模式"

# 更新下载源
RUN echo 'https://mirrors.aliyun.com/alpine/v3.15/main/' > /etc/apk/repositories && \
    echo 'https://mirrors.aliyun.com/alpine/v3.15/community/' >> /etc/apk/repositories

# 安装依赖库和工具
RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    gcc \
    g++ \
    make \
    icu-dev \
    libzip-dev \
    libxml2-dev \
    oniguruma-dev \
    bzip2-dev \
    gettext-dev \
    libmcrypt-dev \
    libwebp-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxslt-dev \
    openssl-dev \
    krb5-dev \
    unixodbc-dev \
    postgresql-dev \
    openldap-dev \
    tidyhtml-dev \
    freetds-dev \
    zlib-dev \
    c-ares-dev \
    curl-dev \
    imap-dev \
    && apk add --no-cache \
    git \
    curl \
    icu \
    libintl \
    libzip \
    libxml2 \
    libxslt \
    libwebp \
    freetype \
    libjpeg-turbo \
    libpng \
    tidyhtml-libs \
    unixodbc \
    postgresql-libs \
    openldap \
    gettext

# 安装 PHP 扩展
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/php/freetype --with-jpeg-dir=/usr/include/php/jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure imap --with-imap --with-imap-ssl \
    && docker-php-ext-install \
    imap \
    bcmath \
    bz2 \
    calendar \
    dba \
    exif \
    gd \
    opcache \
    gettext \
    intl \
    mysqli \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    tidy \
    zip

# 安装 PECL 扩展
RUN pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis \
    && pecl install -D 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes"' swoole-4.8.13 \
    && docker-php-ext-enable swoole

# 安装 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 切换到一个新的阶段，以减少最终镜像大小
FROM php:7.3.33-fpm-alpine3.15

# 复制已安装的扩展和配置
COPY --from=builder /usr/local/etc/php /usr/local/etc/php
COPY --from=builder /usr/local/lib/php /usr/local/lib/php

# 安装运行时依赖
RUN apk add --no-cache \
    icu \
    libintl \
    libzip \
    libxml2 \
    libxslt \
    libwebp \
    freetype \
    libjpeg-turbo \
    libpng \
    tidyhtml-libs \
    unixodbc \
    postgresql-libs \
    openldap \
    gettext \
    imap-dev \
    c-ares-dev

# 复制已安装的 Composer
COPY --from=builder /usr/bin/composer /usr/bin/composer

# 设置工作目录
WORKDIR /var/www

# 清理缓存和无关文件
RUN rm -rf /var/cache/apk/*

# 暴露 FPM 服务端口
EXPOSE 9000