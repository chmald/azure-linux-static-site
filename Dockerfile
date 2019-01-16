FROM nginx:stable
LABEL Chris Maldonado <chmald@microsoft.com>

# ========
# ENV vars
# ========
# ssh
ENV SSH_PASSWD "root:Docker!"
#nginx
ENV NGINX_VERSION 1.14.0
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
#Web Site Home
ENV HOME_SITE "/home/site/wwwroot"
# supervisor
ENV SUPERVISOR_LOG_DIR "/home/LogFiles/supervisor"

COPY init_container.sh /usr/local/bin/
COPY index.html /home/site/wwwroot/

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
	&& rm -rf /var/log/nginx \
	&& ln -s $NGINX_LOG_DIR /var/log/nginx \
	##
	&& rm -rf /var/log/supervisor \
	&& ln -s $SUPERVISOR_LOG_DIR /var/log/supervisor 
# ssh
COPY sshd_config /etc/ssh/ 
# nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY spec-settings.conf /etc/nginx/conf.d/spec-settings.conf
# log rotater
COPY logrotate.conf /etc/logrotate.conf
RUN chmod 444 /etc/logrotate.conf
COPY logrotate.d/. /etc/logrotate.d/
RUN chmod -R 444 /etc/logrotate.d
# supervisor
COPY supervisord.conf /etc/

EXPOSE 2222 80
ENTRYPOINT ["init_container.sh"]
