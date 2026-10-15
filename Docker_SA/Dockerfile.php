FROM php:8.2-apache

# Extensoes PHP para MySQL e mod_rewrite do Apache
RUN docker-php-ext-install mysqli pdo pdo_mysql \
    && a2enmod rewrite headers expires deflate

# Copia o projeto clonado para a raiz do Apache
COPY FalaiSA/ /var/www/html/

# Permite uso de .htaccess
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
    && chown -R www-data:www-data /var/www/html

# Remove aviso AH00558
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Apache passa a escutar na porta 8080
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf

EXPOSE 8080
