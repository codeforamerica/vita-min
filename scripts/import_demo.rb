#!/usr/bin/env ruby

require_relative "../config/environment"

# Really, it's import from aptible demo environment, but abbreviated to make it less
# annoying to type
class ImportDemo < Thor
  desc 'persona', 'Imports a persona from aptible. Uses thor tasks under the hood as defined in the lib/tasks/personas.rb file'

  def persona(state, id, slug)
    say "Importing XML persona", :green
    `aptible ssh --app vita-min-demo bin/thor personas:export -xs #{state} #{id} | bin/thor personas import -s #{state} #{slug}`

    say "Importing JSON persona", :green
    `aptible ssh --app vita-min-demo bin/thor personas:export -js #{state} #{id} | bin/thor personas import -s #{state} #{slug}`

    say "Linking submission ID", :green
    `aptible ssh --app vita-min-demo bin/thor personas:export_federal_submission_id -s #{state} #{id} | bin/thor personas import_federal_submission_id -s #{state} #{slug}`
  end

  desc 'refresh_token', 'Convenience method for opening browser to retrieve token'

  def refresh_token
    say "Opening browser for token", :green
    say "Find the '🔑 CLI SSO Token' in the lower left corner", :green
    say "Copy command and run in terminal", :green

    `open https://app.aptible.com/sso/codeforamerica.org`
  end
end

ImportDemo.start
