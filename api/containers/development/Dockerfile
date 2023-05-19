FROM elixir:1.14.4

ENV LANG C.UTF-8

WORKDIR /api

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    inotify-tools \
    && mix local.hex --force \
    && mix local.rebar \
    && mix archive.install hex phx_new 1.7.2
