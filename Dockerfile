FROM ubuntu:20.04 as install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17.0.6_10-jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ADD PROGRESS_OE_12.7_LNX_64.tar.gz /install/openedge

COPY response-4gldevsys-127.ini /install/openedge/response.ini
ENV TERM xterm

RUN /install/openedge/proinst -b /install/openedge/response.ini -l /install/install_oe.log -n && \
    rm /usr/dlc/progress.cfg

# multi stage build, this give the possibilty to remove all the slack from stage 0
FROM ubuntu:20.04 as instance

LABEL maintainer="Bronco Oostermeyer <dev@bfv.io>"

ENV JAVA_HOME=/opt/java/openjdk
ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk

COPY --from=install $JAVA_HOME $JAVA_HOME
COPY --from=install $DLC $DLC
COPY --from=install $WRKDIR $WRKDIR

RUN mkdir -p /app/src && mkdir /artifacts

WORKDIR /app/src
