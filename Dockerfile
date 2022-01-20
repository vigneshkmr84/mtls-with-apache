FROM httpd

# standard un protected information
COPY ./html/main.html /usr/local/apache2/htdocs/
COPY ./html/health /usr/local/apache2/htdocs/
COPY ./html/unprotected.html /usr/local/apache2/htdocs/unprotected/

# Copying the html files for protected
COPY ./html/protected.html /usr/local/apache2/htdocs/protected/
COPY ./html/confidential.html /usr/local/apache2/htdocs/protected/


# copying mtls certificates
#COPY ./certificates/cert.pem /usr/local/apache2/conf/ssl.crt/

# Copying Server Certificates
COPY ./cert/CA/localhost/localhost.decrypted.key /usr/local/apache2/conf/server.key
COPY ./cert/CA/localhost/localhost.crt /usr/local/apache2/conf/server.crt

# Enabling SSL in httpd.conf server
RUN sed -i '/mod_ssl.so/s/^#//g' /usr/local/apache2/conf/httpd.conf && \   
    sed -i '/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    sed -i '/socache_shmcb_module/s/^#//g' /usr/local/apache2/conf/httpd.conf 
    #sed -i 's/Listen 80/Listen 443/g' /usr/local/apache2/conf/httpd.conf

RUN sed -i 's/www.example.com/localhost/g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    # newly added for wildcard
    sed -i 's/_default_/*/g' /usr/local/apache2/conf/extra/httpd-ssl.conf




