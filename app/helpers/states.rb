module States
  def self.hash
    @hash ||= IceNine.deep_freeze!(self.states.to_h.invert)
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
    self.states
  end

  def self.html_safe_names
    self.states.map(&:first).to_json.html_safe
  end

  private

  def self.states
    @states ||= IceNine.deep_freeze!(
      (YAML.load_file(Rails.root.join("db/states.yml"))['states']).map { |state| [state["name"], state["abbreviation"]] }.sort
    )
  end
end
