module States
  STATE_OPTIONS = State.all.order(:name).map { |state| [state.name, state.abbreviation] }
  STATE_OPTIONS.freeze

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
