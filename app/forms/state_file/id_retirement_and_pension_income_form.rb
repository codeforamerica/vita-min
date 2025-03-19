module StateFile
  class IdRetirementAndPensionIncomeForm < Form
    include FormAttributes

    set_attributes_for :state_file_id1099_r_followup,
                       :eligible_income_source, :income_source,
                       :civil_service_account_number,
                       :police_retirement_fund,
                       :police_persi,
                       :police_none_apply,
                       :firefighter_frf,
                       :firefighter_persi,
                       :firefighter_none_apply

    validates :income_source, presence: true
    validate :answered_follow_up_question

    def initialize(state_file_id1099_r_followup = nil, params = {})
      @state_file_id1099_r_followup = state_file_id1099_r_followup
      super(params)
    end

    def save
      attributes_to_save = attributes_for(:state_file_id1099_r_followup).excluding(:police_none_apply, :firefighter_none_apply)

      # if they're in the middle of the flow when this is deployed, this would save the old values
      if eligible_income_source.present?
        attributes_to_save[:eligible_income_source] = eligible_income_source
        attributes_to_save[:income_source] = "unfilled"
      end

      if attributes_to_save[:eligible_income_source].nil?
        attributes_to_save[:eligible_income_source] = "unfilled"
      end

      [:police_retirement_fund, :police_persi, :firefighter_frf, :firefighter_persi].each do |attr|
        attributes_to_save[attr] = "no" if attributes_to_save[attr].nil?
      end
      if income_source != "civil_service_employee" && attributes_to_save[:civil_service_account_number].nil?
        attributes_to_save[:civil_service_account_number] = "unfilled"
      end
      @state_file_id1099_r_followup.update(attributes_to_save)
    end

    def answered_follow_up_question
      if income_source == "civil_service_employee" && civil_service_account_number.nil?
        errors.add(:civil_service_account_number, I18n.t("general.please_select_at_least_one_option"))
      elsif income_source == "police_officer" && [police_retirement_fund, police_persi, police_none_apply].none?("yes")
        errors.add(:police_none_apply, I18n.t("general.please_select_at_least_one_option"))
      elsif income_source == "firefighter" && [firefighter_frf, firefighter_persi, firefighter_none_apply].none?("yes")
        errors.add(:firefighter_none_apply, I18n.t("general.please_select_at_least_one_option"))
      end
    end
  end
end