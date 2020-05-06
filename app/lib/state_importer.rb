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

  def upsert_states(yml = STATE_YAML)
    say "beginning state upsert using environment: #{Rails.env}"
    states = YAML.load_file(yml)['states']
    State.destroy_all
    states.each do |datum|
      state = State.find_by(abbreviation: datum['abbreviation'])
      state.present? ? State.update!(name: datum['name']) : State.create!(abbreviation: datum['abbreviation'], name: datum['name'])
    end
    say "  -> imported #{states.count} states"
  end
end
