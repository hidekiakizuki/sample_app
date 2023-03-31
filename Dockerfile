FROM ruby:3.1.3

WORKDIR /usr/local/src

ADD Gemfile /usr/local/src/Gemfile
ADD Gemfile.lock /usr/local/src/Gemfile.lock

RUN set -x \
  && apt-get update \
  && apt-get install -y build-essential libpq-dev nodejs \
  && gem install bundler:2.4.9 \
  && bundle install
