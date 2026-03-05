module DiyStates
  ##
  # This module is needed b/c the list of states/territories for the DIY flow differs
  # slightly (specifically, it's shorter) from the States module used in the primary flow. 

  @@excluded = %w(AA AE AP FM PW MH).freeze

  def self.hash
    @hash ||= IceNine.deep_freeze!(self.states.to_h.invert)
  end

  def self.name_value_pairs
    self.states
  end

  private

  def self.states
    @states ||= IceNine.deep_freeze!(
      (YAML.load_file(Rails.root.join("db/states.yml"))['states']).
        filter_map do |state|
          [state["name"], state["abbreviation"]] unless
            @@excluded.include? state["abbreviation"]
        end.sort)
    @states
  end
end
