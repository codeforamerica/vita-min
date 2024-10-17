#!/bin/bash

if heroku apps:info -a gyr-review-app-4882 > /dev/null 2>&1; then
  echo "App exists; continuing";
  echo "APP_EXISTS=true" >> $GITHUB_ENV;
else
  echo "No app found; creating";
  echo "APP_EXISTS=false" >> $GITHUB_ENV;
fi

