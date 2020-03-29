# Dockerfile that will build an arm32v7 image on an x86 build host
# Remove the 'cross-buld' commands to build on a native ARM host

# Balena base image required for cross-build capabilities
FROM balenalib/raspberrypi3:stretch

### Run commands within QEMU ARM cross-build emulation ---------------------------------
#RUN [ "cross-build-start" ]
ENV AIRCONNECT_BIN aircast-arm
RUN apt-get update && \
    apt-get install -y wget multiarch-support && \
    wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_armhf.deb && \
    dpkg -i libssl1.0.0_1.0.1t-1+deb8u12_armhf.deb && \
    wget https://raw.githubusercontent.com/philippe44/AirConnect/master/bin/$AIRCONNECT_BIN && \
    chmod +x $AIRCONNECT_BIN

# setconfig.sh and setoptions.sh dynamically create the config.xml and options.txt files,
# using environment variables (if present) to override defaults
ADD ./setconfig.sh setconfig.sh
ADD ./setoptions.sh setoptions.sh
RUN chmod +x setconfig.sh setoptions.sh

#RUN [ "cross-build-end" ]
### End QEMU ARM emulation -------------------------------------------------------------

# First, dynamically generate the config.xml and options.txt files,
# then run airupnp.
CMD ./setconfig.sh > config.xml ; \
    ./$AIRCONNECT_BIN -Z -x config.xml
