FROM httpd:2.4
LABEL Chris Maldonado <chmald@microsoft.com>

# ========
# ENV vars
# ========
# ssh
ENV SSH_PASSWD "root:Docker!"
#apache httpd
ENV HTTPD_LOG_DIR "/home/LogFiles/httpd"
#Web Site Home
ENV HOME_SITE "/home/site/wwwroot"
# supervisor
ENV SUPERVISOR_LOG_DIR "/home/LogFiles/supervisor"

COPY init_container.sh /usr/local/bin/
COPY index.html /usr/local/apache2/htdocs/
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

RUN apt-get update \
    && apt-get install -y --no-install-recommends dialog \
    && apt-get update \
    && apt-get install -y --no-install-recommends openssh-server \
        vim \
        git \
        gcc \
        g++ \
        build-essential \
        apt-transport-https \
        curl \
        gnupg \
        supervisor \
    && echo "$SSH_PASSWD" | chpasswd \
    && chmod 755 /usr/local/bin/init_container.sh

COPY sshd_config /etc/ssh/

# =========
# Configure
# =========
RUN set -ex\
	##
	&& rm -rf /var/log/httpd \
	&& ln -s $HTTPD_LOG_DIR /var/log/httpd \
	##
	&& rm -rf /var/log/supervisor \
	&& ln -s $SUPERVISOR_LOG_DIR /var/log/supervisor \
	##
	&& ln -s $HOME_SITE /usr/local/apache2/htdocs \
	##
	&& rm -rf /var/log/supervisor \
	&& ln -s $SUPERVISOR_LOG_DIR /var/log/supervisor 
# ssh
COPY sshd_config /etc/ssh/ 
# supervisor
COPY supervisord.conf /etc/

EXPOSE 2222 80
ENTRYPOINT ["init_container.sh"]
