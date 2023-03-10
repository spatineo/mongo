FROM ubuntu:bionic-20230301

USER root

RUN mkdir -p /opt/mongo-build/
WORKDIR /opt/mongo-build/

RUN apt update && \
    apt upgrade -y && \
    apt install -y scons build-essential && \
    apt install -y libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev

COPY . .

RUN scons --disable-warnings-as-errors -j4 all && scons --prefix=/usr/local/ install

CMD [ "/bin/bash" ]
