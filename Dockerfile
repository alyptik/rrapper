FROM i386/ubuntu
ENV MAKEFLAGS="-j8"

########################
# Initialization
########################

# get necessary dependencies and cleanup
RUN dpkg --add-architecture i386
RUN apt-get -q update
RUN apt-get install -q -y --allow-unauthenticated --fix-missing \
      multiarch-support linux-libc-dev:i386 \
      gcc-multilib g++-multilib libc6:i386 \
      libncurses5:i386 libstdc++6:i386 \
      ccache cmake cmake-curses-gui make g++-multilib gdb perl \
      pkg-config coreutils python-pexpect manpages-dev git \
      ninja-build capnproto libcapnp-dev libdw-dev autoconf \
      libpython2.7-dev zlib1g-dev python-pip vim gawk man \
      libbz2-dev libunwind-dev libarchive-dev liblzma-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# get necessary CrashSimulator repos
RUN git clone -b x86_docker https://github.com/alyptik/rr
RUN git clone -b x86_docker https://github.com/alyptik/rrapper rr/rrapper

# create a new nonroot user
RUN useradd crashsim -m

########################
# Installing rrapper
########################

WORKDIR /rr/rrapper
RUN pip install pexpect virtualenv
RUN python2 -m virtualenv ./crashsim
RUN . ./crashsim/bin/activate
# install rrdump
RUN pip install ./rrdump
# install requirements.txt
RUN pip install -Ur requirements.txt
# run setup.py
RUN python setup.py install

########################
# Installing modified rr
########################

# compile and install rr
WORKDIR /rr
RUN mkdir obj && cd obj && cmake .. && make install

########################
# Finalize
########################

USER crashsim
RUN env rrinit
