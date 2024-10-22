# use Build arg to set image
ARG PHP_VERSION
ARG NODE_VERSION

FROM node:${NODE_VERSION}-alpine as node
# Set the base image
FROM php:${PHP_VERSION}-fpm-alpine

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Install system dependencies
RUN apk --no-cache add \
    bash \
    curl \
    git \
    libzip-dev \
    zip \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    openssl-dev

RUN touch /root/.bashrc

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif
RUN apk --no-cache add libsodium-dev && docker-php-ext-install sodium

# Install GD extension
RUN apk --no-cache add libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Increase PHP Memory Limit to system
RUN cd /usr/local/etc/php/conf.d/ && echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-ram-limit.ini

# Start PHP-FPM
CMD ["php-fpm"]