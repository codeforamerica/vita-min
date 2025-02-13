module StateFile
  class NjRetirementIncomeSourceForm < Form
    include FormAttributes

    set_attributes_for :state_specific_followup,
                       :income_source

    attr_accessor :state_specific_followup

    validates :income_source, presence: true

    def initialize(state_specific_followup = nil, params = {})
      @state_specific_followup = state_specific_followup
      super(params)
    end

    def save
      @state_specific_followup.income_source = self.income_source
      @state_specific_followup.save
    end
  end
end