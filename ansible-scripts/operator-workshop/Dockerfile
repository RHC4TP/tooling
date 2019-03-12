FROM fedora:29

RUN dnf update -y && \
  dnf install -y \
  sudo \
  git \
  vim \
  ansible

RUN useradd -ms /bin/bash gfranchini

RUN echo "gfranchini ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN echo "set st=2 sw=2 sts=2 et" > /home/gfranchini/.vimrc

VOLUME /home/gfranchini/ansible

USER gfranchini

WORKDIR /home/gfranchini/ansible


