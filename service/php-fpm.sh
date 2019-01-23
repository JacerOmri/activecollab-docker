#!/bin/sh
exec /usr/sbin/php-fpm7.3 -R --nodaemonize --fpm-config /etc/php/7.3/fpm/php-fpm.conf >> /var/log/php7.3-fpm.log 2>&1
