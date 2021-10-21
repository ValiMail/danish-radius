ARG IMAGE_ARCH=aarch64
FROM balenalib/${IMAGE_ARCH}-python:3.8

ENV APP_NAME maintenance
ENV DEPENDS_DIR applications/${APP_NAME}/depends
ENV SOURCE_DIR applications/${APP_NAME}/src
ENV SCRIPTS_DIR applications/${APP_NAME}/scripts
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /install

COPY ${DEPENDS_DIR} /install/depends
RUN apt-get update && \
    cat /install/depends/os_packages | xargs apt-get install -y 

RUN pip3 install -r /install/depends/requirements.txt

COPY ${SOURCE_DIR}/application.sh /

RUN chmod 755 /application.sh

CMD /application.sh