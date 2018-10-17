FROM centos:centos7

LABEL maintainer="gfranchini88@gmail.com"

RUN yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel \
    libyaml-devel libffi-devel openssl-devel make which\
    bzip2 autoconf automake libtool bison iconv-devel sqlite-devel

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -L get.rvm.io | bash -s stable

SHELL [ "/bin/bash", "-l", "-c" ]

RUN source /etc/profile.d/rvm.sh && \
    rvm reload

RUN rvm install 2.5

WORKDIR /usr/src/app

COPY . .

RUN bundle install

ENTRYPOINT ["bash"]
