module StateFile
  class MdSocialSecurityBenefitsForm < QuestionsForm
    set_attributes_for :intake, :primary_ssb_amount, :spouse_ssb_amount

    validate :valid_amounts

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def valid_amounts
      if @intake.direct_file_data.fed_ssb.present? && ((primary_ssb_amount.to_f + spouse_ssb_amount.to_f).round != @intake.direct_file_data.fed_ssb.to_f.round)
        errors.add(
          :primary_ssb_amount,
          I18n.t("state_file.questions.md_social_security_benefits.edit.sum_form_error", total_ssb: @intake.direct_file_data.fed_ssb)
        )
      end
    end
  end
end
