module States
  STATE_OPTIONS = (YAML.load_file(Rails.root.join("db/states.yml"))['states']).map { |state| [state["name"], state["abbreviation"]] }.sort.freeze

  def self.hash
    @state_hash ||= STATE_OPTIONS.to_h.invert
  end

  def self.keys
    hash.keys
  end

  def self.name_for_key(key)
    self.hash[key]
  end

  def self.key_for_name(name)
    self.hash.key(name)
  end

  def self.name_value_pairs
    STATE_OPTIONS
  end
end
