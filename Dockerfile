FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt dist-upgrade -y && \
    apt install -y wget gcc build-essential make git libgmp-dev pkg-config flex bison autoconf && \
    mkdir -p /opt && cd /opt && git clone --depth=1 https://github.com/richfelker/musl-cross-make.git

COPY config.mak /opt/musl-cross-make/.

# update-alternatives --get-selections
RUN cd /opt/musl-cross-make && make -sj`nproc` && make -s install && \
    update-alternatives --install /usr/bin/g++ c++ /opt/cross/bin/x86_64-linux-musl-g++ 100 && \
    update-alternatives --install /usr/bin/gcc cc /opt/cross/bin/x86_64-linux-musl-cc 100 && \
    update-alternatives --install /usr/bin/cpp cpp /opt/cross/bin/x86_64-linux-musl-cpp 100 && \
    update-alternatives --install /usr/bin/c89-gcc c89 /opt/cross/bin/x86_64-linux-musl-gcc 100 && \
    update-alternatives --install /usr/bin/c99-gcc c99 /opt/cross/bin/x86_64-linux-musl-gcc 100 && \
    ln -sf /opt/cross/bin/x86_64-linux-musl-as /usr/bin/as && \
    ln -sf /opt/cross/bin/x86_64-linux-musl-ar /usr/bin/ar && \
    ln -sf /opt/cross/bin/x86_64-linux-musl-nm /usr/bin/nm && \
    ln -sf /opt/cross/bin/x86_64-linux-musl-ld /usr/bin/ld && \
    ln -sf /opt/cross/bin/x86_64-linux-musl-gcc /usr/bin/cc && \
    ln -s /opt/cross/x86_64-linux-musl/lib/libc.so /lib/ld-musl-x86_64.so.1 && \
    rm -rf /opt/musl-cross-make/

# So.. sometimes auto configure and such tools will not actually add LDFLAGS when they don't think they're needed. They are wrong. Thus this jibberish here to get around it.
ENV LD_LIBRARY_PATH="/opt/cross/lib:/opt/cross/x86_64-linux-musl/lib/" LDFLAGS="-L/opt/cross/lib/ -L/opt/cross/x86_64-linux-musl/lib/" CXXFLAGS="-I/opt/cross/include $LDFLAGS" CFLAGS="$CXXFLAGS" CPPFLAGS="$CXXFLAGS" PATH="$PATH:/opt/cross/bin" CXX="g++" OPENSSL_ROOT_DIR="/opt/cross/"

RUN cd /opt && wget -q https://www.openssl.org/source/openssl-1.1.1f.tar.gz && tar xf openssl-1.1.1f.tar.gz && \
        rm openssl-1.1.1f.tar.gz && cd openssl-1.1.1f && ./config --prefix=/opt/cross -static -no-err && \
        make -sj`nproc` && make install -sj`nproc` && cd /opt/ && rm -rf openssl* && \
    cd /opt && wget -q https://www.zlib.net/zlib-1.2.11.tar.xz && tar xf zlib* && cd zlib-1.2.11 && \
        ./configure --static --prefix=/opt/cross && make -sj`nproc` install && cd /opt && rm -rf zlib* && \
    cd /opt && git clone -b bzip2-1.0.8 --depth=1 git://sourceware.org/git/bzip2.git && cd bzip2 && \
        make -sj`nproc` && ls -la && make -sj`nproc` install PREFIX=/opt/cross && cd /opt && rm -rf bzip2 && \
    cd /opt && git clone -b libpcap-1.9.1 --depth=1 https://github.com/the-tcpdump-group/libpcap.git && cd libpcap && \
        ./configure --prefix=/opt/cross && make -sj`nproc` && make -sj`nproc` install && cd /opt && rm -rf libpcap && \
    cd /opt && wget -q https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz && tar xf gmp* && cd gmp-6.2.0 && \
       ./configure --prefix=/opt/cross --enable-static --enable-cxx && make -sj`nproc` && make install -sj`nproc` && \
        cd /opt && rm -rf gmp* && \
    cd /opt && wget -q https://github.com/Kitware/CMake/releases/download/v3.17.1/cmake-3.17.1.tar.gz && tar xf cmake* && cd cmake-3.17.1 && \
        ./configure && make -sj`nproc` && make -sj`nproc` install && cd /opt && rm -rf cmake*

WORKDIR /data
CMD ["/bin/bash"]

# Toolchain is under /opt/cross
