FROM ruby:2.6.5

# System prerequisites
RUN apt-get update \
 && apt-get -y install build-essential libpq-dev pdftk ghostscript poppler-utils curl \
 && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y nodejs yarn \
 && rm -rf /var/lib/apt/lists/*

# If you require additional OS dependencies, install them here:
# RUN apt-get update \
#  && apt-get -y install imagemagick nodejs \
#  && rm -rf /var/lib/apt/lists/*

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.9/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# pdftk requires Debian's Java 11, but gyr-efiler requires Java 8. Download Java 8 and provide a variable for the Ruby app.
ENV OPENJDK8_URL=https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jre_x64_linux_hotspot_8u292b10.tar.gz \
    OPENJDK_SHA1SUM=55848001c21214d30ca1362bace8613ce9733516
RUN wget -O /tmp/openjdk.tar.gz "$OPENJDK8_URL" \
 && echo "${OPENJDK_SHA1SUM}  /tmp/openjdk.tar.gz" | sha1sum -c - \
 && cd /opt && tar xf /tmp/openjdk.tar.gz \
 && rm -f /tmp/openjdk.tar.gz
ENV VITA_MIN_JAVA_HOME=/opt/jdk8u292-b10-jre

WORKDIR /app
ADD package.json yarn.lock /app/
RUN NODE_ENV=production yarn install --frozen-lockfile
ADD Gemfile Gemfile.lock /app/
RUN gem install bundler:$(cat Gemfile.lock | tail -1 | tr -d " ") --no-document \
 && bundle install --without test development

ADD . /app

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

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
