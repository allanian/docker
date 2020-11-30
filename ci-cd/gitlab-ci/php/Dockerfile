FROM php:7.4-fpm
WORKDIR /var/www
ARG APP_PATH

# install soft
RUN apt-get update && apt-get install --no-install-recommends -y \
       librabbitmq-dev libfreetype6-dev libjpeg62-turbo-dev libwebp-dev libxpm-dev libbz2-dev libpng-dev libmcrypt-dev libmagickwand-dev libreadline-dev libxml2-dev libmemcached-dev libzip-dev libz-dev \
       mcrypt zip git unzip wget ffmpeg netcat \
    && pecl install swoole mcrypt apcu redis amqp memcache imagick \
    && rm -rf /var/lib/apt/lists/*  \
    # docker-php config
    && docker-php-ext-install soap zip bz2 pdo_mysql sockets bcmath \
    #--with-png
    && docker-php-ext-configure gd --with-freetype --with-jpeg \ 
    && docker-php-ext-configure intl \
    && docker-php-ext-install gd intl \
    # cleanup
    && docker-php-source delete

# add extension
RUN docker-php-ext-enable swoole mcrypt apcu redis amqp  memcache  opcache pdo_mysql imagick gd intl
# Install composer
RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
        && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
        && php composer-setup.php && rm composer-setup.php* \
        && chmod +x composer.phar && mv composer.phar /usr/bin/composer && composer -V

# copy APP configs and data
COPY ./$APP_PATH/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./$APP_PATH/php.ini /usr/local/etc/php/conf.d/40-custom.ini
COPY ./app ./app

# php start app
WORKDIR /var/www/app
RUN composer install --no-interaction && php init --env=Production --overwrite=All --interactive=0
WORKDIR /var/www
COPY ./$APP_PATH/entrypoint.sh .
RUN chmod +x ./entrypoint.sh
EXPOSE 9001
ENTRYPOINT ["/var/www/entrypoint.sh"]
