FROM php:8.2-apache

# Install PHP extensions required by Matomo
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libldap2-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        opcache \
        zip \
        ldap \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# PHP config for Matomo
RUN echo "memory_limit=256M" > /usr/local/etc/php/conf.d/matomo.ini && \
    echo "upload_max_filesize=64M" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "post_max_size=64M" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "max_execution_time=300" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "realpath_cache_size=4096K" >> /usr/local/etc/php/conf.d/matomo.ini && \
    echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/matomo.ini

# Install Redis PHP extension for caching
RUN pecl install redis && docker-php-ext-enable redis

WORKDIR /var/www/html

# Copy all source code into the image (avoids slow Windows bind mount for PHP files)
COPY . .

# Copy entrypoint script (sed fixes Windows CRLF line endings)
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r$//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

# Ensure writable directories exist and have correct permissions
RUN mkdir -p config tmp/assets tmp/cache tmp/logs tmp/tcpdf tmp/templates_c tmp/sessions misc && \
    chown -R www-data:www-data config tmp misc && \
    chmod -R 775 config tmp misc

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
