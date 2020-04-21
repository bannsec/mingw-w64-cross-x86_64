FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt dist-upgrade -y && \
    apt install -y wget gcc build-essential make git libgmp-dev pkg-config flex bison file autoconf mingw-w64 unzip zip wine64 wine-binfmt && \
    mkdir -p /opt/cross && \
    update-alternatives --install /usr/bin/g++ c++ /usr/bin/x86_64-w64-mingw32-g++ 100 && \
    update-alternatives --install /usr/bin/gcc cc /usr/bin/x86_64-w64-mingw32-gcc 100 && \
    update-alternatives --install /usr/bin/cpp cpp /usr/bin/x86_64-w64-mingw32-cpp 100 && \
    update-alternatives --install /usr/bin/c89-gcc c89 /usr/bin/x86_64-w64-mingw32-cpp 100 && \
    update-alternatives --install /usr/bin/c99-gcc c99 /usr/bin/x86_64-w64-mingw32-cpp 100 && \
    ln -sf /usr/bin/x86_64-w64-mingw32-as /usr/bin/as && \
    ln -sf /usr/bin/x86_64-w64-mingw32-ar /usr/bin/ar && \
    ln -sf /usr/bin/x86_64-w64-mingw32-nm /usr/bin/nm && \
    ln -sf /usr/bin/x86_64-w64-mingw32-ld /usr/bin/ld && \
    ln -sf /usr/bin/x86_64-w64-mingw32-gcc /usr/bin/cc


# So.. sometimes auto configure and such tools will not actually add LDFLAGS when they don't think they're needed. They are wrong. Thus this jibberish here to get around it.
ENV LDFLAGS="-L/opt/cross/lib/"
ENV CFLAGS="-I/opt/cross/include -L/usr/lib/x86_64-linux-gnu/ $LDFLAGS -static-libgcc"
ENV CXXFLAGS="$CFLAGS -static-libstdc++"
ENV CPPFLAGS="$CFLAGS"
ENV PATH="$PATH:/opt/cross/bin" CXX="g++" OPENSSL_ROOT_DIR="/opt/cross/"

RUN cd /opt && wget -q https://www.openssl.org/source/openssl-1.1.1f.tar.gz && tar xf openssl-1.1.1f.tar.gz && \
       rm openssl-1.1.1f.tar.gz && cd openssl-1.1.1f && ./Configure mingw64 --prefix=/opt/cross --cross-compile-prefix=x86_64-w64-mingw32- -no-err && \
       make -sj`nproc` && make install -sj`nproc` >/dev/null && cd /opt/ && rm -rf openssl* && \
    cd /opt && wget -q https://www.zlib.net/zlib-1.2.11.tar.xz && tar xf zlib* && cd zlib-1.2.11 && \
        ./configure --static --prefix=/opt/cross && make -sj`nproc` install && cd /opt && rm -rf zlib* && \
    cd /opt && git clone -b bzip2-1.0.8 --depth=1 git://sourceware.org/git/bzip2.git && cd bzip2 && \
        make -sj`nproc`; make -sj`nproc` install PREFIX=/opt/cross && cd /opt && rm -rf bzip2 && \
    cd /opt && wget -q https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz && tar xf gmp* && cd gmp-6.2.0 && \
        ./configure --prefix=/opt/cross --enable-cxx --disable-assembly --host=x86_64-pc-mingw64 && make -sj`nproc` && make install -sj`nproc` && \
        cd /opt && rm -rf gmp*

WORKDIR /data
CMD ["/bin/bash"]

# Toolchain is under /opt/cross

############
# REMEMBER #
############
# wine-binfmt
# update-binfmts --enable wine <-- Need to run this on the host before building so that gmp will compile correctly
