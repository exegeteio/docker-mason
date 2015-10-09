FROM ubuntu:14.04
MAINTAINER Jack M. <jack.m@iigins.com>

RUN apt-get -qq update
RUN apt-get -qqy install apache2 \
	apache2-dev \
	apache2-mpm-prefork \
	build-essential \
	cpanminus \
	git \
	htmldoc \
	libapache-dbi-perl \
	libapache-dbilogger-perl \
	libapache2-mod-apreq2 \
	libapache2-mod-perl2 \
	libapache2-mod-perl2-dev \
	libapache2-request-perl \
	libapreq2-dev \
	libcache-memcached-fast-perl \
	libcache-memcached-perl \
	libcgi-simple-perl \
	libclass-dbi-abstractsearch-perl \
	libclass-dbi-mysql-perl \
	libclass-dbi-pager-perl \
	libconfig-tiny-perl \
	libcrypt-ssleay-perl \
	libdata-dumper-simple-perl \
	libdata-guid-perl \
	libdatetime-timezone-perl \
	libdbd-mysql-perl \
	libdigest-hmac-perl \
	libemail-send-perl \
	libemail-simple-perl \
	libemail-valid-perl \
	libfilesys-diskspace-perl \
	libhtml-entities-numbered-perl \
	libhtml-mason-perl \
	libhtml-strip-perl \
	libhttp-request-params-perl \
	libmail-sender-perl \
	libmasonx-request-withapachesession-perl \
	libmime-base64-urlsafe-perl \
	libmime-lite-perl \
	libmime-types-perl \
	libmodule-runtime-perl \
	libnet-smtp-tls-perl \
	libnet-smtps-perl \
	libpdf-fdf-simple-perl \
	libsoap-lite-perl \
	libspreadsheet-writeexcel-perl \
	libsql-abstract-perl \
	libswitch-perl \
	libtext-csv-perl \
	libtext-textile-perl \
	libtext-unaccent-perl \
	libtry-tiny-perl \
	libxml-libxml-perl \
	libxml-simple-perl \
	pdftk \
	perl-modules \
	python \
	python-lxml \
	python-pip \
	python-suds \
	&& rm -rf /var/lib/apt/lists/*

## This puts cpanm's temp files into /tmp/cpanm:
ENV PERL_CPANM_HOME /tmp/cpanm
RUN cpanm -qf \
	AnyData \
	CAM::PDF \
	Data::Dumper \
	Email::Send::Gmail \
	Encoding::FixLatin \
	MasonX::Profiler \
	Math::Currency \
	Net::Braintree \
	Spreadsheet::Write \
	Spreadsheet::WriteExcel \
	Spreadsheet::WriteExcel::Big \
	Template::Mustache \
	WebService::FogBugz \
	WWW::Mailgun \
	XML::Liberal \
	&& rm -Rf $PERL_CPANM_HOME

RUN mkdir -p /tmp/git/ && git clone https://github.com/jackiig/mailgun.perl.git \
	/tmp/git/mailgun.perl \
	&& cd /tmp/git/mailgun.perl \
	&& perl Makefile.PL && make && make test && make install \
	&& cd / && rm -Rf /tmp/git

VOLUME /usr/src/app/
ADD . /usr/src/app/

## Enables prefork in Apache, copies in config and entry point, and sets up
##  v3's models.
RUN a2dismod mpm_event && a2enmod mpm_prefork cgi \
	&& mv mason-app.conf /etc/apache2/sites-enabled/000-default.conf \
	&& chown -R www-data:www-data /usr/src/app/

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/log/apache2/pid

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
