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
      attributes_to_save = attributes_for(:state_file_nc1099_r_followup).excluding(:bailey_settlement_none_apply, :uniformed_services_none_apply)
      attributes_to_save.each { |attr, value| attributes_to_save[attr] = "no" if value.nil? }
      @state_file_nc1099_r_followup.update(attributes_to_save)
    end

    def answered_follow_up_question
      if income_source == "bailey_settlement" && [bailey_settlement_at_least_five_years, bailey_settlement_from_retirement_plan, bailey_settlement_none_apply].none?("yes")
        errors.add(:bailey_settlement_none_apply, I18n.t("general.please_select_at_least_one_option"))
      elsif income_source == "uniformed_services" && [uniformed_services_retired, uniformed_services_qualifying_plan, uniformed_services_none_apply].none?("yes")
        errors.add(:uniformed_services_none_apply, I18n.t("general.please_select_at_least_one_option"))
      end
    end
  end
end
