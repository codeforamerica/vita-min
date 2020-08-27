require 'yaml'

class StateImporter
  STATE_YAML = Rails.root.join("db/states.yml")

  def self.insert_states(yml = STATE_YAML)
    puts "beginning state upsert using environment: #{Rails.env}" unless Rails.env.test?
    states = YAML.load_file(yml)['states']
    State.transaction do
      State.destroy_all
      State.insert_all!(states)
    end
    puts "  -> imported #{states.count} states" unless Rails.env.test?
  end
end
