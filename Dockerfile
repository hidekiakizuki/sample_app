FROM ruby:3.1.3

WORKDIR /var/www/sample_app

ADD Gemfile /var/www/sample_app/Gemfile
ADD Gemfile.lock /var/www/sample_app/Gemfile.lock

RUN set -x \
  && mkdir -p /var/www/sample_app/tmp/pids /var/www/sample_app/tmp/sockets \
  && apt-get update \
  && apt-get install -y build-essential libpq-dev nodejs \
  && gem install bundler:2.4.9 \
  && bundle install
