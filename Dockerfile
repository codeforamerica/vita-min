FROM ruby:2.6.5

# System prerequisites
RUN apt-get update \
 && apt-get -y install build-essential libpq-dev pdftk ghostscript poppler-utils curl \
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

ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN bundle install

ADD . /app
ADD crontab /app/crontab

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with assets.
# Review http://go.aptible.com/assets for production-ready advice.
RUN set -a \
 && . ./.aptible.env \
 && bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
