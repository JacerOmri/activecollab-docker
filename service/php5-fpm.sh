#!/bin/sh
exec /usr/sbin/php-fpm7.0 -R --nodaemonize --fpm-config /etc/php/7.0/fpm/php-fpm.conf >> /var/log/php7.0-fpm.log 2>&1
