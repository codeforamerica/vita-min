FROM ruby:3.2.2

# The Docker environment is based on Debian buster, which used to be called stable Debian, but is now called oldstable.
RUN apt-get update --allow-releaseinfo-change

# System prerequisites
RUN apt-get update \
 && apt-get -y install ca-certificates libgnutls30 build-essential libpq-dev ghostscript default-jre poppler-utils curl \
 && curl -sL https://deb.nodesource.com/setup_20.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y nodejs yarn \
 && rm -rf /var/lib/apt/lists/*

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.9/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

ADD ./vendor/pdftk /app/vendor/pdftk
RUN /app/vendor/pdftk/install

# JDK installation instructions from https://adoptium.net/installation/linux/
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
 && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
 && apt install -y temurin-21-jdk
ENV VITA_MIN_JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64

ADD . /app
WORKDIR /app
ADD package.json yarn.lock /app/
RUN NODE_ENV=production yarn install --frozen-lockfile
ADD .ruby-version Gemfile Gemfile.lock /app/

RUN set -a \
    && . ./.aptible.env \
    && bundle config set --local without 'test development'

RUN set -a \
    && . ./.aptible.env \
    && gem install bundler:$(cat Gemfile.lock | tail -1 | tr -d " ") --no-document \
    && bundle install

# Add IRS e-file schemas, which are not in the git repo
RUN set -a \
 && . ./.aptible.env \
 && bundle exec rails setup:download_efile_schemas setup:unzip_efile_schemas setup:download_gyr_efiler

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with assets.
# Review http://go.aptible.com/assets for production-ready advice.
RUN set -a \
 && . ./.aptible.env \
 && bundle exec rake assets:precompile

RUN echo "IRB.conf[:USE_AUTOCOMPLETE] = false" > ./.irbrc

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
