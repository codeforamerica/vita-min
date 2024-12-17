module StateFile
  class SmsTermsForm < QuestionsForm
    set_attributes_for :intake, :consented_to_sms_terms
    validates :consented_to_sms_terms, inclusion: { in: ['yes', 'no'] }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
