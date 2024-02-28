FROM ubuntu:22.04

USER root
WORKDIR /home/

ENV APT_DEPS build-essential opam clang git pkg-config libgmp-dev libmpfr-dev \
             python3-dev python3-setuptools python3-pip python3-requests  \
             rsync m4 curl wget libc6-dev-i386 zip

ENV TERM xterm-256color
ENV OPAM_DEPS apron zarith menhir ounit dune

RUN apt-get update
RUN apt-get install --no-install-recommends -y $APT_DEPS

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN \
    opam init --disable-sandboxing -y \
    &&  eval $(opam env) \
    &&  opam update -y   \
    &&  opam install -y -j 8 $OPAM_DEPS \
    &&  pip install jupyterlab \
    &&  apt-get update \
    &&  eval $(opam env)\ 
    &&  apt-get install -y wget sed bash bc python3-coloredlogs libseccomp2 lxcfs vim nano 
COPY . function/
ENTRYPOINT ["opam", "exec", "--"]
CMD ["/bin/bash", "--login"]
