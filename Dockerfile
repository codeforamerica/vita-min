FROM ruby:2.6.5

# System prerequisites
RUN apt-get update \
 && apt-get -y install build-essential libpq-dev pdftk ghostscript poppler-utils \
 && rm -rf /var/lib/apt/lists/*

# If you require additional OS dependencies, install them here:
# RUN apt-get update \
#  && apt-get -y install imagemagick nodejs \
#  && rm -rf /var/lib/apt/lists/*

ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN bundle install

ADD . /app

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with assets.
# Review http://go.aptible.com/assets for production-ready advice.
RUN set -a \
 && . ./.aptible.env \
 && bundle exec rake assets:precompile

# Update database with any changes to vita partners
RUN set -a \
 && . ./.aptible.env \
 && bundle exec rake db:upsert_vita_partners

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
