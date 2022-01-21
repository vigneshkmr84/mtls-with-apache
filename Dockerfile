FROM httpd

# Copying the necessary html pages
COPY ./html/ /usr/local/apache2/htdocs/


# Copying Server Certificates
COPY ./cert/CA/localhost/localhost.decrypted.key /usr/local/apache2/conf/server.key
COPY ./cert/CA/localhost/localhost.crt /usr/local/apache2/conf/server.crt

# Copying the incoming certificate
COPY ./incoming-certificate/CA/localhost/localhost.crt ./incoming-certificate/CA/CA.pem /usr/local/apache2/conf/ssl.crt/

# Config changes - httpd.conf
RUN sed -i '/mod_ssl.so/s/^#//g' /usr/local/apache2/conf/httpd.conf && \   
    sed -i '/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    sed -i '/socache_shmcb_module/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    # Config changes - httpd-ssl.conf (mtls related configs)
    sed -i '/SSLCACertificateFile/s/^#//g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    sed -i 's/#SSLVerifyClient require/SSLVerifyClient none/g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    sed -i "s/#SSLVerifyDepth  10*/  <Location \/protected> \n SSLVerifyClient require \n SSLVerifyDepth 2 \n <\/Location>/" /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    sed -i 's/www.example.com/localhost/g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    # create final.crt file 
    cat /usr/local/apache2/conf/ssl.crt/localhost.crt /usr/local/apache2/conf/ssl.crt/CA.pem >> /usr/local/apache2/conf/ssl.crt/ca-bundle.crt && \
    # adding 443 port wildcard
    sed -i 's/_default_/*/g' /usr/local/apache2/conf/extra/httpd-ssl.conf
    
