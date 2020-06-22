module Stimulus
  class StimulusForm < Form
    include FormAttributes

    attr_accessor :stimulus_triage

    def initialize(stimulus_triage, params = {})
      @stimulus_triage = stimulus_triage
      super(params)
    end

    def self.from_stimulus_triage(stimulus_triage)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(stimulus_triage, existing_attributes(stimulus_triage).slice(*attribute_keys))
    end

    def save
      stimulus_triage.update(attributes_for(:stimulus_triage))
    end
  end
end
