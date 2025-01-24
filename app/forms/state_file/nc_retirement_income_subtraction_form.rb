module StateFile
  class NcRetirementIncomeSubtractionForm < Form
    include FormAttributes

    set_attributes_for :state_file_nc1099_r_followup,
                       :income_source,
                       :bailey_settlement_at_least_five_years,
                       :bailey_settlement_from_retirement_plan,
                       :bailey_settlement_none_apply,
                       :uniformed_services_retired,
                       :uniformed_services_qualifying_plan,
                       :uniformed_services_none_apply

    attr_accessor :state_file_nc1099_r_followup

    validates :income_source, presence: true
    validate :answered_follow_up_question

    def initialize(state_file_nc1099_r_followup = nil, params = {})
      @state_file_nc1099_r_followup = state_file_nc1099_r_followup
      super(params)
    end

    def save
      # TODO: check to see if we need to clear out affirmative checkbox values that apply to the non-selected income source
      attributes_to_save = attributes_for(:state_file_nc1099_r_followup).excluding(:bailey_settlement_none_apply, :uniformed_services_none_apply)
      @state_file_nc1099_r_followup.update(attributes_to_save)
    end

    def answered_follow_up_question
      # TODO: add error copy
      if income_source == "bailey_settlement" && [bailey_settlement_at_least_five_years, bailey_settlement_from_retirement_plan, bailey_settlement_none_apply].none?("yes")
        errors.add(:bailey_settlement_none_apply)
      elsif income_source == "uniformed_services" && [uniformed_services_retired, uniformed_services_qualifying_plan, uniformed_services_none_apply].none?("yes")
        errors.add(:uniformed_services_none_apply)
      end
    end
  end
end
