FROM quantumobject/docker-baseimage
MAINTAINER Richard Silver  "hrwebasst@uoregon.edu"

ENV $AEGIR_VERSION=6.x-2.1

RUN apt-get update && apt-get install -y -q apache2 php5 php5-cli php5-gd php5-mysql php-pear postfix sudo rsync git-core unzip nano vim mysql-server drush

RUN adduser --system --group --home /var/aegir aegir && adduser aegir www-data && chmod 755 /var/aegir

RUN a2enmod rewrite && ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf && a2enconf aegir

RUN echo -e "Defaults:aegir  !requiretty\naegir ALL=NOPASSWD: /usr/sbin/apache2ctl" >> /etc/sudoers.d/aegir && chmod 0440 /etc/sudoers.d/aegir

RUN sed -i '/^bind-address*/ s/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
RUN "GRANT ALL PRIVILEGES ON *.* TO 'aegir_root'@'%' IDENTIFIED BY 'aegir_root' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql -u root -h localhost -proot
RUN mysql_secure_installation
RUN drush dl --destination=/var/aegir/.drush provision-$AEGIR_VERSION && drush cache-clear drush

RUN drush hostmaster-install --yes --debug --aegir_host=aegir.dev --aegir_db_host=localhost --aegir_db_user=aegir_root --aegir_db_pass=aegir_root --version=$AEGIR_VERSION  --client_email=$AEGIR_EMAIL --script_user=aegir --http_service_type=apache aegir.dev
RUN drush @hostmaster pm-enable -y hosting_queued
RUN cp /var/aegir/hostmaster-$AEGIR_VERSION/profiles/hostmaster/modules/hosting/queued/hosting_queued.conf /var/aegir
RUN cp /var/aegir/hostmaster-$AEGIR_VERSION/profiles/hostmaster/modules/hosting/queued/hosting_queued.sh /var/aegir

#su -s /bin/bash - aegir

EXPOSE 80
EXPOSE 443