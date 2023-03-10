FROM ubuntu:bionic-20230301

USER root

RUN mkdir -p /opt/mongo-build/
WORKDIR /opt/mongo-build/

RUN apt update && \
    apt upgrade -y && \
    apt install -y scons build-essential && \
    apt install -y libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev

COPY . .

# Some useful -Wno* flags included
# There's a lot of std::auto_ptr in the codebase, which was deprecated in C++11, emitting -Wdeprecated-declarations
# There are a lot of unused local typedefs which probably never emitted warnings with older versions of GCC
RUN CCFLAGS="-Wnodeprecated-declarations -Wnounused-local-typedefs" scons --disable-warnings-as-errors -j4 all && scons --prefix=/usr/local/ install

CMD [ "/bin/bash" ]
