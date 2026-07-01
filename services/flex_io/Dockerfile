FROM elixir:1.18-slim AS builder

ENV MIX_ENV=prod
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y build-essential git && apt-get clean

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

COPY config/ config/
RUN mix deps.compile

COPY lib lib

RUN mix compile
RUN mix release

FROM debian:testing-slim AS app

ENV MIX_ENV=prod
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    openssl \
    libncurses6 \
    locales \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN useradd --create-home appuser
WORKDIR /home/appuser/app

COPY --from=builder --chown=appuser:appuser /app/_build/prod/rel/flex_io_files ./

USER appuser

EXPOSE 4000

CMD ["bin/flex_io_files", "start"]