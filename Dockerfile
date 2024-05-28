# syntax=docker/dockerfile:1.7-labs

FROM ruby:2.7.8-alpine

WORKDIR /usr/local/src

RUN apk add --no-cache alpine-sdk

COPY --parents \
  config \
  lib \
  config.ru \
  Gemfile \
  Gemfile.lock \
  ./

ENV RACK_ENV=production
RUN bundle install && apk del --no-cache alpine-sdk
CMD ["bundle", "exec", "puma"]