# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.0-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
	; \
	# apt-get install -y  \
	# 	vim \
	# ; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		mbstring \
		json \
		opcache \
		pdo_mysql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*



### Matt

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require drush/drush:7.*
# #RUN composer global require drush/drush:dev-master

RUN composer global update

RUN echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

### Matt






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

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.59
ENV DRUPAL_MD5 7e09c6b177345a81439fe0aa9a2d15fc

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites modules themes

# vim:set ft=dockerfile: