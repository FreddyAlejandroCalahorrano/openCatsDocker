FROM php:7.2-apache
RUN apt update && \
    apt upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" \
    TZ="America/Guayaquil" \
    apt install -y antiword poppler-utils html2text unrtf wget unzip rpl

RUN apt-get install -y build-essential libssl-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd

# Download OpenCATS
RUN cd /var/www/html && \
    wget https://github.com/opencats/OpenCATS/releases/download/0.9.6/opencats-0.9.6-full.zip && \
    unzip opencats-0.9.6-full.zip && \
    mv /var/www/html/home/travis/build/opencats/OpenCATS/ . && \
    mv OpenCATS opencats && \
    rm -f index.html && \
    rm -f opencats-0.9.6-full.zip

# Extensions install
RUN docker-php-ext-install mysqli

# MyISAM Problem on AZURE
#RUN cd /var/www/html/opencats && \
#    rpl -Rv -x'.sql' MyISAM InnoDB . && \
#    rpl -Rv -x'.php' MyISAM InnoDB .

# Copy install
COPY ./custom/opencats/ /var/www/html/opencats/
# Copy configs
COPY ./custom/etc/apache2/ /etc/apache2/

# Set file and folder permissions
RUN chown www-data:www-data -R /var/www/html/opencats
#RUN chmod -R 770 /var/www/html/opencats/attachments /var/www/html/opencats/upload
#RUN rm -rf /var/www/html/opencats/attachments && rm -rf /var/www/html/opencats/upload

# Makes www-data owner of folders
RUN chown www-data:www-data -R /var/log/apache2/ && chown www-data:www-data -R /var/run/apache2/

#RUN rm -rf /var/www/html/opencats/INSTALL_BLOCK