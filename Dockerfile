FROM ubuntu
ENV MAKEFLAGS="-j8"

########################
# Initialization
########################

# get necessary dependencies and cleanup
RUN apt-get -q update
RUN apt-get -q -y install \
      ccache cmake make g++-multilib gdb libdw-dev \
      pkg-config coreutils python-pexpect manpages-dev git \
      ninja-build capnproto libcapnp-dev autoconf \
      libpython2.7-dev zlib1g-dev python-pip \
      gawk man libbz2-dev libunwind-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# get necessary CrashSimulator repos
# RUN git clone -b spin-off https://github.com/pkmoore/rr
# RUN git clone https://github.com/pkmoore/rrapper rr/rrapper
RUN git clone -b clean_libstrace https://github.com/alyptik/rr
RUN git clone -b close_mutator https://github.com/alyptik/rrapper rr/rrapper

# create a new nonroot user
RUN useradd crashsim -m

########################
# Installing modified rr
########################

WORKDIR rr/

# compile and install the modified strace
RUN cd third-party/strace && ./bootstrap && autoreconf -fim && make install

# compile and install rr
RUN mkdir obj && cd obj && cmake .. && make install

########################
# Installing rrapper
########################

WORKDIR rrapper/

# install rrdump
RUN pip install ./rrdump

# install requirements.txt
RUN pip install -r requirements.txt

# run setup.py
RUN python setup.py install

########################
# Finalize
########################

USER crashsim
RUN env rrinit
