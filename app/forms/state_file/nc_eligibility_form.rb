module StateFile
  class NcEligibilityForm < QuestionsForm
    set_attributes_for :intake, :eligibility_ed_loan_cancelled, :eligibility_ed_loan_emp_payment, :nc_eligiblity_none

    validate :at_most_one_option_selected
    validate :at_least_one_option_selected

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def at_least_one_option_selected
      values = attributes_for(:intake).values_at(:eligibility_ed_loan_emp_payment, :eligibility_ed_loan_cancelled, :nc_eligiblity_none)
      selected = values.select { |value| value == "yes" }
      if selected.count < 1
        errors.add(:nc_eligiblity_none, I18n.t("forms.errors.nc_eligibility_form.at_most_one_option_selected"))
      end
    end

    def at_most_one_option_selected
      if attributes_for(:intake)[:nc_eligiblity_none] == "yes"
        if attributes_for(:intake).values_at(:eligibility_ed_loan_emp_payment, :eligibility_ed_loan_cancelled).any? { |value| value == "yes" }
          errors.add(:nc_eligiblity_none, I18n.t("forms.errors.nc_eligibility_form.at_most_one_option_selected"))
        end
      end
    end
  end
end
