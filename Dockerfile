# Use the official PHP 8.3 image based on Alpine Linux
FROM php:8.3-fpm-alpine

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
RUN apk add --no-cache nodejs npm

# Start PHP-FPM
CMD ["php-fpm"]