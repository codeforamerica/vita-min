module Ctc
  class PersonalInfoForm < QuestionsForm
    set_attributes_for :intake, :preferred_name, :timezone

    validates :preferred_name, presence: true

    def save
      raise "Intake must be a type of Ctc Intake" unless @intake.is_ctc?

      @intake.assign_attributes(attributes_for(:intake))
      Client.create!(intake: @intake, tax_returns_attributes: [attributes_for_ctc_tax_return])
    end

    private

    def attributes_for_ctc_tax_return
      {
        is_ctc: true,
        year: 2020
      }
    end
  end
end