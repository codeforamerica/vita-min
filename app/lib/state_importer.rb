require 'yaml'

class StateImporter < CliScriptBase
  STATE_YAML = Rails.root.join("db/states.yml")

  def self.insert_states(yml = STATE_YAML)
    report_progress "beginning state upsert using environment: #{Rails.env}"
    states = YAML.load_file(yml)['states']
    State.transaction do
      State.destroy_all
      State.insert_all!(states)
    end
    report_progress "  -> imported #{states.count} states"
  end
end
