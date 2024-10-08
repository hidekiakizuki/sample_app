ARG USER="app-user"
ARG USER_ID="1000"
ARG APP_NAME="sample_app"
ARG APP_ENV="development"

# ---------------------------------------------------------------

FROM ruby:3.2.2-slim AS asset_backend

ARG USER
ARG USER_ID
ARG APP_NAME
ARG APP_ENV

WORKDIR /"${APP_NAME}"

RUN set -x && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl git libpq-dev \
  #&& curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  #&& curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  #&& echo 'deb https://dl.yarnpkg.com/debian stable main' | tee /etc/apt/sources.list.d/yarn.list \
  #&& apt-get update && apt-get install -y --no-install-recommends nodejs yarn \
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
ARG USER_ID
ARG APP_NAME
ARG APP_ENV

WORKDIR /"${APP_NAME}"
USER "${USER}"

ENV RAILS_ENV="${APP_ENV}" \
    NODE_ENV="${APP_ENV}" \
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
ARG APP_ENV

ENV TZ=Asia/Tokyo

WORKDIR /"${APP_NAME}"

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl libpq-dev postgresql-client vim  \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd -m -u ${USER_ID} ${USER} \
  && chown ${USER}:${USER} -R /"${APP_NAME}"

USER "${USER}"

ENV RAILS_ENV="${APP_ENV}" \
    NODE_ENV="${APP_ENV}" \
    APP_NAME="${APP_NAME}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="${USER}"

COPY --chown="${USER}":"${USER}" --from=asset_backend /usr/local/bundle /usr/local/bundle
COPY --chown="${USER}":"${USER}" . .
COPY --chown="${USER}":"${USER}" --from=asset_frontend /"${APP_NAME}"/public /"${APP_NAME}"/public
RUN chmod 0755 ./bin/*

ENTRYPOINT ["./bin/entrypoint.sh"]

# ---------------------------------------------------------------

# web_development
FROM app_base AS web_development

CMD ["bash", "-c", "echo \"Running in development mode\" && \
                    rm -f \"/${APP_NAME}/tmp/pids/server.pid\" && \
                    bundle install --jobs $(nproc) && \
                    (bundle exec rails db:create || true) && \
                    bundle exec rails db:migrate && \
                    #bundle exec rails db:seed && \
                    bundle exec rails s -p 3000 -b '0.0.0.0'"]

# ---------------------------------------------------------------

# web_production
FROM app_base AS web_production

ARG APP_NAME

VOLUME /"${APP_NAME}"/tmp /"${APP_NAME}"/public

CMD ["bash", "-c", "echo \"Running in production mode\" && \
                    rm -f \"/${APP_NAME}/tmp/pids/server.pid\" && \
                    (bundle exec rails db:create || true) && \
                    bundle exec rails db:migrate && \
                    #bundle exec rails db:seed && \
                    bundle exec puma -C config/puma.rb"]

# ---------------------------------------------------------------

# batch
FROM app_base AS batch_development

ARG APP_NAME

CMD ["bash", "-c", "echo \"Running in development mode\" && \
                    bundle install --jobs $(nproc) && \
                    sleep infinity"]

# ---------------------------------------------------------------

# batch
FROM app_base AS batch_production

ARG APP_NAME

CMD ["sleep", "infinity"]
