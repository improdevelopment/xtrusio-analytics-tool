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
    echo "max_execution_time=300" >> /usr/local/etc/php/conf.d/matomo.ini

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
