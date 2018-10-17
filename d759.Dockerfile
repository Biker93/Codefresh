# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.0-apache

# install the PHP extensions we need
# RUN set -ex; \
# 	\
# 	if command -v a2enmod; then \
# 		a2enmod rewrite; \
# 	fi; \
# 	\
# 	savedAptMark="$(apt-mark showmanual)";
	# \
RUN	apt-get update && \
	apt-get install -y \
		zlib1g-dev \
		libpng-dev \
		curl \
		wget \
		vim \
		git \
		unzip \
		mysql-client \
		libjpeg-dev \
		libpq-dev
	# ;
	# \
# RUN	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
# 	\
# RUN	docker-php-ext-install -j "$(nproc)" \
RUN	docker-php-ext-install \
		pdo_mysql \
		mbstring \
		zip \
		gd \
		json \
		opcache
	# ; \
	# \
# # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
# 	apt-mark auto '.*' > /dev/null; \
# 	apt-mark manual $savedAptMark; \
# 	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
# 		| awk '/=>/ { print $3 }' \
# 		| sort -u \
# 		| xargs -r dpkg-query -S \
# 		| cut -d: -f1 \
# 		| sort -u \
# 		| xargs -rt apt-mark manual; \
# 	\
# 	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
# 	rm -rf /var/lib/apt/lists/*



### Matt
# RUN apt-get update && \
#     apt-get install -y \
#     	zlib1g-dev \
#       libpng-dev \
# 		curl \
# 		wget \
# 		vim \
# 		git \
# 		unzip \
# 		mysql-client

# RUN docker-php-ext-install pdo_mysql

# # RUN docker-php-ext-install mysqli

# RUN docker-php-ext-install mbstring

# RUN docker-php-ext-install zip

# RUN docker-php-ext-install gd

# RUN docker-php-ext-install json

RUN echo "disable_functions = mail" >> /usr/local/etc/php/php.ini
RUN echo "date.timezone = america/new_york" >> /usr/local/etc/php/php.ini
# RUN echo "zend_extension=opcache.so" >> /usr/local/etc/php/php.ini
RUN echo "opcache.enable=1" >> /usr/local/etc/php/php.ini
RUN echo "opcache.memory_consumption=128" >> /usr/local/etc/php/php.ini
RUN echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/php.ini
RUN echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/php.ini
RUN echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/php.ini

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
#       echo "opcache.enable=1"; \
#		echo "disable_functions = mail"; \
#		echo "date.timezone = america/new_york"; \
#		echo "zend_extension=opcache.so"; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini



RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require drush/drush:7.*
# #RUN composer global require drush/drush:dev-master

RUN composer global update

RUN echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

### Matt







WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.59
ENV DRUPAL_MD5 7e09c6b177345a81439fe0aa9a2d15fc

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites modules themes

COPY --chown=www-data:www-data d759-local.settings.php sites/default/settings.php

# vim:set ft=dockerfile: