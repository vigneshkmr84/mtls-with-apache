FROM httpd

# ORIGINAL WORKING VERSION
# # standard un protected information
# COPY ./html/main.html /usr/local/apache2/htdocs/
# COPY ./html/health /usr/local/apache2/htdocs/
# COPY ./html/unprotected.html /usr/local/apache2/htdocs/unprotected/

# # Copying the html files for protected
# COPY ./html/protected.html /usr/local/apache2/htdocs/protected/
# COPY ./html/confidential.html /usr/local/apache2/htdocs/protected/

COPY ./html/ /usr/local/apache2/htdocs/


# copying mtls certificates
#COPY ./certificates/cert.pem /usr/local/apache2/conf/ssl.crt/

# Copying Server Certificates
COPY ./cert/CA/localhost/localhost.decrypted.key /usr/local/apache2/conf/server.key
COPY ./cert/CA/localhost/localhost.crt /usr/local/apache2/conf/server.crt

# Copying the incoming certificate
#COPY ./incoming-certificate/CA/localhost/localhost.crt /usr/local/apache2/conf/ssl.crt/ca-bundle.crt

# Final.crt has to be generated manually
#COPY ./incoming-certificate/CA/localhost/final.crt /usr/local/apache2/conf/ssl.crt/ca-bundle.crt

COPY ./incoming-certificate/CA/localhost/localhost.crt ./incoming-certificate/CA/CA.pem /usr/local/apache2/conf/ssl.crt/


#COPY ./incoming-certificate/CA/localhost/localhost.crt /usr/local/apache2/conf/ssl.crt/
#COPY ./incoming-certificate/CA/CA.pem /usr/local/apache2/conf/ssl.crt/

# Enabling SSL in httpd.conf server
RUN sed -i '/mod_ssl.so/s/^#//g' /usr/local/apache2/conf/httpd.conf && \   
    sed -i '/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    sed -i '/socache_shmcb_module/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    #sed -i 's/Listen 80/Listen 443/g' /usr/local/apache2/conf/httpd.conf
    # configuration changes for mTLS 
    sed -i '/SSLCACertificateFile/s/^#//g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    sed -i 's/#SSLVerifyClient require/SSLVerifyClient none/g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    sed -i "s/#SSLVerifyDepth  10*/  <Location \/protected> \n SSLVerifyClient require \n SSLVerifyDepth 2 \n <\/Location>/" /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    sed -i 's/www.example.com/localhost/g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    # newly added for wildcard
    sed -i 's/_default_/*/g' /usr/local/apache2/conf/extra/httpd-ssl.conf && \
    # create final.crt file 
    cat /usr/local/apache2/conf/ssl.crt/localhost.crt /usr/local/apache2/conf/ssl.crt/CA.pem >> /usr/local/apache2/conf/ssl.crt/ca-bundle.crt




