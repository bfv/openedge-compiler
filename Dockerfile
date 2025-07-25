FROM ubuntu:24.04 AS install

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:JDKVERSION $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# the running process (i.e. the github action) is responsible for placing the install .tar 
# in the correct location
ADD PROGRESS_OE.tar.gz /install/openedge/
ADD PROGRESS_PATCH_OE.tar.gz /install/patch/
ADD scripts/install-openedge.sh /install/

COPY response.ini /install/openedge/response.ini
ENV TERM=linux

RUN /install/install-openedge.sh

RUN cat /install/install_oe.log
RUN /usr/dlc/bin/proDebugEnable -enable-all
RUN rm /usr/dlc/progress.cfg

COPY clean-dlc.sh /install/openedge/clean-dlc.sh
RUN /install/openedge/clean-dlc.sh

# multi stage build, this give the possibilty to remove all the slack from stage 0
FROM ubuntu:24.04 AS instance

LABEL maintainer="Bronco Oostermeyer <dev@bfv.io>"

ENV JAVA_HOME=/opt/java/openjdk
ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk
ENV TERM=linux

# ubuntu 24.04 has the user ubuntu as user 1000, which is not compatible with the openedge installation
# this user is removed and replaced with a new user openedge with uid 1000
RUN userdel -r ubuntu && \
    groupadd -g 1000 openedge && \
    useradd -r -u 1000 -g openedge openedge

COPY --from=install $JAVA_HOME $JAVA_HOME
COPY --from=install $DLC $DLC
COPY --from=install $WRKDIR $WRKDIR

# allow for progress to be copied into $DLC
# kubernetes does not support volume mount of single files
RUN chown root:openedge $DLC $WRKDIR && \
    chmod 775 $DLC && \
    chmod 777 $WRKDIR

# if not present ESAM starts complaining
# this file is necessary in order for a Dockerfile which uses the openedge-pas image to 
# be able to use oeprop.sh to set properties
RUN touch /usr/dlc/progress.cfg  && \
    chown openedge:openedge /usr/dlc/progress.cfg

RUN mkdir -p /app/src && mkdir /artifacts && \
    chown -R openedge:openedge /app /artifacts

COPY protocols /etc/protocols

USER openedge

WORKDIR /app/src

ENV PATH="${DLC}:${DLC}/bin:${JAVA_HOME}/bin:${PATH}"
