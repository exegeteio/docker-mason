FROM ubuntu:14.04
MAINTAINER Jack M. <jack.m@iigins.com>

RUN apt-get -qq update
RUN apt-get -qqy install apache2 \
	perl-modules \
	libapache2-mod-apreq2 \
	libapache2-mod-perl2 \
	libcgi-simple-perl \
	libclass-dbi-abstractsearch-perl \
	libclass-dbi-mysql-perl \
	libclass-dbi-pager-perl \
	libconfig-tiny-perl \
	libcrypt-ssleay-perl \
	libdata-dumper-simple-perl \
	libdatetime-timezone-perl \
	libdbd-mysql-perl \
	libhtml-mason-perl \
	libmail-sender-perl \
	libmasonx-request-withapachesession-perl \
	libsql-abstract-perl \
	libtry-tiny-perl \
	libxml-libxml-perl \
	libxml-simple-perl


VOLUME /usr/src/app/
ADD . /usr/src/app/

RUN chown -R www-data:www-data /usr/src/app/
ADD mason-app.conf /etc/apache2/sites-enabled/000-default.conf

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/log/apache2/pid

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
