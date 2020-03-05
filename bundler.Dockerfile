FROM ruby:2.7.0-buster

ENV LANG=C.UTF-8

RUN apt-get update; \
    apt-get install -y libaio-dev; \
    rm -rf /var/lib/apt/lists/*;

RUN gem install bundler -v '2.1.4'
