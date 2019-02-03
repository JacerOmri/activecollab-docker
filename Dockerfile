# Use "phusion/baseimage" as base image. To make your builds reproducible, make sure you lock down to a specific
# version, not to "latest"! To see a list of version numbers, visit:
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# NOTE: Build baseimage from submodule, it uses Ubuntu 15.04 instead of 14.04 to get the recommended PHP 5.6 packages.
FROM        phusion/baseimage:0.9.17
MAINTAINER  Zander Baldwin <hello@zanderbaldwin.com>
VOLUME      /var/www
WORKDIR     /var/www
EXPOSE      80

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Don't forget to use the custom init system provided by phusion/baseimage.
CMD         ["/sbin/my_init"]

# Upgrade the Operating System.
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

RUN add-apt-repository -y ppa:ondrej/php && apt-get update

# Install Nginx
RUN apt-get install --no-install-recommends -y nginx

# Setup the Nginx daemon.
RUN mkdir -p /etc/service/nginx
ADD service/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# Install PHP
RUN apt-get install --no-install-recommends -y \
    php7.3-cli \
    php7.3-curl \
    php7.3-fpm \
    php7.3-gd \
    php7.3-imap \
    php7.3-json \
    php7.3-xml \
    php7.3-dom \
    php7.3-mbstring \
    php7.3-mysqlnd

# Setup the PHP-FPM daemon.
RUN mkdir -p /etc/service/php-fpm
ADD service/php-fpm.sh /etc/service/php-fpm/run
RUN chmod +x /etc/service/php-fpm/run

# Add PHP Configuration
ADD config/pool-www.conf /etc/php/7.3/fpm/pool.d/www.conf
ADD config/php.ini /etc/php/7.3/fpm/php.ini
ADD config/php.ini /etc/php/7.3/cli/php.ini
# RUN ln -s /etc/php/7.0/mods-available/imap.ini /etc/php/7.0/cli/conf.d/20-imap.ini \
#  && ln -s /etc/php/7.0/mods-available/imap.ini /etc/php/7.0/fpm/conf.d/20-imap.ini

RUN service php7.3-fpm start

# Install the CRON tab.
ADD config/crontab /etc/cron.d/activecollab
RUN chmod 0644 /etc/cron.d/activecollab

# Clean up APT when done.
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start nginx
RUN service nginx start
