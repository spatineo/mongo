FROM ubuntu:bionic-20230301

USER root

RUN mkdir -p /opt/mongo-build/
WORKDIR /opt/mongo-build/

RUN apt update && \
    apt upgrade -y && \
    apt install -y scons build-essential gcc-4.8 g++-4.8

COPY . .

# The bundled v8 which the mongo shell uses by default is completely broken
# when compiled with GCC 7 (incl. in bionic): its heap allocator is busted.
# After some initial head scratching it seems like the spidermonkey backend
# works just fine. Therefore `--usesm`.
#   When compiling with GCC 4.8, don't do `--usesm`. Instead leave the
# parameter out, which defaults to using v8. That seems to result in a more
# reliable build.
RUN scons --cc=gcc-4.8 --cxx=g++-4.8 --disable-warnings-as-errors -j4 all && \
    scons --cc=gcc-4.8 --cxx=g++-4.8 --prefix=/usr/local/ install && \
    scons --cc=gcc-4.8 --cxx=g++-4.8 --prefix=/usr/local/ --distmod=spat-1-gcc4.8-v8 dist

CMD [ "/bin/bash" ]
