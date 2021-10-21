ARG IMAGE_ARCH=aarch64
FROM balenalib/${IMAGE_ARCH}-ubuntu:bionic

ENV APP_NAME radius
ENV DEPENDS_DIR applications/${APP_NAME}/depends
ENV SOURCE_DIR applications/${APP_NAME}/src
ENV SCRIPTS_DIR applications/${APP_NAME}/scripts
ENV CONFIG_DIR applications/${APP_NAME}/configs
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1


# Add the freeradius repo
RUN sudo apt-get update && apt-get install gnupg curl
RUN curl https://packages.networkradius.com/pgp/packages%40networkradius.com | sudo apt-key add -

WORKDIR /install

COPY ${DEPENDS_DIR} /install/depends
COPY ${SOURCE_DIR} /
COPY ${CONFIG_DIR}/default /etc/freeradius/3.0/
COPY ${CONFIG_DIR}/eap-tls /etc/eap-tls.orig
COPY ${CONFIG_DIR}/clients.conf /etc/clients.conf.orig
RUN chmod 755 /application.sh
RUN apt-get update && \
    cat /install/depends/os_packages | xargs apt-get install -y 

RUN pip3 install --upgrade pip
RUN pip3 install -r /install/depends/requirements.txt

RUN which pkix_cd_verify
RUN which pkix_cd_manage_trust
RUN mkdir /etc/freeradius-conf-cache/
# COPY ${CONFIG_DIR}/default /etc/freeradius/3.0/sites-enabled/
# COPY ${CONFIG_DIR}/eap-tls /etc/eap-tls.orig
# COPY ${CONFIG_DIR}/clients.conf /etc/clients.conf.orig
COPY ${CONFIG_DIR} /etc/freeradius-conf-cache
CMD /application.sh
# CMD balena-idle