FROM clouder/clouder-php
MAINTAINER Yannick Buron yburon@goclouder.net

RUN curl -SL -o /tmp/drush.phar http://files.drush.org/drush.phar 
RUN mv /tmp/drush.phar /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

USER www-data
RUN yes | drush init

USER root
