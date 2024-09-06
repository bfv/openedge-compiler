FROM ubuntu:22.04 as install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:JDKVERSION $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# the running process (i.e. the github action) is responsible for placing the install .tar 
# in the correct location
ADD PROGRESS_OE.tar.gz /install/openedge/
ADD PROGRESS_PATCH_OE.tar.gz /install/patch/
ADD scripts/install-openedge.sh /install/

COPY response.ini /install/openedge/response.ini
ENV TERM xterm

RUN /install/install-openedge.sh

RUN cat /install/install_oe.log
RUN /usr/dlc/bin/proDebugEnable -enable-all
RUN rm /usr/dlc/progress.cfg

COPY clean-dlc.sh /install/openedge/clean-dlc.sh
RUN /install/openedge/clean-dlc.sh

# multi stage build, this give the possibilty to remove all the slack from stage 0
FROM ubuntu:22.04 as instance

LABEL maintainer="Bronco Oostermeyer <dev@bfv.io>"

ENV JAVA_HOME=/opt/java/openjdk
ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk
ENV TERM xterm

COPY --from=install $JAVA_HOME $JAVA_HOME
COPY --from=install $DLC $DLC
COPY --from=install $WRKDIR $WRKDIR

RUN mkdir -p /app/src && mkdir /artifacts

WORKDIR /app/src

ENV PATH="${DLC}:${DLC}/bin:${JAVA_HOME}/bin:${PATH}"
