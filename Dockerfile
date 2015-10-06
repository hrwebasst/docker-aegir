FROM quantumobject/docker-baseimage
MAINTAINER Richard Silver  "hrwebasst@uoregon.edu"

RUN apt-get update && apt-get install -y -q apache2 php5 php5-cli php5-gd php5-mysql php-pear postfix sudo rsync git-core unzip nano vim mysql-server drush

RUN adduser --system --group --home /var/aegir aegir && adduser aegir www-data && chmod 755 /var/aegir

RUN a2enmod rewrite && 


RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf && a2enconf aegir

RUN echo -e "Defaults:aegir  !requiretty\naegir ALL=NOPASSWD: /usr/sbin/apache2ctl" >> /etc/sudoers.d/aegir && chmod 0440 /etc/sudoers.d/aegir

RUN sed -i '/^bind-address*/ s/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
RUN "GRANT ALL PRIVILEGES ON *.* TO 'aegir_root'@'%' IDENTIFIED BY '${AEGIR_DB_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql -u root -h localhost -p$MYSQL_ROOT_PW
RUN sudo mysql_secure_installation

#su -s /bin/bash - aegir

EXPOSE 80
EXPOSE 443