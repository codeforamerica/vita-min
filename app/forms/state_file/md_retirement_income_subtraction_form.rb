module StateFile
  class MdRetirementIncomeSubtractionForm < Form
    include FormAttributes

    set_attributes_for :state_file_md1099_r_followup, :income_source, :service_type

    attr_accessor :state_file_md1099_r_followup

    validates :income_source, presence: true
    validates :service_type, presence: true

    def initialize(state_file_md1099_r_followup = nil, params = {})
      @state_file_md1099_r_followup = state_file_md1099_r_followup
      super(params)
    end

    def save
      state_file_md1099_r_followup.update(attributes_for(:state_file_md1099_r_followup))
    end
  end
end
