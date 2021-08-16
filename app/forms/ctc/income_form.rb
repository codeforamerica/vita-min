module Ctc
  class IncomeForm < QuestionsForm
    set_attributes_for :intake, :timezone
    set_attributes_for :misc, :had_reportable_income

    def save
      @intake.assign_attributes(attributes_for(:intake))
      @intake.build_client(tax_returns_attributes: [{ year: 2020, is_ctc: true }])
      @intake.save!
    end

    def had_reportable_income?
      had_reportable_income == "yes"
    end
  end
end
