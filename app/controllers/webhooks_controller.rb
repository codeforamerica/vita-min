class WebhooksController < ApplicationController
  def github_push
    system('git remote add aptible git@beta.aptible.com:eitc-staging/vita-min-staging.git')
    system('git push aptible master')
  end
end