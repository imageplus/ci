# use Build arg to set image
ARG PHP_VERSION
ARG NODE_VERSION
# Set the base image
FROM php:${PHP_VERSION}-fpm-alpine

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

# Install Node.js
# RUN apk add --no-cache nodejs npm

# Install Node.js using NVM
RUN apk add --no-cache --virtual .build-deps curl \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && source /root/.bashrc \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && apk del .build-deps


# Start PHP-FPM
CMD ["php-fpm"]