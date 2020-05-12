require 'yaml'

##
# this module upserts State data
module StateImporter
  STATE_YAML = Rails.root.join("db/states.yml")

  ##
  # output normally except in test
  def say(message)
    puts message unless Rails.env.test?
  end

  def insert_states(yml = STATE_YAML)
    say "beginning state upsert using environment: #{Rails.env}"
    states = YAML.load_file(yml)['states']
    State.transaction do
      State.destroy_all
      State.insert_all!(states)
    end
    say "  -> imported #{states.count} states"
  end
end
