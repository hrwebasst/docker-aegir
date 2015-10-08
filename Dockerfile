FROM ubuntu:14.04
MAINTAINER Richard Silver  "hrwebasst@uoregon.edu"

ENV AEGIR_VERSION=6.x-2.1
ENV MYSQL_ROOT_PW=root

RUN apt-get update && apt-get install -y -q apache2 php5 php5-cli php5-gd php5-mysql php-pear postfix sudo rsync git-core unzip nano vim mysql-server drush supervisor mysql-client mysql-server openssh-server ssh

RUN adduser --system --group --home /var/aegir aegir && adduser aegir www-data && chmod 755 /var/aegir && chsh -s /bin/bash aegir

RUN echo "Defaults:aegir  !requiretty\naegir  ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/aegir && chmod 0440 /etc/sudoers.d/aegir

RUN sed -i '/^bind-address*/ s/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
RUN bash -c "/usr/bin/mysqld_safe &" && sleep 2 && /usr/bin/mysqladmin -u root password ${MYSQL_ROOT_PW} && echo "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;" | mysql -u root -h localhost -p${MYSQL_ROOT_PW} && echo "GRANT ALL PRIVILEGES ON *.* TO 'aegir_root'@'%' IDENTIFIED BY 'aegir_root' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql -u root -h localhost -p${MYSQL_ROOT_PW}

#RUN ln -s /var/aegir/drush/drush /usr/local/bin/drush
USER aegir
#aegir install
RUN mkdir /var/aegir/.drush && drush dl --destination=/var/aegir/.drush provision-$AEGIR_VERSION && drush cache-clear drush

RUN bash -c "sudo service mysql start" && sleep 2 && drush hostmaster-install --yes --debug --aegir_host=localhost --aegir_db_host=localhost --aegir_db_user=aegir_root --aegir_db_pass=aegir_root --version=$AEGIR_VERSION  --client_email=root@localhost --script_user=aegir --http_service_type=apache aegir1.aegir.dev

RUN bash -c "sudo service mysql start" && sleep 2 && drush @hostmaster pm-enable -y hosting_queued

USER root

RUN sed -i 's/memory_limit = .*/memory_limit = '256M'/' /etc/php5/apache2/php.ini
ENV AEGIR_VERSION=6.x-2.1
RUN cp /var/aegir/hostmaster-$AEGIR_VERSION/profiles/hostmaster/modules/hosting/queued/hosting_queued.conf /var/aegir/
RUN cp /var/aegir/hostmaster-$AEGIR_VERSION/profiles/hostmaster/modules/hosting/queued/hosting_queued.sh /var/aegir/

RUN mkdir /var/aegir/drush /var/run/sshd && ln -s /usr/bin/drush /var/aegir/drush/drush

RUN cp /var/aegir/hosting_queued.conf /etc/supervisor/conf.d/ && chown aegir:aegir /var/aegir/hosting_queued.sh && chmod 700 /var/aegir/hosting_queued.sh

RUN a2enmod rewrite && ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf && a2enconf aegir

#su -s /bin/bash - aegir
ADD supervisor.conf /opt/supervisor.conf
EXPOSE 80
EXPOSE 443

CMD supervisord -c /opt/supervisor.conf -n

