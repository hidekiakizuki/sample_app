ARG USER="app-user"
ARG USER_ID="1000"
ARG APP_NAME="app"
ARG RAILS_ENV="production"
ARG NODE_ENV="production"

# ---------------------------------------------------------------

FROM ruby:3.2.2-slim AS asset_backend

ARG USER
ARG USER_ID
ARG APP_NAME
ARG RAILS_ENV
ARG NODE_ENV

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

#COPY --chown="${USER}":"${USER}" package.json yarn.lock ./
#RUN yarn install

CMD ["bash"]

# ---------------------------------------------------------------

FROM asset_backend AS asset_frontend

ARG USER
ARG APP_NAME
ARG RAILS_ENV
ARG NODE_ENV

WORKDIR /"${APP_NAME}"
USER "${USER}"

ARG RAILS_ENV="production"
ARG NODE_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="${USER}"

COPY --chown="${USER}":"${USER}" . .

RUN if [ "${RAILS_ENV}" != "development" ]; then \
  SECRET_KEY_BASE=dummy rails assets:precompile; fi

CMD ["bash"]

# ---------------------------------------------------------------

FROM ruby:3.2.2-slim AS app_base

ARG USER
ARG USER_ID
ARG APP_NAME
ARG RAILS_ENV
ARG NODE_ENV

ENV TZ Asia/Tokyo

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

COPY --chown="${USER}":"${USER}" --from=asset_backend /usr/local/bundle /usr/local/bundle
COPY --chown="${USER}":"${USER}" . .
COPY --chown="${USER}":"${USER}" --from=asset_frontend /"${APP_NAME}"/public /"${APP_NAME}"/public
RUN chmod 0755 ./bin/*

ENTRYPOINT ["./bin/entrypoint.sh"]

# ---------------------------------------------------------------

# development
FROM app_base as development

CMD ["bash", "-c", "echo \"Running in development mode\" && \
                    bundle install --jobs $(nproc) && \
                    bundle exec rails db:create && \
                    bundle exec rails db:migrate && \
                    bundle exec rails db:seed && \
                    bundle exec rails s -p 3000 -b '0.0.0.0'"]

# ---------------------------------------------------------------

# production
FROM app_base as production

ARG APP_NAME

VOLUME /"${APP_NAME}"/tmp /"${APP_NAME}"/public

CMD ["bash", "-c", "echo \"Running in production mode\" && \
                    # bundle exec rails db:create && \
                    # bundle exec rails db:migrate && \
                    # bundle exec rails db:seed && \
                    bundle exec puma -C config/puma.rb"]
