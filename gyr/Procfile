// Deployment procfile for Aptible and Heroku
web: exec bin/rails s -b 0.0.0.0 -p ${PORT:-3000}
worker: exec bin/rails jobs:work
cron: exec supercronic /app/crontab
release: exec bin/rails heroku:release
