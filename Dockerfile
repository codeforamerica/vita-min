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
 && bundle exec rails efile:download efile:unzip

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with assets.
# Review http://go.aptible.com/assets for production-ready advice.
RUN set -a \
 && . ./.aptible.env \
 && bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
