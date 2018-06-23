FROM ubuntu:16.04

RUN apt-get -qq update
RUN apt-get install -qq -y build-essential libtool autotools-dev autoconf libssl-dev libboost-all-dev software-properties-common python-software-properties git curl jq wget php7.0-cli php7.0-curl iputils-ping python-concurrent.futures python-pip
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN add-apt-repository ppa:longsleep/golang-backports

ENV ATOMIC_JSON=true

RUN python -m pip install grpcio



## ZEROTIER
RUN apt-get -y install supervisor && \
    mkdir -p /var/log/supervisor

RUN curl -s https://install.zerotier.com/ |  bash || true
 # rm /var/lib/zerotier-one/zerotier-one.pid || true && \
RUN service zerotier-one stop && \ 
    echo "manual" >> /etc/init/zerotier-one.override
   # rm /var/lib/zerotier-one/identity.secret && \
   # rm /var/lib/zerotier-one/identity.public

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## /ZEROTIER
RUN apt-get update

RUN apt-get install -y  golang-go 

#golang
RUN apt-get install -y bitcoind
RUN mkdir /root/.bitcoin/
RUN mkdir -p /usr/local/go

#Qt

RUN wget -P /tmp/ http://download.qt.io/official_releases/qt/5.11/5.11.1/qt-opensource-linux-x64-5.11.1.run
RUN chmod +x /tmp/qt-opensource-linux-x64-5.11.1.run
RUN apt-get install -y libgl1-mesa-dev  libxext-dev libglib2.0-0 libfontconfig1 libdbus-1-3 libnss3 libxcomposite1 libxcursor1 libxi6 libxtst6 libxrandr2 libasound2 libegl1-mesa 
COPY extract-qt-installer /tmp/extract-qt-installer
RUN chmod +x /tmp/extract-qt-installer
ENV QT_CI_PACKAGES="qt.qt5.5111.gcc_64,qt.qt5.5111.qtwebglplugin,qt.qt5.5111.qtwebengine"
RUN  /tmp/extract-qt-installer /tmp/qt-opensource-linux-x64-5.11.1.run /qt
ENV QTDIR=/qt/5.11.1/gcc_64
ENV PATH="$QTDIR/bin:$PATH"
ENV LD_LIBRARY_PATH="$QTDIR/lib:$LD_LIBRARY_PATH"
ENV QT_DEBUG_PLUGINS=1

#ENV GOROOT=/usr/local/go
#ENV GOPATH=/root/go
ENV PATH=$PATH:/root/go/bin/

RUN go get -u github.com/threefoldfoundation/tfchain/cmd/...

COPY bitcoin.conf /root/.bitcoin/
COPY btcatomicswap /bin/
COPY rundaemons.sh /rundaemons.sh
#CMD ["bitcoind"]
#Temp - for php


COPY dist /dist

RUN chmod +x /dist/atomicExchange
RUN chmod +x /rundaemons.sh
RUN mkdir -p /crypto/btc 
RUN mkdir -p /crypto/tft
CMD /rundaemons.sh