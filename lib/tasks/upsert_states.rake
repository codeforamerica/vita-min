## these tasks manage VITA partner information
require 'yaml'

namespace :db do
  desc 'loads states'
  task upsert_states: [:environment] do
    puts "beginning state upsert using environment: #{Rails.env}"
    states = YAML.load_file('db/states.yml')['states']
    State.destroy_all
    states.each do |datum|
      puts datum.inspect
      state = State.find_by(abbreviation: datum['abbreviation'])
      state.present? ? State.update!(name: datum['name']) : State.create!(abbreviation: datum['abbreviation'], name: datum['name']
      )
    end
  end
end

