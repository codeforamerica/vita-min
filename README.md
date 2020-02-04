# vita-min

Vita-Min is a Rails app that helps people access the VITA program through a digital intake form, a "valet" drop-off workflow using Zendesk, and a national landing page to find the nearest VITA site.

## Setup
```bash
# 1. Install Ruby using your preferred installation method. For example, to
# install it with rbenv:
brew install rbenv
rbenv install

# 2. Install postgresql using your preferred installation method. You'll need
# the PostGIS extension as well.
brew install postgresql postgis

# 3. Install bundler & system dependencies
gem install bundler
rbenv rehash
bundle install
brew install poppler

# 4. Get the secret key from LastPass / someone who has it set up.
echo "[secret key]" > config/master.key
```
