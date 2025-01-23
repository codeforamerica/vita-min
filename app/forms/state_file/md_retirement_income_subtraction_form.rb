module StateFile
  class MdRetirementIncomeSubtractionForm < Form
    include FormAttributes

    set_attributes_for :state_specific_followup, :income_source, :service_type

    attr_accessor :state_specific_followup

    validates :income_source, presence: true
    validates :service_type, presence: true

    def initialize(state_specific_followup = nil, params = {})
      @state_specific_followup = state_specific_followup
      super(params)
    end

    def save
      @state_specific_followup.income_source = self.income_source
      @state_specific_followup.service_type = self.service_type
      @state_specific_followup.save
    end
  end
end
