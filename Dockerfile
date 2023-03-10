FROM ubuntu:bionic-20230301

USER root

RUN mkdir -p /opt/mongo-build/
WORKDIR /opt/mongo-build/

RUN apt update && \
    apt upgrade -y && \
    apt install -y scons build-essential && \
    apt install -y libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev

COPY . .

# The bundled v8 which the mongo shell uses by default is completely broken
# when compiled with GCC 7 (incl. in bionic): its heap allocator is busted.
# After some initial head scratching it seems like the spidermonkey backend
# works just fine. Therefore `--usesm`.
RUN scons --disable-warnings-as-errors --usesm -j4 all && scons --prefix=/usr/local/ install

CMD [ "/bin/bash" ]
