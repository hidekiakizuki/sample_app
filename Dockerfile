FROM ruby:3.2.2-slim AS assets

ARG USER="app-user"
ARG USER_ID="1000"
ARG APP_NAME="app"

WORKDIR /"${APP_NAME}"

RUN set -x && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl git libpq-dev \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb https://dl.yarnpkg.com/debian stable main' | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y --no-install-recommends nodejs yarn \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd -m -u "${USER_ID}" "${USER}" \
  && chown "${USER}":"${USER}" -R /"${APP_NAME}"

USER "${USER}"

COPY --chown="${USER}":"${USER}" Gemfile Gemfile.lock ./
RUN bundle install --jobs "$(nproc)"

ARG RAILS_ENV="development"
ARG NODE_ENV="development"
ENV RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="${USER}"

COPY --chown="${USER}":"${USER}" . .

RUN if [ "${RAILS_ENV}" != "development" ]; then \
  SECRET_KEY_BASE=dummy rails assets:precompile; fi

CMD ["bash"]

# ---

FROM ruby:3.2.2-slim AS app

ARG USER="app-user"
ARG USER_ID="1000"
ARG APP_NAME="app"

WORKDIR /"${APP_NAME}"

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential libpq-dev vim \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd -m -u ${USER_ID} ${USER} \
  && chown ${USER}:${USER} -R /"${APP_NAME}"

USER "${USER}"

ARG RAILS_ENV
ARG NODE_ENV
ENV RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    APP_NAME="${APP_NAME}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="${USER}"

COPY --chown="${USER}":"${USER}" --from=assets /usr/local/bundle /usr/local/bundle
COPY --chown="${USER}":"${USER}" . .
COPY --chown="${USER}":"${USER}" --from=assets /"${APP_NAME}"/public /"${APP_NAME}"/public
RUN chmod 0755 ./bin/*

VOLUME /"${APP_NAME}"/tmp /"${APP_NAME}"/public

ENTRYPOINT [ "sh", "-c", "/${APP_NAME}/bin/entrypoint.sh" ]
