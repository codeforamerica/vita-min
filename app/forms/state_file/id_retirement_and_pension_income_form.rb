module StateFile
  class IdRetirementAndPensionIncomeForm < Form
    include FormAttributes


    set_attributes_for :state_file_id1099_r_followup, :eligible_income_source

    validates :eligible_income_source, presence: true

    def initialize(state_file_id1099_r_followup = nil, params = {})
      @state_file_id1099_r_followup = state_file_id1099_r_followup
      super(params)
    end

    def save
      @state_file_id1099_r_followup.update(attributes_for(:state_file_id1099_r_followup))
    end
  end
end