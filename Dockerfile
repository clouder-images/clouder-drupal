FROM clouder/clouder-nginx
MAINTAINER Yannick Buron yburon@goclouder.net

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install php5-pgsql php-apc php5-fpm php5-curl php5-gd php5-intl php-pear php5-imap php5-memcache memcached mc postgresql-client curl git

RUN curl -SL -o /tmp/drush.phar http://files.drush.org/drush.phar 
RUN mv /tmp/drush.phar /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

USER www-data
RUN yes | drush init

USER root
# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "[program:php5-fpm]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/usr/sbin/php5-fpm -c /etc/php5/fpm" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf

RUN echo "[program:memcached]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "command=/usr/bin/memcached -p 11211 -u www-data -m 64 -c 1024 -t 4" >> /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /base-backup
RUN chown -R www-data /base-backup
VOLUME /base-backup
